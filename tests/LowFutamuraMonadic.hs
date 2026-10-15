module LowFutamuraMonadic(main) where
import Data.List(nub, nubBy)
import Data.Maybe(fromMaybe)
import Staged.Low
import Staged.Low.C(toC)

-- The first Futamura projection of tests/LowFutamura.hs (Jones optimal, call
-- by need), written in a different style:
--
--  * One term type.  Every binder and every application argument gets a
--    globally unique id from a name supply when the program is built, so
--    there are no de Bruijn indices, no separate labelled terms, and no
--    labelling pass.  Environments map ids to entries.  A term that is built
--    once and used twice (with share, e.g. the two copies of
--    \ x -> f (x x) in the Y combinator) has the same ids in both places, so
--    equal closures have equal shapes.
--
--  * A monadic interpreter.  The interpreter is written once, against the
--    class MonadPE of partial evaluation monads, whose methods are the ways a
--    compiler uses code: bind it, branch on it, make a join point, define a
--    recursive function.  The code generator and the analysis that finds the
--    recursive functions are two instances of it.

-------------------------------------------------------------------------------
-- Terms

type Id = Int

data Term = Var Id | Lam Id Term | App Term Id Term     -- the Id of App labels the argument
          | Lit Int | Prim Op Term Term | If0 Term Term Term

data Op = Plus | Minus | Times

-- The name supply: the next id, and the source names of the ids
newtype Fresh a = Fresh (Int -> (a, Int, [(Id, String)]))

runF :: Fresh a -> Int -> (a, Int, [(Id, String)])
runF (Fresh m) = m

instance Functor Fresh where
  fmap f (Fresh m) = Fresh $ \ i -> case m i of (a, i', ns) -> (f a, i', ns)
instance Applicative Fresh where
  pure a = Fresh $ \ i -> (a, i, [])
  mf <*> ma = do { f <- mf; a <- ma; pure (f a) }
instance Monad Fresh where
  Fresh m >>= f = Fresh $ \ i ->
    case m i of
      (a, i1, ns1) -> case runF (f a) i1 of
                        (b, i2, ns2) -> (b, i2, ns1 ++ ns2)

fresh :: String -> Fresh Id
fresh x = Fresh $ \ i -> (i, i + 1, [(i, x)])

-- A program, and the names of its ids
runFresh :: Fresh a -> (a, [(Id, String)])
runFresh m = case runF m 0 of (a, _, ns) -> (a, ns)

-- The terms of the labels: the bodies of the lambdas and the application
-- arguments, for rebuilding closures and thunks from their shapes
codes :: Term -> [(Id, Term)]
codes t =
  case t of
    Var _ -> []
    Lam x b -> (x, b) : codes b
    App f l a -> (l, a) : codes f ++ codes a
    Lit _ -> []
    Prim _ a b -> codes a ++ codes b
    If0 c a b -> codes c ++ codes a ++ codes b

-- The free variables of a term
free :: Term -> [Id]
free t =
  case t of
    Var x -> [x]
    Lam x b -> filter (/= x) (free b)
    App f _ a -> free f ++ free a
    Lit _ -> []
    Prim _ a b -> free a ++ free b
    If0 c a b -> free c ++ free a ++ free b

used :: Term -> [Id]
used = nub . free

-- Does a term always use variable x (is it strict in it)?
strict :: Term -> Id -> Bool
strict t x =
  case t of
    Var y -> y == x
    Lam _ _ -> False
    App f _ _ -> strict f x
    Lit _ -> False
    Prim _ a b -> strict a x || strict b x
    If0 c a b -> strict c x || (strict a x && strict b x)

-------------------------------------------------------------------------------
-- Compile time values

-- An integer known at compile time, a run time integer (with a number that
-- identifies it), or a closure (its binder, body, and the entries of the
-- variables it uses, as in closure conversion)
data V = VInt Int | VDyn Int (Low Int) | VClo Id Term Env

-- An environment entry: a value, or a thunk (its label, term, and the
-- entries of the variables it uses)
data E = EVal V | EThk Id Term Env

