module LowFutamura(main) where
import Data.List(elemIndex, nub)
import Staged.Low
import Staged.Low.C(toC)

-- The first Futamura projection with two-level type theory, Jones optimal,
-- with call by need.
--
-- tests/LowLambda.hs is a call by need interpreter, eval :: Low (Term -> Res).
-- Here the interpreter runs at compile time on a known program and leaves
-- low code for the program alone: compiling the factorial program
--
--   pfactorial :: Low (Int -> Int)
--   pfactorial = evalFun (deBruijn factorial)
--
-- gives the factorial function you would write in low code by hand, with
-- none of the interpreter left: no terms, environments, closures, heap, or
-- dispatch.  What makes that possible:
--
--  * Closures and thunks are compile time values (a label and an
--    environment), so applying a closure, the Y combinator included, happens
--    in the compiler.  Only integers exist at run time.
--
--  * Call by need is resolved at compile time.  An argument is a thunk; it is
--    evaluated where a path of the program first needs it, and later uses on
--    the same path reuse the value.  An argument that is never needed is
--    never evaluated (also not at compile time), and a variable passed as an
--    argument shares its thunk.  A strict function (one whose body always
--    uses its argument) gets its argument evaluated before the call, which
--    cannot change the result.
--
--  * Recursion through run time integers becomes a recursive low function:
--    applying a closure to arguments of the same shape (the same closure and
--    environment, with run time integers abstracted) again is a call.  The
--    shapes that recur are found by running the compiler in an analysis mode
--    first, until no new ones are found.
--
-- Not done: a thunk passed to a recursive function that is not strict in it
-- is evaluated (when needed) once per call of that function, not once for
-- all of them.  The results are those of call by need; only that sharing
-- across calls is lost.

-- Terms, with de Bruijn indices
data Term = Var Int | Lam Term | App Term Term
          | Lit Int | Prim Op Term Term | If0 Term Term Term

data Op = Plus | Minus | Times
  deriving (Eq)

-------------------------------------------------------------------------------
-- Compile time

-- Terms whose lambda bodies and application arguments have labels
data LTerm = LVar Int | LLam Int LTerm | LApp LTerm Int LTerm
           | LLit Int | LPrim Op LTerm LTerm | LIf0 LTerm LTerm LTerm
  deriving (Eq)

-- Label the lambda bodies and application arguments.  Equal terms get the
-- same label (the two copies of \ x -> f (x x) in the Y combinator are one
-- closure), so equal closures have equal shapes.
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
  where
    label u tb = case lookup u tb of
                   Just l -> (l, tb)
                   Nothing -> let l = length tb in (l, (u, l) : tb)

-- A program's labelled term, and the terms of its labels
labelled :: Term -> (LTerm, [(Int, LTerm)])
labelled t = let (lt, tbl) = labelTerm [] t in (lt, [ (l, u) | (u, l) <- tbl ])

-- Compile time values: an integer known at compile time, a run time integer
-- (with a number that identifies it), or a closure (the label of its body,
-- the body, and its environment)
data V = VInt Int | VDyn Int (Low Int) | VClo Int LTerm [E]

-- An environment entry: a value, or a thunk (the label of its term, the
-- term, and its environment)
data E = EVal V | EThk Int LTerm [E]

-- The shape of a value: what is known at compile time.  Sh Int identifies
-- run time integers (for thunks forced on a path), Sh () abstracts them
-- (for the arguments of recursive functions).
-- A closure or thunk only has the shapes of the variables its term uses
-- (SNone for the others), as in closure conversion.
data Sh d = SInt Int | SDyn d | SClo Int [ShE d]
  deriving (Eq)
data ShE d = SVal (Sh d) | SThk Int [ShE d] | SNone
  deriving (Eq)

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

-- The variables of its environment that a closure body uses
freeClo :: LTerm -> [Int]
freeClo b = free (LLam 0 b)

shapeEnv :: (Int -> d) -> [Int] -> [E] -> [ShE d]
shapeEnv f used env = [ if i `elem` used then shapeE f e else SNone | (i, e) <- zip [0 ..] env ]

-- The run time integers of the used variables of an environment
dynsEnv :: [Int] -> [E] -> [Low Int]
dynsEnv used env = concat [ dynsE e | (i, e) <- zip [0 ..] env, i `elem` used ]

