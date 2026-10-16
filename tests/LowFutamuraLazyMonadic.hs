module LowFutamuraLazyMonadic(main) where
import Data.Char(isAlpha, isAlphaNum, isDigit, isSpace)
import Data.List(nub)
import Data.Maybe(fromMaybe, isJust)
import Staged.Low
import LowCompactC(toCompactC)

-- The first Futamura projection of tests/LowFutamuraLazy.hs (lazy lists,
-- call by need, a heap of cells at run time), written in the style of
-- tests/LowFutamuraMonadic.hs:
--
--  * One term type.  Every binder, application argument, and constructor
--    field gets a globally unique id from a name supply when the program is
--    built; environments map ids to entries.  The id of a binder labels the
--    code bound to it (a lambda body, or a letrec binding).
--
--  * A monadic interpreter, written once against the class MonadPE, whose
--    methods are the ways the compiler uses code; the heap (Low St) is part
--    of the monad's state, so the methods thread it.  The code generator and
--    the analysis (which finds the recursive functions and the code of the
--    thunks) are its two instances.
--
--  * A small parser for terms (at the end), so that the examples can be
--    written as text, e.g. letrec nats = 0 : map (\ x -> x + 1) nats in ...
--
-- The parts: the language; the run time data; compile time values (V, E),
-- their shapes (Sh, ShE), abstracting them (absEnv) and the keys of
-- applications (recKey); the items of the analysis and the run time system
-- (Rt); the partial evaluation monads, with the state along a path (GS) and
-- the context (Ctx); the interpreter; compiling a program, with the
-- analysis; the parser and the examples.

-------------------------------------------------------------------------------
-- The language

type Id = Int

-- In Case s n h t c, h and t bind the head and the tail of a Cons in c.  In
-- Letrec x b body, x is bound in both b and body.
data Term = Var Id | Lam Id Term | App Term Id Term     -- the Id of App labels the argument
          | Lit Int | Prim Op Term Term | If0 Term Term Term
          | Nil | Cons Id Term Id Term                  -- the Ids label the fields
          | Case Term Term Id Id Term
          | Letrec Id Term Term

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

runFresh :: Fresh a -> (a, [(Id, String)])
runFresh m = case runF m 0 of (a, _, ns) -> (a, ns)

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

-- The code of the labels: lambda bodies, letrec bindings, application
-- arguments, and constructor fields
codes :: Term -> [(Id, Term)]
codes t =
  case t of
    Var _ -> []
    Lam x b -> (x, b) : codes b
    App f l a -> (l, a) : codes f ++ codes a
    Lit _ -> []
    Prim _ a b -> codes a ++ codes b
    If0 c a b -> codes c ++ codes a ++ codes b
    Nil -> []
    Cons lh h lr r -> (lh, h) : (lr, r) : codes h ++ codes r
    Case s n _ _ c -> codes s ++ codes n ++ codes c
    Letrec x b body -> (x, b) : codes b ++ codes body

code :: [(Id, Term)] -> Id -> Term
code tbl l = fromMaybe (error "peval: label") (lookup l tbl)

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
    Nil -> []
    Cons _ h _ r -> free h ++ free r
    Case s n h tl c -> free s ++ free n ++ filter (`notElem` [h, tl]) (free c)
    Letrec x b body -> filter (/= x) (free b ++ free body)

used :: Term -> [Id]
used = nub . free

-- An application spine: the function and the arguments
spine :: Term -> (Term, [(Id, Term)])
spine t = go t []
  where go u acc = case u of
                     App f l a -> go f ((l, a) : acc)
                     _ -> (u, acc)

-- Is a closure body strict in its argument x, when r more arguments follow
-- (so its inner lambdas are applied too)?
strictIn :: Term -> Id -> Int -> Bool
strictIn b x r = strict b x || (r > 0 && case b of
                                           Lam _ b' -> strictIn b' x (r - 1)
                                           _ -> False)

-- Does a term always use variable x?
strict :: Term -> Id -> Bool
strict t x =
  case t of
    Var y -> y == x
    App f _ _ -> strict f x
    Prim _ a b -> strict a x || strict b x
    If0 c a b -> strict c x || (strict a x && strict b x)
    Case s n _ _ c -> strict s x || (strict n x && strict c x)
    Letrec _ _ body -> strict body x
    _ -> False

-- Compile time values, V
--
-- What the compiler knows about the value of a term.  Integers and closures
-- can be known at compile time; a list only exists at run time (it is in
-- the heap), so a list, or any value that comes from the heap or from a
-- call, is a run time value (RV) in the generated code.  The Int of a run
-- time integer or value is a number that identifies it, so that forcing the
-- same thing twice on a path can be recognised (see keyE).
data V = VInt Int                -- an integer known at compile time
       | VDyn Int (Low Int)      -- a run time integer: a variable of the generated code
       | VRV Int (Low RV)        -- a run time value in weak head normal form (RInt, RNil
                                 -- or RCons): from a cell, a constructor, or a call
       | VClo Id Term Env        -- a closure: its binder, its body, and the entries of the
                                 -- variables it uses (as in closure conversion)

-- Environment entries, E
--
-- A variable is bound to an entry, which is evaluated when the variable is
-- used (call by need).  There are two kinds of delayed computation:
--
--  * a compile time thunk (EThk) is evaluated by the compiler, inline, the
--    first time it is used on a path of the generated code, which costs
--    nothing at run time.  It can only be used where the compiler sees all
--    its uses: as the argument of an application that is unfolded.
--
--  * a run time cell (ERef) is a heap address, whose cell holds a run time
--    thunk (the number of its code, and its captures) or a value.  A thunk
--    that escapes, into a constructor field or the argument of a recursive
--    function (whose calls are made at run time), is allocated in a cell
--    (thunkCell, reify); forcing a cell is a call of rt at run time.
--
-- A letrec bound lambda is an EFix, which unfolds to a closure that has
-- itself in its environment.
data E = EVal V                  -- a value
       | EThk Id Term Env        -- a compile time thunk: its label, term, and the entries
                                 -- of the variables it uses
       | ERef Int (Low Int)      -- a run time cell: a number that identifies it, and its address
       | EFix Id Term Env        -- a recursive function: its binder, the lambda, and the
                                 -- entries of the other variables it uses

type Env = [(Id, E)]