type Env = [(Id, E)]

look :: Id -> Env -> E
look x env = fromMaybe (error ("peval: unbound " ++ show x)) (lookup x env)

-- The entries of the given variables
restrict :: [Id] -> Env -> Env
restrict xs env = [ (x, e) | x <- xs, Just e <- [lookup x env] ]

-- The shape of a value: what is known at compile time.  Sh Int identifies
-- run time integers (for thunks forced on a path), Sh () abstracts them
-- (for the arguments of recursive functions).
data Sh d = SInt Int | SDyn d | SClo Id [(Id, ShE d)]
  deriving (Eq)
data ShE d = SVal (Sh d) | SThk Id [(Id, ShE d)]
  deriving (Eq)

shapeV :: (Int -> d) -> V -> Sh d
shapeV f v =
  case v of
    VInt n -> SInt n
    VDyn i _ -> SDyn (f i)
    VClo x _ env -> SClo x (shapeEnv f env)

shapeE :: (Int -> d) -> E -> ShE d
shapeE f e =
  case e of
    EVal v -> SVal (shapeV f v)
    EThk l _ env -> SThk l (shapeEnv f env)

shapeEnv :: (Int -> d) -> Env -> [(Id, ShE d)]
shapeEnv f env = [ (x, shapeE f e) | (x, e) <- env ]

-- The run time integers of an environment
dynsEnv :: Env -> [Low Int]
dynsEnv = concatMap (dynsE . snd)

dynsE :: E -> [Low Int]
dynsE e =
  case e of
    EVal (VDyn _ x) -> [x]
    EVal (VClo _ _ env) -> dynsEnv env
    EVal (VInt _) -> []
    EThk _ _ env -> dynsEnv env

-- Their names in the generated code, after the variables they come from
dynNamesEnv :: [(Id, String)] -> Env -> [String]
dynNamesEnv names env = concat [ dynNamesE names x e | (x, e) <- env ]

dynNamesE :: [(Id, String)] -> Id -> E -> [String]
dynNamesE names x e =
  case e of
    EVal (VDyn _ _) -> [nameOf names x]
    EVal (VClo _ _ env) -> dynNamesEnv names env
    EVal (VInt _) -> []
    EThk _ _ env -> dynNamesEnv names env

nameOf :: [(Id, String)] -> Id -> String
nameOf names x = fromMaybe "x" (lookup x names)

-- An environment of a shape, with the given run time integers
rebuild :: [(Id, Term)] -> [(Id, ShE ())] -> [Low Int] -> Int -> (Env, [Low Int], Int)
rebuild tbl ss ps i =
  case ss of
    [] -> ([], ps, i)
    (x, s) : ss' ->
      let (e, ps1, i1) = rebuildE tbl s ps i
          (env, ps2, i2) = rebuild tbl ss' ps1 i1
      in  ((x, e) : env, ps2, i2)

rebuildE :: [(Id, Term)] -> ShE () -> [Low Int] -> Int -> (E, [Low Int], Int)
rebuildE tbl s ps i =
  case s of
    SVal (SInt n) -> (EVal (VInt n), ps, i)
    SVal (SDyn _) -> case ps of
                       p : ps' -> (EVal (VDyn i p), ps', i + 1)
                       [] -> error "rebuild"
    SVal (SClo x es) -> let (env, ps1, i1) = rebuild tbl es ps i
                        in  (EVal (VClo x (code tbl x) env), ps1, i1)
    SThk l es -> let (env, ps1, i1) = rebuild tbl es ps i
                 in  (EThk l (code tbl l) env, ps1, i1)

code :: [(Id, Term)] -> Id -> Term
code tbl l = fromMaybe (error "peval: label") (lookup l tbl)

-- A recursive low function, by its number of run time arguments (0 is
-- passed a dummy argument)
data Fn = Fn1 (Low (Int -> Int)) | Fn2 (Low (Int -> Int -> Int)) | Fn3 (Low (Int -> Int -> Int -> Int))

