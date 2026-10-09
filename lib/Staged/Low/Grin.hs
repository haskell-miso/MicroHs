-- Compiling lazy lambda programs to low code with a heap, by staging.
--
-- The programs are the lambda calculus of the MicroHs compiler, MicroHs.Exp
-- (variables, applications, lambdas, and literals: integers, characters, the
-- primitives of the runtime system, and the combinators), as a list of global
-- definitions, like the definitions of a program after desugaring
-- (MicroHs.Desugar.LDef).  Using it needs the compiler's modules on the
-- search path (-isrc -imhs).  The result is low code that uses the heap operations of GRIN
-- (store, fetch, update; Boquist 1999), which Staged.Low.C turns into C.
--
-- The compiler is a call by need interpreter that runs at compile time (the
-- first Futamura projection, as in tests/LowFutamura.hs), in continuation
-- passing style:
--
--  * Closures, thunks and integers known at compile time are compile time
--    values: applying a known closure happens in the compiler, and a thunk is
--    evaluated (in the compiler) where a path first needs it.
--
--  * What is only known at run time is low code: an integer, or a pointer to
--    a heap node.  A value that has to exist at run time (a thunk with run time
--    parts that is passed on, a value at the join of a conditional or a case,
--    the fields of a node) is stored as a node: a tag and the run time words of
--    its free variables.  The tag stands for a node kind: the label of the
--    lambda (a closure, GRIN's P nodes) or of the thunk (F nodes), with the
--    shape of what is known about the free variables at compile time, or a
--    boxed integer or Bool.
--
--  * Recursion through run time values becomes recursive low functions: an
--    application of the same closure to arguments of the same shape (with
--    the run time values abstracted) is a call.
--
-- While it stages, the compiler accumulates a static analysis, the heap
-- points-to analysis of GRIN in the form of node kinds: which node kinds can
-- be in a field of a node, at a join, in the result of a recursive function
-- or of the code of a thunk, and which applications are recursive.  The
-- analysis is the same interpreter in an analysis mode, run until nothing
-- new is found.  With it the code generation inlines eval and apply (GRIN's
-- inlining of eval and apply): forcing a pointer is a case on the tags of
-- the thunk kinds it can point to (a call of the code of the thunk, and an
-- update of the node with an indirection to the value), and applying a
-- pointer is a case on the closure kinds it can point to, where each
-- alternative applies a known closure in the compiler.  There is no generic
-- eval or apply, and no interpreter is left.
--
-- Not done: garbage collection (Staged.Low.C allocates with malloc), and
-- sharing of thunks without run time parts across the calls of a recursive
-- function (they are evaluated in the compiler, and again per call when that
-- generates code).
module Staged.Low.Grin(
  Prog,
  compileInt, compileFun,
  Info, analyse, showInfo,
  interp,
  ) where
import Prelude
import Data.Char(ord)
import Data.List(nub, sort, intercalate)
import Data.Maybe(fromMaybe)
import MicroHs.Exp(Exp(..))
import MicroHs.Expr(Lit(..))
import MicroHs.Ident(Ident, mkIdent, unIdent)
import Staged.Low(Low, lowInt, lowBool, genLet, store, fetch, update)
import Staged.Low.Internal(LowExp(..), LowTy(..), toLow, fromLow)

-------------------------------------------------------------------------------
-- Programs

-- Global definitions (MicroHs.Desugar.LDef); the program is main
type Prog = [(Ident, Exp)]

-- The primitives, with their arities.  The comparisons return Scott encoded
-- Bools (False = \ f t -> f, True = \ f t -> t), as in MicroHs.
primitives :: [(String, Int)]
primitives =
  [ (p, 2) | p <- arith ++ compares ++ ["seq"] ] ++ [ ("neg", 1) ]

arith, compares :: [String]
arith = ["+", "-", "*", "quot", "rem", "subtract"]
compares = ["==", "/=", "<", "<=", ">", ">="]

-- The combinators of MicroHs (the rules of src/runtime/eval.c), and Y
combinator :: String -> Maybe Exp
combinator p =
  case p of
    "S"   -> Just $ l "xyz"   $ a [x, z, a [y, z]]
    "S'"  -> Just $ l "xyzw"  $ a [x, a [y, w], a [z, w]]
    "K"   -> Just $ l "xy"    x
    "A"   -> Just $ l "xy"    y
    "U"   -> Just $ l "xy"    $ a [y, x]
    "I"   -> Just $ l "x"     x
    "B"   -> Just $ l "xyz"   $ a [x, a [y, z]]
    "B'"  -> Just $ l "xyzw"  $ a [x, y, a [z, w]]
    "Z"   -> Just $ l "xyz"   $ a [x, y]
    "J"   -> Just $ l "xyz"   $ a [z, x]
    "L"   -> Just $ l "xyz"   $ a [y, x]
    "KK"  -> Just $ l "xyz"   y
    "KA"  -> Just $ l "xyz"   z
    "C"   -> Just $ l "xyz"   $ a [x, z, y]
    "C'"  -> Just $ l "xyzw"  $ a [x, a [y, w], z]
    "P"   -> Just $ l "xyz"   $ a [z, x, y]
    "R"   -> Just $ l "xyz"   $ a [y, z, x]
    "O"   -> Just $ l "xyzw"  $ a [w, x, y]
    "K2"  -> Just $ l "xyz"   x
    "K3"  -> Just $ l "xyzw"  x
    "K4"  -> Just $ l "xyzwv" x
    "C'B" -> Just $ l "xyzw"  $ a [x, z, a [y, w]]
    -- the lazy fixed point combinator
    "Y"   -> Just $ l "f" $ a [l "x" (a [f, a [x, x]]), l "x" (a [f, a [x, x]])]
    _ -> Nothing
  where
    v c = Var (mkIdent ['%', c])
    x = v 'x'; y = v 'y'; z = v 'z'; w = v 'w'; f = v 'f'
    l cs b = foldr (\ c r -> Lam (mkIdent ['%', c]) r) b cs
    a = foldl1 App

-------------------------------------------------------------------------------
-- Labelled terms

-- The lambdas and the application arguments (the thunks) have labels; the
-- code of a label is in the table, with its free (local) variables.
data T = UVar String | ULam Int | UApp T Int T | UInt Int | UPrim String Int

data Code = CLam String T [String] | CThk T [String]

type Table = [(Int, Code)]

-- Label a program: the table, and the labelled global definitions
labelProg :: Prog -> (Table, [(String, T)])
labelProg prog =
  let go (tbl, gs) (g, e) = let (t, _, tbl') = labelExp [] e tbl in (tbl', (unIdent g, t) : gs)
      (table, globs) = foldl go ([], []) prog
  in  (table, reverse globs)

labelExp :: [String] -> Exp -> Table -> (T, [String], Table)
labelExp bound e tbl =
  case e of
    Var i | x <- unIdent i, x `elem` bound -> (UVar x, [x], tbl)
          | otherwise -> (UVar (unIdent i), [], tbl)
    Lit (LInt n) -> (UInt n, [], tbl)
    Lit (LChar c) -> (UInt (ord c), [], tbl)
    Lit (LPrim p) | Just c <- combinator p -> labelExp [] c tbl
                  | Just n <- lookup p primitives -> (UPrim p n, [], tbl)
                  | otherwise -> error ("Staged.Low.Grin: unknown primitive " ++ p)
    Lit _ -> error "Staged.Low.Grin: literal not supported"
    Lam i b | x <- unIdent i ->
      let (b', fv, tbl1) = labelExp (x : bound) b tbl
          fv' = nub (filter (/= x) fv)
          l = length tbl1
      in  (ULam l, fv', (l, CLam x b' fv') : tbl1)
    App f a ->
      let (f', fv1, tbl1) = labelExp bound f tbl
          (a', fv2, tbl2) = labelExp bound a tbl1
          l = length tbl2
      in  (UApp f' l a', nub (fv1 ++ fv2), (l, CThk a' (nub fv2)) : tbl2)

-------------------------------------------------------------------------------
-- Compile time values

-- A Bool known at compile time, or at run time
data BoolV = BS Bool | BD (Low Bool)

-- A value: an integer known at compile time or at run time, a Bool (a
-- function of two arguments) and one applied to one argument, a closure
-- (label, the entries of its free variables), a primitive applied to some
-- arguments, or a run time pointer to a node in weak head normal form (with
-- the node kinds it can be)
data V = VInt Int | VDInt (Low Int) | VBool BoolV | VBool1 BoolV E
       | VClo Int [E] | VPrim String Int [E] | VPtr (Low Int) Tags

-- An entry of an environment: a value, a thunk (a number, its label, the
-- entries of its free variables), a global definition, or a run time pointer
-- to a node that can be a thunk (a number, the pointer, the node kinds)
data E = EV V | EThk Int Int [E] | EGlob String | ERef Int (Low Int) Tags

-- The shape of a value or entry: what is known at compile time.  The run time
-- words (the leaves: ShDInt, ShBool, ShPtr, ShRef) are abstracted.
data Sh = ShInt Int | ShDInt | ShBS Bool | ShBool | ShPtr Tags | ShRef Tags
        | ShClo Int [Sh] | ShThk Int [Sh] | ShPrim String Int [Sh] | ShBool1 Sh Sh | ShGlob String
  deriving (Eq, Ord)

-- A node kind: a boxed integer or Bool, a closure (label, the shapes of the
-- fields; GRIN's P nodes), a primitive applied to some arguments, a Bool
-- applied to one argument, or a thunk (GRIN's F nodes).  The shapes in a node
-- kind have no node kinds of their own (that is in the analysis), and no
-- integers known at compile time (they are fields).
data NK = NInt | NBool | NClo Int [Sh] | NPrim String Int [Sh] | NBool1 Sh Sh | NThk Int [Sh]
  deriving (Eq, Ord)

type Tags = [NK]

-- An application of a closure: the label, and the shapes of the free
-- variables and the argument
type Key = (Int, [Sh])

isThunkK :: NK -> Bool
isThunkK (NThk _ _) = True
isThunkK _ = False

unionS :: Ord a => [a] -> [a] -> [a]
unionS a b = sort (nub (a ++ b))

-------------------------------------------------------------------------------
-- The analysis

data Info = Info
  { iRecs   :: [Key]                     -- the recursive applications (low functions)
  , iKinds  :: [NK]                      -- the node kinds (in order: their tags)
  , iFields :: [((NK, Int), Tags)]       -- the node kinds in a field of a node kind
  , iJoins  :: [(Int, (Bool, Tags))]     -- at a join (by site): integers only, the node kinds
  , iFunRes :: [(Key, (Bool, Tags))]     -- the result of a low function
  , iThkRes :: [(NK, Tags)]              -- the result of the code of a thunk kind
  }
  deriving (Eq)

data Obs = ORec Key | OKind NK | OField NK Int Tags | OJoin Int Bool Tags | OFunRes Key Bool Tags | OThkRes NK Tags

emptyInfo :: Info
emptyInfo = Info [] [] [] [] [] []

addObs :: Info -> Obs -> Info
addObs info o =
  case o of
    ORec k -> info{ iRecs = unionS [k] (iRecs info) }
    OKind k -> info{ iKinds = unionS [k] (iKinds info) }
    OField k i ts -> info{ iFields = ins (k, i) ts (iFields info) }
    OJoin s b ts -> info{ iJoins = insB s (b, ts) (iJoins info) }
    OFunRes k b ts -> info{ iFunRes = insB k (b, ts) (iFunRes info) }
    OThkRes k ts -> info{ iThkRes = ins k ts (iThkRes info) }
  where
    ins k ts m = sort ((k, unionS ts (fromMaybe [] (lookup k m))) : [ p | p@(k', _) <- m, k' /= k ])
    insB k (b, ts) m =
      let (b', ts') = maybe (b, ts) (\ (b0, ts0) -> (b && b0, unionS ts ts0)) (lookup k m)
      in  sort ((k, (b', ts')) : [ p | p@(k', _) <- m, k' /= k ])

-- The tag of a node kind (1 is an indirection)
tagOf :: Info -> NK -> Int
tagOf info k = maybe (-1) (+ 2) (lookup k (zip (iKinds info) [0 ..]))

-------------------------------------------------------------------------------
-- Code generation, in continuation passing style

-- What the compiler does with code: generate it, or (in the analysis) only
-- observe.  r is the result: the code, or the observations.
data Ops r = Ops
  { oLet  :: Low Int -> (Low Int -> r) -> r                     -- let x = e in ...
  , oLetB :: Low Bool -> (Low Bool -> r) -> r
  , oIf   :: Low Bool -> r -> r -> r
  , oJoin :: (Low Int -> r) -> ((Low Int -> r) -> r) -> r       -- a join point
  , oUpd  :: Low Int -> [Low Int] -> r -> r                     -- update a node, then ...
  , oRet  :: Low Int -> r                                       -- return a value
  , oObs  :: Obs -> r -> r                                      -- an observation of the analysis
  , oStop :: r                                                  -- (analysis) nothing is known here yet
  , oAna  :: Bool }

genOps :: Ops (Low Int)
genOps = Ops
  { oLet = \ e k -> [| let x = ~e in ~(k [| x |]) |]
  , oLetB = \ e k -> [| let b = ~e in ~(k [| b |]) |]
  , oIf = \ c a b -> [| if ~c then ~a else ~b |]
  , oJoin = \ k body -> [| let j = \ v -> ~(k [| v |]) in ~(body (\ v -> [| j ~v |])) |]
  , oUpd = update
  , oRet = id
  , oObs = \ _ r -> r
  , oStop = error "Staged.Low.Grin: a path that the analysis did not find"
  , oAna = False }

anaOps :: Ops [Obs]
anaOps = Ops
  { oLet = \ _ k -> k (lowInt 0)
  , oLetB = \ _ k -> k (lowBool False)
  , oIf = \ _ a b -> a ++ b
  , oJoin = \ k body -> k (lowInt 0) ++ body (\ _ -> [])
  , oUpd = \ _ _ r -> r
  , oRet = \ _ -> []
  , oObs = (:)
  , oStop = []
  , oAna = True }

-- The context: what to do with code, the analysis, the program, and the low
-- functions (of the recursive applications and of the thunk kinds)
data Ctx r = Ctx
  { cOps   :: Ops r
  , cInfo  :: Info
  , cTable :: Table
  , cGlobs :: [(String, T)]
  , cFun   :: Key -> [Low Int] -> Low Int
  , cThk   :: NK -> Low Int -> Low Int }

-- The state along a path: the next number, the thunks (and pointers) forced
-- on this path, the thunks stored on this path, the global definitions
-- evaluated on this path, and the applications being unfolded
data GS = GS
  { gsNext   :: Int
  , gsMemo   :: [(Int, V)]
  , gsStored :: [(Int, (Low Int, Tags))]
  , gsGlobs  :: [(String, V)]
  , gsAnc    :: [Key] }

newtype G r a = G (Ctx r -> GS -> (a -> GS -> r) -> r)

runG :: G r a -> Ctx r -> GS -> (a -> GS -> r) -> r
runG (G m) = m

instance Functor (G r) where
  fmap f (G m) = G (\ c s k -> m c s (\ a s' -> k (f a) s'))
instance Applicative (G r) where
  pure a = G (\ _ s k -> k a s)
  G mf <*> G ma = G (\ c s k -> mf c s (\ f s1 -> ma c s1 (\ a s2 -> k (f a) s2)))
instance Monad (G r) where
  G m >>= f = G (\ c s k -> m c s (\ a s' -> runG (f a) c s' k))

getCtx :: G r (Ctx r)
getCtx = G $ \ c s k -> k c s

getS :: G r GS
getS = G $ \ _ s k -> k s s

modS :: (GS -> GS) -> G r ()
modS f = G $ \ _ s k -> k () (f s)

freshId :: G r Int
freshId = do { s <- getS; modS (\ s' -> s'{ gsNext = gsNext s' + 1 }); return (gsNext s) }

letI :: Low Int -> G r (Low Int)
letI e = G $ \ c s k -> oLet (cOps c) e (\ x -> k x s)

letB :: Low Bool -> G r (Low Bool)
letB e = G $ \ c s k -> oLetB (cOps c) e (\ x -> k x s)

updateG :: Low Int -> [Low Int] -> G r ()
updateG p ws = G $ \ c s k -> oUpd (cOps c) p ws (k () s)

obs :: Obs -> G r ()
obs o = G $ \ c s k -> oObs (cOps c) o (k () s)

stop :: G r a
stop = G $ \ c _ _ -> oStop (cOps c)

code :: Int -> G r Code
code l = do { c <- getCtx; return (fromMaybe (error "Staged.Low.Grin: label") (lookup l (cTable c))) }

info :: G r Info
info = cInfo <$> getCtx

tagNum :: NK -> G r Int
tagNum k = (\ i -> tagOf i k) <$> info

-------------------------------------------------------------------------------
-- The interpreter

eval :: T -> [(String, E)] -> G r V
eval t env =
  case t of
    UVar x -> force (entry env x)
    UInt n -> return (VInt n)
    UPrim p n -> return (VPrim p n [])
    ULam l -> do { c <- code l; case c of { CLam _ _ fvs -> return (VClo l (map (entry env) fvs)); _ -> error "lam" } }
    UApp f l a -> do
      fv <- eval f env
      e <- delay l a env
      e' <- strictArg fv e
      apply l fv e'

entry :: [(String, E)] -> String -> E
entry env x = fromMaybe (EGlob x) (lookup x env)

-- An argument: shared if it is a variable, a value if it is one, otherwise a thunk
delay :: Int -> T -> [(String, E)] -> G r E
delay l a env =
  case a of
    UVar x -> return (entry env x)
    UInt n -> return (EV (VInt n))
    UPrim p n -> return (EV (VPrim p n []))
    ULam _ -> EV <$> eval a env
    _ -> do
      c <- code l
      i <- freshId
      case c of
        CThk _ fvs -> return (EThk i l (map (entry env) fvs))
        _ -> error "delay"

-- A function that always uses its argument (a closure whose body is strict
-- in its variable, or a primitive) gets the argument evaluated now; that
-- cannot change the result, and it saves a thunk.
strictArg :: V -> E -> G r E
strictArg fv e =
  case (fv, e) of
    (_, EV _) -> return e
    (VClo l _, _) -> do
      c <- code l
      tbl <- cTable <$> getCtx
      case c of
        CLam x b _ | strictIn tbl b x -> EV <$> force e
        _ -> return e
    (VPrim _ n as, _) | length as + 1 >= n -> EV <$> force e      -- a saturated primitive
    _ -> return e

-- Does a term always use a variable?
strictIn :: Table -> T -> String -> Bool
strictIn tbl t x =
  case spine t [] of
    (UVar y, _) | y == x -> True
    (UPrim p n, as) | length as >= n -> any (\ a -> strictIn tbl a x) (take (if p == "seq" then 1 else n) as)
    (ULam l, a : _) | Just (CLam y b _) <- lookup l tbl ->
      (y /= x && strictIn tbl b x) || (strictIn tbl b y && strictIn tbl a x)
    _ -> False
  where
    spine (UApp f _ a) as = spine f (a : as)
    spine h as = (h, as)

-- Use an entry: a thunk is evaluated the first time on a path
force :: E -> G r V
force e =
  case e of
    EV v -> return v
    EGlob g -> do
      s <- getS
      case lookup g (gsGlobs s) of
        Just v -> return v
        Nothing -> do
          c <- getCtx
          v <- eval (fromMaybe (error ("Staged.Low.Grin: undefined " ++ g)) (lookup g (cGlobs c))) []
          modS (\ s' -> s'{ gsGlobs = (g, v) : gsGlobs s' })
          return v
    EThk i l es -> memo i $ do
      s <- getS
      case lookup i (gsStored s) of
        Just (p, tags) -> evalPtr p tags                  -- it is in the heap: share it
        Nothing -> do
          c <- code l
          case c of
            CThk t fvs -> eval t (zip fvs es)
            _ -> error "force"
    ERef i p tags -> memo i (evalPtr p tags)

memo :: Int -> G r V -> G r V
memo i g = do
  s <- getS
  case lookup i (gsMemo s) of
    Just v -> return v
    Nothing -> do { v <- g; modS (\ s' -> s'{ gsMemo = (i, v) : gsMemo s' }); return v }

-- Apply a value to an argument (site: the label of the application, for joins)
apply :: Int -> V -> E -> G r V
apply site fv e =
  case fv of
    VClo l es -> unfold l es e
    VPrim p n as
      | length as + 1 < n -> return (VPrim p n (as ++ [e]))
      | otherwise -> prim p (as ++ [e])
    VBool b -> return (VBool1 b e)
    -- False = \ f t -> f, True = \ f t -> t
    VBool1 (BS False) f -> force f
    VBool1 (BS True) _ -> force e
    VBool1 (BD c) f -> joinV site [(c, force e)] (force f)
    VPtr p tags -> applyPtr site p tags e
    _ -> error "Staged.Low.Grin: applying an integer"

-- Unfold an application of a closure, or call the low function of its shape
unfold :: Int -> [E] -> E -> G r V
unfold l es e = do
  s <- getS
  let nested = length [ () | (l', _) <- gsAnc s, l' == l ]
  -- too much static recursion: the integers known at compile time become run
  -- time integers, so the recursion is found
  (es', e') <- if nested >= whistle then do { es1 <- mapM genInts es; e1 <- genInts e; return (es1, e1) }
               else return (es, e)
  shs <- mapM (shapeE False 0) (es' ++ [e'])
  let key = (l, shs)
  inf <- info
  if key `elem` iRecs inf then callFun key (es' ++ [e'])
  else if key `elem` gsAnc s then do { obs (ORec key); stop }
  else do
    c <- code l
    case c of
      CLam x b fvs -> withAnc key (eval b ((x, e') : zip fvs es'))
      _ -> error "unfold"

withAnc :: Key -> G r a -> G r a
withAnc key g = G $ \ c s k ->
  runG g c s{ gsAnc = key : gsAnc s } (\ a s' -> k a s'{ gsAnc = gsAnc s })

whistle :: Int
whistle = 3

genInts :: E -> G r E
genInts e = do
  s <- getS
  case e of
    EV v -> EV <$> genV v
    -- (the value of a thunk can refer to the thunk; a closure there is a node anyway)
    EThk i l es | Just v <- lookup i (gsMemo s) -> return (memoInt v e)
                | otherwise -> do { es' <- mapM genInts es; j <- freshId; return (EThk j l es') }
    ERef i _ _ | Just v <- lookup i (gsMemo s) -> return (memoInt v e)
    _ -> return e
  where
    memoInt v e' = case v of { VInt n -> EV (VDInt (lowInt n)); _ -> e' }
    genV v =
      case v of
        VInt n -> return (VDInt (lowInt n))
        VClo l es -> VClo l <$> mapM genInts es
        VPrim p n es -> VPrim p n <$> mapM genInts es
        _ -> return v

-- Call the low function of a recursive application
callFun :: Key -> [E] -> G r V
callFun key es = do
  ws <- concat <$> mapM (leavesE False 0) es
  inf <- info
  c <- getCtx
  case lookup key (iFunRes inf) of
    Nothing -> stop
    Just (ints, tags) -> do
      r <- letI (cFun c key (if null ws then [lowInt 0] else ws))
      return (if ints then VDInt r else VPtr r tags)

-- Force a pointer: inline eval.  If the node can be a thunk, it is a case on
-- the tags of the thunk kinds it can be: call the code of the thunk and
-- update the node with an indirection (tag 1) to the value.
evalPtr :: Low Int -> Tags -> G r V
evalPtr p tags = do
  let ths = filter isThunkK tags
      whnf = filter (not . isThunkK) tags
  if null ths then return (VPtr p tags) else do
    inf <- info
    c <- getCtx
    let res = foldr unionS whnf [ fromMaybe [] (lookup k (iThkRes inf)) | k <- ths ]
        alt k = genLet (cThk c k p) (\ v -> update p [lowInt 1, v] v)
        chain t ks =
          case ks of
            [k] | null whnf -> alt k
            [] -> p
            k : ks' -> [| if ~t == ~(lowInt (tagOf inf k)) then ~(alt k) else ~(chain t ks') |]
    t <- letI (fetch p 0)
    r <- letI [| if ~t == 1 then ~(fetch p 1) else ~(chain t ths) |]
    return (VPtr r res)

-- Apply a pointer: inline apply, a case on the tags of the closure kinds the
-- node can be; each alternative applies a known closure
applyPtr :: Int -> Low Int -> Tags -> E -> G r V
applyPtr site p tags e =
  case filter (/= NInt) tags of
    [] -> stop
    [k] -> do { v <- nodeValue k p; apply site v e }
    ks -> do
      t <- letI (fetch p 0)
      ns <- mapM tagNum ks
      joinV site [ ([| ~t == ~(lowInt n) |], do { v <- nodeValue k p; apply site v e }) | (k, n) <- init (zip ks ns) ]
                 (do { v <- nodeValue (last ks) p; apply site v e })

-- The value of a node in weak head normal form
nodeValue :: NK -> Low Int -> G r V
nodeValue k p =
  case k of
    NInt -> VDInt <$> letI (fetch p 1)
    NBool -> do { w <- letI (fetch p 1); return (VBool (BD [| ~w /= 0 |])) }
    NClo l shs -> VClo l <$> fields k p shs
    NPrim q n shs -> VPrim q n <$> fields k p shs
    NBool1 b s -> do { es <- fields k p [b, s]; case es of { [EV (VBool bv), e] -> return (VBool1 bv e); _ -> error "nodeValue" } }
    NThk _ _ -> error "Staged.Low.Grin: a thunk where a value was expected"

-- The entries of the fields of a node (the node kinds of pointers come from the analysis)
fields :: NK -> Low Int -> [Sh] -> G r [E]
fields k p shs = do
  inf <- info
  let n = sum (map leafCount shs)
      shs' = fst (fillTags (\ i -> fromMaybe [] (lookup (k, i) (iFields inf))) 1 shs)
  ws <- mapM (\ i -> letI (fetch p i)) [1 .. n]
  fst <$> rebuildAll shs' ws

-- A join of conditional code: the alternatives (with their conditions) and the
-- default.  The value at the join is a run time integer or pointer, as the
-- analysis says.
joinV :: Int -> [(Low Bool, G r V)] -> G r V -> G r V
joinV site alts dflt = G $ \ c s k ->
  let ops = cOps c
      known = lookup site (iJoins (cInfo c))
      cont x = case known of
                 Just (True, _) -> k (VDInt x) s
                 Just (False, tags) -> k (VPtr x tags) s
                 Nothing -> oStop ops
      -- a branch: its value, at the join (in the analysis: observed)
      branch g j = runG (do { v <- g; atJoin v }) c s (\ w _ -> j w)
      atJoin v
        | oAna ops = do { tags <- observed v; obs (OJoin site (intish v) tags); return (lowInt 0) }
        | otherwise = case known of
                        Just (True, _) -> intOf v >>= lowI
                        _ -> fst <$> liftPtr v
      chain as j =
        case as of
          [] -> branch dflt j
          (b, g) : rest -> oIf ops b (branch g j) (chain rest j)
      -- the analysis observes the branches, and goes on after the join if it
      -- knows what is there (oIf in the analysis explores both)
  in  if oAna ops then oIf ops (lowBool False) (chain alts (\ _ -> oStop ops)) (case known of { Just _ -> cont (lowInt 0); Nothing -> oStop ops })
      else oJoin ops cont (chain alts)

-- (analysis) the node kinds of a value at a join or a result: none for an integer
observed :: V -> G r Tags
observed v = if intish v then return [] else snd <$> liftPtr v

intish :: V -> Bool
intish v =
  case v of
    VInt _ -> True
    VDInt _ -> True
    VPtr _ tags -> all (== NInt) tags
    _ -> False

-- An integer, known at compile time or at run time
data IntV = IS Int | ID (Low Int)

intOf :: V -> G r IntV
intOf v =
  case v of
    VInt n -> return (IS n)
    VDInt x -> return (ID x)
    VPtr p tags | all (== NInt) tags -> ID <$> letI (fetch p 1)
    _ -> error "Staged.Low.Grin: not an integer"

lowI :: IntV -> G r (Low Int)
lowI (IS n) = return (lowInt n)
lowI (ID x) = return x

-- A saturated primitive
prim :: String -> [E] -> G r V
prim p args =
  case args of
    [a, b] | p == "seq" -> do { _ <- force a; force b }
    [a, b] -> do
      x <- force a >>= intOf
      y <- force b >>= intOf
      case (x, y) of
        (IS i, IS j) | p `elem` compares -> return (VBool (BS (cmpOp p i j)))
                     | p `elem` arith, okDiv j -> return (VInt (arithOp p i j))
        _ | p `elem` compares -> VBool . BD <$> letB (cmpL p (lowIV x) (lowIV y))
          | otherwise -> VDInt <$> letI (arithL p (lowIV x) (lowIV y))
    [a] | p == "neg" -> do
      x <- force a >>= intOf
      case x of
        IS i -> return (VInt (negate i))
        ID d -> VDInt <$> letI [| 0 - ~d |]
    _ -> error ("Staged.Low.Grin: primitive " ++ p)
  where
    okDiv j = not (p `elem` ["quot", "rem"] && j == 0)
    lowIV (IS n) = lowInt n
    lowIV (ID d) = d

arithOp :: String -> Int -> Int -> Int
arithOp p i j =
  case p of
    "+" -> i + j; "-" -> i - j; "*" -> i * j
    "quot" -> quot i j; "rem" -> rem i j; "subtract" -> j - i
    _ -> error "arithOp"

cmpOp :: String -> Int -> Int -> Bool
cmpOp p i j =
  case p of
    "==" -> i == j; "/=" -> i /= j; "<" -> i < j
    "<=" -> i <= j; ">" -> i > j; ">=" -> i >= j
    _ -> error "cmpOp"

arithL :: String -> Low Int -> Low Int -> Low Int
arithL p x y =
  case p of
    "+" -> [| ~x + ~y |]
    "-" -> [| ~x - ~y |]
    "*" -> [| ~x * ~y |]
    "quot" -> [| quot ~x ~y |]
    "rem" -> [| rem ~x ~y |]
    "subtract" -> [| ~y - ~x |]
    _ -> error "arithL"

cmpL :: String -> Low Int -> Low Int -> Low Bool
cmpL p x y =
  case p of
    "==" -> [| ~x == ~y |]
    "/=" -> [| ~x /= ~y |]
    "<" -> [| ~x < ~y |]
    "<=" -> [| ~x <= ~y |]
    ">" -> [| ~x > ~y |]
    ">=" -> [| ~x >= ~y |]
    _ -> error "cmpL"

-------------------------------------------------------------------------------
-- Shapes, and values at run time

-- Closures and thunks nested deeper than this are nodes
depth :: Int
depth = 3

-- The shape of an entry.  In a node (nodeM) the integers known at compile
-- time are fields; elsewhere (the key of an application) they are known.  A
-- thunk with run time parts, and anything nested too deep, is a pointer to a
-- node.
shapeE :: Bool -> Int -> E -> G r Sh
shapeE nodeM d e = do
  s <- getS
  return (shapeP (gsMemo s) (gsStored s) nodeM d e)

shapeP :: [(Int, V)] -> [(Int, (Low Int, Tags))] -> Bool -> Int -> E -> Sh
shapeP m st nodeM d e =
  case e of
    EV v -> shV v
    EThk i l es
      | Just v <- lookup i m -> memoSh v
      | Just (_, tags) <- lookup i st -> ShRef tags
      | otherwise ->
          let shs = map (shapeP m st nodeM (d + 1)) es
          in  if d >= depth || any hasLeaves shs then ShRef [NThk l (map (strip . shapeP m st True 1) es)] else ShThk l shs
    EGlob g -> ShGlob g
    ERef i _ tags | Just v <- lookup i m -> memoSh v
                  | otherwise -> ShRef tags
  where
    -- an evaluated thunk whose value is a closure is a node (the value can
    -- refer to the thunk: a cycle)
    memoSh v = case nodeOf v of
                 Just (mk, es) -> ShPtr [mk (node es)]
                 Nothing -> shV v
    sub = map (shapeP m st nodeM (d + 1))
    node = map (strip . shapeP m st True 1)
    shV v =
      case v of
        VInt n -> if nodeM then ShDInt else ShInt n
        VDInt _ -> ShDInt
        VBool b -> shB b
        VPtr _ tags -> ShPtr tags
        VClo l es | d >= depth -> ShPtr [NClo l (node es)]
                  | otherwise -> ShClo l (sub es)
        VPrim p n es | d >= depth -> ShPtr [NPrim p n (node es)]
                     | otherwise -> ShPrim p n (sub es)
        VBool1 b e' | d >= depth -> ShPtr [NBool1 (shB b) (strip (shapeP m st True 1 e'))]
                    | otherwise -> ShBool1 (shB b) (shapeP m st nodeM (d + 1) e')
    shB (BS b) = ShBS b
    shB (BD _) = ShBool

hasLeaves :: Sh -> Bool
hasLeaves sh = leafCount sh > 0

leafCount :: Sh -> Int
leafCount sh =
  case sh of
    ShDInt -> 1
    ShBool -> 1
    ShPtr _ -> 1
    ShRef _ -> 1
    ShClo _ shs -> sum (map leafCount shs)
    ShThk _ shs -> sum (map leafCount shs)
    ShPrim _ _ shs -> sum (map leafCount shs)
    ShBool1 b s -> leafCount b + leafCount s
    _ -> 0

-- Remove the node kinds of pointers (a node kind does not have them); a
-- field that is a pointer to a value is a pointer to a node that can be a
-- thunk, so node kinds do not differ in that
strip :: Sh -> Sh
strip sh =
  case sh of
    ShPtr _ -> ShRef []
    ShRef _ -> ShRef []
    ShClo l shs -> ShClo l (map strip shs)
    ShThk l shs -> ShThk l (map strip shs)
    ShPrim p n shs -> ShPrim p n (map strip shs)
    ShBool1 b s -> ShBool1 b (strip s)
    _ -> sh

-- The node kinds of the pointers in shapes, by field number (from i)
leafTags :: Int -> [Sh] -> [(Int, Tags)]
leafTags i0 shs0 = fst (go i0 shs0)
  where
    go i shs =
      case shs of
        [] -> ([], i)
        sh : rest -> let (a, i1) = one i sh; (b, i2) = go i1 rest in (a ++ b, i2)
    one i sh =
      case sh of
        ShPtr ts -> ([(i, ts)], i + 1)
        ShRef ts -> ([(i, ts)], i + 1)
        ShDInt -> ([], i + 1)
        ShBool -> ([], i + 1)
        ShClo _ shs -> go i shs
        ShThk _ shs -> go i shs
        ShPrim _ _ shs -> go i shs
        ShBool1 b s -> go i [b, s]
        _ -> ([], i)

-- Put the node kinds of pointers (by field number, from i) in shapes
fillTags :: (Int -> Tags) -> Int -> [Sh] -> ([Sh], Int)
fillTags tg i shs =
  case shs of
    [] -> ([], i)
    sh : rest -> let (a, i1) = one sh; (b, i2) = fillTags tg i1 rest in (a : b, i2)
  where
    one sh =
      case sh of
        ShPtr _ -> (ShPtr (tg i), i + 1)
        ShRef _ -> (ShRef (tg i), i + 1)
        ShDInt -> (sh, i + 1)
        ShBool -> (sh, i + 1)
        ShClo l s -> let (s', i') = fillTags tg i s in (ShClo l s', i')
        ShThk l s -> let (s', i') = fillTags tg i s in (ShThk l s', i')
        ShPrim p n s -> let (s', i') = fillTags tg i s in (ShPrim p n s', i')
        ShBool1 b s -> case fillTags tg i [b, s] of
                         ([b', s'], i') -> (ShBool1 b' s', i')
                         _ -> error "fillTags"
        _ -> (sh, i)

-- The run time words of an entry (as in its shape), storing what has to be a node
leavesE :: Bool -> Int -> E -> G r [Low Int]
leavesE nodeM d e = do
  s <- getS
  case e of
    EV v -> leavesV v
    EThk i l es
      | Just v <- lookup i (gsMemo s) -> memoLeaves i v
      | Just (p, _) <- lookup i (gsStored s) -> return [p]
      | otherwise -> do
          shs <- mapM (shapeE nodeM (d + 1)) es
          if d >= depth || any hasLeaves shs then do { (p, _) <- storeCell i (NThk l) es; return [p] }
          else concat <$> mapM (leavesE nodeM (d + 1)) es
    EGlob _ -> return []
    ERef i p _ | Just v <- lookup i (gsMemo s) -> memoLeaves i v
               | otherwise -> return [p]
  where
    memoLeaves i v = case nodeOf v of
                       Just (mk, es) -> do { (p, _) <- storeCell i mk es; return [p] }
                       Nothing -> leavesV v
    sub es = concat <$> mapM (leavesE nodeM (d + 1)) es
    leavesV v =
      case v of
        VInt n -> return (if nodeM then [lowInt n] else [])
        VDInt x -> return [x]
        VBool (BS _) -> return []
        VBool (BD b) -> return [[| if ~b then 1 else 0 |]]
        VPtr p _ -> return [p]
        VClo _ es | d < depth -> sub es
        VPrim _ _ es | d < depth -> sub es
        VBool1 b e' | d < depth -> (++) <$> leavesV (VBool b) <*> leavesE nodeM (d + 1) e'
        _ -> do { (p, _) <- liftPtr v; return [p] }

-- A closure, primitive or Bool applied to an argument as a node: the node
-- kind (of the shapes of the entries) and the entries
nodeOf :: V -> Maybe ([Sh] -> NK, [E])
nodeOf v =
  case v of
    VClo l es -> Just (NClo l, es)
    VPrim p n es -> Just (NPrim p n, es)
    VBool1 b e -> Just (\ shs -> case shs of { [bs, s] -> NBool1 bs s; _ -> error "nodeOf" }, [EV (VBool b), e])
    _ -> Nothing

-- Rebuild entries from shapes and run time words
rebuildAll :: [Sh] -> [Low Int] -> G r ([E], [Low Int])
rebuildAll shs ws =
  case shs of
    [] -> return ([], ws)
    sh : rest -> do
      (e, ws1) <- rebuild sh ws
      (es, ws2) <- rebuildAll rest ws1
      return (e : es, ws2)

rebuild :: Sh -> [Low Int] -> G r (E, [Low Int])
rebuild sh ws =
  case (sh, ws) of
    (ShInt n, _) -> return (EV (VInt n), ws)
    (ShDInt, w : ws') -> return (EV (VDInt w), ws')
    (ShBS b, _) -> return (EV (VBool (BS b)), ws)
    (ShBool, w : ws') -> return (EV (VBool (BD [| ~w /= 0 |])), ws')
    (ShPtr tags, w : ws') -> return (EV (VPtr w tags), ws')
    (ShRef tags, w : ws') -> do { i <- freshId; return (ERef i w tags, ws') }
    (ShClo l shs, _) -> do { (es, ws') <- rebuildAll shs ws; return (EV (VClo l es), ws') }
    (ShPrim p n shs, _) -> do { (es, ws') <- rebuildAll shs ws; return (EV (VPrim p n es), ws') }
    (ShThk l shs, _) -> do { (es, ws') <- rebuildAll shs ws; i <- freshId; return (EThk i l es, ws') }
    (ShBool1 b s, _) -> do
      (be, ws1) <- rebuild b ws
      (e, ws2) <- rebuild s ws1
      case be of
        EV (VBool bv) -> return (EV (VBool1 bv e), ws2)
        _ -> error "rebuild"
    (ShGlob g, _) -> return (EGlob g, ws)
    _ -> error "Staged.Low.Grin: rebuild"

-- Store a node: its tag and fields
storeNode :: NK -> [Low Int] -> G r (Low Int, Tags)
storeNode k ws = do
  obs (OKind k)
  n <- tagNum k
  p <- letI (store (lowInt n : ws))
  return (p, [k])

-- The node of a closure, a primitive applied to arguments, or a Bool applied
-- to an argument: the shapes of the entries are the node kind, their run time
-- words the fields
storeEntries :: ([Sh] -> NK) -> [E] -> G r (Low Int, Tags)
storeEntries mk es = do
  shs <- mapM (shapeE True 1) es
  ws <- concat <$> mapM (leavesE True 1) es
  let k = mk (map strip shs)
  mapM_ (\ (i, ts) -> obs (OField k i ts)) (leafTags 1 shs)
  storeNode k ws

-- A thunk (unevaluated, or evaluated to a closure) as a node; later uses on
-- this path share it.  The cell is allocated first and filled in with an
-- update, since a field can refer to the cell itself (a cycle through the
-- value of the thunk).  A thunk cell has at least two words (an update
-- overwrites it with an indirection).
storeCell :: Int -> ([Sh] -> NK) -> [E] -> G r (Low Int, Tags)
storeCell i mk es = do
  s <- getS
  case lookup i (gsStored s) of
    Just r -> return r
    Nothing -> do
      shs <- mapM (shapeE True 1) es
      let k = mk (map strip shs)
          n = max (if isThunkK k then 1 else 0) (sum (map leafCount shs))
      obs (OKind k)
      tag <- tagNum k
      p <- letI (store (lowInt tag : replicate n (lowInt 0)))
      modS (\ s' -> s'{ gsStored = (i, (p, [k])) : gsStored s' })
      ws <- concat <$> mapM (leavesE True 1) es
      mapM_ (\ (j, ts) -> obs (OField k j ts)) (leafTags 1 shs)
      if null ws then return () else updateG p (lowInt tag : ws)
      return (p, [k])

-- A value as a pointer to a node in weak head normal form
liftPtr :: V -> G r (Low Int, Tags)
liftPtr v =
  case v of
    VPtr p tags -> return (p, tags)
    VInt n -> storeNode NInt [lowInt n]
    VDInt x -> storeNode NInt [x]
    VBool (BS b) -> storeNode NBool [lowInt (if b then 1 else 0)]
    VBool (BD b) -> storeNode NBool [[| if ~b then 1 else 0 |]]
    VClo l es -> storeEntries (NClo l) es
    VPrim p n es -> storeEntries (NPrim p n) es
    VBool1 b e -> storeEntries (\ shs -> case shs of { [bs, s] -> NBool1 bs s; _ -> error "liftPtr" }) [EV (VBool b), e]

-------------------------------------------------------------------------------
-- Programs

-- The result of a program: an integer
resultInt :: V -> G r (Low Int)
resultInt v = intOf v >>= lowI

-- The roots of the code: the program, the low functions of the recursive
-- applications, and the code of the thunk kinds
mainCode :: Maybe (Low Int) -> G r (Low Int)
mainCode arg = do
  v <- force (EGlob "main")
  r <- case arg of
         Nothing -> return v
         Just n -> apply (-1) v (EV (VDInt n))
  resultInt r

funCode :: Key -> [Low Int] -> G r (Low Int)
funCode key@(l, shs) ps = do
  (es, _) <- rebuildAll shs ps
  c <- code l
  inf <- info
  ana <- (oAna . cOps) <$> getCtx
  case c of
    CLam x b fvs -> do
      v <- withAnc key (eval b ((x, last es) : zip fvs (init es)))
      if ana then do
        tags <- observed v
        obs (OFunRes key (intish v) tags)
        return (lowInt 0)
      else
        case lookup key (iFunRes inf) of
          Just (True, _) -> resultInt v
          _ -> fst <$> liftPtr v
    _ -> error "funCode"

thkCode :: NK -> Low Int -> G r (Low Int)
thkCode k p =
  case k of
    NThk l shs -> do
      es <- fields k p shs
      c <- code l
      ana <- (oAna . cOps) <$> getCtx
      case c of
        CThk t fvs -> do
          v <- eval t (zip fvs es)
          (r, tags) <- liftPtr v
          whenG ana $ obs (OThkRes k tags)
          return r
        _ -> error "thkCode"
    _ -> error "thkCode"

whenG :: Bool -> G r () -> G r ()
whenG b g = if b then g else return ()

runCode :: Ctx r -> G r (Low Int) -> r
runCode c g = runG g c (GS 0 [] [] [] []) (\ w _ -> oRet (cOps c) w)

-- The analysis of a program: the interpreter in the analysis mode, on all
-- the roots, until it finds nothing new
analyse :: Prog -> Bool -> Info
analyse prog hasArg =
  let (tbl, globs) = labelProg prog
  in  analyseL tbl globs hasArg

analyseL :: Table -> [(String, T)] -> Bool -> Info
analyseL tbl globs hasArg = go emptyInfo
  where
    go inf =
      let c = Ctx anaOps inf tbl globs (\ _ _ -> lowInt 0) (\ _ _ -> lowInt 0)
          os = runCode c (mainCode (if hasArg then Just (lowInt 0) else Nothing)) ++
               concat [ runCode c (funCode k (dummies (sum (map leafCount (snd k))))) | k <- iRecs inf ] ++
               concat [ runCode c (thkCode k (lowInt 0)) | k <- iKinds inf, isThunkK k ]
          inf' = foldl addObs inf os
      in  if inf' == inf then inf else go inf'
    dummies n = replicate n (lowInt 0)

-- Compile a program: all the low functions in one recursive group, around the program
compileL :: Prog -> Maybe (Low Int) -> Low Int
compileL prog arg =
  let (tbl, globs) = labelProg prog
      inf = analyseL tbl globs (case arg of { Nothing -> False; Just _ -> True })
      funs = iRecs inf
      thks = filter isThunkK (iKinds inf)
      arity k = max 1 (sum (map leafCount (snd k)))
      decls = [ ("f" ++ show i, TFun (replicate (arity k) TInt) TInt) | (i, k) <- zip [0 :: Int ..] funs ] ++
              [ ("t" ++ show i, TFun [TInt] TInt) | (i, _) <- zip [0 :: Int ..] thks ]
      call f ws = toLow (HApp f (map fromLow ws))
      group vs =
        let (fvs, tvs) = splitAt (length funs) vs
            c = Ctx genOps inf tbl globs
                    (\ k ws -> call (fromMaybe (error "fun") (lookup k (zip funs fvs))) ws)
                    (\ k p -> call (fromMaybe (error "thunk") (lookup k (zip thks tvs))) [p])
            fun k = lams (arity k) (\ ps -> runCode c (funCode k (take (sum (map leafCount (snd k))) ps)))
            thk k = lams 1 (\ ps -> runCode c (thkCode k (head ps)))
        in  (map (fromLow . fun) funs ++ map (fromLow . thk) thks, fromLow (runCode c (mainCode arg)))
  in  toLow (HLetRec decls group)

-- A low function of n integers
lams :: Int -> ([Low Int] -> Low Int) -> Low Int
lams n f = toLow (go n [])
  where
    go 0 ps = fromLow (f (reverse ps))
    go i ps = HLam "p" TInt (\ x -> go (i - 1) (toLow x : ps))

-- A program whose value is an integer
compileInt :: Prog -> Low Int
compileInt prog = compileL prog Nothing

-- A program whose value is a function of an integer
compileFun :: Prog -> Low (Int -> Int)
compileFun prog = [| \ n -> ~(compileL prog (Just [| n |])) |]

-------------------------------------------------------------------------------
-- Showing the analysis

showInfo :: Prog -> Bool -> String
showInfo prog hasArg =
  let inf = analyse prog hasArg
  in  unlines $
        [ "node kinds (tag: kind):" ] ++
        [ "  " ++ show (tagOf inf k) ++ ": " ++ showNK k | k <- iKinds inf ] ++
        [ "fields (kind.field: kinds):" ] ++
        [ "  " ++ show (tagOf inf k) ++ "." ++ show i ++ ": " ++ showTags inf ts | ((k, i), ts) <- iFields inf ] ++
        [ "results of thunk code (kind: kinds):" ] ++
        [ "  " ++ show (tagOf inf k) ++ ": " ++ showTags inf ts | (k, ts) <- iThkRes inf ] ++
        [ "joins (site: kinds):" ] ++
        [ "  " ++ show s ++ ": " ++ (if b then "Int" else showTags inf ts) | (s, (b, ts)) <- iJoins inf ] ++
        [ "recursive applications (lambda shape: result):" ] ++
        [ "  " ++ showKey k ++ ": " ++ maybe "?" (\ (b, ts) -> if b then "Int" else showTags inf ts) (lookup k (iFunRes inf)) | k <- iRecs inf ]

showTags :: Info -> Tags -> String
showTags inf ts = "{" ++ intercalate ", " (map (show . tagOf inf) ts) ++ "}"

showNK :: NK -> String
showNK k =
  case k of
    NInt -> "Int"
    NBool -> "Bool"
    NClo l shs -> "P lambda" ++ show l ++ showShs shs
    NPrim p n shs -> "P " ++ p ++ "/" ++ show n ++ showShs shs
    NBool1 b s -> "P Bool1" ++ showShs [b, s]
    NThk l shs -> "F thunk" ++ show l ++ showShs shs

showKey :: Key -> String
showKey (l, shs) = "lambda" ++ show l ++ showShs shs

showShs :: [Sh] -> String
showShs shs = "(" ++ intercalate ", " (map showSh shs) ++ ")"

showSh :: Sh -> String
showSh sh =
  case sh of
    ShInt n -> show n
    ShDInt -> "int"
    ShBS b -> show b
    ShBool -> "bool"
    ShPtr _ -> "ptr"
    ShRef _ -> "ref"
    ShClo l shs -> "lambda" ++ show l ++ showShs shs
    ShThk l shs -> "thunk" ++ show l ++ showShs shs
    ShPrim p n shs -> p ++ "/" ++ show n ++ showShs shs
    ShBool1 b s -> "bool1" ++ showShs [b, s]
    ShGlob g -> g

-------------------------------------------------------------------------------
-- A reference interpreter (call by need), for testing

data RV = RInt Int | RFun (RT -> RV)
data RT = RT RV

interp :: Prog -> Maybe Int -> Int
interp prog arg =
  let genv = [ (unIdent g, ev [] e) | (g, e) <- prog ]
      look env x = case lookup x env of
                     Just (RT v) -> v
                     Nothing -> fromMaybe (error ("unbound " ++ x)) (lookup x genv)
      ev env e =
        case e of
          Var x -> look env (unIdent x)
          Lam x b -> RFun (\ a -> ev ((unIdent x, a) : env) b)
          App f a -> case ev env f of
                       RFun g -> g (RT (ev env a))
                       RInt _ -> error "interp: applying an integer"
          Lit (LInt n) -> RInt n
          Lit (LChar c) -> RInt (ord c)
          Lit (LPrim p) | Just c <- combinator p -> ev [] c
                        | otherwise -> primR p
          Lit _ -> error "interp: literal not supported"
      primR p
        | p `elem` arith = RFun (\ (RT a) -> RFun (\ (RT b) -> RInt (arithOp p (int a) (int b))))
        | p `elem` compares = RFun (\ (RT a) -> RFun (\ (RT b) -> if cmpOp p (int a) (int b) then true else false))
        | p == "seq" = RFun (\ (RT a) -> RFun (\ (RT b) -> case a of { RInt _ -> b; RFun _ -> b }))
        | p == "neg" = RFun (\ (RT a) -> RInt (negate (int a)))
        | otherwise = error ("interp: " ++ p)
      false = RFun (\ (RT f) -> RFun (\ _ -> f))
      true = RFun (\ _ -> RFun (\ (RT t) -> t))
      int v = case v of { RInt n -> n; RFun _ -> error "interp: not an integer" }
      m = look [] "main"
  in  int (case arg of
             Nothing -> m
             Just n -> case m of { RFun g -> g (RT (RInt n)); RInt _ -> error "interp" })