look :: Id -> Env -> E
look x env = fromMaybe (error ("peval: unbound " ++ show x)) (lookup x env)

-- The entries of the given variables
restrict :: [Id] -> Env -> Env
restrict xs env = [ (x, e) | x <- xs, Just e <- [lookup x env] ]

-- Shapes, Sh and ShE
--
-- The shape of a value or an entry is what is known about it at compile
-- time, without the terms: closures, thunks and recursive functions are
-- their labels (which name their code, since ids are unique) and the shapes
-- of their environments.  Shapes can be compared, unlike values (which
-- contain code), so they are the keys of the compiler's tables.  The
-- parameter d is what a shape records of a run time integer, value, or cell:
--
--  * ShE Int (keyE) identifies them by their numbers.  It is the key of what
--    was forced on a path (gsForced): forcing the same thunk or cell again
--    reuses the value.
--
--  * ShE () (absE) abstracts them: all run time integers are the same.  It
--    is the key of a recursive function, or of the code of a run time thunk,
--    whose run time values are parameters (see absEnv).
data Sh d = SInt Int                   -- an integer known at compile time
          | SDyn d                     -- a run time integer
          | SRV d                      -- a run time value
          | SClo Id [(Id, ShE d)]      -- a closure: its binder, and its environment
  deriving (Eq)
data ShE d = SVal (Sh d)               -- a value
           | SThk Id [(Id, ShE d)]     -- a compile time thunk: its label, and its environment
           | SRef d                    -- a run time cell
           | SFix Id [(Id, ShE d)]     -- a recursive function: its binder, and its environment
  deriving (Eq)

-- The identifying shape of an entry
keyE :: E -> ShE Int
keyE e =
  case e of
    EVal v -> SVal (keyV v)
    EThk l _ env -> SThk l (keyEnv env)
    ERef i _ -> SRef i
    EFix x _ env -> SFix x (keyEnv env)
  where
    keyV v = case v of
               VInt n -> SInt n
               VDyn i _ -> SDyn i
               VRV i _ -> SRV i
               VClo x _ env -> SClo x (keyEnv env)
    keyEnv env = [ (x, keyE e') | (x, e') <- env ]

-- Abstracting an environment: absEnv and absE
--
-- Code that is generated once and used in many places sees an environment
-- only through its shape; the run time parts are passed to it.  absEnv
-- splits an environment into its abstract shape (ShE ()) and the list of its
-- run time parts, as Ints: run time integers, and the addresses of cells.
-- The list is in depth first, left to right order, the order in which
-- rebuild takes them back (and absNames names them).  It is used for two
-- kinds of code:
--
--  * a recursive function (g = False): the list is the arguments of a call.
--    Integers known at compile time stay in the shape (SInt), so the
--    function is specialised to them.
--
--  * the code of a run time thunk (g = True): the list is the captures that
--    the thunk cell stores (Ints).  Known integers are captured too (as
--    SDyn), so the code does not depend on them: the thunks of n - 1 for
--    n = 3, 2, 1, ... share one code.
--
-- A run time value (VRV) is a boxed RV, not an Int, so it must be put in a
-- cell first (norm) and is then a cell address.  absE does this for one
-- entry: its abstract shape, and its run time parts.
absEnv :: Bool -> Env -> ([(Id, ShE ())], [Low Int])
absEnv g env =
  let xs = [ (x, absE g e) | (x, e) <- env ]
  in  ([ (x, s) | (x, (s, _)) <- xs ], concatMap (snd . snd) xs)

absE :: Bool -> E -> (ShE (), [Low Int])
absE g e =
  case e of
    EVal v -> let (s, cs) = absV v in (SVal s, cs)
    EThk l _ env' -> let (ss, cs) = absEnv g env' in (SThk l ss, cs)
    ERef _ a -> (SRef (), [a])
    EFix x _ env' -> let (ss, cs) = absEnv g env' in (SFix x ss, cs)
  where
    absV v = case v of
      VInt n -> if g then (SDyn (), [lowInt n]) else (SInt n, [])
      VDyn _ x -> (SDyn (), [x])
      VRV _ _ -> error "absEnv: a run time value not in a cell"
      VClo x _ env' -> let (ss, cs) = absEnv g env' in (SClo x ss, cs)

-- The names of the run time values of an environment (as absEnv False finds
-- them), after the variables they come from
absNames :: [(Id, String)] -> Env -> [String]
absNames names env = concat [ absNamesE names x e | (x, e) <- env ]