callFn :: Fn -> [Low Int] -> Low Int
callFn fn ps =
  case (fn, ps) of
    (Fn1 f, []) -> [| ~f 0 |]
    (Fn1 f, [a]) -> [| ~f ~a |]
    (Fn2 f, [a, b]) -> [| ~f ~a ~b |]
    (Fn3 f, [a, b, c]) -> [| ~f ~a ~b ~c |]
    _ -> error "callFn"

-------------------------------------------------------------------------------
-- Partial evaluation monads

-- The state along a path of the program: the next number for a run time
-- integer, the thunks forced on this path, the recursive functions in scope,
-- and the applications being unfolded
data GS = GS Int [(ShE Int, V)] [(Sh (), Fn)] [Sh ()]

-- The context: the shapes of the recursive functions (with the name of the
-- variable that the recursive call uses), the terms of the labels, and the
-- names of the ids
data Ctx = Ctx [(Sh (), String)] [(Id, Term)] [(Id, String)]

ctxRecs :: Ctx -> [(Sh (), String)]
ctxRecs (Ctx recs _ _) = recs

ctxCode :: Ctx -> [(Id, Term)]
ctxCode (Ctx _ tbl _) = tbl

ctxNames :: Ctx -> [(Id, String)]
ctxNames (Ctx _ _ names) = names

-- The end of a block of code: a computation of type m End does not return,
-- it ends with done, a join point, or a call
data End = End

class Monad m => MonadPE m where
  askCtx  :: m Ctx
  getGS   :: m GS
  putGS   :: GS -> m ()
  -- let x = e in ...
  letInt  :: Low Int -> m (Low Int)
  -- if e == 0 then .. else ..
  ifInt   :: Low Int -> m End -> m End -> m End
  -- a join point: the code after it is a function that the block returns to
  joinInt :: ((Low Int -> m End) -> m End) -> m (Low Int)
  -- a recursive function: its name, the names of its arguments, their
  -- number, and its body
  recFun  :: String -> [String] -> Int -> (Fn -> [Low Int] -> m End) -> m Fn
  -- a recursive application, of the variable with the name
  recCall :: Sh () -> String -> m ()
  -- return a value
  done    :: Low Int -> m End

modifyGS :: MonadPE m => (GS -> GS) -> m ()
modifyGS f = getGS >>= putGS . f

-- Both instances are continuation passing; r is the result, the code or the
-- shapes of the recursive functions found
newtype PE r a = PE (Ctx -> GS -> (a -> GS -> r) -> r)

runPE :: PE r a -> Ctx -> GS -> (a -> GS -> r) -> r
runPE (PE m) = m

runEnd :: PE r End -> Ctx -> GS -> r
runEnd m c s = runPE m c s (\ _ _ -> error "peval: a block of code returned")

-- Run the code generator, and the analysis
genCode :: PE (Low Int) End -> Ctx -> GS -> Low Int
genCode = runEnd

analyse :: PE [(Sh (), String)] End -> Ctx -> GS -> [(Sh (), String)]
analyse = runEnd

instance Functor (PE r) where
  fmap f (PE m) = PE (\ c s k -> m c s (\ a s' -> k (f a) s'))
instance Applicative (PE r) where
  pure a = PE (\ _ s k -> k a s)
  PE mf <*> PE ma = PE (\ c s k -> mf c s (\ f s1 -> ma c s1 (\ a s2 -> k (f a) s2)))
instance Monad (PE r) where
  PE m >>= f = PE (\ c s k -> m c s (\ a s' -> runPE (f a) c s' k))