shapeV :: (Int -> d) -> V -> Sh d
shapeV f v =
  case v of
    VInt n -> SInt n
    VDyn i _ -> SDyn (f i)
    VClo l b env -> SClo l (shapeEnv f (freeClo b) env)

shapeE :: (Int -> d) -> E -> ShE d
shapeE f e =
  case e of
    EVal v -> SVal (shapeV f v)
    EThk l t env -> SThk l (shapeEnv f (free t) env)

-- The run time integers of an environment
dynsE :: E -> [Low Int]
dynsE e =
  case e of
    EVal (VDyn _ x) -> [x]
    EVal (VClo _ b env) -> dynsEnv (freeClo b) env
    EVal (VInt _) -> []
    EThk _ t env -> dynsEnv (free t) env

-- An environment of a shape, with the given run time integers
rebuild :: [(Int, LTerm)] -> [ShE ()] -> [Low Int] -> Int -> ([E], [Low Int], Int)
rebuild tbl ss ps i =
  case ss of
    [] -> ([], ps, i)
    s : ss' ->
      let (e, ps1, i1) = rebuildE tbl s ps i
          (es, ps2, i2) = rebuild tbl ss' ps1 i1
      in  (e : es, ps2, i2)

rebuildE :: [(Int, LTerm)] -> ShE () -> [Low Int] -> Int -> (E, [Low Int], Int)
rebuildE tbl s ps i =
  case s of
    SVal (SInt n) -> (EVal (VInt n), ps, i)
    SVal (SDyn _) -> case ps of
                       p : ps' -> (EVal (VDyn i p), ps', i + 1)
                       [] -> error "rebuild"
    SVal (SClo l es) -> let (env, ps1, i1) = rebuild tbl es ps i
                        in  (EVal (VClo l (code tbl l) env), ps1, i1)
    SThk l es -> let (env, ps1, i1) = rebuild tbl es ps i
                 in  (EThk l (code tbl l) env, ps1, i1)
    SNone -> (EVal (VInt 0), ps, i)                 -- not used

code :: [(Int, LTerm)] -> Int -> LTerm
code tbl l = maybe (error "label") id (lookup l tbl)

-- Does a term always use variable i (is it strict in it)?
strict :: LTerm -> Int -> Bool
strict t i =
  case t of
    LVar n -> n == i
    LLam _ _ -> False
    LApp f _ _ -> strict f i
    LLit _ -> False
    LPrim _ a b -> strict a i || strict b i
    LIf0 c a b -> strict c i || (strict a i && strict b i)

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

-- What the compiler does with the code: generate it, or (in the analysis)
-- only find the shapes of the recursive functions.  r is the result: the
-- code, or the shapes found.
data Ops r = Ops (Low Int -> (Low Int -> r) -> r)                     -- let x = e in ...
                 (Low Int -> r -> r -> r)                              -- if e == 0 then .. else ..
                 ((Low Int -> r) -> ((Low Int -> r) -> r) -> r)        -- a join point
                 (Int -> (Fn -> [Low Int] -> r) -> (Fn -> r) -> r)     -- a recursive function
                 (Low Int -> r)                                        -- return a value
                 (Sh () -> r -> r)                                     -- a recursive application

genOps :: Ops (Low Int)
genOps = Ops (\ e k -> [| let x = ~e in ~(k [| x |]) |])
             (\ c a b -> [| if ~c == 0 then ~a else ~b |])
             (\ k body -> [| let j = \ v -> ~(k [| v |]) in ~(body (\ v -> [| j ~v |])) |])
             (\ n body rest ->
                case n of
                  0 -> [| let f = \ d -> ~(body (Fn1 [| f |]) []) in ~(rest (Fn1 [| f |])) |]
                  1 -> [| let f = \ a -> ~(body (Fn1 [| f |]) [[| a |]]) in ~(rest (Fn1 [| f |])) |]
                  2 -> [| let f = \ a b -> ~(body (Fn2 [| f |]) [[| a |], [| b |]]) in ~(rest (Fn2 [| f |])) |]
                  3 -> [| let f = \ a b c -> ~(body (Fn3 [| f |]) [[| a |], [| b |], [| c |]]) in ~(rest (Fn3 [| f |])) |]
                  _ -> error "peval: a recursive function with more than 3 run time arguments")
             id
             (\ _ _ -> error "peval: a recursive application that the analysis did not find")