absNamesE :: [(Id, String)] -> Id -> E -> [String]
absNamesE names x e =
  case e of
    EVal (VDyn _ _) -> [nameOf names x]
    EVal (VClo _ _ env') -> absNames names env'
    EVal _ -> []
    EThk _ _ env' -> absNames names env'
    ERef _ _ -> [nameOf names x]
    EFix _ _ env' -> absNames names env'

nameOf :: [(Id, String)] -> Id -> String
nameOf names x = fromMaybe "x" (lookup x names)

-- The key of an application, recKey
--
-- An application of a closure (binder x) is recursive when the compiler,
-- unfolding it, meets an application with the same key, and is then
-- compiled to a recursive function of that key.  The key is the abstract
-- shape of the environment of the closure's body (the argument included),
-- like absE False, except that compile time thunks are abstracted to cells
-- (SRef ()):
--
--  * the function that the application becomes takes cells, not compile
--    time thunks (call reifies the thunks before defining or calling it),
--    so this is the shape of what it is passed;
--
--  * the shape of a thunk includes the shapes of its environment, which can
--    grow with each unfolding: in go (n + 1), where go does not always use
--    its argument (so it is delayed), the argument is a thunk of n, which is
--    the thunk n + 1 of the application before, and so on.  Without
--    abstracting thunks, the keys of the applications of go would all
--    differ, and the compiler would unfold go forever.
recKey :: Id -> Env -> Sh ()
recKey x benv =
  SClo x [ (y, case e of
                 EThk _ _ _ -> SRef ()
                 _ -> fst (absE False e))
         | (y, e) <- benv ]

-- An environment of a shape, with the given run time values
rebuild :: [(Id, Term)] -> [(Id, ShE ())] -> [Low Int] -> Int -> (Env, [Low Int], Int)
rebuild tbl ss ps i =
  case ss of
    [] -> ([], ps, i)
    (x, s) : ss' ->
      let (e, ps1, i1) = rebuildE s ps i
          (es, ps2, i2) = rebuild tbl ss' ps1 i1
      in  ((x, e) : es, ps2, i2)
  where
    rebuildE s ps0 i0 =
      case (s, ps0) of
        (SVal (SInt n), _) -> (EVal (VInt n), ps0, i0)
        (SVal (SDyn _), p : ps') -> (EVal (VDyn i0 p), ps', i0 + 1)
        (SVal (SClo x es), _) -> let (env, ps1, i1) = rebuild tbl es ps0 i0
                                 in  (EVal (VClo x (code tbl x) env), ps1, i1)
        (SThk l es, _) -> let (env, ps1, i1) = rebuild tbl es ps0 i0
                          in  (EThk l (code tbl l) env, ps1, i1)
        (SRef _, p : ps') -> (ERef i0 p, ps', i0 + 1)
        (SFix x es, _) -> let (env, ps1, i1) = rebuild tbl es ps0 i0
                          in  (EFix x (code tbl x) env, ps1, i1)
        _ -> error "rebuild"

-- The number of run time values of an abstract shape
nParams :: [(Id, ShE ())] -> Int
nParams = sum . map (count . snd)
  where count s = case s of
                    SVal (SDyn _) -> 1
                    SVal (SClo _ es) -> nParams es
                    SThk _ es -> nParams es
                    SRef _ -> 1
                    SFix _ es -> nParams es
                    _ -> 0

-- A recursive low function, by its number of run time arguments
data Fn = Fn0 (Low (St -> Res)) | Fn1 (Low (Int -> St -> Res))
        | Fn2 (Low (Int -> Int -> St -> Res)) | Fn3 (Low (Int -> Int -> Int -> St -> Res))

callFn :: Fn -> [Low Int] -> Low St -> Low Res
callFn fn ps st =
  case (fn, ps) of
    (Fn0 f, []) -> [| ~f ~st |]
    (Fn1 f, [a]) -> [| ~f ~a ~st |]
    (Fn2 f, [a, b]) -> [| ~f ~a ~b ~st |]
    (Fn3 f, [a, b, c]) -> [| ~f ~a ~b ~c ~st |]
    _ -> error "callFn"

-- Items: what the analysis finds
--
-- The code generator has to know two things before it generates any code:
--
--  * which applications are recursive (IRec, by key, see recKey): they are
--    compiled to recursive functions instead of being unfolded;
--
--  * the code of the run time thunks (IThk, by the abstract shape of the
--    thunk, see absEnv): each one gets a number, which the thunk cells
--    store, and the run time system has a case for each number (dispatch).
data Item = IRec (Sh ())       -- a recursive application
          | IThk (ShE ())      -- the code of a run time thunk
  deriving (Eq)

-- The numbers of the thunk codes
thunkNumbers :: [Item] -> [(ShE (), Int)]
thunkNumbers items = zip [ key | IThk key <- items ] [0 ..]

-- The run time system, Rt: the low functions that the generated code calls
-- (generated once, in compileFun)
data Rt = Rt
  { rtStore :: Low (Heap -> Int -> Cell -> Heap)       -- update the cell at an address
  , rtRun   :: Low (Int -> Int -> Ints -> St -> Res)   -- rt 0 a INil st forces the cell at
                                                       -- address a; rt (c + 1) 0 cs st runs
                                                       -- the code of thunk c, on captures cs
  }

-------------------------------------------------------------------------------
-- Partial evaluation monads

-- The generation state, GS
--
-- What the compiler knows at a point of the generated code.  It is threaded
-- along a path of the program: the monads pass it to the continuation, and
-- the branches of a conditional or a case start with the state before it.
-- The heap is part of it: the methods that use the heap take the current
-- heap (a variable of the generated code) from it, and put the new one back.
data GS = GS
  { gsNext      :: Int             -- the number of the next run time value (VDyn, VRV, ERef)
  , gsForced    :: [(ShE Int, V)]  -- the thunks and cells forced on this path, with their values
  , gsFns       :: [(Sh (), Fn)]   -- the recursive functions in scope, by key
  , gsUnfolding :: [Sh ()]         -- the keys of the applications being unfolded here;
                                   -- meeting one of them again is a recursive application
  , gsSt        :: Low St          -- the heap (and the next free address) at this point
  }

-- The state at the start of some code, numbering run time values from i,
-- with the heap st
initGS :: Int -> Low St -> GS
initGS i st = GS{ gsNext = i, gsForced = [], gsFns = [], gsUnfolding = [], gsSt = st }

withSt :: Low St -> GS -> GS
withSt st s = s{ gsSt = st }

-- The context, Ctx: what is fixed for the whole program
data Ctx = Ctx
  { ctxItems  :: [Item]           -- the items found by the analysis
  , ctxCode   :: [(Id, Term)]     -- the terms of the labels, for rebuild
  , ctxNames  :: [(Id, String)]   -- the source names of the ids, for the generated code
  , ctxThunks :: [(ShE (), Int)]  -- the numbers of the thunk codes
  , ctxRt     :: Rt               -- the run time system (not used by the analysis)
  }

-- The end of a block of code: a computation of type m End does not return,
-- it ends with a return, a jump to a join point, or a tail call
data End = End

-- The methods that use the heap take it from the state, and leave the new
-- heap there
class Monad m => MonadPE m where
  askCtx  :: m Ctx
  getGS   :: m GS
  putGS   :: GS -> m ()
  -- let an integer, a value
  letI    :: Low Int -> m (Low Int)
  letV    :: Low RV -> m (Low RV)
  -- if e == 0
  ifI     :: Low Int -> m End -> m End -> m End
  -- case on a list: nil, and cons (the addresses of the head and the tail)
  caseL   :: Low RV -> m End -> (Low Int -> Low Int -> m End) -> m End
  -- the integer of a value
  unbox   :: Low RV -> m (Low Int)
  -- a join point: the code after it is a function that the block jumps to
  joinV   :: ((Low RV -> m End) -> m End) -> m (Low RV)
  -- a recursive function: its name, the names of its arguments, their
  -- number, and its body (which starts with the heap it is given)
  recFun  :: String -> [String] -> Int -> (Fn -> [Low Int] -> Low St -> m End) -> m Fn
  -- call it, and call it in tail position
  callF   :: Fn -> [Low Int] -> m (Low RV)
  tailF   :: Fn -> [Low Int] -> m End
  -- return
  ret     :: Low RV -> m End
  -- force a cell, and force it in tail position
  forceC  :: Low Int -> m (Low RV)
  forceT  :: Low Int -> m End
  -- allocate a cell, update a cell
  allocC  :: Low Cell -> m (Low Int)
  setC    :: Low Int -> Low Cell -> m ()
  -- take a capture
  uncons  :: Low Ints -> m (Low Int, Low Ints)
  -- an item found
  record  :: Item -> m ()

modifyGS :: MonadPE m => (GS -> GS) -> m ()
modifyGS f = getGS >>= putGS . f

-- Both instances are continuation passing; r is the result, the code or the
-- items found
newtype PE r a = PE (Ctx -> GS -> (a -> GS -> r) -> r)

runPE :: PE r a -> Ctx -> GS -> (a -> GS -> r) -> r
runPE (PE m) = m

runEnd :: PE r End -> Ctx -> GS -> r
runEnd m c s = runPE m c s (\ _ _ -> error "peval: a block of code returned")

-- Run the code generator, and the analysis
genCode :: PE (Low Res) End -> Ctx -> GS -> Low Res
genCode = runEnd

analysis :: PE [Item] End -> Ctx -> GS -> [Item]
analysis = runEnd

instance Functor (PE r) where
  fmap f (PE m) = PE (\ c s k -> m c s (\ a s' -> k (f a) s'))
instance Applicative (PE r) where
  pure a = PE (\ _ s k -> k a s)
  PE mf <*> PE ma = PE (\ c s k -> mf c s (\ f s1 -> ma c s1 (\ a s2 -> k (f a) s2)))
instance Monad (PE r) where
  PE m >>= f = PE (\ c s k -> m c s (\ a s' -> runPE (f a) c s' k))

-- Code generation
instance MonadPE (PE (Low Res)) where
  askCtx = PE (\ c s k -> k c s)
  getGS = PE (\ _ s k -> k s s)
  putGS s = PE (\ _ _ k -> k () s)
  letI e = PE (\ _ s k -> [| let x = ~e in ~(k [| x |] s) |])
  letV e = PE (\ _ s k -> [| let x = ~e in ~(k [| x |] s) |])
  ifI x a b = PE (\ c s _ -> [| if ~x == 0 then ~(runEnd a c s) else ~(runEnd b c s) |])
  caseL v a b = PE (\ c s _ -> [| case ~v of { RNil -> ~(runEnd a c s); RCons h t -> ~(runEnd (b [| h |] [| t |]) c s) } |])
  unbox v = PE (\ _ s k -> [| case ~v of RInt i -> ~(k [| i |] s) |])
  joinV body = PE $ \ c s k ->
    [| let j = \ v st -> ~(k [| v |] (withSt [| st |] s))
       in  ~(runEnd (body (\ w -> PE (\ _ s' _ -> [| j ~w ~(gsSt s') |]))) c s) |]
  recFun name xs n body = PE $ \ c s k ->
    let b fn ps st = runEnd (body fn ps st) c s in
    named name (xs ++ ["st"]) $
    case n of
      0 -> [| let f = \ st -> ~(b (Fn0 [| f |]) [] [| st |]) in ~(k (Fn0 [| f |]) s) |]
      1 -> [| let f = \ a st -> ~(b (Fn1 [| f |]) [[| a |]] [| st |]) in ~(k (Fn1 [| f |]) s) |]
      2 -> [| let f = \ a1 a2 st -> ~(b (Fn2 [| f |]) [[| a1 |], [| a2 |]] [| st |]) in ~(k (Fn2 [| f |]) s) |]
      3 -> [| let f = \ a1 a2 a3 st -> ~(b (Fn3 [| f |]) [[| a1 |], [| a2 |], [| a3 |]] [| st |]) in ~(k (Fn3 [| f |]) s) |]
      _ -> error "peval: a recursive function with more than 3 run time arguments"
  callF fn ps = PE (\ _ s k -> [| case ~(callFn fn ps (gsSt s)) of Res v st -> ~(k [| v |] (withSt [| st |] s)) |])
  tailF fn ps = PE (\ _ s _ -> callFn fn ps (gsSt s))
  ret v = PE (\ _ s _ -> [| Res ~v ~(gsSt s) |])
  forceC a = PE $ \ c s k ->
    let rt = rtRun (ctxRt c)
    in  [| case ~rt 0 ~a INil ~(gsSt s) of Res v st -> ~(k [| v |] (withSt [| st |] s)) |]
  forceT a = PE $ \ c s _ ->
    let rt = rtRun (ctxRt c)
    in  [| ~rt 0 ~a INil ~(gsSt s) |]
  allocC cell = PE $ \ c s k ->
    let store = rtStore (ctxRt c)
    in  [| case ~(gsSt s) of
             St next h -> let s1 = St (next + 1) (~store h next ~cell) in ~(k [| next |] (withSt [| s1 |] s)) |]
  setC a cell = PE $ \ c s k ->
    let store = rtStore (ctxRt c)
    in  [| case ~(gsSt s) of
             St next h -> let s1 = St next (~store h ~a ~cell) in ~(k () (withSt [| s1 |] s)) |]
  uncons xs = PE (\ _ s k -> [| case ~xs of ICons y ys -> ~(k ([| y |], [| ys |]) s) |])
  record it = PE $ \ _ s k ->
    case it of
      IThk _ -> k () s                 -- the code of a thunk: looked up in thunkCell
      IRec _ -> error "peval: a recursive application that the analysis did not find"

