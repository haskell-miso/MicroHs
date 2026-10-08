-- See LICENSE file for full license.
--
-- The staged call by need interpreter of mhs -wpo (see doc/wpo.md).
--
-- The program (decoded lambda calculus, MicroHs.Staged.Decode) is
-- interpreted at compile time, starting from main.  Values known at compile
-- time (integers, closures, partially applied primitives, IO actions) are
-- compile time values; what is only known at run time is a C variable of
-- type W (a machine word), and the code that computes it is C.
--
-- The interpreter has two modes: it evaluates an expression to a value
-- (MValue), or it evaluates an expression to an IO action and runs it
-- (MRun), which generates the C code of the effects in order.  The mode goes
-- into function bodies and the branches of conditionals, so a conditional
-- on a run time value runs the IO action of each branch and joins on the
-- result, which is a run time value.
--
-- Function applications are unfolded at compile time.  When an application
-- of the same shape (the same closure and environment, with run time values
-- abstracted) is found while unfolding it, the unfolding is abandoned and the
-- application becomes a C function, whose arguments are the run time values
-- of the shape; the recursive application is a call.
module MicroHs.Staged.Eval(evalProgram) where
import qualified Prelude(); import MHSPrelude
import Data.Char(ord)
import Data.List
import MicroHs.Exp
import MicroHs.Expr(Lit(..), ImpEnt(..), CType)
import MicroHs.FFI(ffiSignature)
import MicroHs.Ident
import qualified MicroHs.IntMap as IM
import MicroHs.Staged.Decode

-------------------------------------------------------------------------------
-- Compile time values

data V
  = VInt Int                   -- an integer (Int or Char) known at compile time
  | VStr String                -- a string literal
  | VDyn String                -- a run time word: a C variable or literal
  | VBool String               -- a run time Bool (a C condition), a function of two arguments
  | VBool1 String E            --   ... applied to one argument (the False branch)
  | VClo Env Ident Exp         -- a closure
  | VPrim Prim [E]             -- a primitive applied to some of its arguments (in reverse)
  | VUnit                      -- the result of an IO action that returns ()
  | VProbe                     -- the argument of a strictness probe (see probeStrict)

-- A primitive: its name and arity, or a foreign function
data Prim = Prim String Int | PFFI FFI

data FFI = FFI String [String] String Bool    -- C name, argument types, result type, IO

primArity :: Prim -> Int
primArity (Prim _ n) = n
primArity (PFFI (FFI _ as _ _)) = length as

-- An environment entry: a value, a thunk (a number, its environment and
-- expression), a global definition, or the fixed point of a function (Y f)
data E = EV V | EThk Int Env Exp | EGlob Ident | EFix Int E

type Env = [(Ident, E)]

data Mode = MValue | MRun
  deriving (Eq)

-------------------------------------------------------------------------------
-- Shapes: what is known at compile time of a value, with the run time values
-- abstracted; the shape of an application identifies its C function

-- A closure is identified by its binder (decoded lambdas have unique
-- binders, see MicroHs.Staged.Decode)
data Sh = SInt Int | SStr String | SDyn | SBool | SBool1 ShE | SClo [(Ident, ShE)] Ident
        | SPrim String [ShE] | SUnit | SProbe
  deriving (Eq)
data ShE = SV Sh | SThk [(Ident, ShE)] Exp | SGlob Ident | SFix ShE
  deriving (Eq)

type Key = (Mode, Sh, ShE)       -- the mode, the function, and the argument

shapeV :: V -> Sh
shapeV v =
  case v of
    VInt i -> SInt i
    VStr s -> SStr s
    VDyn _ -> SDyn
    VBool _ -> SBool
    VBool1 _ e -> SBool1 (shapeE e)
    VClo env i b -> SClo (shapeEnv (freeVars (Lam i b)) env) i
    VPrim p es -> SPrim (primName p) (map shapeE es)
    VUnit -> SUnit
    VProbe -> SProbe

shapeE :: E -> ShE
shapeE e =
  case e of
    EV v -> SV (shapeV v)
    EThk _ env x -> SThk (shapeEnv (freeVars x) env) x
    EGlob i -> SGlob i
    EFix _ f -> SFix (shapeE f)

shapeEnv :: [Ident] -> Env -> [(Ident, ShE)]
shapeEnv fvs env = [ (i, shapeE e) | (i, e) <- trimEnv fvs env ]