-- Code generation
instance MonadPE (PE (Low Int)) where
  askCtx = PE (\ c s k -> k c s)
  getGS = PE (\ _ s k -> k s s)
  putGS s = PE (\ _ _ k -> k () s)
  letInt e = PE (\ _ s k -> [| let x = ~e in ~(k [| x |] s) |])
  ifInt x a b = PE (\ c s _ -> [| if ~x == 0 then ~(runEnd a c s) else ~(runEnd b c s) |])
  joinInt body = PE $ \ c s k ->
    [| let j = \ v -> ~(k [| v |] s) in ~(runEnd (body (\ w -> PE (\ _ _ _ -> [| j ~w |]))) c s) |]
  recFun name xs n body = PE $ \ c s k ->
    let b fn ps = runEnd (body fn ps) c s in
    named name xs $
    case n of
      0 -> [| let f = \ d -> ~(b (Fn1 [| f |]) []) in ~(k (Fn1 [| f |]) s) |]
      1 -> [| let f = \ a -> ~(b (Fn1 [| f |]) [[| a |]]) in ~(k (Fn1 [| f |]) s) |]
      2 -> [| let f = \ a1 a2 -> ~(b (Fn2 [| f |]) [[| a1 |], [| a2 |]]) in ~(k (Fn2 [| f |]) s) |]
      3 -> [| let f = \ a1 a2 a3 -> ~(b (Fn3 [| f |]) [[| a1 |], [| a2 |], [| a3 |]]) in ~(k (Fn3 [| f |]) s) |]
      _ -> error "peval: a recursive function with more than 3 run time arguments"
  recCall _ _ = error "peval: a recursive application that the analysis did not find"
  done x = PE (\ _ _ _ -> x)

-- The analysis: only find the shapes of the recursive functions
instance MonadPE (PE [(Sh (), String)]) where
  askCtx = PE (\ c s k -> k c s)
  getGS = PE (\ _ s k -> k s s)
  putGS s = PE (\ _ _ k -> k () s)
  letInt _ = PE (\ _ s k -> k dummy s)
  ifInt _ a b = PE (\ c s _ -> runEnd a c s ++ runEnd b c s)
  joinInt body = PE (\ c s k -> k dummy s ++ runEnd (body (\ _ -> PE (\ _ _ _ -> []))) c s)
  recFun _ _ n body = PE (\ c s k -> runEnd (body dummyFn (replicate n dummy)) c s ++ k dummyFn s)
  recCall key name = PE (\ _ s k -> (key, name) : k () s)
  done _ = PE (\ _ _ _ -> [])

dummy :: Low Int
dummy = lowInt 0

dummyFn :: Fn
dummyFn = Fn1 [| \ x -> x |]

-------------------------------------------------------------------------------
-- The interpreter, at compile time

-- A new run time integer
newDyn :: MonadPE m => Low Int -> m V
newDyn x = do
  s <- getGS
  let GS i m fs as = s
  putGS (GS (i + 1) m fs as)
  pure (VDyn i x)

-- Bind run time integer code to a variable
bindInt :: MonadPE m => Low Int -> m V
bindInt e = letInt e >>= newDyn

int :: V -> Low Int
int v =
  case v of
    VInt n -> lowInt n
    VDyn _ x -> x
    VClo _ _ _ -> error "peval: a function where an integer was expected"

eval :: MonadPE m => Term -> Env -> m V
eval t env =
  case t of
    Var x -> force (look x env)
    Lam x b -> pure (VClo x b (restrict (used t) env))
    App f l a -> do
      fv <- eval f env
      e <- argument fv l a env
      name <- funName f
      apply name fv e
    Lit n -> pure (VInt n)
    Prim o a b -> do
      x <- eval a env
      y <- eval b env
      case (x, y) of
        (VInt i, VInt j) -> pure (VInt (op o i j))
        _ -> bindInt (primL o (int x) (int y))
    If0 c a b -> do
      cv <- eval c env
      case cv of
        VInt 0 -> eval a env
        VInt _ -> eval b env
        -- the code after the conditional is a join point, and the branches
        -- are in tail position (they return to the join point)
        VDyn _ x -> joinInt (\ ret -> ifInt x (evalT a env ret) (evalT b env ret)) >>= newDyn
        VClo _ _ _ -> error "peval: if0 on a function"