-- The analysis instance: only find the items (see analyse).  It generates no
-- code: a let gives a dummy value, a conditional or a case runs all its
-- branches, a join point runs both the code after it and the block before
-- it, a recursive function runs its body, and record collects the items.
instance MonadPE (PE [Item]) where
  askCtx = PE (\ c s k -> k c s)
  getGS = PE (\ _ s k -> k s s)
  putGS s = PE (\ _ _ k -> k () s)
  letI _ = PE (\ _ s k -> k di s)
  letV _ = PE (\ _ s k -> k dv s)
  ifI _ a b = PE (\ c s _ -> runEnd a c s ++ runEnd b c s)
  caseL _ a b = PE (\ c s _ -> runEnd a c s ++ runEnd (b di di) c s)
  unbox _ = PE (\ _ s k -> k di s)
  joinV body = PE (\ c s k -> k dv (withSt ds s) ++ runEnd (body (\ _ -> PE (\ _ _ _ -> []))) c s)
  recFun _ _ n body = PE (\ c s k -> let fn = dummyFn n in runEnd (body fn (replicate n di) ds) c s ++ k fn s)
  callF _ _ = PE (\ _ s k -> k dv (withSt ds s))
  tailF _ _ = PE (\ _ _ _ -> [])
  ret _ = PE (\ _ _ _ -> [])
  forceC _ = PE (\ _ s k -> k dv (withSt ds s))
  forceT _ = PE (\ _ _ _ -> [])
  allocC _ = PE (\ _ s k -> k di (withSt ds s))
  setC _ _ = PE (\ _ s k -> k () (withSt ds s))
  uncons _ = PE (\ _ s k -> k (di, [| INil |]) s)
  record it = PE (\ _ s k -> it : k () s)