trimEnv :: [Ident] -> Env -> Env
trimEnv fvs env = [ (i, e) | i <- nub fvs, Just e <- [lookup i env] ]

primName :: Prim -> String
primName (Prim p _) = p
primName (PFFI (FFI c _ _ _)) = "ffi:" ++ c

-- The run time values of a value and an entry, in a fixed order (the
-- arguments of a C function)
dynsV :: V -> [String]
dynsV v =
  case v of
    VDyn x -> [x]
    VBool c -> [c]
    VBool1 c e -> c : dynsE e
    VClo env i b -> concatMap (dynsE . snd) (trimEnv (freeVars (Lam i b)) env)
    VPrim _ es -> concatMap dynsE es
    _ -> []

dynsE :: E -> [String]
dynsE e =
  case e of
    EV v -> dynsV v
    EThk _ env x -> concatMap (dynsE . snd) (trimEnv (freeVars x) env)
    EGlob _ -> []
    EFix _ f -> dynsE f

-------------------------------------------------------------------------------
-- Code generation, in continuation passing style

type Code = [String]

-- What is shared by all paths: a counter for names, the C functions
-- (by key, with their names), the definitions of the C functions, and the
-- prototypes of the foreign functions used
data Glob = Glob Int [(Key, String)] [String] [String] [(Sh, Bool)]
  -- (the definitions of the C functions start with their prototypes, see makeFun)

-- The result of code generation: code (and the shared state), or a
-- recursive application that was found (the key of the application to make
-- a C function)
data R = RCode Code Glob | RRec Key | RProbe | RGen Key Sh ShE

-- The state along a path: the shared state, the thunks evaluated on this
-- path (thunks by number, global definitions by a negative number: see
-- globalMemo), and the applications being unfolded
data GS = GS Glob (IM.IntMap V) [Key]

newtype G a = G (Defs -> GS -> (a -> GS -> R) -> R)

runG :: G a -> Defs -> GS -> (a -> GS -> R) -> R
runG (G m) = m

instance Functor G where
  fmap f (G m) = G (\ d s k -> m d s (\ a s' -> k (f a) s'))
instance Applicative G where
  pure a = G (\ _ s k -> k a s)
  G mf <*> G ma = G (\ d s k -> mf d s (\ f s1 -> ma d s1 (\ a s2 -> k (f a) s2)))
instance Monad G where
  G m >>= f = G (\ d s k -> m d s (\ a s' -> runG (f a) d s' k))

failG :: String -> G a
failG msg = G (\ _ _ _ -> error ("mhs -wpo: " ++ msg))

-- A fresh C variable name
fresh :: G String
fresh = G $ \ _ (GS (Glob n fs ds ps st) m as) k -> k ("x" ++ show n) (GS (Glob (n + 1) fs ds ps st) m as)

freshId :: G Int
freshId = G $ \ _ (GS (Glob n fs ds ps st) m as) k -> k n (GS (Glob (n + 1) fs ds ps st) m as)

-- Declare a foreign function
proto :: String -> G ()
proto d = G $ \ _ (GS (Glob n fs ds ps st) m as) k -> k () (GS (Glob n fs ds (if d `elem` ps then ps else d : ps) st) m as)

-- Emit a C statement
emit :: String -> G ()
emit stmt = G $ \ _ s k -> prepend [stmt] (k () s)

prepend :: Code -> R -> R
prepend c r = case r of { RCode c' g -> RCode (c ++ c') g; _ -> r }

-- Bind run time code to a new variable
bind :: String -> G V
bind e = do { x <- fresh; emit ("W " ++ x ++ " = " ++ e ++ ";"); return (VDyn x) }

-- The C expression of a run time word
word :: V -> G String
word v =
  case v of
    VInt i -> return (show i)
    VDyn x -> return x
    VBool c -> return c
    VUnit -> return "0"
    _ -> failG "a value that is not a run time word"

-------------------------------------------------------------------------------
-- The interpreter

eval :: Mode -> Env -> Exp -> G V
eval mode env e =
  case e of
    Var i -> force mode (maybe (EGlob i) id (lookup i env))
    Lit l -> lit l >>= result mode
    Lam i b -> result mode (VClo env i b)
    App f a -> do
      fv <- eval MValue env f
      x <- delay env a
      apply mode fv x

