module LowFutamura(main) where
import Data.List(elemIndex)
import Staged.Low
import Staged.Low.C(toC)

-- The first Futamura projection with two-level type theory.
--
-- This is the call by need interpreter of tests/LowLambda.hs with the same
-- design (a heap of thunks threaded through the evaluator, closures and
-- thunks as data, a step counter), but with the term at the meta level:
--
--   LowLambda:   eval  :: Low (Term -> Res)                    the term is run time data
--   here:        eval  :: Term -> Low Res                      the term is known at compile time
--
-- Applying peval to a program runs the interpreter's traversal of the term in
-- the compiler, and what is left is low code for that program alone.
--
-- Where eval kept a term at run time (in a closure or a thunk), the compiled
-- code keeps a label instead: the lambda bodies and the arguments of
-- applications are numbered at compile time, and one low function, run,
-- dispatches on the label to the compiled code of that term.  Everything
-- else is as in eval, so the compiled programs compute the same values in
-- the same number of steps.

-- Terms, with de Bruijn indices
data Term = Var Int | Lam Term | App Term Term
          | Lit Int | Prim Op Term Term | If0 Term Term Term

data Op = Plus | Minus | Times

-------------------------------------------------------------------------------
-- Run time data: as in LowLambda, with labels instead of terms

-- An environment: the heap addresses of the variables, innermost first
data Env = Nil | Bind Int Env
  deriving (Show)

-- Values; a closure is its environment and the label of its body
data Val = VInt Int | VClo Env Int
  deriving (Show)

-- A heap cell is an unevaluated thunk (the label of its term and its
-- environment) or a value
data Cell = Thunk Int Env | Done Val

-- Address 1 is the root, address a has children 2a and 2a+1
data Heap = Empty | Node Heap Cell Heap

-- The next free address, the heap, and the number of evaluation steps
data St = St Int Heap Int

data Res = Res Val St

-------------------------------------------------------------------------------
-- Compile time

-- Terms whose lambda bodies and application arguments have labels
data LTerm = LVar Int | LLam Int LTerm | LApp LTerm Int LTerm
           | LLit Int | LPrim Op LTerm LTerm | LIf0 LTerm LTerm LTerm