di :: Low Int
di = lowInt 0

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

-- The context needs no run time system in the analysis
noRt :: Rt
noRt = error "peval: the run time system in the analysis"

-------------------------------------------------------------------------------
-- The interpreter, at compile time

-- Where the value of a term in tail position goes: returned (from a
-- recursive function or the code of a thunk), or passed to a join point
data K m = KRet | KJoin (Low RV -> m End)

jump :: MonadPE m => K m -> Low RV -> m End
jump k v = case k of { KRet -> ret v; KJoin j -> j v }

-- Call a recursive function in tail position: a tail call, or a call
-- followed by the join point
callK :: MonadPE m => K m -> Fn -> [Low Int] -> m End
callK k fn ps = case k of { KRet -> tailF fn ps; KJoin j -> callF fn ps >>= j }

newId :: MonadPE m => m Int
newId = do
  s <- getGS
  putGS s{ gsNext = gsNext s + 1 }
  pure (gsNext s)

newRV :: MonadPE m => Low RV -> m V
newRV x = do { i <- newId; pure (VRV i x) }

bindInt :: MonadPE m => Low Int -> m V
bindInt e = do { x <- letI e; i <- newId; pure (VDyn i x) }

bindRV :: MonadPE m => Low RV -> m V
bindRV e = letV e >>= newRV

-- The integer of a value
intOf :: MonadPE m => V -> m (Low Int)
intOf v =
  case v of
    VInt n -> pure (lowInt n)
    VDyn _ x -> pure x
    VRV _ x -> unbox x
    VClo _ _ _ -> error "peval: a function where an integer was expected"

-- A value as a run time value
box :: V -> Low RV
box v =
  case v of
    VInt n -> [| RInt ~(lowInt n) |]
    VDyn _ x -> [| RInt ~x |]
    VRV _ x -> x
    VClo _ _ _ -> error "peval: a function where a run time value was expected"

-- Put the run time values of an entry in cells, so it can be captured
norm :: MonadPE m => E -> m E
norm e =
  case e of
    EVal (VRV _ x) -> do { a <- allocC [| Done ~x |]; i <- newId; pure (ERef i a) }
    EVal (VClo x b env) -> EVal . VClo x b <$> normEnv env
    EThk l t env -> EThk l t <$> normEnv env
    EFix x b env -> EFix x b <$> normEnv env
    _ -> pure e

normEnv :: MonadPE m => Env -> m Env
normEnv = mapM (\ (x, e) -> (,) x <$> norm e)

-- Make the compile time thunks of an environment cells: the arguments of a
-- recursive function are run time values, so a delayed argument is a run
-- time thunk, shared by all the calls
reify :: MonadPE m => Env -> m Env
reify = mapM one
  where one (x, e) = case e of
                       EThk l t env -> do { c <- thunkCell l t env; a <- allocC c; j <- newId; pure (x, ERef j a) }
                       _ -> pure (x, e)

-- A thunk cell for a term in an environment (of the variables it uses): the
-- number of the code for its shape, and the run time values it uses
thunkCell :: MonadPE m => Id -> Term -> Env -> m (Low Cell)
thunkCell l t env = do
  env' <- normEnv env
  let (ss, cs) = absEnv True env'
      key = SThk l ss
  record (IThk key)
  c <- askCtx
  let n = case lookup key (ctxThunks c) of
            Just k -> k
            Nothing | IThk key `elem` ctxItems c -> error "thunkCell"
                    | otherwise -> 0                -- the analysis, which records it
  pure [| Thunk ~(lowInt n) ~(ints cs) |]

ints :: [Low Int] -> Low Ints
ints cs = case cs of
  [] -> [| INil |]
  c : cs' -> [| ICons ~c ~(ints cs') |]

-- The name of a function, for the generated code
funName :: MonadPE m => Term -> m String
funName t =
  case t of
    Var x -> do { c <- askCtx; pure (nameOf (ctxNames c) x) }
    _ -> pure "f"

eval :: MonadPE m => Term -> Env -> m V
eval t env =
  case t of
    Var x -> force (look x env)
    Lam x b -> pure (VClo x b (restrict (used t) env))
    App _ _ _ -> do
      let (h, args) = spine t
      fv <- eval h env
      name <- funName h
      applyAll name fv args 0 env
    Lit n -> pure (VInt n)
    Prim o a b -> do
      x <- eval a env
      y <- eval b env
      case (x, y) of
        (VInt i, VInt j) -> pure (VInt (op o i j))
        _ -> do { xi <- intOf x; yi <- intOf y; bindInt (primL o xi yi) }
    If0 c a b -> do
      cv <- eval c env
      case cv of
        VInt 0 -> eval a env
        VInt _ -> eval b env
        _ -> do
          ci <- intOf cv
          branch (\ k -> ifI ci (evalT a env k) (evalT b env k))
    Nil -> newRV [| RNil |]
    Cons lh h lr r -> do
      ha <- field lh h env
      ra <- field lr r env
      bindRV [| RCons ~ha ~ra |]
    Case s n hx tx c -> do
      sv <- eval s env
      case sv of
        VRV _ x -> branch (caseOn x n hx tx c env)
        _ -> error "peval: case on a value that is not a list"
    Letrec x b body -> letrec x b env >>= eval body

