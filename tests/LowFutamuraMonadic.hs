module LowFutamuraMonadic(main) where
import Data.Char(isAlpha, isAlphaNum, isDigit, isSpace)
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
--
--  * A small parser for terms (at the end), so that the examples can be
--    written as text, e.g. fix (\ fact n -> if0 n then 1 else n * fact (n - 1)).
--
-- The parts: terms; compile time values (V, E) and their shapes (Sh, ShE);
-- the partial evaluation monads, with the state along a path (GS), the
-- context (Ctx), and the analysis; the interpreter; the projections; the
-- parser and the examples.

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

-- Shapes
--
-- The shape of a value is the part of it that is known at compile time,
-- without the terms: a closure is its binder (which names its body, since
-- ids are unique) and the shapes of the entries it captures, a thunk is its
-- label and the shapes of its entries.  Shapes can be compared, unlike
-- values, which contain code; they are the keys of two tables:
--
--  * Sh Int, where a run time integer is the number of its VDyn, is the key
--    of a thunk forced on a path (gsForced): forcing an equal thunk again
--    (the same code, with the same compile time values and the same run time
--    integers) reuses the value, which is call by need.
--
--  * Sh (), where all run time integers are the same, is the key of an
--    application: a closure with its argument (see call).  It is what a
--    specialised function knows statically; the run time integers are the
--    arguments of the function.  So all the applications fact (n - 1) of
--    factorial have the same key, and the compiler finds the recursion when
--    it unfolds an application with a key it is already unfolding.
--    Integers known at compile time are part of the key, so the function is
--    specialised to them (the power example).
data Sh d = SInt Int                   -- an integer known at compile time
          | SDyn d                     -- a run time integer
          | SClo Id [(Id, ShE d)]      -- a closure: its binder, and its environment
  deriving (Eq)
data ShE d = SVal (Sh d)               -- a value
           | SThk Id [(Id, ShE d)]     -- a thunk: its label, and its environment
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

-- Rebuilding an environment from its shape
--
-- The body of a recursive function is evaluated once, for all the
-- applications of its key, so it cannot use the environment of the
-- application that defined it: its run time integers are that call's
-- arguments.  rebuild makes the environment that the body is evaluated in,
-- from the shape (Sh ()) of the closure's environment and the parameters of
-- the function:
--
--  * a known integer (SInt) is itself;
--  * a run time integer (SDyn) is the next parameter, with a new number for
--    its VDyn (the third argument and result: the next number);
--  * a closure or a thunk is rebuilt from its label, and its term looked up
--    in the table of codes (shapes have no terms), with its environment
--    rebuilt recursively.
--
-- The parameters are used in the order of dynsEnv (depth first, left to
-- right), which is the order of the arguments that a call passes, and of the
-- names that dynNamesEnv gives them.  rebuild returns the environment, the
-- unused parameters, and the next number; rebuildE does the same for an
-- entry.
rebuild ::[(Id, Term)] -> [(Id, ShE ())] -> [Low Int] -> Int -> (Env, [Low Int], Int)
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

-- The generation state, GS
--
-- What the compiler knows at a point of the generated code.  It is threaded
-- along a path of the program (a sequence of lets): the monads pass it to
-- the continuation, and both branches of a conditional start with the state
-- before it, so what one branch learns is not used in the other, or after
-- the join point.
data GS = GS
  { gsNext      :: Int             -- the number of the next run time integer (VDyn)
  , gsForced    :: [(ShE Int, V)]  -- the thunks forced on this path, with their values:
                                   -- the variables of the generated code that hold them
  , gsFns       :: [(Sh (), Fn)]   -- the recursive functions in scope, by key: defined
                                   -- before this point (or the one whose body this is)
  , gsUnfolding :: [Sh ()]         -- the keys of the applications being unfolded here;
                                   -- unfolding one of them again is a recursive application
  }

-- The state at the start of a program, numbering run time integers from i
initGS :: Int -> GS
initGS i = GS{ gsNext = i, gsForced = [], gsFns = [], gsUnfolding = [] }