-- An expression as an entry: shared if it is a variable, a value if it is
-- one, otherwise a thunk
delay :: Env -> Exp -> G E
delay env e =
  case e of
    Var i -> return (maybe (EGlob i) id (lookup i env))
    Lam i b -> return (EV (VClo env i b))
    Lit l | cheap l -> EV <$> lit l
    _ -> do { n <- freshId; return (EThk n env e) }
  where cheap l = case l of { LInt _ -> True; LChar _ -> True; _ -> False }

-- The value of a literal
lit :: Lit -> G V
lit l =
  case l of
    LInt i -> return (VInt i)
    LChar c -> return (VInt (ord c))
    LStr s -> return (VStr s)
    LPrim "Y" -> return (VPrim (Prim "Y" 1) [])
    LPrim p | Just n <- lookup p primitives -> return (VPrim (Prim p n) [])
            | otherwise -> failG ("primitive not implemented: " ++ p)
    LForImp _ (ImpStatic _ _ c) _ t -> return (VPrim (PFFI (ffi c t)) [])
    _ -> failG ("literal not implemented: " ++ show l)

ffi :: String -> CType -> FFI
ffi c t = let (as, r, io) = ffiSignature t in FFI c as r io

-- In run mode a value is an IO action, which is run
result :: Mode -> V -> G V
result MValue v = return v
result MRun v = run v

-- Use an entry
force :: Mode -> E -> G V
force mode e =
  case e of
    EV VProbe -> G $ \ _ _ _ -> RProbe
    EV v -> result mode v
    -- an IO action that has not been evaluated on this path is evaluated and
    -- run together, so a conditional in it runs the branches (see branch)
    EGlob i | mode == MRun -> ifMemo (globalKey i) (G $ \ d s k -> runG (eval MRun [] (globalDef i d)) d s k)
            | otherwise -> globalMemo i (G $ \ d s k -> runG (eval MValue [] (globalDef i d)) d s k)
    EThk n env x | mode == MRun -> ifMemo n (eval MRun env x)
                 | otherwise -> memo n (eval MValue env x)
    EFix n f -> memo n (do { fv <- force MValue f; apply MValue fv e }) >>= result mode

globalDef :: Ident -> Defs -> Exp
globalDef i d = maybe (error ("mhs -wpo: undefined: " ++ showIdent i)) id (lookupDef i d)

-- Run the value of a memoized entry if it has one on this path, otherwise
-- evaluate and run it
ifMemo :: Int -> G V -> G V
ifMemo n g = G $ \ d s@(GS _ m _) k ->
  case IM.lookup n m of
    Just v -> runG (run v) d s k
    Nothing -> runG g d s k

-- Evaluate a global definition once on a path
globalMemo :: Ident -> G V -> G V
globalMemo i g = G $ \ d s@(GS _ m _) k ->
  case IM.lookup (globalKey i) m of
    Just v -> k v s
    Nothing -> runG g d s (\ v (GS gl m' as) -> k v (GS gl (IM.insert (globalKey i) v m') as))

-- Global definitions are memoized with the thunks, by a negative number
globalKey :: Ident -> Int
globalKey i = negate (1 + foldl (\ h c -> (h * 31 + ord c) `mod` 1000000007) 7 (showIdent i))

-- Evaluate a thunk once on a path
memo :: Int -> G V -> G V
memo n g = G $ \ d s@(GS _ m _) k ->
  case IM.lookup n m of
    Just v -> k v s
    Nothing -> runG g d s (\ v (GS gl m' as) -> k v (GS gl (IM.insert n v m') as))

-- Apply a value to an argument
apply :: Mode -> V -> E -> G V
apply mode fv x =
  case fv of
    VClo _ _ _ -> do
      -- thunks evaluated to run time values on this path are used as values
      -- (they are arguments of a C function)
      fv' <- resolve fv
      x0 <- resolveEntry x
      apply' mode fv' x0
    _ -> apply' mode fv x