anaOps :: Ops [Sh ()]
anaOps = Ops (\ _ k -> k dummy)
             (\ _ a b -> a ++ b)
             (\ k body -> k dummy ++ body (\ _ -> []))
             (\ n body rest -> body dummyFn (replicate n dummy) ++ rest dummyFn)
             (\ _ -> [])
             (:)
  where dummy = lowInt 0
        dummyFn = Fn1 [| \ x -> x |]

-- The state along a path of the program: the next number for a run time
-- integer, the thunks forced on this path, the recursive functions in scope,
-- and the applications being unfolded
data GS = GS Int [(ShE Int, V)] [(Sh (), Fn)] [Sh ()]

-- The context: what to do with code, the shapes of the recursive functions,
-- and the terms of the labels
data Ctx r = Ctx (Ops r) [Sh ()] [(Int, LTerm)]

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

-- Bind run time integer code to a variable
bindInt :: Low Int -> G r V
bindInt e = G $ \ (Ctx (Ops olet _ _ _ _ _) _ _) (GS i m fs as) k ->
  olet e (\ x -> k (VDyn i x) (GS (i + 1) m fs as))

int :: V -> Low Int
int v =
  case v of
    VInt n -> lowInt n
    VDyn _ x -> x
    VClo _ _ _ -> error "peval: a function where an integer was expected"

-- The interpreter, at compile time
eval :: LTerm -> [E] -> G r V
eval t env =
  case t of
    LVar n -> force (env !! n)
    LLam l b -> pure (VClo l b env)
    LApp f l x -> do
      fv <- eval f env
      a <- argument fv l x env
      apply fv a
    LLit n -> pure (VInt n)
    LPrim o a b -> do
      x <- eval a env
      y <- eval b env
      case (x, y) of
        (VInt i, VInt j) -> pure (VInt (op o i j))
        _ -> bindInt (primL o (int x) (int y))
    LIf0 c a b -> do
      cv <- eval c env
      case cv of
        VInt 0 -> eval a env
        VInt _ -> eval b env
        VDyn _ x -> ifDyn x a b env
        VClo _ _ _ -> error "peval: if0 on a function"

-- The argument of an application: shared if it is a variable, a value if it
-- is one, evaluated now if the function is strict, and a thunk otherwise
argument :: V -> Int -> LTerm -> [E] -> G r E
argument fv l x env =
  case x of
    LVar n -> pure (env !! n)
    LLam l' b -> pure (EVal (VClo l' b env))
    LLit n -> pure (EVal (VInt n))
    _ -> case fv of
           VClo _ b _ | strict b 0 -> EVal <$> eval x env
           _ -> pure (EThk l x env)

-- Use an environment entry: evaluate a thunk the first time on this path
force :: E -> G r V
force e =
  case e of
    EVal v -> pure v
    EThk _ t env -> G $ \ ctx gs@(GS _ m _ _) k ->
      let key = shapeE id e in
      case lookup key m of
        Just v -> k v gs
        Nothing -> runG (eval t env) ctx gs (\ v (GS i' m' fs' as') -> k v (GS i' ((key, v) : m') fs' as'))

-- A conditional on a run time integer: the code after it is a join point,
-- and the branches are in tail position (they return to the join point)
ifDyn :: Low Int -> LTerm -> LTerm -> [E] -> G r V
ifDyn c a b env = G $ \ ctx@(Ctx (Ops _ oif ojoin _ _ _) _ _) gs@(GS i m fs as) k ->
  ojoin (\ v -> k (VDyn i v) (GS (i + 1) m fs as))
        (\ j -> oif c (evalT a env ctx gs j) (evalT b env ctx gs j))