-- The context, Ctx
--
-- What is fixed for the whole program.  ctxRecs is the result of the
-- analysis (see the projections): the keys of the applications that are
-- recursive, which the code generator compiles to recursive functions
-- instead of unfolding them.  Its name is the name of the variable the
-- function is called through (fact in factorial), for the generated code.
data Ctx = Ctx
  { ctxRecs  :: [(Sh (), String)]  -- the recursive applications, with a name for their function
  , ctxCode  :: [(Id, Term)]       -- the terms of the labels, for rebuild
  , ctxNames :: [(Id, String)]     -- the source names of the ids, for the generated code
  }

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

-- The analysis
--
-- The code generator works in one pass, in continuation passing style: when
-- it meets an application, it must decide there whether to unfold it or to
-- define a recursive function (a letrec around the code that follows).  But
-- recursion only shows later, deeper in the unfolding, when the same key
-- comes up again, and the code that would have to become a function is then
-- already generated.  So the compiler runs the interpreter twice: first as
-- the analysis, which finds the keys of the recursive applications, and then
-- as the code generator, which knows them (ctxRecs) from the start.
--
-- The analysis is the same interpreter in a monad that generates no code:
-- a let gives a dummy run time integer, a conditional runs both branches,
-- a join point runs both the code after it and the block before it, and a
-- recursive function runs its body.  Its result is the list of the keys of
-- the recursive applications it met (recCall), with the name of the
-- function.  It is run until it finds nothing new (see recursive), since a
-- function body is evaluated in an environment rebuilt from a shape, where
-- other applications can have new keys.
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
  putGS s{ gsNext = gsNext s + 1 }
  pure (VDyn (gsNext s) x)

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
    App f _ _ -> funName f            -- the head of an application of more arguments
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
      case lookup key (gsForced s) of
        Just v -> pure v
        Nothing -> do
          v <- eval t env
          modifyGS (\ s' -> s'{ gsForced = (key, v) : gsForced s' })
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
      pure $ case lookup key (gsFns s) of
        Just fn -> Known fn ps
        Nothing
          | Just fname <- lookup key (ctxRecs c) -> Define fname key ps
          | key `elem` gsUnfolding s -> Again key
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
      modifyGS (\ s -> s{ gsUnfolding = as })
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
  putGS s{ gsUnfolding = key : gsUnfolding s }
  pure (gsUnfolding s)

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
      fn <- recFun name (dynNamesEnv (ctxNames c) benv) (length (dynsEnv benv)) $ \ fn ps -> do
              -- the body: nothing is forced yet, and the function itself is in scope
              let (benv', _, i1) = rebuild (ctxCode c) ss ps (gsNext s)
              putGS s{ gsNext = i1, gsForced = [], gsFns = (key, fn) : gsFns s }
              evalT b benv' done
      modifyGS (\ s' -> s'{ gsFns = (key, fn) : gsFns s' })
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

-- Find the keys of the recursive applications: run the analysis, with the
-- ones found so far, until it finds no new ones
recursive :: (Ctx -> [(Sh (), String)]) -> [(Id, Term)] -> [(Id, String)] -> [(Sh (), String)]
recursive run tbl names = go []
  where go recs = let ctx = Ctx{ ctxRecs = recs, ctxCode = tbl, ctxNames = names }
                      new = [ r | r@(key, _) <- run ctx, key `notElem` map fst recs ] in
                  if null new then recs else go (recs ++ nubBy (\ p q -> fst p == fst q) new)

-- A program whose value is an integer
startInt :: MonadPE m => Term -> m End
startInt t = evalT t [] done

evalInt :: Fresh Term -> Low Int
evalInt p =
  let (t, names) = runFresh p
      tbl = codes t
      recs = recursive (\ c -> analyse (startInt t) c (initGS 0)) tbl names
  in  genCode (startInt t) Ctx{ ctxRecs = recs, ctxCode = tbl, ctxNames = names } (initGS 0)

-- A program whose value is a function of an integer
startFun :: MonadPE m => Term -> Low Int -> m End
startFun t n = do
  f <- eval t []
  applyT "f" f (EVal (VDyn 0 n)) done

evalFun :: Fresh Term -> Low (Int -> Int)
evalFun p =
  let (t, names) = runFresh p
      tbl = codes t
      recs = recursive (\ c -> analyse (startFun t dummy) c (initGS 1)) tbl names
  in  [| \ n -> ~(genCode (startFun t [| n |]) Ctx{ ctxRecs = recs, ctxCode = tbl, ctxNames = names } (initGS 1)) |]

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

-------------------------------------------------------------------------------
-- A parser for terms, for writing examples
--
--   e ::= \ x1 .. xn -> e             a lambda (of n arguments)
--       | if0 e then e else e         a conditional on zero
--       | let x = e in e              sharing: the term is built once, and is
--                                     the same term (with the same ids) where
--                                     x is used; it is not recursive
--       | e + e | e - e | e * e       arithmetic (* binds tighter; left associative)
--       | e e                         an application (binds tightest)
--       | x | n | ( e )
--
-- A definition is x = e.  A defined name is a macro: each use of it builds
-- the term again, with new ids, like a Haskell definition of type T (let
-- does not copy).  The parser builds a T (with the builders above) from the
-- scope: the defined names and the bound variables.

type Scope = [(String, T)]

-- A parser of a term: the term (in a scope), and the tokens after it
type Parse = [String] -> (Scope -> T, [String])

tokens :: String -> [String]
tokens s =
  case s of
    [] -> []
    c : cs
      | isSpace c -> tokens cs
      | isAlpha c || c == '_' -> let (w, r) = span (\ d -> isAlphaNum d || d == '_' || d == '\'') s in w : tokens r
      | isDigit c -> let (w, r) = span isDigit s in w : tokens r
      | c == '-', '>' : r <- cs -> "->" : tokens r
      | otherwise -> [c] : tokens cs

keywords :: [String]
keywords = ["if0", "then", "else", "let", "in"]

isName :: String -> Bool
isName t = case t of
             c : _ -> (isAlpha c || c == '_') && t `notElem` keywords
             _ -> False

isNumber :: String -> Bool
isNumber t = not (null t) && all isDigit t

parseError :: String -> [String] -> a
parseError msg ts = error ("parse error: " ++ msg ++ ", at: " ++ unwords (take 8 ts))

expect :: String -> [String] -> [String]
expect t ts =
  case ts of
    t' : ts' | t' == t -> ts'
    _ -> parseError ("expected " ++ t) ts

pExpr :: Parse
pExpr ts =
  case ts of
    "\\" : ts1 ->
      let (xs, ts2) = span isName ts1
          (b, ts3) = pExpr (expect "->" ts2)
      in  if null xs then parseError "expected a variable" ts1 else (\ sc -> lams xs b sc, ts3)
    "if0" : ts1 ->
      let (c, ts2) = pExpr ts1
          (a, ts3) = pExpr (expect "then" ts2)
          (b, ts4) = pExpr (expect "else" ts3)
      in  (\ sc -> ifz (c sc) (a sc) (b sc), ts4)
    "let" : x : "=" : ts1 | isName x ->
      let (e, ts2) = pExpr ts1
          (b, ts3) = pExpr (expect "in" ts2)
      in  (\ sc -> share (e sc) (\ v -> b ((x, v) : sc)), ts3)
    _ -> pLeft ["+", "-"] (pLeft ["*"] pApp) ts
  where lams xs b sc = case xs of
                         [] -> b sc
                         x : xs' -> lam x (\ v -> lams xs' b ((x, v) : sc))

-- Left associative operators over the terms of p
pLeft :: [String] -> Parse -> Parse
pLeft ops p ts0 = let (a, ts1) = p ts0 in go a ts1
  where go a ts = case ts of
                    o : ts' | o `elem` ops -> let (b, ts'') = p ts' in go (\ sc -> binop o (a sc) (b sc)) ts''
                    _ -> (a, ts)
        binop o = case o of { "+" -> (.+); "-" -> (.-); _ -> (.*) }

pApp :: Parse
pApp ts0 = let (f, ts1) = pAtom ts0 in go f ts1
  where go f ts = case ts of
                    t : _ | isName t || isNumber t || t == "(" -> let (a, ts') = pAtom ts in go (\ sc -> f sc .@ a sc) ts'
                    _ -> (f, ts)

pAtom :: Parse
pAtom ts =
  case ts of
    "(" : ts1 -> let (e, ts2) = pExpr ts1 in (e, expect ")" ts2)
    t : ts1 | isNumber t -> (\ _ -> lit (read t), ts1)
            | isName t -> (\ sc -> fromMaybe (error ("unbound variable " ++ t)) (lookup t sc), ts1)
    _ -> parseError "expected a term" ts

-- A term, with the given definitions in scope
parseTerm :: Scope -> String -> T
parseTerm sc s =
  case pExpr (tokens s) of
    (e, []) -> e sc
    (_, ts) -> parseError "unexpected tokens" ts

-- Definitions, each with the ones before it in scope
defs :: [String] -> Scope
defs = foldl def []
  where def sc d = case tokens d of
                     x : "=" : ts | isName x -> (x, parseTerm sc (unwords ts)) : sc
                     ts -> parseError "expected a definition x = e" ts

-------------------------------------------------------------------------------
-- Examples

-- The Church numeral n: \ f x -> f (f (... x))
church :: Int -> String
church n = "\\ f x -> " ++ concat (replicate n "f (") ++ "x" ++ replicate n ')'

examples :: Scope
examples = defs
  [ -- the (lazy) fixed point combinator Y, which loops under call by value;
    -- let shares \ x -> f (x x), so both of its copies have the same ids
    "fix = \\ f -> let w = \\ x -> f (x x) in w w"
  , "factorial = fix (\\ fact n -> if0 n then 1 else n * fact (n - 1))"
  , "fibonacci = fix (\\ fib n -> if0 n then 0 else if0 n - 1 then 1 else fib (n - 1) + fib (n - 2))"
  , "spin = fix (\\ f m -> f m)"                                     -- never returns
  , "power = fix (\\ power b e -> if0 e then 1 else b * power b (e - 1))"
  , "omega = let w = \\ x -> x x in w w"
  , "times = \\ m n f -> m (n f)"                                    -- Church numerals
  , "toInt = \\ c -> c (\\ k -> k + 1) 0"
  , "six = " ++ church 6
  , "seven = " ++ church 7
  ]

term :: String -> T
term = parseTerm examples

-- Compiled programs
pfactorial :: Low (Int -> Int)
pfactorial = evalFun (term "factorial")

pfibonacci :: Low (Int -> Int)
pfibonacci = evalFun (term "fibonacci")

-- call by need: x is only needed when the input is not 0, and then only once
pneed :: Low (Int -> Int)
pneed = evalFun (term "\\ input -> (\\ x -> if0 input then 0 else x + x) (spin input)")

-- sharing: the argument is evaluated once
pshare :: Low (Int -> Int)
pshare = evalFun (term "\\ input -> (\\ x -> x + x + x + x) (fibonacci input)")

-- specialisation: power is specialised to the base 2, which is known at
-- compile time (it is part of the key of the recursive application)
ppower :: Low (Int -> Int)
ppower = evalFun (term "\\ n -> power 2 n")

-- Factorial written by hand in low code, for comparison
handFactorial :: Low (Int -> Int)
handFactorial = [| \ n -> let go m = if m == 0 then 1 else m * go (m - 1) in go n |]

-- Run time code: the compiled programs are spliced in.
factorialC, fibonacciC, needC, shareC, powerC :: Int -> Int
factorialC = pfactorial
fibonacciC = pfibonacci
needC = pneed
shareC = pshare
powerC = ppower

factorial10C, churchC, lazyC :: Int
factorial10C = evalInt (term "factorial 10")
churchC = evalInt (term "toInt (times six seven)")
lazyC = evalInt (term "(\\ x -> 42) omega")

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
  putStrLn "---- \\ input -> (\\ x -> x + x + x + x) (fibonacci input), reflected"
  putStr (lowString (lowPretty (reflect pshare)))
  putStrLn "---- \\ n -> power 2 n, reflected"
  putStr (lowString (lowPretty (reflect ppower)))
  putStrLn "---- factorial 10, toInt (times six seven), (\\ x -> 42) omega: computed by the compiler"
  putStr (lowString (lowPretty (reflect (evalInt (term "factorial 10")))))
  putStr (lowString (lowPretty (reflect (evalInt (term "toInt (times six seven)")))))
  putStr (lowString (lowPretty (reflect (evalInt (term "(\\ x -> 42) omega")))))
  putStrLn "---- run"
  print (map factorialC [0, 1, 5, 10, 12])        -- 12! is the largest that fits a 32 bit Int
  print (map fibonacciC [0, 1, 2, 15])
  print (needC 0, shareC 15)
  print (map powerC [0, 1, 10, 20])
  print (factorial10C, churchC, lazyC)
