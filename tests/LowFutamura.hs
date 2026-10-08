module LowFutamura(main) where
import Data.List(elemIndex)
import Staged.Low
import Staged.Low.C(toC)

-- The first Futamura projection with two-level type theory: an interpreter
-- for the lambda calculus whose term is a compile time (meta level) value.
-- Applying it to a program runs the interpreter in the compiler, and what is
-- left is low code for that program: the program compiled, with no trace of
-- the interpreter (no terms, environments, or closures).
--
-- Compare tests/LowLambda.hs, where the interpreter has the type
-- Low (Term -> Res): there the term is a run time value, so applying the
-- interpreter to a program specializes nothing.

-- Terms, with de Bruijn indices.  Fix b is a recursive function of one
-- argument: in b, Var 0 is the argument and Var 1 the function itself.
data Term = Var Int | Lam Term | App Term Term
          | Lit Int | Prim Op Term Term | If0 Term Term Term
          | Fix Term

data Op = Plus | Minus | Times

-- Compile time values.  Only integers can be dynamic (known at run time);
-- a function value of the object language is a compile time function.
data SVal = SLit Int                -- an integer known at compile time
          | SDyn Bool (Low Int)     -- run time integer code; True if it is a variable,
                                    -- so it can be used more than once without recomputing it
          | SFun (SVal -> SVal)     -- an object language closure

-- The interpreter, at the meta level.  The meta level is lazy Haskell, so an
-- argument is only evaluated when it is used (call by need at compile time).
peval :: Term -> [SVal] -> SVal
peval t env =
  case t of
    Var n -> env !! n
    Lam b -> SFun (\ v -> share (uses 0 b) v (\ v' -> peval b (v' : env)))
    App f a -> apply (peval f env) (peval a env)
    Lit n -> SLit n
    Prim o a b -> prim o (peval a env) (peval b env)
    If0 c a b ->
      case peval c env of
        SLit 0 -> peval a env                           -- known condition: choose now
        SLit _ -> peval b env
        c' -> SDyn False [| if ~(int c') == 0 then ~(int (peval a env)) else ~(int (peval b env)) |]
    Fix b ->
      let self = SFun (\ v ->
            case v of
              -- a known argument: unfold the recursion in the compiler
              SLit _ -> peval b (v : self : env)
              -- a run time argument: the recursion becomes a low recursive function
              _ -> SDyn False $ runGen $ do
                     go <- genRec $ \ go ->
                             [| \ n -> ~(int (peval b (SDyn True [| n |] : dynFun go : env))) |]
                     return [| ~go ~(int v) |])
      in self

-- Run time code for an integer
int :: SVal -> Low Int
int v =
  case v of
    SLit n -> lowInt n
    SDyn _ c -> c
    SFun _ -> error "peval: a function where an integer was expected"

apply :: SVal -> SVal -> SVal
apply f a =
  case f of
    SFun g -> g a
    _ -> error "peval: applying an integer"

-- A call of a low recursive function
dynFun :: Low (Int -> Int) -> SVal
dynFun go = SFun (\ v -> SDyn False [| ~go ~(int v) |])

prim :: Op -> SVal -> SVal -> SVal
prim o (SLit x) (SLit y) =
  SLit (case o of { Plus -> x + y; Minus -> x - y; Times -> x * y })
prim o a b =
  SDyn False (case o of
                Plus  -> [| ~(int a) + ~(int b) |]
                Minus -> [| ~(int a) - ~(int b) |]
                Times -> [| ~(int a) * ~(int b) |])

-- A run time argument that is used more than once is bound to a variable,
-- so its code is not duplicated.
share :: Int -> SVal -> (SVal -> SVal) -> SVal
share n v k =
  if n < 2 then k v else
  case v of
    SDyn False e -> bindDyn e k
    _ -> k v

bindDyn :: Low Int -> (SVal -> SVal) -> SVal
bindDyn e k =
  -- Look at the shape of the result (a dynamic variable cannot change it)
  case k (SDyn True (lowInt 0)) of
    SFun _ -> SFun (\ w -> bindDyn e (\ x -> apply (k x) w))
    r@(SLit _) -> r
    _ -> SDyn False (genLet e (\ x -> int (k (SDyn True x))))