-- Number the lambda bodies and application arguments, from n, and collect
-- them: these are the terms that are evaluated later, through run.
labelTerm :: Int -> Term -> (LTerm, Int, [(Int, LTerm)])
labelTerm n t =
  case t of
    Var i -> (LVar i, n, [])
    Lam b ->
      let (b', n1, bs) = labelTerm (n + 1) b
      in  (LLam n b', n1, (n, b') : bs)
    App f x ->
      let (f', n1, fs) = labelTerm n f
          (x', n2, xs) = labelTerm (n1 + 1) x
      in  (LApp f' n1 x', n2, fs ++ (n1, x') : xs)
    Lit k -> (LLit k, n, [])
    Prim o a b ->
      let (a', n1, as) = labelTerm n a
          (b', n2, bs) = labelTerm n1 b
      in  (LPrim o a' b', n2, as ++ bs)
    If0 c a b ->
      let (c', n1, cs) = labelTerm n c
          (a', n2, as) = labelTerm n1 a
          (b', n3, bs) = labelTerm n2 b
      in  (LIf0 c' a' b', n3, cs ++ as ++ bs)

-- The low functions of a compiled program: the heap operations, the
-- environment lookup, and the dispatch on labels
data Rt = Rt (Low (Heap -> Int -> Cell))
             (Low (Heap -> Int -> Cell -> Heap))
             (Low (Env -> Int -> Int))
             (Low (Int -> Env -> St -> Res))

-- The interpreter: LowLambda's ev, with the case on the term at compile time
peval :: Rt -> LTerm -> Low Env -> Low St -> Low Res
peval rt t env st =
  [| case ~st of
       St next h steps ->
         let st0 = St next h (steps + 1) in
         ~(step rt t env [| h |] [| st0 |]) |]

-- One step of ev, on a known term; h is the heap and st0 the state after
-- counting the step
step :: Rt -> LTerm -> Low Env -> Low Heap -> Low St -> Low Res
step rt@(Rt fetch store look run) t env h st0 =
         case t of
             LVar n ->
               [| let a = ~look ~env ~(lowInt n) in
                  case ~fetch ~h a of
                    Done v -> Res v ~st0
                    Thunk l tenv ->
                      case ~run l tenv ~st0 of                   -- force the thunk ...
                        Res v st1 ->
                          case st1 of
                            St next1 h1 steps1 ->               -- ... and update it with its value
                              Res v (St next1 (~store h1 a (Done v)) steps1) |]
             LLam l _ -> [| Res (VClo ~env ~(lowInt l)) ~st0 |]
             LApp f l x ->
               [| case ~(peval rt f env st0) of
                    Res fv st1 ->
                      case fv of
                        VClo cenv b ->
                          case st1 of
                            St next1 h1 steps1 ->               -- allocate a thunk for the argument
                              ~run b (Bind next1 cenv)
                                     (St (next1 + 1) (~store h1 next1 (Thunk ~(lowInt l) ~env)) steps1) |]
             LLit k -> [| Res (VInt ~(lowInt k)) ~st0 |]
             LPrim o a b ->
               [| case ~(peval rt a env st0) of
                    Res vx st1 ->
                      case vx of
                        VInt i ->
                          case ~(peval rt b env [| st1 |]) of
                            Res vy st2 ->
                              case vy of
                                VInt j -> Res (VInt ~(prim o [| i |] [| j |])) st2 |]
             LIf0 c a b ->
               [| case ~(peval rt c env st0) of
                    Res vc st1 ->
                      case vc of
                        VInt i -> if i == 0 then ~(peval rt a env [| st1 |])
                                            else ~(peval rt b env [| st1 |]) |]

prim :: Op -> Low Int -> Low Int -> Low Int
prim o x y =
  case o of
    Plus  -> [| ~x + ~y |]
    Minus -> [| ~x - ~y |]
    Times -> [| ~x * ~y |]

-- The body of run: the compiled code of every labelled term
dispatch :: Rt -> [(Int, LTerm)] -> Low Int -> Low Env -> Low St -> Low Res
dispatch rt blocks l env st =
  case blocks of
    [] -> [| Res (VInt 0) ~st |]                  -- no labels: run is never called
    [(_, b)] -> peval rt b env st
    (k, b) : bs -> [| if ~l == ~(lowInt k) then ~(peval rt b env st)
                                           else ~(dispatch rt bs l env st) |]

-- The low functions, then the program
withRt :: Term -> (Rt -> LTerm -> Low Res) -> Low Res
withRt t body =
  let (lt, _, blocks) = labelTerm 0 t in
  runGen $ do
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
    look <- genRec $ \ look -> [| \ env n ->
               case env of
                 Bind a r -> if n == 0 then a else ~look r (n - 1) |]
    run <- genRec $ \ run -> [| \ l env st ->
               ~(dispatch (Rt fetch store look run) blocks [| l |] [| env |] [| st |]) |]
    return (body (Rt fetch store look run) lt)

-- The staged interpreter: a program, known at compile time, to low code
-- that runs it with call by need
eval :: Term -> Low Res
eval t = withRt t $ \ rt lt -> peval rt lt [| Nil |] [| St 1 Empty 0 |]

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

plusC, timesC, toInt :: Named
plusC  = L "m" (L "n" (L "f" (L "x" (V "m" :@ V "f" :@ (V "n" :@ V "f" :@ V "x")))))
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

-- Compiled programs: the interpreter applied to a program at compile time
pfactorial :: Low Res
pfactorial = eval (deBruijn factorial)

pfactorial10 :: Low Res
pfactorial10 = eval (deBruijn (factorial :@ N 10))

pfibonacci :: Low Res
pfibonacci = eval (deBruijn (fibonacci :@ N 15))

pchurch :: Low Res
pchurch = eval (deBruijn (toInt :@ (timesC :@ church 6 :@ church 7)))

-- call by need: the argument is never evaluated
plazy :: Low Res
plazy = eval (deBruijn (L "x" (N 42) :@ omega))

-- call by need: the argument loops, but it is only needed if the condition is not 0
pneed :: Low Res
pneed = eval (deBruijn (L "x" (IfZ (N 0) (N 0) (V "x" :+ V "x")) :@ (spin :@ N 1)))

-- Show a value and the number of evaluation steps, as LowLambda does
report :: String -> Res -> IO ()
report name r =
  case r of
    Res v (St _ _ steps) -> putStrLn (name ++ " = " ++ show v ++ "  (" ++ show steps ++ " steps)")

main :: IO ()
main = do
  putStrLn "---- pfactorial = eval (deBruijn factorial), reflected"
  putStr (lowString (lowPretty (reflect pfactorial)))
  putStrLn "---- pfactorial, C"
  putStr (lowString (toC "pfactorial" (reflect pfactorial)))
  putStrLn "---- run (the same values and steps as LowLambda's interpreter)"
  report "factorial 10 (Y)" pfactorial10
  report "fib 15 (Y)" pfibonacci
  report "6 * 7 (Church)" pchurch
  report "(\\ x -> 42) omega" plazy
  report "(\\ x -> if0 0 then 0 else x + x) (spin 1)" pneed
