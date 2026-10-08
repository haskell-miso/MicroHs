module LowFutamuraLazy(main) where
import Data.List(elemIndex, nub)
import Data.Maybe(isJust)
import Staged.Low
import Staged.Low.C(toC)

-- The first Futamura projection of a call by need interpreter, for programs
-- with lazy data structures (lists), with call by need kept.
--
-- tests/LowFutamura.hs compiles programs whose run time values are integers:
-- closures and thunks only exist at compile time, so factorial compiles to
-- the factorial you would write by hand.  A lazy data structure whose size
-- depends on a run time value, like the list of Fibonacci numbers in
--
--   fibs = 0 : 1 : zipWith (+) fibs (tail fibs)
--   main input = fibs !! input
--
-- cannot be built at compile time.  Here lists are run time data, and the
-- compiled program has a heap of cells, threaded through it (store passing):
--
--  * A list is a run time value, Nil or Cons with the heap addresses of its
--    head and tail, which are lazy.  A cell holds a thunk or its value
--    (Thunk code captures | Done value).
--
--  * A thunk's code is compiled once for each shape of its environment,
--    which is known at compile time (closures are still compile time values,
--    and are part of the shape), and its captures are only the run time
--    values (integers and cells) it uses.  A Thunk holds the number of its
--    code and its captures, and one low function, run, dispatches on the
--    number: this is how a compiled lazy language calls the code of a thunk,
--    without closures.
--
--  * Forcing a cell runs its thunk once and updates the cell with the value
--    (call by need), and letrec ties a knot in the heap: fibs is one cell
--    whose thunk refers to the cell itself, so its elements are shared and
--    fibs !! n takes linear time.
--
--  * Everything else is as in LowFutamura: closures are compile time
--    values, integer arithmetic and conditionals are compiled away from the
--    interpreter, and recursion through run time values (nth here) becomes
--    a recursive low function.

-------------------------------------------------------------------------------
-- The language

-- Terms, with de Bruijn indices.  In Case s n c, c has the head (Var 1) and
-- the tail (Var 0) of a Cons; in Letrec b body, Var 0 is the binding in
-- both b and body.
data Term = Var Int | Lam Term | App Term Term
          | Lit Int | Prim Op Term Term | If0 Term Term Term
          | Nil | Cons Term Term | Case Term Term Term
          | Letrec Term Term

data Op = Plus | Minus | Times
  deriving (Eq)

-------------------------------------------------------------------------------
-- Run time data of a compiled program

-- A value in weak head normal form: an integer, or a list (whose head and
-- tail are heap addresses)
data RV = RInt Int | RNil | RCons Int Int

-- The run time values a thunk captures
data Ints = INil | ICons Int Ints

-- A heap cell: a thunk (the number of its code and its captures), or a value
data Cell = Thunk Int Ints | Done RV

-- Address 1 is the root, address a has children 2a and 2a+1
data Heap = Empty | Node Heap Cell Heap

-- The next free address, and the heap
data St = St Int Heap

data Res = Res RV St

-------------------------------------------------------------------------------
-- Compile time

-- Terms whose lambda bodies, application arguments, constructor fields, and
-- letrec bindings have labels; equal terms have equal labels
data LTerm = LVar Int | LLam Int LTerm | LApp LTerm Int LTerm
           | LLit Int | LPrim Op LTerm LTerm | LIf0 LTerm LTerm LTerm
           | LNil | LCons Int LTerm Int LTerm | LCase LTerm LTerm LTerm
           | LLetrec Int LTerm LTerm
  deriving (Eq)

