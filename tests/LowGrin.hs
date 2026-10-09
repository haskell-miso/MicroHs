module LowGrin(main) where
import MicroHs.Exp(Exp(..))
import qualified MicroHs.Expr as E
import MicroHs.Ident(mkIdent)
import Staged.Low
import Staged.Low.C(toC)
import Staged.Low.Grin

-- Lazy programs in the lambda calculus of MicroHs (MicroHs.Exp, the
-- compiler's own type: compile with -i../src -i../mhs), compiled to
-- low code with a heap (GRIN's store, fetch and update) by a staged call by
-- need interpreter (Staged.Low.Grin), and from low code to C (Staged.Low.C).
-- For every program: the static analysis that the compiler accumulates, the
-- low code, and the C.  The C files (LowGrin.<name>.c, with a main that
-- prints the result for the numbers on the command line) are compiled and
-- run by tests/LowGrin.sh, which compares with the reference interpreter.

v :: String -> Exp
v = Var . mkIdent

lam :: String -> Exp -> Exp
lam x = Lam (mkIdent x)

(@@) :: Exp -> Exp -> Exp
(@@) = App
infixl 9 @@

int :: Int -> Exp
int = Lit . E.LInt

prim :: String -> Exp
prim = Lit . E.LPrim

op :: String -> Exp -> Exp -> Exp
op o a b = prim o @@ a @@ b

-- Scott encoded Bools (the comparisons) and lists: if c then t else e is
-- c e t, [] is K and (:) is O, as in MicroHs
ifte :: Exp -> Exp -> Exp -> Exp
ifte c t e = c @@ e @@ t

nil :: Exp
nil = prim "K"

cons :: Exp -> Exp -> Exp
cons x xs = prim "O" @@ x @@ xs

-- case xs of [] -> n; y : ys -> c
caseList :: Exp -> Exp -> String -> String -> Exp -> Exp
caseList xs n y ys c = xs @@ n @@ lam y (lam ys c)

-- Programs: global definitions, as after desugaring (MicroHs.Desugar.LDef)

defs :: [(String, Exp)] -> Prog
defs ds = [ (mkIdent g, e) | (g, e) <- ds ]

factorial :: Prog
factorial = defs
  [ ("main", lam "n" (prim "Y" @@ lam "fact" (lam "m"
                (ifte (op "==" (v "m") (int 0)) (int 1) (op "*" (v "m") (v "fact" @@ op "-" (v "m") (int 1))))) @@ v "n")) ]

listLib :: Prog
listLib = defs
  [ ("zipWith", lam "f" (lam "xs" (lam "ys" (caseList (v "xs") nil "x" "xt" (caseList (v "ys") nil "y" "yt"
                   (cons (v "f" @@ v "x" @@ v "y") (v "zipWith" @@ v "f" @@ v "xt" @@ v "yt")))))))
  , ("tail", lam "xs" (caseList (v "xs") nil "x" "xt" (v "xt")))
  , ("nth", lam "xs" (lam "n" (caseList (v "xs") (int 0) "x" "xt"
               (ifte (op "==" (v "n") (int 0)) (v "x") (v "nth" @@ v "xt" @@ op "-" (v "n") (int 1))))))
  , ("enumFromTo", lam "a" (lam "b" (ifte (op ">" (v "a") (v "b")) nil (cons (v "a") (v "enumFromTo" @@ op "+" (v "a") (int 1) @@ v "b")))))
  , ("sum", lam "xs" (caseList (v "xs") (int 0) "x" "xt" (op "+" (v "x") (v "sum" @@ v "xt"))))
  , ("map", lam "f" (lam "xs" (caseList (v "xs") nil "x" "xt" (cons (v "f" @@ v "x") (v "map" @@ v "f" @@ v "xt")))))
  ]

-- fibs = 0 : 1 : zipWith (+) fibs (tail fibs); main n = fibs !! n
fibs :: Prog
fibs = listLib ++ defs
  [ ("fibs", cons (int 0) (cons (int 1) (v "zipWith" @@ prim "+" @@ v "fibs" @@ (v "tail" @@ v "fibs"))))
  , ("main", lam "n" (v "nth" @@ v "fibs" @@ v "n")) ]

-- main n = sum (map (\ x -> x * x) [1 .. n])
sumSquares :: Prog
sumSquares = listLib ++ defs
  [ ("main", lam "n" (v "sum" @@ (v "map" @@ lam "x" (op "*" (v "x") (v "x")) @@ (v "enumFromTo" @@ int 1 @@ v "n")))) ]

-- combinators: main = S K K (+ 1), a lazy argument that is never used, and C
combinators :: Prog
combinators = defs
  [ ("loop", v "loop")
  , ("main", lam "n" (prim "S" @@ prim "K" @@ prim "K" @@ (prim "K" @@ (prim "C" @@ prim "-" @@ v "n" @@ int 100) @@ v "loop"))) ]

-- known at compile time: 6 * 7 with Church numerals
church :: Prog
church = defs
  [ ("two", lam "f" (lam "x" (v "f" @@ (v "f" @@ v "x"))))
  , ("three", lam "f" (lam "x" (v "f" @@ (v "f" @@ (v "f" @@ v "x")))))
  , ("times", lam "m" (lam "n" (lam "f" (v "m" @@ (v "n" @@ v "f")))))
  , ("toInt", lam "c" (v "c" @@ lam "k" (op "+" (v "k") (int 1)) @@ int 0))
  , ("main", v "toInt" @@ (v "times" @@ (v "times" @@ v "two" @@ v "three") @@ (prim "S" @@ prim "B" @@ prim "I" @@ v "three")))
  ]

-- What the compiler shows for a program (at compile time): the analysis,
-- the low code, and the C
report :: String -> Prog -> String
report name prog =
  "==== " ++ name ++ "\n" ++
  showInfo prog True ++
  "---- low code\n" ++ lowPretty (reflect (compileFun prog)) ++
  "---- C\n" ++ cCode name prog

cCode :: String -> Prog -> String
cCode name prog = toC name (reflect (compileFun prog))

cMain :: String -> String
cMain name = unlines
  [ "int main(int argc, char **argv) {"
  , "  for (int i = 1; i < argc; i++) printf(\"%lld\\n\", (long long)" ++ name ++ "(atoll(argv[i])));"
  , "  return 0;"
  , "}" ]

main :: IO ()
main = do
  putStr (lowString (report "factorial" factorial))
  writeFile "LowGrin.factorial.c" (lowString (cCode "factorial" factorial ++ cMain "factorial"))
  putStrLn "---- reference interpreter"
  print [ (n, interp factorial (Just n)) | n <- [0, 1, 5, 10, 20] ]

  putStr (lowString (report "fibs" fibs))
  writeFile "LowGrin.fibs.c" (lowString (cCode "fibs" fibs ++ cMain "fibs"))
  putStrLn "---- reference interpreter"
  print [ (n, interp fibs (Just n)) | n <- [0, 1, 2, 10, 40] ]

  putStr (lowString (report "sumSquares" sumSquares))
  writeFile "LowGrin.sumSquares.c" (lowString (cCode "sumSquares" sumSquares ++ cMain "sumSquares"))
  putStrLn "---- reference interpreter"
  print [ (n, interp sumSquares (Just n)) | n <- [0, 1, 10, 100] ]

  putStr (lowString (report "combinators" combinators))
  writeFile "LowGrin.combinators.c" (lowString (cCode "combinators" combinators ++ cMain "combinators"))
  putStrLn "---- reference interpreter"
  print [ (n, interp combinators (Just n)) | n <- [0, 7] ]

  putStrLn "==== church (known at compile time)"
  putStr (lowString (lowPretty (reflect (compileInt church))))
  print (interp church Nothing)