-- Evaluate a term in tail position: its value is passed to ret (the return
-- of a function, or a join point).  A conditional needs no join point of its
-- own, and a call of a recursive function is a tail call.
evalT :: MonadPE m => Term -> Env -> (Low Int -> m End) -> m End
evalT t env ret =
  case t of
    If0 c a b -> do
      cv <- eval c env
      case cv of
        VInt 0 -> evalT a env ret
        VInt _ -> evalT b env ret
        VDyn _ x -> ifInt x (evalT a env ret) (evalT b env ret)
        VClo _ _ _ -> error "peval: if0 on a function"
    App f l a -> do
      fv <- eval f env
      e <- argument fv l a env
      name <- funName f
      applyT name fv e ret
    _ -> do
      v <- eval t env
      ret (int v)

-- The name of a function, for the generated code
funName :: MonadPE m => Term -> m String
funName t =
  case t of
    Var x -> do { c <- askCtx; pure (nameOf (ctxNames c) x) }
    _ -> pure "f"

-- The argument of an application: shared if it is a variable, a value if it
-- is one, evaluated now if the function is strict, and a thunk otherwise
argument :: MonadPE m => V -> Id -> Term -> Env -> m E
argument fv l a env =
  case a of
    Var x -> pure (look x env)
    Lam _ _ -> EVal <$> eval a env
    Lit n -> pure (EVal (VInt n))
    _ -> case fv of
           VClo x b _ | strict b x -> EVal <$> eval a env
           _ -> pure (EThk l a (restrict (used a) env))

-- Use an environment entry: evaluate a thunk the first time on this path
force :: MonadPE m => E -> m V
force e =
  case e of
    EVal v -> pure v
    EThk _ t env -> do
      let key = shapeE id e
      s <- getGS
      let GS _ m _ _ = s
      case lookup key m of
        Just v -> pure v
        Nothing -> do
          v <- eval t env
          modifyGS (\ (GS i m' fs as) -> GS i ((key, v) : m') fs as)
          pure v

-- What applying a closure does
data Call = Known Fn [Low Int]               -- call a recursive function
          | Define String (Sh ()) [Low Int]   -- define one, then call it
          | Again (Sh ())                     -- a recursive application
          | Unfold (Sh ()) Term Env           -- unfold the closure

-- Apply a closure to an argument: call (and first define) the recursive
-- function of its shape, or unfold it
call :: MonadPE m => V -> E -> m Call
call fv a =
  case fv of
    VClo x b cenv -> do
      let benv = restrict (used b) ((x, a) : cenv)
          key = SClo x (shapeEnv (const ()) benv)
          ps = dynsEnv benv
      s <- getGS
      c <- askCtx
      let GS _ _ fs as = s
      pure $ case lookup key fs of
        Just fn -> Known fn ps
        Nothing
          | Just fname <- lookup key (ctxRecs c) -> Define fname key ps
          | key `elem` as -> Again key
          | otherwise -> Unfold key b benv
    _ -> error "peval: applying an integer"

apply :: MonadPE m => String -> V -> E -> m V
apply name fv a = do
  cl <- call fv a
  case cl of
    Known fn ps -> bindInt (callFn fn ps)
    Define fname key ps -> do
      fn <- define fname key fv a
      bindInt (callFn fn ps)
    Again key -> do
      recCall key name
      newDyn (lowInt 0)
    Unfold key b benv -> do
      as <- unfolding key
      v <- eval b benv
      modifyGS (\ (GS i m fs _) -> GS i m fs as)
      pure v

applyT :: MonadPE m => String -> V -> E -> (Low Int -> m End) -> m End
applyT name fv a ret = do
  cl <- call fv a
  case cl of
    Known fn ps -> ret (callFn fn ps)
    Define fname key ps -> do
      fn <- define fname key fv a
      ret (callFn fn ps)
    Again key -> do
      recCall key name
      ret (lowInt 0)
    Unfold key b benv -> do
      _ <- unfolding key
      evalT b benv ret

-- Start unfolding an application, returning the applications unfolded before
unfolding :: MonadPE m => Sh () -> m [Sh ()]
unfolding key = do
  s <- getGS
  let GS i m fs as = s
  putGS (GS i m fs (key : as))
  pure as

