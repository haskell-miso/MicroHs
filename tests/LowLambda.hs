module LowLambda(main) where
import Data.List(elemIndex)
import Staged.Low
import Staged.Low.C(toC)

-- A call by need (lazy) interpreter for the untyped lambda calculus,
-- written as closure free low code, with the quotations and splices
-- inferred by the type checker (see stageCoercion in TypeCheck.hs).
--
-- Low code has no closures and no mutable references, so everything the
-- interpreter needs is first order data, threaded explicitly (store passing,
-- as in Launchbury's natural semantics for lazy evaluation):
--
--  * a function value is a closure represented as data: its environment
--    and its body;
--  * an environment maps variables to heap addresses;
--  * an application allocates a thunk for its argument (the argument's
--    environment and term) instead of evaluating it;
--  * forcing a variable evaluates its thunk once and overwrites it with the
--    value, so every later use shares the result.
--
-- The heap is a binary tree indexed by the bits of an address, so lookup,
-- allocation, and update are logarithmic.

-- Terms, with de Bruijn indices
data Term = Var Int | Lam Term | App Term Term
          | Lit Int | Prim Op Term Term | If0 Term Term Term
  deriving (Show)

data Op = Plus | Minus | Times
  deriving (Show)

-- An environment: the heap addresses of the variables, innermost first
data Env = Nil | Bind Int Env
  deriving (Show)

-- Values; the environment of a closure holds heap addresses
data Val = VInt Int | VClo Env Term
  deriving (Show)

-- A heap cell is an unevaluated thunk or a value
data Cell = Thunk Env Term | Done Val

-- Address 1 is the root, address a has children 2a and 2a+1
data Heap = Empty | Node Heap Cell Heap

-- The next free address, the heap, and the number of evaluation steps
data St = St Int Heap Int

data Res = Res Val St

eval :: Low (Term -> Res)
eval = \ t0 ->
  let half a = a `quot` 2
      isEven a = a - 2 * half a == 0
      fetch h a = case h of
                    Node l c r -> if a == 1 then c
                                  else if isEven a then fetch l (half a) else fetch r (half a)
      store h a c = case h of
                      Empty -> Node Empty c Empty
                      Node l c0 r -> if a == 1 then Node l c r
                                     else if isEven a then Node (store l (half a) c) c0 r
                                     else Node l c0 (store r (half a) c)
      look env n = case env of
                     Bind a r -> if n == 0 then a else look r (n - 1)
      prim o x y = case o of
                     Plus  -> x + y
                     Minus -> x - y
                     Times -> x * y
      ev st env t =
        case st of
          St next h steps ->
            let st0 = St next h (steps + 1) in
            case t of
              Var n ->
                let a = look env n in
                case fetch h a of
                  Done v -> Res v st0
                  Thunk tenv tt ->
                    case ev st0 tenv tt of                -- force the thunk ...
                      Res v st1 ->
                        case st1 of
                          St next1 h1 steps1 ->           -- ... and update it with its value
                            Res v (St next1 (store h1 a (Done v)) steps1)
              Lam b -> Res (VClo env b) st0
              App f x ->
                case ev st0 env f of
                  Res fv st1 ->
                    case fv of
                      VClo cenv b ->
                        case st1 of
                          St next1 h1 steps1 ->           -- allocate a thunk for the argument
                            ev (St (next1 + 1) (store h1 next1 (Thunk env x)) steps1) (Bind next1 cenv) b
              Lit n -> Res (VInt n) st0
              Prim o x y ->
                case ev st0 env x of
                  Res vx st1 ->
                    case vx of
                      VInt i ->
                        case ev st1 env y of
                          Res vy st2 ->
                            case vy of
                              VInt j -> Res (VInt (prim o i j)) st2
              If0 c x y ->
                case ev st0 env c of
                  Res vc st1 ->
                    case vc of
                      VInt i -> if i == 0 then ev st1 env x else ev st1 env y
  in ev (St 1 Empty 0) Nil t0

-- Ordinary run time code: the low interpreter is spliced in.
run :: Term -> Res
run t = eval t

-------------------------------------------------------------------------------
-- Writing terms with names (ordinary Haskell, not part of the interpreter)

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
        V x      -> maybe (error ("unbound " ++ x)) Var (elemIndex x vs)
        L x b    -> Lam (go (x : vs) b)
        f :@ a   -> App (go vs f) (go vs a)
        N n      -> Lit n
        a :+ b   -> Prim Plus (go vs a) (go vs b)
        a :- b   -> Prim Minus (go vs a) (go vs b)
        a :* b   -> Prim Times (go vs a) (go vs b)
        IfZ c a b -> If0 (go vs c) (go vs a) (go vs b)

-- A term that never finishes evaluating
omega :: Named
omega = w :@ w
  where w = L "x" (V "x" :@ V "x")

-- Church numerals
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

factorial, fibonacci :: Named
factorial = fixY :@ L "fact" (L "n" (IfZ (V "n") (N 1) (V "n" :* (V "fact" :@ (V "n" :- N 1)))))
fibonacci = fixY :@ L "fib" (L "n"
              (IfZ (V "n") (N 0)
                (IfZ (V "n" :- N 1) (N 1)
                  (V "fib" :@ (V "n" :- N 1) :+ V "fib" :@ (V "n" :- N 2)))))

-- Run a term, and show its value and the number of evaluation steps
test :: String -> Named -> IO ()
test name e =
  case run (deBruijn e) of
    Res v (St _ _ steps) -> putStrLn (name ++ " = " ++ show v ++ "  (" ++ show steps ++ " steps)")

main :: IO ()
main = do
  putStrLn "---- eval, reflected"
  putStr (lowString (lowPretty (reflect eval)))
  putStrLn "---- eval, C"
  putStr (lowString (toC "eval" (reflect eval)))
  putStrLn "---- run"
  test "2 + 3 * 4" (N 2 :+ N 3 :* N 4)
  test "(\\ x -> x + 1) 41" (L "x" (V "x" :+ N 1) :@ N 41)
  test "\\ x y -> x" (L "x" (L "y" (V "x")))
  -- laziness: the argument is never evaluated
  test "(\\ x -> 42) omega" (L "x" (N 42) :@ omega)
  test "(\\ x y -> y) omega 7" (L "x" (L "y" (V "y")) :@ omega :@ N 7)
  test "2 + 3 (Church)" (toInt :@ (plusC :@ church 2 :@ church 3))
  test "6 * 7 (Church)" (toInt :@ (timesC :@ church 6 :@ church 7))
  test "factorial 10 (Y)" (factorial :@ N 10)
  test "fib 15 (Y)" (fibonacci :@ N 15)
  -- sharing: the argument is evaluated once, not four times
  test "(\\ x -> x + x + x + x) (fib 15)" (L "x" (V "x" :+ V "x" :+ V "x" :+ V "x") :@ (fibonacci :@ N 15))