-- Apply a closure: unfold it, or call (and first define) the recursive
-- function of its shape
apply :: V -> E -> G r V
apply fv a =
  case fv of
    VClo l b cenv -> G $ \ ctx@(Ctx ops@(Ops olet _ _ _ _ orec) recs _) gs@(GS i m fs as) k ->
      let benv = a : cenv
          key = SClo l (shapeEnv (const ()) (free b) benv)
          ps = dynsEnv (free b) benv
          result x gs' = case gs' of GS i' m' fs' as' -> k (VDyn i' x) (GS (i' + 1) m' fs' as')
      in  case lookup key fs of
            Just fn -> olet (callFn fn ps) (\ x -> result x gs)
            Nothing
              | key `elem` recs -> define ctx key b benv gs (\ fn gs1 -> olet (callFn fn ps) (\ x -> result x gs1))
              | key `elem` as -> orec key (result (lowInt 0) gs)
              | otherwise -> runG (eval b benv) ctx (GS i m fs (key : as))
                               (\ v (GS i' m' fs' _) -> k v (GS i' m' fs' as))
    _ -> error "peval: applying an integer"

-- Define the recursive function of a shape: its body is the closure's body
-- with the run time integers of the environment as arguments
define :: Ctx r -> Sh () -> LTerm -> [E] -> GS -> (Fn -> GS -> r) -> r
define ctx@(Ctx (Ops _ _ _ ofun oret _) _ tbl) key b benv (GS i m fs as) k =
  let ss = shapeEnv (const ()) (free b) benv
      n = length (dynsEnv (free b) benv)
  in  ofun n (\ fn ps -> let (benv', _, i1) = rebuild tbl ss ps i
                         in  evalT b benv' ctx (GS i1 [] ((key, fn) : fs) as) oret)
             (\ fn -> k fn (GS i m ((key, fn) : fs) as))

-- Evaluate a term in tail position: its value is passed to ret (the return
-- of a function, or a join point).  A conditional needs no join point of its
-- own, and a call of a recursive function is a tail call.
evalT :: LTerm -> [E] -> Ctx r -> GS -> (Low Int -> r) -> r
evalT t env ctx@(Ctx (Ops _ oif _ _ _ _) _ _) gs ret =
  case t of
    LIf0 c a b ->
      runG (eval c env) ctx gs $ \ cv gs1 ->
        case cv of
          VInt 0 -> evalT a env ctx gs1 ret
          VInt _ -> evalT b env ctx gs1 ret
          VDyn _ x -> oif x (evalT a env ctx gs1 ret) (evalT b env ctx gs1 ret)
          VClo _ _ _ -> error "peval: if0 on a function"
    LApp f l x ->
      runG (do { fv <- eval f env; a <- argument fv l x env; return (fv, a) }) ctx gs $ \ (fv, a) gs1 ->
        applyT fv a ctx gs1 ret
    _ -> runG (eval t env) ctx gs (\ v _ -> ret (int v))

applyT :: V -> E -> Ctx r -> GS -> (Low Int -> r) -> r
applyT fv a ctx@(Ctx ops@(Ops _ _ _ _ _ orec) recs _) gs@(GS i m fs as) ret =
  case fv of
    VClo l b cenv ->
      let benv = a : cenv
          key = SClo l (shapeEnv (const ()) (free b) benv)
          ps = dynsEnv (free b) benv
      in  case lookup key fs of
            Just fn -> ret (callFn fn ps)
            Nothing
              | key `elem` recs -> define ctx key b benv gs (\ fn _ -> ret (callFn fn ps))
              | key `elem` as -> orec key (ret (lowInt 0))
              | otherwise -> evalT b benv ctx (GS i m fs (key : as)) ret
    _ -> error "peval: applying an integer"

op :: Op -> Int -> Int -> Int
op o i j = case o of { Plus -> i + j; Minus -> i - j; Times -> i * j }

primL :: Op -> Low Int -> Low Int -> Low Int
primL o x y =
  case o of
    Plus  -> [| ~x + ~y |]
    Minus -> [| ~x - ~y |]
    Times -> [| ~x * ~y |]

-- Find the shapes of the recursive functions: run the compiler in the
-- analysis mode until it finds no new ones
recursive :: (Ctx [Sh ()] -> [Sh ()]) -> [(Int, LTerm)] -> [Sh ()]
recursive run tbl = go []
  where go recs = let new = nub (run (Ctx anaOps recs tbl)) in
                  if all (`elem` recs) new then recs else go (nub (recs ++ new))

-- The projections: a program whose value is an integer, and a program whose
-- value is a function of an integer
evalInt :: Term -> Low Int
evalInt t =
  let (lt, tbl) = labelled t
      start :: Ctx r -> r
      start ctx@(Ctx (Ops _ _ _ _ oret _) _ _) = evalT lt [] ctx (GS 0 [] [] []) oret
  in  start (Ctx genOps (recursive start tbl) tbl)

evalFun :: Term -> Low (Int -> Int)
evalFun t =
  let (lt, tbl) = labelled t
      start :: Ctx r -> Low Int -> r
      start ctx@(Ctx (Ops _ _ _ _ oret _) _ _) n =
        runG (eval lt []) ctx (GS 1 [] [] []) (\ f gs -> applyT f (EVal (VDyn 0 n)) ctx gs oret)
      recs = recursive (\ ctx -> start ctx (lowInt 0)) tbl
  in  [| \ n -> ~(start (Ctx genOps recs tbl) [| n |]) |]

-------------------------------------------------------------------------------
-- Writing terms with names, as in LowLambda

data Named = V String | L String Named | Named :@ Named
           | N Int | Named :+ Named | Named :- Named | Named :* Named
           | IfZ Named Named Named
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

omega :: Named
omega = w :@ w
  where w = L "x" (V "x" :@ V "x")

church :: Int -> Named
church n = L "f" (L "x" (iterate (V "f" :@) (V "x") !! n))

timesC, toInt :: Named
timesC = L "m" (L "n" (L "f" (V "m" :@ (V "n" :@ V "f"))))
toInt  = L "c" (V "c" :@ L "k" (V "k" :+ N 1) :@ N 0)

-- The (lazy) fixed point combinator Y, which loops under call by value
fixY :: Named
fixY = L "f" (w :@ w)
  where w = L "x" (V "f" :@ (V "x" :@ V "x"))

factorial, fibonacci, spin :: Named
factorial = fixY :@ L "fact" (L "n" (IfZ (V "n") (N 1) (V "n" :* (V "fact" :@ (V "n" :- N 1)))))
fibonacci = fixY :@ L "fib" (L "n"
              (IfZ (V "n") (N 0)
                (IfZ (V "n" :- N 1) (N 1)
                  (V "fib" :@ (V "n" :- N 1) :+ V "fib" :@ (V "n" :- N 2)))))
spin = fixY :@ L "f" (L "m" (V "f" :@ V "m"))         -- never returns

-- Compiled programs
pfactorial :: Low (Int -> Int)
pfactorial = evalFun (deBruijn factorial)

pfibonacci :: Low (Int -> Int)
pfibonacci = evalFun (deBruijn fibonacci)

-- call by need: x is only needed when the input is not 0, and then only once
pneed :: Low (Int -> Int)
pneed = evalFun (deBruijn (L "input" (L "x" (IfZ (V "input") (N 0) (V "x" :+ V "x")) :@ (spin :@ V "input"))))

-- sharing: the argument is evaluated once
pshare :: Low (Int -> Int)
pshare = evalFun (deBruijn (L "input" (L "x" (V "x" :+ V "x" :+ V "x" :+ V "x") :@ (fibonacci :@ V "input"))))

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
factorial10C = evalInt (deBruijn (factorial :@ N 10))
churchC = evalInt (deBruijn (toInt :@ (timesC :@ church 6 :@ church 7)))
lazyC = evalInt (deBruijn (L "x" (N 42) :@ omega))

main :: IO ()
main = do
  putStrLn "---- pfactorial = evalFun (deBruijn factorial), reflected"
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
  putStr (lowString (lowPretty (reflect (evalInt (deBruijn (factorial :@ N 10))))))
  putStr (lowString (lowPretty (reflect (evalInt (deBruijn (toInt :@ (timesC :@ church 6 :@ church 7)))))))
  putStr (lowString (lowPretty (reflect (evalInt (deBruijn (L "x" (N 42) :@ omega))))))
  putStrLn "---- run"
  print (map factorialC [0, 1, 5, 10, 12])        -- 12! is the largest that fits a 32 bit Int
  print (map fibonacciC [0, 1, 2, 15])
  print (needC 0, shareC 15)
  print (factorial10C, churchC, lazyC)