apply' :: Mode -> V -> E -> G V
apply' mode fv x =
  case fv of
    VClo env i b -> do
      -- too much static recursion: restart at the outermost of the
      -- applications of this lambda, generalized (see call)
      g <- whistles fv
      case g of
       Just outer -> G $ \ _ _ _ -> RGen outer (shapeV fv) (shapeE x)
       _ -> do
        x' <- strictArg fv x
        call mode fv (eval mode ((i, x') : env) b) x'
    VPrim (Prim "Y" _) [] -> do { n <- freshId; force mode (EFix n x) }
    VPrim p es
      | length es + 1 < primArity p -> result mode (VPrim p (x : es))
      | otherwise -> prim mode p (reverse (x : es))
    VBool c -> result mode (VBool1 c x)
    -- a Bool known at compile time chooses now
    VBool1 "1" _ -> force mode x
    VBool1 "0" f -> force mode f
    VBool1 c f -> branch mode c (force mode x) (force mode f)
    _ -> failG "applying a value that is not a function"

-- Unfold an application, or call (and make) its C function.
--
-- The applications being unfolded are kept (with their binder).  If a lambda
-- is unfolded more than 'whistle' times inside itself (static recursion,
-- like fib 25), its compile time integers are generalized to run time
-- values: the recursion becomes a C function instead of being computed by
-- the compiler.
call :: Mode -> V -> G V -> E -> G V
call mode fv body x = G $ \ d s@(GS (Glob _ fs _ _ _) _ as) k ->
  let key = (mode, shapeV fv, shapeE x)
      args = dynsV fv ++ dynsE x
      callIt name s' = runG (bind (name ++ "(" ++ intercalate ", " args ++ ")")) d s' k
  in  case lookup key fs of
        Just name -> callIt name s
        Nothing
          | key `elem` as -> RRec key
          | otherwise ->
              case runG body d (pushAnc key s) (\ v s' -> k v (popAnc as s')) of
                RRec key' | key' == key -> makeFun d key fv x s (\ name s' -> callIt name s')
                -- generalize what differs from the inner application (an
                -- argument that is a thunk stays one: call by need)
                RGen key' shf shx | key' == key -> runG (apply' mode (genVBy shf fv) (genEBy shx x)) d s k
                r -> r
  where
    pushAnc key (GS g m as) = GS g m (key : as)
    popAnc as (GS g m _) = GS g m as

-- A value and an entry with the thunks evaluated to run time values on this
-- path replaced by their values (thunks evaluated to compile time values
-- keep their shape, which does not depend on the path)
resolve :: V -> G V
resolve v = G $ \ _ s@(GS _ m _) k -> k (resolveV m v) s

resolveEntry :: E -> G E
resolveEntry e = G $ \ _ s@(GS _ m _) k -> k (resolveE m e) s

resolveV :: IM.IntMap V -> V -> V
resolveV m v =
  case v of
    VClo env i b -> VClo [ (j, resolveE m e) | (j, e) <- env ] i b
    VPrim p es -> VPrim p (map (resolveE m) es)
    VBool1 c e -> VBool1 c (resolveE m e)
    _ -> v

resolveE :: IM.IntMap V -> E -> E
resolveE m e =
  case e of
    EV v -> EV (resolveV m v)
    EThk n env x -> case IM.lookup n m of
                      Just v | not (null (dynsV v)) -> EV (resolveV m v)
                      _ -> EThk n [ (j, resolveE m e') | (j, e') <- env ] x
    EFix n f -> case IM.lookup n m of
                  Just v | not (null (dynsV v)) -> EV (resolveV m v)
                  _ -> EFix n (resolveE m f)
    _ -> e

-- A function that will be called with run time values gets the value of its
-- argument if it is strict in it (call by need otherwise)
strictArg :: V -> E -> G E
strictArg fv x
  | isThunk x && not (null (dynsV fv ++ dynsE x)) = do
      st <- probeStrict fv
      if st then EV <$> force MValue x else return x
  | otherwise = return x

isThunk :: E -> Bool
isThunk e = case e of { EThk _ _ _ -> True; EFix _ _ -> True; _ -> False }

-- Is a closure strict in its argument?  Evaluate its body with the
-- argument bound to a probe: it is strict if the probe is forced on all paths
-- (before code that cannot be evaluated, see branch).  The answer is kept
-- for the shape of the closure; while a closure is probed it is assumed not
-- to be strict (for recursion).
probeStrict :: V -> G Bool
probeStrict fv = G $ \ d s@(GS g@(Glob n fs ds ps st) m as) k ->
  case fv of
    VClo env i b ->
      let sh = shapeV fv
      in  case lookup sh st of
            Just r -> k r s
            Nothing ->
              let g' = Glob n fs ds ps ((sh, False) : st)
                  r = case runG (eval MValue ((i, EV VProbe) : env) b) d (GS g' m as) (\ _ (GS g2 _ _) -> RCode [] g2) of
                        RProbe -> True
                        _ -> False
              in  k r (GS (Glob n fs ds ps ((sh, r) : st)) m as)
    _ -> k False s

-- Has the lambda of a closure been unfolded 'whistle' times inside itself?
-- Then the outermost of those applications.
whistles :: V -> G (Maybe Key)
whistles fv = G $ \ _ s@(GS _ _ as) k ->
  case fv of
    VClo _ i _ ->
      let same = [ a | a@(_, SClo _ j, _) <- as, j == i ]
      in  k (if length same >= whistle then Just (last same) else Nothing) s
    _ -> k Nothing s

whistle :: Int
whistle = 3

-- Generalize the compile time integers of a value and an entry to run time
-- values (C literals)
genV :: V -> V
genV v =
  case v of
    VInt i -> VDyn (show i)
    VClo env i b -> VClo [ (j, genE e) | (j, e) <- env ] i b
    VPrim p es -> VPrim p (map genE es)
    _ -> v

genE :: E -> E
genE e =
  case e of
    EV v -> EV (genV v)
    -- a new number: the generalized thunk is evaluated again
    EThk n env x -> EThk (n + genOffset) [ (j, genE e') | (j, e') <- env ] x
    EFix n f -> EFix (n + genOffset) (genE f)
    _ -> e

genOffset :: Int
genOffset = 1000000000

-- Generalize the compile time integers of a value that differ from a shape
-- (the most specific generalization of the two)
genVBy :: Sh -> V -> V
genVBy sh v =
  case (sh, v) of
    (SInt j, VInt i) | i == j -> v
    (SClo envSh _, VClo env i b) -> VClo [ (j, maybe (genE e) (\ s' -> genEBy s' e) (lookup j envSh)) | (j, e) <- env ] i b
    (SPrim _ shs, VPrim p es) | length shs == length es -> VPrim p (zipWith genEBy shs es)
    _ -> genV v

genEBy :: ShE -> E -> E
genEBy sh e =
  case (sh, e) of
    (SV s', EV v) -> EV (genVBy s' v)
    (SThk envSh _, EThk n env x) -> EThk (n + genOffset) [ (j, maybe (genE e') (\ s' -> genEBy s' e') (lookup j envSh)) | (j, e') <- env ] x
    (SFix s', EFix n f) -> EFix (n + genOffset) (genEBy s' f)
    (SGlob _, EGlob _) -> e
    _ -> genE e

-- Make the C function of an application
makeFun :: Defs -> Key -> V -> E -> GS -> (String -> GS -> R) -> R
makeFun d key@(mode, _, _) fv x (GS (Glob n fs ds ps st) m as) k =
  let name = "f" ++ show n
      params = [ "W p" ++ show j | (j, _) <- zip [0 :: Int ..] (dynsV fv ++ dynsE x) ]
      -- the function body: the application with the run time values renamed to the parameters
      (fv', x') = renameDyn fv x
      body = case fv' of
               VClo env i b -> eval mode ((i, x') : env) b
               _ -> error "makeFun"
      g0 = Glob (n + 1) ((key, name) : fs) ds ps st
  in  case runG body d (GS g0 IM.empty [key]) (\ v s' -> case runG (word v) d s' (\ w (GS g _ _) -> RCode ["return " ++ w ++ ";"] g) of r -> r) of
        RCode c (Glob n' fs' ds' ps' st') ->
          let sig = "static W " ++ name ++ "(" ++ intercalate ", " (if null params then ["void"] else params) ++ ")"
              def = "/* " ++ showKey key ++ " */\n" ++ sig ++ " {\n" ++ unlines (map ("  " ++) c) ++ "}"
          in  k name (GS (Glob n' fs' (def : ds') ((sig ++ ";") : ps') st') m as)
        _ -> error "mhs -wpo: nested recursion that is not supported yet"

showKey :: Key -> String
showKey (m, f, x) = (if m == MRun then "run " else "") ++ showSh f ++ " @ " ++ showShE x

showSh :: Sh -> String
showSh sh =
  case sh of
    SInt i -> show i
    SStr _ -> "str"
    SDyn -> "D"
    SBool -> "B"
    SBool1 e -> "B1(" ++ showShE e ++ ")"
    SClo env i -> "\\" ++ short i ++ showShEnv env
    SPrim p es -> p ++ "(" ++ intercalate "," (map showShE es) ++ ")"
    SUnit -> "()"
    SProbe -> "?"

showShE :: ShE -> String
showShE e =
  case e of
    SV v -> showSh v
    SThk env _ -> "thk" ++ showShEnv env
    SGlob i -> showIdent i
    SFix f -> "fix(" ++ showShE f ++ ")"

showShEnv :: [(Ident, ShE)] -> String
showShEnv env = "{" ++ intercalate "," [ short j ++ "=" ++ showShE e | (j, e) <- env ] ++ "}"

short :: Ident -> String
short i = drop 4 (showIdent i)

-- Rename the run time values of a value and an entry to the parameters p0, p1, ...
renameDyn :: V -> E -> (V, E)
renameDyn fv x =
  let names = dynsV fv ++ dynsE x
      sub = zip names [ "p" ++ show j | j <- [0 :: Int ..] ]
      r s = maybe s id (lookup s sub)
  in  (renV r fv, renE r x)

renV :: (String -> String) -> V -> V
renV r v =
  case v of
    VDyn x -> VDyn (r x)
    VBool c -> VBool (r c)
    VBool1 c e -> VBool1 (r c) (renE r e)
    VClo env i b -> VClo [ (j, renE r e) | (j, e) <- env ] i b
    VPrim p es -> VPrim p (map (renE r) es)
    _ -> v

renE :: (String -> String) -> E -> E
renE r e =
  case e of
    EV v -> EV (renV r v)
    EThk n env x -> EThk n [ (j, renE r e') | (j, e') <- env ] x
    EFix n f -> EFix n (renE r f)
    _ -> e

-- A conditional on a run time value: both branches assign the result to a
-- variable (a join point), and the code after it continues
branch :: Mode -> String -> G V -> G V -> G V
branch mode c gt gf = G $ \ d s@(GS g0 m as) k ->
  let Glob n0 fs0 ds0 ps0 st0 = g0
      r = "x" ++ show n0
      g1 = Glob (n0 + 1) fs0 ds0 ps0 st0
      local gx gl = runG (do { v <- gx; w <- word v; emit (r ++ " = " ++ w ++ ";") }) d (GS gl m as)
                         (\ () (GS gl' _ _) -> RCode [] gl')
      done gl = k (VDyn r) (GS gl m as)
  in  case local gt g1 of
        -- a strictness probe: forced on all paths if forced in both branches
        RProbe -> case local gf g1 of
                    RCode _ g3 -> done g3
                    r' -> r'
        RCode ct g2 ->
          case local gf g2 of
            RProbe -> done g2
            RCode cf g3 ->
              prepend (["W " ++ r ++ ";", "if (" ++ c ++ ") {"] ++ map ("  " ++) ct ++ ["} else {"] ++ map ("  " ++) cf ++ ["}"])
                      (done g3)
            r' -> r'
        r' -> r'

-- Run an IO action
run :: V -> G V
run v =
  case v of
    VPrim (Prim "IO.return" _) [x] -> force MValue x
    VPrim (Prim "IO.>>=" _) [kx, mx] -> do
      r <- force MRun mx
      kv <- force MValue kx
      apply MRun kv (EV r)
    VPrim (Prim "IO.>>" _) [nx, mx] -> do
      _ <- force MRun mx
      force MRun nx
    VPrim (PFFI f@(FFI _ as _ True)) es | length es == length as -> ffiCall f (reverse es)
    _ -> failG "running a value that is not an IO action"

-- A call of a foreign function
ffiCall :: FFI -> [E] -> G V
ffiCall (FFI c as r _) es = do
  proto (r ++ " " ++ c ++ "(" ++ intercalate ", " (if null as then ["void"] else as) ++ ");")
  ws <- mapM (\ e -> force MValue e >>= word) es
  let cargs = zipWith (\ t w -> "(" ++ t ++ ")" ++ w) as ws
      callE = c ++ "(" ++ intercalate ", " cargs ++ ")"
  if r == "void" then do { emit (callE ++ ";"); return VUnit }
                 else bind ("(W)" ++ callE)

-------------------------------------------------------------------------------
-- Primitives

primitives :: [(String, Int)]
primitives =
  [ (p, 2) | p <- ["+", "-", "*", "quot", "rem", "==", "/=", "<", "<=", ">", ">=", "and", "or", "xor", "shl", "shr", "subtract", "seq",
                   "IO.>>=", "IO.>>"] ] ++
  [ (p, 1) | p <- ["neg", "inv", "chr", "ord", "IO.return", "IO.performIO"] ]

-- A saturated primitive
prim :: Mode -> Prim -> [E] -> G V
prim mode p es =
  case (p, es) of
    (Prim "seq" _, [a, b]) -> do { _ <- force MValue a; force mode b }
    (Prim "IO.performIO" _, [a]) -> force MRun a >>= result mode
    (Prim io _, _) | io `elem` ["IO.>>=", "IO.>>", "IO.return"] -> result mode (VPrim p (reverse es))
    (PFFI f@(FFI _ _ _ True), _) -> result mode (VPrim p (reverse es))
    (PFFI f, _) -> ffiCall f es >>= result mode
    (Prim o _, [a, b]) -> do
      x <- force MValue a
      y <- force MValue b
      v <- arith2 o x y
      result mode v
    (Prim o _, [a]) -> do
      x <- force MValue a
      v <- arith1 o x
      result mode v
    _ -> failG ("primitive not implemented: " ++ primName p)

arith2 :: String -> V -> V -> G V
arith2 o x y =
  case (x, y) of
    (VInt i, VInt j) | Just r <- static o i j -> return r
    _ -> do
      a <- word x
      b <- word y
      case lookup o cmps of
        Just c -> do { v <- bind ("(" ++ a ++ " " ++ c ++ " " ++ b ++ ")"); VBool <$> word v }
        Nothing -> case lookup o ops of
          Just c -> bind ("(" ++ a ++ " " ++ c ++ " " ++ b ++ ")")
          Nothing | o == "subtract" -> bind ("(" ++ b ++ " - " ++ a ++ ")")
                  | otherwise -> failG ("primitive not implemented: " ++ o)
  where
    cmps = [("==", "=="), ("/=", "!="), ("<", "<"), ("<=", "<="), (">", ">"), (">=", ">=")]
    ops = [("+", "+"), ("-", "-"), ("*", "*"), ("quot", "/"), ("rem", "%"), ("and", "&"), ("or", "|"), ("xor", "^"), ("shl", "<<"), ("shr", ">>")]
    static op i j =
      case op of
        "+" -> Just (VInt (i + j)); "-" -> Just (VInt (i - j)); "*" -> Just (VInt (i * j))
        "quot" | j /= 0 -> Just (VInt (i `quot` j))
        "rem" | j /= 0 -> Just (VInt (i `rem` j))
        "subtract" -> Just (VInt (j - i))
        "==" -> Just (bool (i == j)); "/=" -> Just (bool (i /= j))
        "<" -> Just (bool (i < j)); "<=" -> Just (bool (i <= j))
        ">" -> Just (bool (i > j)); ">=" -> Just (bool (i >= j))
        _ -> Nothing
    -- a Bool known at compile time: False = \ f t -> f, True = \ f t -> t
    bool b = VBool (if b then "1" else "0")

arith1 :: String -> V -> G V
arith1 o x =
  case (o, x) of
    ("neg", VInt i) -> return (VInt (negate i))
    ("chr", _) -> return x
    ("ord", _) -> return x
    ("neg", _) -> do { a <- word x; bind ("(-" ++ a ++ ")") }
    ("inv", _) -> do { a <- word x; bind ("(~" ++ a ++ ")") }
    _ -> failG ("primitive not implemented: " ++ o)

-------------------------------------------------------------------------------
-- The program

-- The C program for main
evalProgram :: Defs -> Ident -> String
evalProgram defs mainName =
  case runG (force MRun (EGlob mainName)) defs (GS (Glob 0 [] [] [] []) IM.empty []) (\ _ (GS g _ _) -> RCode [] g) of
    RCode c (Glob _ _ ds ps _) ->
      unlines $
        [ "#include <stdint.h>"
        , "typedef intptr_t W;" ] ++
        reverse ps ++
        reverse ds ++
        [ "int main(void) {" ] ++ map ("  " ++) c ++ [ "  return 0;", "}" ]
    _ -> error "mhs -wpo: recursion at the top level"