-- Define the recursive function of a shape: its body is the closure's body
-- with the run time integers of the environment as arguments
define :: MonadPE m => String -> Sh () -> V -> E -> m Fn
define name key fv a =
  case fv of
    VClo x b cenv -> do
      c <- askCtx
      s <- getGS
      let benv = restrict (used b) ((x, a) : cenv)
          ss = shapeEnv (const ()) benv
          GS i _ fs as = s
      fn <- recFun name (dynNamesEnv (ctxNames c) benv) (length (dynsEnv benv)) $ \ fn ps -> do
              let (benv', _, i1) = rebuild (ctxCode c) ss ps i
              putGS (GS i1 [] ((key, fn) : fs) as)
              evalT b benv' done
      modifyGS (\ (GS i' m fs' as') -> GS i' m ((key, fn) : fs') as')
      pure fn
    _ -> error "peval: applying an integer"

op :: Op -> Int -> Int -> Int
op o i j = case o of { Plus -> i + j; Minus -> i - j; Times -> i * j }

primL :: Op -> Low Int -> Low Int -> Low Int
primL o x y =
  case o of
    Plus  -> [| ~x + ~y |]
    Minus -> [| ~x - ~y |]
    Times -> [| ~x * ~y |]

-------------------------------------------------------------------------------
-- The projections

-- Find the shapes of the recursive functions: run the analysis until it
-- finds no new ones
recursive :: (Ctx -> [(Sh (), String)]) -> [(Id, Term)] -> [(Id, String)] -> [(Sh (), String)]
recursive run tbl names = go []
  where go recs = let new = [ r | r@(key, _) <- run (Ctx recs tbl names), key `notElem` map fst recs ] in
                  if null new then recs else go (recs ++ nubBy (\ p q -> fst p == fst q) new)

-- A program whose value is an integer
startInt :: MonadPE m => Term -> m End
startInt t = evalT t [] done

evalInt :: Fresh Term -> Low Int
evalInt p =
  let (t, names) = runFresh p
      tbl = codes t
      gs0 = GS 0 [] [] []
      recs = recursive (\ c -> analyse (startInt t) c gs0) tbl names
  in  genCode (startInt t) (Ctx recs tbl names) gs0

-- A program whose value is a function of an integer
startFun :: MonadPE m => Term -> Low Int -> m End
startFun t n = do
  f <- eval t []
  applyT "f" f (EVal (VDyn 0 n)) done

evalFun :: Fresh Term -> Low (Int -> Int)
evalFun p =
  let (t, names) = runFresh p
      tbl = codes t
      gs1 = GS 1 [] [] []
      recs = recursive (\ c -> analyse (startFun t dummy) c gs1) tbl names
  in  [| \ n -> ~(genCode (startFun t [| n |]) (Ctx recs tbl names) gs1) |]

-------------------------------------------------------------------------------
-- Building terms: lam gives its body the variable it binds

type T = Fresh Term

lam :: String -> (T -> T) -> T
lam x f = do
  i <- fresh x
  b <- f (pure (Var i))
  pure (Lam i b)

infixl 9 .@
infixl 6 .+, .-
infixl 7 .*

(.@) :: T -> T -> T
f .@ a = do
  f' <- f
  a' <- a
  l <- fresh "arg"
  pure (App f' l a')

(.+), (.-), (.*) :: T -> T -> T
a .+ b = Prim Plus <$> a <*> b
a .- b = Prim Minus <$> a <*> b
a .* b = Prim Times <$> a <*> b

lit :: Int -> T
lit n = pure (Lit n)

ifz :: T -> T -> T -> T
ifz c a b = If0 <$> c <*> a <*> b

-- Build a term once and use it more than once, with the same ids
share :: T -> (T -> T) -> T
share m k = m >>= k . pure

omega :: T
omega = share (lam "x" $ \ x -> x .@ x) $ \ w -> w .@ w

church :: Int -> T
church n = lam "f" $ \ f -> lam "x" $ \ x -> iterate (f .@) x !! n

timesC, toInt :: T
timesC = lam "m" $ \ m -> lam "n" $ \ n -> lam "f" $ \ f -> m .@ (n .@ f)
toInt  = lam "c" $ \ c -> c .@ lam "k" (\ k -> k .+ lit 1) .@ lit 0

-- The (lazy) fixed point combinator Y, which loops under call by value
fixY :: T
fixY = lam "f" $ \ f -> share (lam "x" $ \ x -> f .@ (x .@ x)) $ \ w -> w .@ w

factorial, fibonacci, spin :: T
factorial = fixY .@ lam "fact" (\ fact -> lam "n" $ \ n -> ifz n (lit 1) (n .* (fact .@ (n .- lit 1))))
fibonacci = fixY .@ lam "fib" (\ fib -> lam "n" $ \ n ->
              ifz n (lit 0)
                (ifz (n .- lit 1) (lit 1)
                  (fib .@ (n .- lit 1) .+ fib .@ (n .- lit 2))))
spin = fixY .@ lam "f" (\ f -> lam "m" $ \ m -> f .@ m)         -- never returns

-- Compiled programs
pfactorial :: Low (Int -> Int)
pfactorial = evalFun factorial

pfibonacci :: Low (Int -> Int)
pfibonacci = evalFun fibonacci

-- call by need: x is only needed when the input is not 0, and then only once
pneed :: Low (Int -> Int)
pneed = evalFun (lam "input" $ \ input -> lam "x" (\ x -> ifz input (lit 0) (x .+ x)) .@ (spin .@ input))

-- sharing: the argument is evaluated once
pshare :: Low (Int -> Int)
pshare = evalFun (lam "input" $ \ input -> lam "x" (\ x -> x .+ x .+ x .+ x) .@ (fibonacci .@ input))

-- Factorial written by hand in low code, for comparison
handFactorial :: Low (Int -> Int)
handFactorial = [| \ n -> let go m = if m == 0 then 1 else m * go (m - 1) in go n |]

-- Run time code: the compiled programs are spliced in.
factorialC, fibonacciC, needC, shareC :: Int -> Int
factorialC = pfactorial
fibonacciC = pfibonacci
needC = pneed
shareC = pshare

factorial10C, churchC, lazyC :: Int
factorial10C = evalInt (factorial .@ lit 10)
churchC = evalInt (toInt .@ (timesC .@ church 6 .@ church 7))
lazyC = evalInt (lam "x" (\ _ -> lit 42) .@ omega)

main :: IO ()
main = do
  putStrLn "---- pfactorial = evalFun factorial, reflected"
  putStr (lowString (lowPretty (reflect pfactorial)))
  putStrLn "---- pfactorial, C"
  putStr (lowString (toC "pfactorial" (reflect pfactorial)))
  putStrLn "---- factorial written by hand in low code, reflected"
  putStr (lowString (lowPretty (reflect handFactorial)))
  putStrLn "---- factorial written by hand in low code, C"
  putStr (lowString (toC "factorial" (reflect handFactorial)))
  putStrLn "---- pfibonacci, reflected"
  putStr (lowString (lowPretty (reflect pfibonacci)))
  putStrLn "---- \\ input -> (\\ x -> if0 input then 0 else x + x) (spin input), reflected"
  putStr (lowString (lowPretty (reflect pneed)))
  putStrLn "---- \\ input -> (\\ x -> x + x + x + x) (fib input), reflected"
  putStr (lowString (lowPretty (reflect pshare)))
  putStrLn "---- factorial 10, 6 * 7 (Church), (\\ x -> 42) omega: computed by the compiler"
  putStr (lowString (lowPretty (reflect (evalInt (factorial .@ lit 10)))))
  putStr (lowString (lowPretty (reflect (evalInt (toInt .@ (timesC .@ church 6 .@ church 7))))))
  putStr (lowString (lowPretty (reflect (evalInt (lam "x" (\ _ -> lit 42) .@ omega)))))
  putStrLn "---- run"
  print (map factorialC [0, 1, 5, 10, 12])        -- 12! is the largest that fits a 32 bit Int
  print (map fibonacciC [0, 1, 2, 15])
  print (needC 0, shareC 15)
  print (factorial10C, churchC, lazyC)