-- How many times a variable occurs; a use inside a recursive function counts
-- as many.
uses :: Int -> Term -> Int
uses i t =
  case t of
    Var n -> if n == i then 1 else 0
    Lam b -> uses (i + 1) b
    App f a -> uses i f + uses i a
    Lit _ -> 0
    Prim _ a b -> uses i a + uses i b
    If0 c a b -> uses i c + uses i a + uses i b
    Fix b -> 2 * uses (i + 2) b

-- The projections: a closed program, and a program of one run time input
compile0 :: Term -> Low Int
compile0 t = int (peval t [])

compile1 :: Term -> Low (Int -> Int)
compile1 t = [| \ n -> ~(int (apply (peval t []) (SDyn True [| n |]))) |]

-------------------------------------------------------------------------------
-- Writing terms with names

data Named = V String | L String Named | Named :@ Named
           | N Int | Named :+ Named | Named :- Named | Named :* Named
           | IfZ Named Named Named
           | Rec String String Named      -- Rec f x body: a recursive function
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
        Rec f x b -> Fix (go (x : f : vs) b)

omega :: Named
omega = w :@ w
  where w = L "x" (V "x" :@ V "x")

-- The lazy fixed point combinator
fixY :: Named
fixY = L "f" (w :@ w)
  where w = L "x" (V "f" :@ (V "x" :@ V "x"))

factorialRec, factorialY, fibonacciRec, square1, shared :: Named
factorialRec = Rec "fact" "n" (IfZ (V "n") (N 1) (V "n" :* (V "fact" :@ (V "n" :- N 1))))
factorialY = fixY :@ L "fact" (L "n" (IfZ (V "n") (N 1) (V "n" :* (V "fact" :@ (V "n" :- N 1)))))
fibonacciRec = Rec "fib" "n"
                 (IfZ (V "n") (N 0)
                   (IfZ (V "n" :- N 1) (N 1)
                     (V "fib" :@ (V "n" :- N 1) :+ V "fib" :@ (V "n" :- N 2))))
square1 = L "x" (V "x" :* V "x" :+ N 1)
shared = L "x" (L "y" (V "y" :+ V "y") :@ (V "x" :* V "x"))

-- Run time code: the compiled programs are spliced in.
factorialC, fibonacciC, square1C, sharedC :: Int -> Int
factorialC = compile1 (deBruijn factorialRec)
fibonacciC = compile1 (deBruijn fibonacciRec)
square1C = compile1 (deBruijn square1)
sharedC = compile1 (deBruijn shared)

lazyC, factorial10C, factorialY10C :: Int
lazyC = compile0 (deBruijn (L "x" (N 42) :@ omega))
factorial10C = compile0 (deBruijn (factorialRec :@ N 10))
factorialY10C = compile0 (deBruijn (factorialY :@ N 10))

main :: IO ()
main = do
  putStrLn "---- factorial, compiled (reflected)"
  putStr (lowString (lowPretty (reflect (compile1 (deBruijn factorialRec)))))
  putStrLn "---- factorial, compiled to C"
  putStr (lowString (toC "factorial" (reflect (compile1 (deBruijn factorialRec)))))
  putStrLn "---- fib, compiled (reflected)"
  putStr (lowString (lowPretty (reflect (compile1 (deBruijn fibonacciRec)))))
  putStrLn "---- \\ x -> x * x + 1, compiled: straight line code"
  putStr (lowString (lowPretty (reflect (compile1 (deBruijn square1)))))
  putStrLn "---- \\ x -> (\\ y -> y + y) (x * x), compiled: the argument is shared"
  putStr (lowString (lowPretty (reflect (compile1 (deBruijn shared)))))
  putStrLn "---- factorial 10, compiled: computed by the compiler"
  putStr (lowString (lowPretty (reflect (compile0 (deBruijn (factorialRec :@ N 10))))))
  putStrLn "---- factorial 10 with the Y combinator, compiled: lazy at compile time"
  putStr (lowString (lowPretty (reflect (compile0 (deBruijn (factorialY :@ N 10))))))
  putStrLn "---- (\\ x -> 42) omega, compiled: omega is never evaluated"
  putStr (lowString (lowPretty (reflect (compile0 (deBruijn (L "x" (N 42) :@ omega))))))
  putStrLn "---- run"
  print (map factorialC [0, 1, 5, 10], factorialC 10 == product [1 .. 10])
  print (map fibonacciC [0, 1, 2, 15])
  print (square1C 7, sharedC 3)
  print (lazyC, factorial10C, factorialY10C)