-- A conditional on run time values: the code after it is a join point
branch :: MonadPE m => (K m -> m End) -> m V
branch alts = joinV (alts . KJoin) >>= newRV

-- The environment of the body of a letrec: a recursive function, or a knot
-- in the heap (a cell whose thunk captures the cell itself)
letrec :: MonadPE m => Id -> Term -> Env -> m Env
letrec x b env =
  case b of
    Lam _ _ -> pure ((x, EFix x b (restrict (filter (/= x) (used b)) env)) : env)
    _ -> do
      a <- allocC [| Done RNil |]
      i <- newId
      let env' = (x, ERef i a) : env
      cell <- thunkCell x b (restrict (used b) env')
      setC a cell
      pure env'

-- A case on a run time list, with the branches in tail position
caseOn :: MonadPE m => Low RV -> Term -> Id -> Id -> Term -> Env -> K m -> m End
caseOn x n hx tx c env k =
  caseL x (evalT n env k)
          (\ h tl -> do
              ih <- newId
              it <- newId
              evalT c ((tx, ERef it tl) : (hx, ERef ih h) : env) k)

-- A constructor field: the address of a cell
field :: MonadPE m => Id -> Term -> Env -> m (Low Int)
field l t env =
  case t of
    Var x -> cellOf (look x env)
    Lit k -> allocC [| Done (RInt ~(lowInt k)) |]
    _ -> thunkCell l t (restrict (used t) env) >>= allocC

cellOf :: MonadPE m => E -> m (Low Int)
cellOf e =
  case e of
    ERef _ a -> pure a
    EVal v -> allocC [| Done ~(box v) |]
    EThk l t env -> thunkCell l t env >>= allocC
    EFix _ _ _ -> error "peval: a function in a data structure"

-- Apply a function to the arguments of a spine, with more arguments after
-- them (for the strictness of a fully applied function)
applyAll :: MonadPE m => String -> V -> [(Id, Term)] -> Int -> Env -> m V
applyAll name fv args more env =
  case args of
    [] -> pure fv
    (l, a) : rest -> do
      e <- argument fv l a env (length rest + more)
      v <- apply name fv e
      applyAll name v rest more env

-- The argument of an application, with r more arguments after it
argument :: MonadPE m => V -> Id -> Term -> Env -> Int -> m E
argument fv l a env r =
  case a of
    Var x -> pure (look x env)
    Lam _ _ -> EVal <$> eval a env
    Lit n -> pure (EVal (VInt n))
    _ -> case fv of
           VClo x b _ | strictIn b x r -> EVal <$> eval a env
           _ -> pure (EThk l a (restrict (used a) env))

-- Use an entry: a compile time thunk is evaluated the first time on a path,
-- a cell is forced at run time the first time on a path
force :: MonadPE m => E -> m V
force e =
  case e of
    EVal v -> pure v
    EFix x b env -> eval b ((x, e) : env)
    _ -> do
      let key = keyE e
      s <- getGS
      case lookup key (gsForced s) of
        Just v -> pure v
        Nothing -> do
          v <- case e of
                 EThk _ t env -> eval t env
                 ERef _ a -> forceC a >>= newRV
                 _ -> error "force"
          modifyGS (\ s' -> s'{ gsForced = (key, v) : gsForced s' })
          pure v

-- What applying a closure does
data Call = Known Fn [Low Int]       -- call a recursive function
          | Again (Sh ())             -- a recursive application, not known yet
          | Unfold (Sh ()) Term Env   -- unfold the closure

-- Apply a closure to an argument: call (and first define) the recursive
-- function of its shape, or unfold it
call :: MonadPE m => String -> V -> E -> m Call
call name fv a =
  case fv of
    VClo x b cenv -> do
      benv0 <- normEnv (restrict (used b) ((x, a) : cenv))
      c <- askCtx
      s0 <- getGS
      let key = recKey x benv0
          isRec = IRec key `elem` ctxItems c
      if isJust (lookup key (gsFns s0)) || isRec || key `elem` gsUnfolding s0 then do
        benv <- reify benv0
        s <- getGS
        let (ss, ps) = absEnv False benv
        case lookup key (gsFns s) of
          Just fn -> pure (Known fn ps)
          Nothing
            | isRec -> do
                fn <- define name (absNames (ctxNames c) benv) key b ss
                pure (Known fn ps)
            | otherwise -> pure (Again key)
      else
        pure (Unfold key b benv0)
    _ -> error "peval: applying a value that is not a function"

apply :: MonadPE m => String -> V -> E -> m V
apply name fv a = do
  cl <- call name fv a
  case cl of
    Known fn ps -> callF fn ps >>= newRV
    Again key -> do
      record (IRec key)
      newRV [| RNil |]
    Unfold key b benv -> do
      as <- unfolding key
      v <- eval b benv
      modifyGS (\ s -> s{ gsUnfolding = as })
      pure v

applyT :: MonadPE m => String -> V -> E -> K m -> m End
applyT name fv a k = do
  cl <- call name fv a
  case cl of
    Known fn ps -> callK k fn ps
    Again key -> do
      record (IRec key)
      jump k [| RNil |]
    Unfold key b benv -> do
      _ <- unfolding key
      evalT b benv k

-- Start unfolding an application, returning the applications unfolded before
unfolding :: MonadPE m => Sh () -> m [Sh ()]
unfolding key = do
  s <- getGS
  putGS s{ gsUnfolding = key : gsUnfolding s }
  pure (gsUnfolding s)

-- Define the recursive function of a shape: its body is the closure's body
-- with the run time values of the environment as arguments
define :: MonadPE m => String -> [String] -> Sh () -> Term -> [(Id, ShE ())] -> m Fn
define name xs key b ss = do
  c <- askCtx
  s <- getGS
  fn <- recFun name xs (nParams ss) $ \ fn ps st0 -> do
          -- the body: nothing is forced yet, the function itself is in scope,
          -- and the heap is the one it is called with
          let (benv', _, i1) = rebuild (ctxCode c) ss ps (gsNext s)
          putGS s{ gsNext = i1, gsForced = [], gsFns = (key, fn) : gsFns s, gsSt = st0 }
          evalT b benv' KRet
  modifyGS (\ s' -> s'{ gsFns = (key, fn) : gsFns s' })
  pure fn

-- Evaluate a term in tail position: its value goes to k.  A conditional
-- needs no join point of its own, and calls and forcing a cell are tail
-- calls when k returns.
evalT :: MonadPE m => Term -> Env -> K m -> m End
evalT t env k =
  case t of
    If0 c a b -> do
      cv <- eval c env
      case cv of
        VInt 0 -> evalT a env k
        VInt _ -> evalT b env k
        _ -> do
          ci <- intOf cv
          ifI ci (evalT a env k) (evalT b env k)
    Case s n hx tx c -> do
      sv <- eval s env
      case sv of
        VRV _ x -> caseOn x n hx tx c env k
        _ -> error "peval: case on a value that is not a list"
    App _ _ _ -> do
      let (h, args) = spine t
          (l, a) = last args
      f0 <- eval h env
      name <- funName h
      fv <- applyAll name f0 (init args) 1 env
      e <- argument fv l a env 0
      applyT name fv e k
    Letrec x b body -> do
      env' <- letrec x b env
      evalT body env' k
    Var x | ERef _ a <- look x env, KRet <- k -> do
      s <- getGS
      case lookup (keyE (look x env)) (gsForced s) of
        Nothing -> forceT a
        Just v -> jump k (box v)
    _ -> do
      v <- eval t env
      jump k (box v)

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
thunkCode :: MonadPE m => ShE () -> Low Ints -> m End
thunkCode key cs =
  case key of
    SThk l ss -> do
      ps <- unconsN (nParams ss) cs
      c <- askCtx
      s <- getGS
      let (env, _, i) = rebuild (ctxCode c) ss ps 0
      putGS (initGS i (gsSt s))
      evalT (code (ctxCode c) l) env KRet
    _ -> error "thunkCode"
  where unconsN n xs = if n == 0 then pure [] else do
                         (y, ys) <- uncons xs
                         (y :) <$> unconsN (n - 1 :: Int) ys

-- The program applied to the input
program :: MonadPE m => Term -> Low Int -> m End
program t n = do
  f <- eval t []
  applyT "f" f (EVal (VDyn 0 n)) KRet

-- The analysis
--
-- The items of a program: run the analysis (the interpreter in the monad
-- PE [Item], which generates no code) on the program, and on the code of
-- every thunk found so far (the thunk codes are entry points of their own:
-- rt runs them), until it finds no new items.  The items found so far are
-- in the context, and change what the interpreter does: an application
-- whose key is an IRec defines a recursive function, whose body is
-- evaluated in an environment rebuilt from the key, so it can find new
-- items; and a new thunk code is analysed in the next round.
analyse :: Term -> [(Id, Term)] -> [(Id, String)] -> [Item]
analyse t tbl names = go []
  where
    go items =
      let ctx = Ctx{ ctxItems = items, ctxCode = tbl, ctxNames = names, ctxThunks = thunkNumbers items, ctxRt = noRt }
          found = analysis (program t di) ctx (initGS 1 ds) ++
                  concat [ analysis (thunkCode key [| INil |]) ctx (initGS 0 ds) | IThk key <- items ]
          new = nub found
      in  if all (`elem` items) new then items else go (nub (items ++ new))

-- The run time system and the program
compileFun :: Fresh Term -> Low (Int -> Int)
compileFun p =
  let (t, names) = runFresh p
      tbl = codes t
      items = analyse t tbl names
      tcs = thunkNumbers items
      context store rt = Ctx{ ctxItems = items, ctxCode = tbl, ctxNames = names, ctxThunks = tcs
                            , ctxRt = Rt{ rtStore = store, rtRun = rt } }
  in  [| \ n -> ~(runGen $ do
          fetch <- genRecNamed "fetch" $ \ fetch -> [| \ h a ->
                     case h of
                       Node l c r -> if a == 1 then c
                                     else if a - 2 * (a `quot` 2) == 0 then ~fetch l (a `quot` 2)
                                     else ~fetch r (a `quot` 2) |]
          store <- genRecNamed "store" $ \ store -> [| \ h a c ->
                     case h of
                       Empty -> Node Empty c Empty
                       Node l c0 r -> if a == 1 then Node l c r
                                      else if a - 2 * (a `quot` 2) == 0 then Node (~store l (a `quot` 2) c) c0 r
                                      else Node l c0 (~store r (a `quot` 2) c) |]
          rt <- genRecNamed "rt" $ \ rt -> [| \ c a xs st ->
                     if c == 0 then
                       case st of
                         St _ h -> case ~fetch h a of
                                     Done v -> Res v st
                                     Thunk d cs -> case ~rt (d + 1) 0 cs st of
                                                     Res v st1 -> case st1 of
                                                       St n1 h1 -> Res v (St n1 (~store h1 a (Done v)))
                     else let d = c - 1 in
                          ~(dispatch (context store rt) tcs [| d |] [| xs |] [| st |]) |]
          return [| case ~(genCode (program t [| n |]) (context store rt) (initGS 1 [| St 1 Empty |])) of
                      Res v _ -> case v of RInt i -> i |]) |]

-- The body of run: the code of every thunk, by number
dispatch :: Ctx -> [(ShE (), Int)] -> Low Int -> Low Ints -> Low St -> Low Res
dispatch ctx tcs c xs st =
  case tcs of
    [] -> [| Res RNil ~st |]                       -- no thunks: run is never called
    [(key, _)] -> genCode (thunkCode key xs) ctx (initGS 0 st)
    (key, n) : rest -> [| if ~c == ~(lowInt n) then ~(genCode (thunkCode key xs) ctx (initGS 0 st))
                                              else ~(dispatch ctx rest c xs st) |]

-------------------------------------------------------------------------------
-- Building terms: a binder gives its scope the variable it binds

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

(.+), (.-) :: T -> T -> T
a .+ b = Prim Plus <$> a <*> b
a .- b = Prim Minus <$> a <*> b

lit :: Int -> T
lit n = pure (Lit n)

ifz :: T -> T -> T -> T
ifz c a b = If0 <$> c <*> a <*> b

nil :: T
nil = pure Nil

cons :: T -> T -> T
cons h r = do
  h' <- h
  lh <- fresh "hd"
  r' <- r
  lr <- fresh "tl"
  pure (Cons lh h' lr r')

-- case s of [] -> n; h : t -> c
caseList :: T -> T -> String -> String -> (T -> T -> T) -> T
caseList s n hx tx c = do
  s' <- s
  n' <- n
  h <- fresh hx
  t <- fresh tx
  c' <- c (pure (Var h)) (pure (Var t))
  pure (Case s' n' h t c')

-- letrec x = b in body
letrecT :: String -> (T -> T) -> (T -> T) -> T
letrecT x b body = do
  i <- fresh x
  b' <- b (pure (Var i))
  body' <- body (pure (Var i))
  pure (Letrec i b' body')

(.*) :: T -> T -> T
a .* b = Prim Times <$> a <*> b

-------------------------------------------------------------------------------
-- A parser for terms, for writing examples
--
--   e ::= \ x1 .. xn -> e                          a lambda (of n arguments)
--       | if0 e then e else e                      a conditional on zero
--       | case e of { [] -> e; h : t -> e }        a case on a list
--       | letrec x = e in e                        x is bound in both
--       | e : e                                    a cons (right associative)
--       | e + e | e - e | e * e                    arithmetic (* binds tighter; left
--                                                  associative; tighter than :)
--       | e e                                      an application (binds tightest)
--       | x | n | [] | ( e )
--
-- A definition is x = e.  A defined name is a macro: each use of it builds
-- the term again, with new ids, like a Haskell definition of type T.  The
-- parser builds a T (with the builders above) from the scope: the defined
-- names and the bound variables.

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
      | c == '[', ']' : r <- cs -> "[]" : tokens r
      | otherwise -> [c] : tokens cs

keywords :: [String]
keywords = ["if0", "then", "else", "case", "of", "letrec", "in"]

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

pName :: [String] -> (String, [String])
pName ts =
  case ts of
    x : ts' | isName x -> (x, ts')
    _ -> parseError "expected a variable" ts

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
    "case" : ts1 ->
      let (e, ts2) = pExpr ts1
          (n, ts3) = pExpr (expect "->" (expect "[]" (expect "{" (expect "of" ts2))))
          (h, ts4) = pName (expect ";" ts3)
          (t, ts5) = pName (expect ":" ts4)
          (c, ts6) = pExpr (expect "->" ts5)
      in  (\ sc -> caseList (e sc) (n sc) h t (\ hv tv -> c ((t, tv) : (h, hv) : sc)), expect "}" ts6)
    "letrec" : ts1 ->
      let (x, ts2) = pName ts1
          (e, ts3) = pExpr (expect "=" ts2)
          (b, ts4) = pExpr (expect "in" ts3)
      in  (\ sc -> letrecT x (\ v -> e ((x, v) : sc)) (\ v -> b ((x, v) : sc)), ts4)
    _ -> pCons ts
  where lams xs b sc = case xs of
                         [] -> b sc
                         x : xs' -> lam x (\ v -> lams xs' b ((x, v) : sc))

-- e : e, right associative, over arithmetic
pCons :: Parse
pCons ts0 =
  let (a, ts1) = pLeft ["+", "-"] (pLeft ["*"] pApp) ts0
  in  case ts1 of
        ":" : ts2 -> let (b, ts3) = pCons ts2 in (\ sc -> cons (a sc) (b sc), ts3)
        _ -> (a, ts1)

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
                    t : _ | isName t || isNumber t || t == "(" || t == "[]" -> let (a, ts') = pAtom ts in go (\ sc -> f sc .@ a sc) ts'
                    _ -> (f, ts)

pAtom :: Parse
pAtom ts =
  case ts of
    "(" : ts1 -> let (e, ts2) = pExpr ts1 in (e, expect ")" ts2)
    "[]" : ts1 -> (\ _ -> nil, ts1)
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

-- Definitions that the examples use
prelude :: Scope
prelude = defs
  [ "tail = \\ xs -> case xs of { [] -> []; h : t -> t }"
  , "nth = letrec nth = \\ n xs -> if0 n then case xs of { [] -> 0; h : t -> h }" ++
    "                              else case xs of { [] -> 0; h : t -> nth (n - 1) t } in nth"
  , "map = letrec map = \\ f xs -> case xs of { [] -> []; x : xs' -> f x : map f xs' } in map"
  ]

term :: String -> T
term = parseTerm prelude

-- fibs = 0 : 1 : zipWith (+) fibs (tail fibs);  main input = fibs !! input
-- (nth is strict in the index, like (!!))
fibsProgram :: T
fibsProgram = term $ unwords
  [ "\\ input ->"
  , "  letrec zipWith = \\ f xs ys ->"
  , "    case xs of { [] -> []; x : xs' -> case ys of { [] -> []; y : ys' -> f x y : zipWith f xs' ys' } } in"
  , "  letrec nth = \\ n xs ->"
  , "    if0 n then case xs of { [] -> 0; h : t -> h }"
  , "          else case xs of { [] -> 0; h : t -> nth (n - 1) t } in"
  , "  letrec fibs = 0 : 1 : zipWith (\\ a b -> a + b) fibs (tail fibs) in"
  , "  nth input fibs" ]

pfibs :: Low (Int -> Int)
pfibs = compileFun fibsProgram

-- An infinite list, made and consumed lazily: nats is 0, 1, 2, ...
psquares :: Low (Int -> Int)
psquares = compileFun (term "\\ input -> letrec nats = 0 : map (\\ x -> x + 1) nats in nth input (map (\\ x -> x * x) nats)")

-- Run time code: the compiled programs are spliced in.
fibsC, squaresC :: Int -> Int
fibsC = pfibs
squaresC = psquares

main :: IO ()
main = do
  putStrLn "---- pfibs = compileFun fibsProgram, reflected"
  putStr (lowString (lowPretty (reflect pfibs)))
  putStrLn "---- pfibs, compact C"
  putStr (lowString (toCompactC False "pfibs" (reflect pfibs)))
  putStrLn "---- pfibs, compact C with a mutable heap"
  putStr (lowString (toCompactC True "pfibs" (reflect pfibs)))
  putStrLn "---- psquares = compileFun (\\ input -> letrec nats = 0 : map (\\ x -> x + 1) nats in nth input (map (\\ x -> x * x) nats)), reflected"
  putStr (lowString (lowPretty (reflect psquares)))
  putStrLn "---- run"
  print (map fibsC [0 .. 20])
  print (fibsC 40)                  -- fib 46 is the largest that fits a 32 bit Int
  print (map squaresC [0 .. 10])