labelTerm :: [(LTerm, Int)] -> Term -> (LTerm, [(LTerm, Int)])
labelTerm tbl t =
  case t of
    Var i -> (LVar i, tbl)
    Lam b ->
      let (b', tbl1) = labelTerm tbl b
          (l, tbl2) = label b' tbl1
      in  (LLam l b', tbl2)
    App f x ->
      let (f', tbl1) = labelTerm tbl f
          (x', tbl2) = labelTerm tbl1 x
          (l, tbl3) = label x' tbl2
      in  (LApp f' l x', tbl3)
    Lit k -> (LLit k, tbl)
    Prim o a b ->
      let (a', tbl1) = labelTerm tbl a
          (b', tbl2) = labelTerm tbl1 b
      in  (LPrim o a' b', tbl2)
    If0 c a b ->
      let (c', tbl1) = labelTerm tbl c
          (a', tbl2) = labelTerm tbl1 a
          (b', tbl3) = labelTerm tbl2 b
      in  (LIf0 c' a' b', tbl3)
    Nil -> (LNil, tbl)
    Cons h r ->
      let (h', tbl1) = labelTerm tbl h
          (lh, tbl2) = label h' tbl1
          (r', tbl3) = labelTerm tbl2 r
          (lr, tbl4) = label r' tbl3
      in  (LCons lh h' lr r', tbl4)
    Case s n c ->
      let (s', tbl1) = labelTerm tbl s
          (n', tbl2) = labelTerm tbl1 n
          (c', tbl3) = labelTerm tbl2 c
      in  (LCase s' n' c', tbl3)
    Letrec b body ->
      let (b', tbl1) = labelTerm tbl b
          (l, tbl2) = label b' tbl1
          (body', tbl3) = labelTerm tbl2 body
      in  (LLetrec l b' body', tbl3)
  where
    label u tb = case lookup u tb of
                   Just l -> (l, tb)
                   Nothing -> let l = length tb in (l, (u, l) : tb)

labelled :: Term -> (LTerm, [(Int, LTerm)])
labelled t = let (lt, tbl) = labelTerm [] t in (lt, [ (l, u) | (u, l) <- tbl ])

code :: [(Int, LTerm)] -> Int -> LTerm
code tbl l = maybe (error "label") id (lookup l tbl)

-- The free variables of a term
free :: LTerm -> [Int]
free t =
  case t of
    LVar n -> [n]
    LLam _ b -> [ i - 1 | i <- free b, i > 0 ]
    LApp f _ x -> free f ++ free x
    LLit _ -> []
    LPrim _ a b -> free a ++ free b
    LIf0 c a b -> free c ++ free a ++ free b
    LNil -> []
    LCons _ h _ r -> free h ++ free r
    LCase s n c -> free s ++ free n ++ [ i - 2 | i <- free c, i > 1 ]
    LLetrec _ b body -> [ i - 1 | i <- free b ++ free body, i > 0 ]

-- The variables of its environment that a closure body uses
freeClo :: LTerm -> [Int]
freeClo b = [ i - 1 | i <- free b, i > 0 ]

-- An application spine: the function and the arguments
spine :: LTerm -> (LTerm, [(Int, LTerm)])
spine t = go t []
  where go u acc = case u of
                     LApp f l x -> go f ((l, x) : acc)
                     _ -> (u, acc)

-- Is a closure body strict in its argument, when r more arguments follow
-- (so its inner lambdas are applied too)?
strictIn :: LTerm -> Int -> Bool
strictIn b r = go b r 0
  where go u k i = strict u i || (k > 0 && case u of
                                              LLam _ u' -> go u' (k - 1) (i + 1)
                                              _ -> False)

-- Does a term always use variable i?
strict :: LTerm -> Int -> Bool
strict t i =
  case t of
    LVar n -> n == i
    LApp f _ _ -> strict f i
    LPrim _ a b -> strict a i || strict b i
    LIf0 c a b -> strict c i || (strict a i && strict b i)
    LCase s n c -> strict s i || (strict n i && strict c (i + 2))
    LLetrec _ _ body -> strict body (i + 1)
    _ -> False

-- Compile time values: an integer known at compile time, a run time integer,
-- a run time value (from a cell or a constructor), or a closure.  The Int of
-- a run time value identifies it.
data V = VInt Int | VDyn Int (Low Int) | VRV Int (Low RV) | VClo Int LTerm [E]

-- An environment entry: a value, a compile time thunk, a run time cell, or a
-- recursive function (a letrec bound lambda, whose environment is itself
-- and env)
data E = EVal V | EThk Int LTerm [E] | ERef Int (Low Int) | EFix Int LTerm [E]

-- Shapes: what is known at compile time.  Sh Int identifies run time values
-- (to remember what was forced on a path), Sh () abstracts them.
data Sh d = SInt Int | SDyn d | SRV d | SClo Int [ShE d]
  deriving (Eq)
data ShE d = SVal (Sh d) | SThk Int [ShE d] | SRef d | SFix Int [ShE d] | SNone
  deriving (Eq)

-- The identifying shape of an entry
keyE :: E -> ShE Int
keyE e =
  case e of
    EVal v -> SVal (keyV v)
    EThk l t env -> SThk l (keyEnv (free t) env)
    ERef i _ -> SRef i
    EFix l b env -> SFix l (keyEnv (freeClo b) env)
  where
    keyV v = case v of
               VInt n -> SInt n
               VDyn i _ -> SDyn i
               VRV i _ -> SRV i
               VClo l b env -> SClo l (keyEnv (freeClo b) env)
    keyEnv used env = [ if i `elem` used then keyE x else SNone | (i, x) <- zip [0 ..] env ]

-- The abstract shape of an environment, and its run time values (integers
-- and cell addresses), as arguments of a recursive function (g = False) or
-- the captures of a thunk (g = True, where integers known at compile time
-- are captured too, so that the code of a thunk does not depend on them).
-- Run time values must be in cells (see norm).
absEnv :: Bool -> [Int] -> [E] -> ([ShE ()], [Low Int])
absEnv g used env =
  let xs = [ if i `elem` used then absE g e else (SNone, []) | (i, e) <- zip [0 ..] env ]
  in  (map fst xs, concatMap snd xs)

absE :: Bool -> E -> (ShE (), [Low Int])
absE g e =
  case e of
    EVal v -> let (s, cs) = absV v in (SVal s, cs)
    EThk l t env' -> let (ss, cs) = absEnv g (free t) env' in (SThk l ss, cs)
    ERef _ a -> (SRef (), [a])
    EFix l b env' -> let (ss, cs) = absEnv g (freeClo b) env' in (SFix l ss, cs)
  where
    absV v = case v of
      VInt n -> if g then (SDyn (), [lowInt n]) else (SInt n, [])
      VDyn _ x -> (SDyn (), [x])
      VRV _ _ -> error "absEnv: a run time value not in a cell"
      VClo l b env' -> let (ss, cs) = absEnv g (freeClo b) env' in (SClo l ss, cs)

-- The shape of the environment of an application, for finding recursion:
-- its compile time thunks are abstracted to cells (see apply)
recKey :: Int -> LTerm -> [E] -> Sh ()
recKey l b benv =
  SClo l [ if i `elem` used then (case e of
                                     EThk _ _ _ -> SRef ()
                                     _ -> fst (absE False e))
                            else SNone
         | (i, e) <- zip [0 ..] benv ]
  where used = free b

-- Make the compile time thunks of an environment cells: the arguments of a
-- recursive function are run time values, so a delayed argument is a run
-- time thunk, shared by all the calls
reify :: [Int] -> [E] -> G r [E]
reify used env = mapM one (zip [0 ..] env)
  where one (i, e) = if i `notElem` used then pure e else
                     case e of
                       EThk l t env' -> do { c <- thunkCell l t env'; a <- alloc c; j <- newId; pure (ERef j a) }
                       _ -> pure e

-- An environment of a shape, with the given run time values
rebuild :: [(Int, LTerm)] -> [ShE ()] -> [Low Int] -> Int -> ([E], [Low Int], Int)
rebuild tbl ss ps i =
  case ss of
    [] -> ([], ps, i)
    s : ss' ->
      let (e, ps1, i1) = rebuildE s ps i
          (es, ps2, i2) = rebuild tbl ss' ps1 i1
      in  (e : es, ps2, i2)
  where
    rebuildE s ps0 i0 =
      case (s, ps0) of
        (SVal (SInt n), _) -> (EVal (VInt n), ps0, i0)
        (SVal (SDyn _), p : ps') -> (EVal (VDyn i0 p), ps', i0 + 1)
        (SVal (SClo l es), _) -> let (env, ps1, i1) = rebuild tbl es ps0 i0
                                 in  (EVal (VClo l (code tbl l) env), ps1, i1)
        (SThk l es, _) -> let (env, ps1, i1) = rebuild tbl es ps0 i0
                          in  (EThk l (code tbl l) env, ps1, i1)
        (SRef _, p : ps') -> (ERef i0 p, ps', i0 + 1)
        (SFix l es, _) -> let (env, ps1, i1) = rebuild tbl es ps0 i0
                          in  (EFix l (code tbl l) env, ps1, i1)
        (SNone, _) -> (EVal (VInt 0), ps0, i0)            -- not used
        _ -> error "rebuild"

-- A recursive low function, by its number of run time arguments
data Fn = Fn0 (Low (St -> Res)) | Fn1 (Low (Int -> St -> Res))
        | Fn2 (Low (Int -> Int -> St -> Res)) | Fn3 (Low (Int -> Int -> Int -> St -> Res))

-- What the analysis finds: the shapes of the recursive functions, and of the
-- code of the thunks
data Item = IRec (Sh ()) | IThk (ShE ())
  deriving (Eq)

-- What the compiler does with code: generate it, or (in the analysis) only
-- find the items.  r is the result: the code, or the items found.
data Ops r = Ops
  { oLetI   :: Low Int -> (Low Int -> r) -> r                                -- let an integer
  , oLetV   :: Low RV -> (Low RV -> r) -> r                                  -- let a value
  , oIf     :: Low Int -> r -> r -> r                                        -- if e == 0
  , oCase   :: Low RV -> r -> (Low Int -> Low Int -> r) -> r                 -- case on a list
  , oUnbox  :: Low RV -> (Low Int -> r) -> r                                 -- the integer of a value
  , oJoin   :: (Low RV -> Low St -> r) -> ((Low RV -> Low St -> r) -> r) -> r  -- a join point
  , oFun    :: Int -> (Fn -> [Low Int] -> Low St -> r) -> (Fn -> r) -> r     -- a recursive function
  , oCall   :: Fn -> [Low Int] -> Low St -> (Low RV -> Low St -> r) -> r     -- call it
  , oRet    :: Low RV -> Low St -> r                                         -- return
  , oForce  :: Low Int -> Low St -> (Low RV -> Low St -> r) -> r             -- force a cell
  , oAlloc  :: Low Cell -> Low St -> (Low Int -> Low St -> r) -> r           -- allocate a cell
  , oSet    :: Low Int -> Low Cell -> Low St -> (Low St -> r) -> r           -- update a cell
  , oUncons :: Low Ints -> (Low Int -> Low Ints -> r) -> r                   -- take a capture
  , oItem   :: Item -> r -> r                                                -- an item found
  }

-- The low functions of the run time system
data Rt = Rt (Low (Heap -> Int -> Cell)) (Low (Heap -> Int -> Cell -> Heap)) (Low (Int -> Ints -> St -> Res))

genOps :: Rt -> Ops (Low Res)
genOps (Rt fetch store run) = Ops
  { oLetI = \ e k -> [| let x = ~e in ~(k [| x |]) |]
  , oLetV = \ e k -> [| let x = ~e in ~(k [| x |]) |]
  , oIf = \ c a b -> [| if ~c == 0 then ~a else ~b |]
  , oCase = \ v a b -> [| case ~v of { RNil -> ~a; RCons h t -> ~(b [| h |] [| t |]) } |]
  , oUnbox = \ v k -> [| case ~v of RInt i -> ~(k [| i |]) |]
  , oJoin = \ k body -> [| let j = \ v s -> ~(k [| v |] [| s |]) in ~(body (\ v s -> [| j ~v ~s |])) |]
  , oFun = \ n body rest ->
      case n of
        0 -> [| let f = \ s -> ~(body (Fn0 [| f |]) [] [| s |]) in ~(rest (Fn0 [| f |])) |]
        1 -> [| let f = \ a s -> ~(body (Fn1 [| f |]) [[| a |]] [| s |]) in ~(rest (Fn1 [| f |])) |]
        2 -> [| let f = \ a b s -> ~(body (Fn2 [| f |]) [[| a |], [| b |]] [| s |]) in ~(rest (Fn2 [| f |])) |]
        3 -> [| let f = \ a b c s -> ~(body (Fn3 [| f |]) [[| a |], [| b |], [| c |]] [| s |]) in ~(rest (Fn3 [| f |])) |]
        _ -> error "peval: a recursive function with more than 3 run time arguments"
  , oCall = \ fn ps st k ->
      let call :: Low Res
          call = case (fn, ps) of
                   (Fn0 f, []) -> [| ~f ~st |]
                   (Fn1 f, [a]) -> [| ~f ~a ~st |]
                   (Fn2 f, [a, b]) -> [| ~f ~a ~b ~st |]
                   (Fn3 f, [a, b, c]) -> [| ~f ~a ~b ~c ~st |]
                   _ -> error "call"
      in  [| case ~call of Res v s -> ~(k [| v |] [| s |]) |]
  , oRet = \ v st -> [| Res ~v ~st |]
  , oForce = \ a st k ->
      [| let j = \ v s -> ~(k [| v |] [| s |]) in
         case ~st of
           St _ h -> case ~fetch h ~a of
                       Done v -> j v ~st
                       Thunk c cs -> case ~run c cs ~st of
                                       Res v st1 -> case st1 of
                                         St n1 h1 -> j v (St n1 (~store h1 ~a (Done v))) |]
  , oAlloc = \ cell st k ->
      [| case ~st of St next h -> let s1 = St (next + 1) (~store h next ~cell) in ~(k [| next |] [| s1 |]) |]
  , oSet = \ a cell st k ->
      [| case ~st of St next h -> let s1 = St next (~store h ~a ~cell) in ~(k [| s1 |]) |]
  , oUncons = \ xs k -> [| case ~xs of ICons y ys -> ~(k [| y |] [| ys |]) |]
  , oItem = \ it r -> case it of
                        IThk _ -> r                 -- the code of a thunk: looked up in thunkCell
                        IRec _ -> error "peval: a recursive application that the analysis did not find"
  }

anaOps :: Ops [Item]
anaOps = Ops
  { oLetI = \ _ k -> k di
  , oLetV = \ _ k -> k dv
  , oIf = \ _ a b -> a ++ b
  , oCase = \ _ a b -> a ++ b di di
  , oUnbox = \ _ k -> k di
  , oJoin = \ k body -> k dv ds ++ body (\ _ _ -> [])
  , oFun = \ n body rest -> let fn = dummyFn n in body fn (replicate n di) ds ++ rest fn
  , oCall = \ _ _ _ k -> k dv ds
  , oRet = \ _ _ -> []
  , oForce = \ _ _ k -> k dv ds
  , oAlloc = \ _ _ k -> k di ds
  , oSet = \ _ _ _ k -> k ds
  , oUncons = \ _ k -> k di [| INil |]
  , oItem = (:)
  }
  where di = lowInt 0
        dv :: Low RV
        dv = [| RNil |]
        ds :: Low St
        ds = [| St 0 Empty |]
        dummyFn :: Int -> Fn
        dummyFn n = case n of
                      0 -> Fn0 [| \ s -> Res RNil s |]
                      1 -> Fn1 [| \ a s -> Res RNil s |]
                      2 -> Fn2 [| \ a b s -> Res RNil s |]
                      _ -> Fn3 [| \ a b c s -> Res RNil s |]

-- The context: what to do with code, the items of the analysis, the terms of
-- the labels, and the numbers of the thunk codes
data Ctx r = Ctx (Ops r) [Item] [(Int, LTerm)] [(ShE (), Int)]

ops :: Ctx r -> Ops r
ops (Ctx o _ _ _) = o

-- The state along a path: the next number for a run time value, what was
-- forced on this path, the recursive functions in scope, the applications
-- being unfolded, and the heap
data GS = GS Int [(ShE Int, V)] [(Sh (), Fn)] [Sh ()] (Low St)

-- Code generation, in continuation passing style
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

fresh :: GS -> (Int, GS)
fresh (GS i m fs as st) = (i, GS (i + 1) m fs as st)

stOf :: GS -> Low St
stOf (GS _ _ _ _ st) = st

withSt :: Low St -> GS -> GS
withSt st (GS i m fs as _) = GS i m fs as st

newId :: G r Int
newId = G $ \ _ gs k -> let (i, gs1) = fresh gs in k i gs1

bindInt :: Low Int -> G r V
bindInt e = G $ \ ctx gs k -> oLetI (ops ctx) e (\ x -> let (i, gs1) = fresh gs in k (VDyn i x) gs1)

bindRV :: Low RV -> G r V
bindRV e = G $ \ ctx gs k -> oLetV (ops ctx) e (\ x -> let (i, gs1) = fresh gs in k (VRV i x) gs1)

-- The integer of a value
intOf :: V -> G r (Low Int)
intOf v =
  case v of
    VInt n -> pure (lowInt n)
    VDyn _ x -> pure x
    VRV _ x -> G $ \ ctx gs k -> oUnbox (ops ctx) x (\ i -> k i gs)
    VClo _ _ _ -> error "peval: a function where an integer was expected"

-- A value as a run time value
box :: V -> Low RV
box v =
  case v of
    VInt n -> [| RInt ~(lowInt n) |]
    VDyn _ x -> [| RInt ~x |]
    VRV _ x -> x
    VClo _ _ _ -> error "peval: a function where a run time value was expected"

alloc :: Low Cell -> G r (Low Int)
alloc cell = G $ \ ctx gs k -> oAlloc (ops ctx) cell (stOf gs) (\ a st1 -> k a (withSt st1 gs))

setCell :: Low Int -> Low Cell -> G r ()
setCell a cell = G $ \ ctx gs k -> oSet (ops ctx) a cell (stOf gs) (\ st1 -> k () (withSt st1 gs))

item :: Item -> G r ()
item it = G $ \ ctx gs k -> oItem (ops ctx) it (k () gs)

-- Put the run time values of an entry in cells, so it can be captured
norm :: E -> G r E
norm e =
  case e of
    EVal (VRV _ x) -> do { a <- alloc [| Done ~x |]; i <- newId; pure (ERef i a) }
    EVal (VClo l b env) -> (EVal . VClo l b) <$> normEnv (freeClo b) env
    EThk l t env -> EThk l t <$> normEnv (free t) env
    EFix l b env -> EFix l b <$> normEnv (freeClo b) env
    _ -> pure e

normEnv :: [Int] -> [E] -> G r [E]
normEnv used env = mapM (\ (i, e) -> if i `elem` used then norm e else pure e) (zip [0 ..] env)

-- The number of run time values of an abstract shape
nParams :: [ShE ()] -> Int
nParams = sum . map count
  where count s = case s of
                    SVal (SDyn _) -> 1
                    SVal (SClo _ es) -> nParams es
                    SThk _ es -> nParams es
                    SRef _ -> 1
                    SFix _ es -> nParams es
                    _ -> 0

-- A thunk cell for a term in an environment: the number of the code for
-- its shape, and the run time values it uses
thunkCell :: Int -> LTerm -> [E] -> G r (Low Cell)
thunkCell l t env = do
  env' <- normEnv (free t) env
  let (ss, cs) = absEnv True (free t) env'
      key = SThk l ss
  item (IThk key)
  G $ \ (Ctx _ items _ codes) gs k ->
    let n = case lookup key codes of
              Just c -> c
              Nothing | IThk key `elem` items -> error "thunkCell"
                      | otherwise -> 0                -- the analysis, which records it
    in  k [| Thunk ~(lowInt n) ~(ints cs) |] gs

ints :: [Low Int] -> Low Ints
ints cs = case cs of
  [] -> [| INil |]
  c : cs' -> [| ICons ~c ~(ints cs') |]

-- The interpreter, at compile time
eval :: LTerm -> [E] -> G r V
eval t env =
  case t of
    LVar n -> force (env !! n)
    LLam l b -> pure (VClo l b env)
    LApp _ _ _ -> do
      let (h, args) = spine t
      fv <- eval h env
      applyAll fv args env
    LLit n -> pure (VInt n)
    LPrim o a b -> do
      x <- eval a env
      y <- eval b env
      case (x, y) of
        (VInt i, VInt j) -> pure (VInt (op o i j))
        _ -> do { xi <- intOf x; yi <- intOf y; bindInt (primL o xi yi) }
    LIf0 c a b -> do
      cv <- eval c env
      case cv of
        VInt 0 -> eval a env
        VInt _ -> eval b env
        _ -> do
          ci <- intOf cv
          branch (\ ctx gs ret -> oIf (ops ctx) ci (evalT a env ctx gs ret) (evalT b env ctx gs ret))
    LNil -> bindRV [| RNil |]
    LCons lh h lr r -> do
      ha <- field lh h env
      ra <- field lr r env
      bindRV [| RCons ~ha ~ra |]
    LCase s n c -> do
      sv <- eval s env
      case sv of
        VRV _ x -> branch (caseOn x n c env)
        _ -> error "peval: case on a value that is not a list"
    LLetrec l b body ->
      case b of
        LLam _ _ -> eval body (EFix l b env : env)
        _ -> do
          -- a knot in the heap: the cell's thunk captures the cell itself
          a <- alloc [| Done RNil |]
          i <- newId
          let env' = ERef i a : env
          cell <- thunkCell l b env'
          setCell a cell
          eval body env'

-- A case on a run time list, with the branches in tail position
caseOn :: Low RV -> LTerm -> LTerm -> [E] -> Ctx r -> GS -> (Low RV -> Low St -> r) -> r
caseOn x n c env ctx gs ret =
  oCase (ops ctx) x (evalT n env ctx gs ret)
        (\ h tl -> let (ih, gs1) = fresh gs
                       (it, gs2) = fresh gs1
                   in  evalT c (ERef it tl : ERef ih h : env) ctx gs2 ret)

-- A conditional on run time values: the code after it is a join point
branch :: (Ctx r -> GS -> (Low RV -> Low St -> r) -> r) -> G r V
branch alts = G $ \ ctx gs@(GS i m fs as _) k ->
  oJoin (ops ctx) (\ v s -> k (VRV i v) (GS (i + 1) m fs as s)) (\ j -> alts ctx gs j)

-- A constructor field: the address of a cell
field :: Int -> LTerm -> [E] -> G r (Low Int)
field l t env =
  case t of
    LVar n -> cellOf (env !! n)
    LLit k -> alloc [| Done (RInt ~(lowInt k)) |]
    _ -> thunkCell l t env >>= alloc

cellOf :: E -> G r (Low Int)
cellOf e =
  case e of
    ERef _ a -> pure a
    EVal v -> alloc [| Done ~(box v) |]
    EThk l t env -> thunkCell l t env >>= alloc
    EFix _ _ _ -> error "peval: a function in a data structure"

-- Apply a function to the arguments of a spine
applyAll :: V -> [(Int, LTerm)] -> [E] -> G r V
applyAll fv args env =
  case args of
    [] -> pure fv
    (l, x) : rest -> do
      a <- argument fv l x env (length rest)
      v <- apply fv a
      applyAll v rest env

-- The argument of an application, with r more arguments after it
argument :: V -> Int -> LTerm -> [E] -> Int -> G r E
argument fv l x env r =
  case x of
    LVar n -> pure (env !! n)
    LLam l' b -> pure (EVal (VClo l' b env))
    LLit n -> pure (EVal (VInt n))
    _ -> case fv of
           VClo _ b _ | strictIn b r -> EVal <$> eval x env
           _ -> pure (EThk l x env)

-- Use an entry: a compile time thunk is evaluated the first time on a path,
-- a cell is forced at run time the first time on a path
force :: E -> G r V
force e =
  case e of
    EVal v -> pure v
    EFix _ b env -> eval b (e : env)
    _ -> G $ \ ctx gs@(GS _ m _ _ _) k ->
      let key = keyE e
          remember v (GS i' m' fs' as' st') = GS i' ((key, v) : m') fs' as' st'
      in  case lookup key m of
            Just v -> k v gs
            Nothing ->
              case e of
                EThk _ t env -> runG (eval t env) ctx gs (\ v gs1 -> k v (remember v gs1))
                ERef _ a -> oForce (ops ctx) a (stOf gs) $ \ x st1 ->
                              let (i, gs1) = fresh (withSt st1 gs)
                                  v = VRV i x
                              in  k v (remember v gs1)
                _ -> error "force"

-- Apply a closure: unfold it, or call (and first define) the recursive
-- function of its shape
apply :: V -> E -> G r V
apply fv a =
  case fv of
    VClo l b cenv -> do
      benv0 <- normEnv (free b) (a : cenv)
      G $ \ ctx@(Ctx o items _ _) gs0@(GS _ _ fs0 as0 _) k ->
        let key = recKey l b benv0
            recursive = isJust (lookup key fs0) || IRec key `elem` items || key `elem` as0
        in  if recursive then
              runG (reify (free b) benv0) ctx gs0 $ \ benv gs@(GS _ _ fs _ st) ->
                let (ss, ps) = absEnv False (free b) benv
                    result v gs1 = let (j, gs2) = fresh gs1 in k (VRV j v) gs2
                in  case lookup key fs of
                      Just fn -> oCall o fn ps st (\ v st1 -> result v (withSt st1 gs))
                      Nothing
                        | IRec key `elem` items ->
                            define ctx key b ss gs (\ fn gs1 -> oCall o fn ps (stOf gs1) (\ v st1 -> result v (withSt st1 gs1)))
                        | otherwise -> oItem o (IRec key) (result [| RNil |] gs)
            else case gs0 of
              GS i m fs as st -> runG (eval b benv0) ctx (GS i m fs (key : as) st)
                                   (\ v (GS i' m' fs' _ st') -> k v (GS i' m' fs' as st'))
    _ -> error "peval: applying a value that is not a function"

define :: Ctx r -> Sh () -> LTerm -> [ShE ()] -> GS -> (Fn -> GS -> r) -> r
define ctx@(Ctx o _ tbl _) key b ss (GS i m fs as st) k =
  oFun o (nParams ss)
    (\ fn ps st0 -> let (benv', _, i1) = rebuild tbl ss ps i
                    in  evalT b benv' ctx (GS i1 [] ((key, fn) : fs) as st0) (oRet o))
    (\ fn -> k fn (GS i m ((key, fn) : fs) as st))

-- Evaluate a term in tail position: its value goes to ret
evalT :: LTerm -> [E] -> Ctx r -> GS -> (Low RV -> Low St -> r) -> r
evalT t env ctx gs ret =
  case t of
    LIf0 c a b ->
      runG (eval c env) ctx gs $ \ cv gs1 ->
        case cv of
          VInt 0 -> evalT a env ctx gs1 ret
          VInt _ -> evalT b env ctx gs1 ret
          _ -> runG (intOf cv) ctx gs1 $ \ ci gs2 ->
                 oIf (ops ctx) ci (evalT a env ctx gs2 ret) (evalT b env ctx gs2 ret)
    LCase s n c ->
      runG (eval s env) ctx gs $ \ sv gs1 ->
        case sv of
          VRV _ x -> caseOn x n c env ctx gs1 ret
          _ -> error "peval: case on a value that is not a list"
    LApp _ _ _ ->
      let (h, args) = spine t
          (l, x) = last args
      in  runG (do { f0 <- eval h env; fv <- applyAll f0 (init args) env; a <- argument fv l x env 0; return (fv, a) })
               ctx gs $ \ (fv, a) gs1 -> applyT fv a ctx gs1 ret
    _ -> runG (eval t env) ctx gs (\ v gs1 -> ret (box v) (stOf gs1))

applyT :: V -> E -> Ctx r -> GS -> (Low RV -> Low St -> r) -> r
applyT fv a ctx@(Ctx o items _ _) gs ret =
  case fv of
    VClo l b cenv ->
      runG (normEnv (free b) (a : cenv)) ctx gs $ \ benv0 gs0@(GS i m fs0 as st0) ->
        let key = recKey l b benv0
            recursive = isJust (lookup key fs0) || IRec key `elem` items || key `elem` as
        in  if recursive then
              runG (reify (free b) benv0) ctx gs0 $ \ benv gs1@(GS _ _ fs _ st) ->
                let (ss, ps) = absEnv False (free b) benv
                in  case lookup key fs of
                      Just fn -> oCall o fn ps st ret
                      Nothing
                        | IRec key `elem` items -> define ctx key b ss gs1 (\ fn gs2 -> oCall o fn ps (stOf gs2) ret)
                        | otherwise -> oItem o (IRec key) (ret [| RNil |] st)
            else evalT b benv0 ctx (GS i m fs0 (key : as) st0) ret
    _ -> error "peval: applying a value that is not a function"

op :: Op -> Int -> Int -> Int
op o i j = case o of { Plus -> i + j; Minus -> i - j; Times -> i * j }

primL :: Op -> Low Int -> Low Int -> Low Int
primL o x y =
  case o of
    Plus  -> [| ~x + ~y |]
    Minus -> [| ~x - ~y |]
    Times -> [| ~x * ~y |]

-------------------------------------------------------------------------------
-- Compiling a program whose value is a function of one run time integer

-- The code of a thunk: its captures are the run time values of its shape
thunkCode :: Ctx r -> ShE () -> Low Ints -> Low St -> r
thunkCode ctx@(Ctx o _ tbl _) key cs st =
  case key of
    SThk l ss -> uncons (nParams ss) cs $ \ ps ->
                   let (env, _, i) = rebuild tbl ss ps 0
                   in  evalT (code tbl l) env ctx (GS i [] [] [] st) (oRet o)
    _ -> error "thunkCode"
  where uncons n xs f = if n == 0 then f [] else
                          oUncons o xs (\ y ys -> uncons (n - 1) ys (\ zs -> f (y : zs)))

-- The program applied to the input
program :: LTerm -> Ctx r -> Low Int -> Low St -> r
program lt ctx n st =
  runG (eval lt []) ctx (GS 1 [] [] [] st) (\ f gs -> applyT f (EVal (VDyn 0 n)) ctx gs (oRet (ops ctx)))

-- The items of a program: run the compiler in the analysis mode, on the
-- program and the code of every thunk found, until it finds no new items
analyse :: LTerm -> [(Int, LTerm)] -> [Item]
analyse lt tbl = go []
  where
    go items =
      let ctx = Ctx anaOps items tbl (codes items)
          found = program lt ctx (lowInt 0) [| St 0 Empty |] ++
                  concat [ thunkCode ctx key [| INil |] [| St 0 Empty |] | IThk key <- items ]
          new = nub found
      in  if all (`elem` items) new then items else go (nub (items ++ new))

codes :: [Item] -> [(ShE (), Int)]
codes items = zip [ key | IThk key <- items ] [0 ..]

-- The run time system and the program
compileFun :: Term -> Low (Int -> Int)
compileFun t =
  let (lt, tbl) = labelled t
      items = analyse lt tbl
      cs = codes items
  in  [| \ n -> ~(runGen $ do
          fetch <- genRec $ \ fetch -> [| \ h a ->
                     case h of
                       Node l c r -> if a == 1 then c
                                     else if a - 2 * (a `quot` 2) == 0 then ~fetch l (a `quot` 2)
                                     else ~fetch r (a `quot` 2) |]
          store <- genRec $ \ store -> [| \ h a c ->
                     case h of
                       Empty -> Node Empty c Empty
                       Node l c0 r -> if a == 1 then Node l c r
                                      else if a - 2 * (a `quot` 2) == 0 then Node (~store l (a `quot` 2) c) c0 r
                                      else Node l c0 (~store r (a `quot` 2) c) |]
          run <- genRec $ \ run -> [| \ c xs st ->
                     ~(dispatch (Ctx (genOps (Rt fetch store run)) items tbl cs) cs [| c |] [| xs |] [| st |]) |]
          let ctx = Ctx (genOps (Rt fetch store run)) items tbl cs
          return [| case ~(program lt ctx [| n |] [| St 1 Empty |]) of
                      Res v _ -> case v of RInt i -> i |]) |]

-- The body of run: the code of every thunk, by number
dispatch :: Ctx (Low Res) -> [(ShE (), Int)] -> Low Int -> Low Ints -> Low St -> Low Res
dispatch ctx tcs c xs st =
  case tcs of
    [] -> [| Res RNil ~st |]                       -- no thunks: run is never called
    [(key, _)] -> thunkCode ctx key xs st
    (key, n) : rest -> [| if ~c == ~(lowInt n) then ~(thunkCode ctx key xs st)
                                              else ~(dispatch ctx rest c xs st) |]

-------------------------------------------------------------------------------
-- Writing terms with names

data Named = V String | L String Named | Named :@ Named
           | N Int | Named :+ Named | Named :- Named | Named :* Named
           | IfZ Named Named Named
           | NilN | ConsN Named Named
           | CaseN Named Named String String Named      -- case s of [] -> n; h : t -> c
           | LetRec String Named Named                  -- letrec x = b in body
infixl 9 :@
infixl 6 :+, :-
infixl 7 :*

deBruijn :: Named -> Term
deBruijn = go []
  where
    go vs e =
      case e of
        V x       -> maybe (error ("unbound " ++ x)) Var (elemIndex x vs)
        L x b     -> Lam (go (x : vs) b)
        f :@ a    -> App (go vs f) (go vs a)
        N n       -> Lit n
        a :+ b    -> Prim Plus (go vs a) (go vs b)
        a :- b    -> Prim Minus (go vs a) (go vs b)
        a :* b    -> Prim Times (go vs a) (go vs b)
        IfZ c a b -> If0 (go vs c) (go vs a) (go vs b)
        NilN      -> Nil
        ConsN h r -> Cons (go vs h) (go vs r)
        CaseN s n h r c -> Case (go vs s) (go vs n) (go (r : h : vs) c)
        LetRec x b body -> Letrec (go (x : vs) b) (go (x : vs) body)

-- Lists
zipWithN, tailN, nthN :: Named
zipWithN = L "f" (L "xs" (L "ys"
             (CaseN (V "xs") NilN "x" "xs'"
               (CaseN (V "ys") NilN "y" "ys'"
                 (ConsN (V "f" :@ V "x" :@ V "y") (V "zipWith" :@ V "f" :@ V "xs'" :@ V "ys'"))))))
tailN = L "xs" (CaseN (V "xs") NilN "h" "t" (V "t"))
nthN = L "n" (L "xs" (CaseN (V "xs") (N 0) "h" "t"
         (IfZ (V "n") (V "h") (V "nth" :@ (V "n" :- N 1) :@ V "t"))))

-- fibs = 0 : 1 : zipWith (+) fibs (tail fibs);  main input = fibs !! input
fibsProgram :: Named
fibsProgram =
  L "input"
    (LetRec "zipWith" zipWithN
      (LetRec "nth" nthN
        (LetRec "fibs" (ConsN (N 0) (ConsN (N 1)
                          (V "zipWith" :@ L "a" (L "b" (V "a" :+ V "b")) :@ V "fibs" :@ (tailN :@ V "fibs"))))
          (V "nth" :@ V "input" :@ V "fibs"))))

pfibs :: Low (Int -> Int)
pfibs = compileFun (deBruijn fibsProgram)

-- Run time code: the compiled program is spliced in.
fibsC :: Int -> Int
fibsC = pfibs

main :: IO ()
main = do
  putStrLn "---- pfibs = compileFun (deBruijn fibsProgram), reflected"
  putStr (lowString (lowPretty (reflect pfibs)))
  putStrLn "---- pfibs, C"
  putStr (lowString (toC "pfibs" (reflect pfibs)))
  putStrLn "---- run"
  print (map fibsC [0 .. 20])
  print (fibsC 40)                  -- fib 46 is the largest that fits a 32 bit Int
