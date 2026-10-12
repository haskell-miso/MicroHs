module LowMem(main) where
import Staged.Low
import Staged.Low.C(toC)
import Staged.Low.JS(toJS)

-- Memory in low code: a flat array of words, as a value (Mem) that peek and
-- poke take and return.  Store the squares 0, 1, 4, ... at addresses
-- 0 .. n-1, then read them back and sum them.  fill returns the memory
-- after the writes; sumUp reads it (peek does not consume it) and returns
-- it with the sum.  The backends erase the Mem values: tests/LowMem.sh
-- compiles the C and checks the sums.
squares :: Low (Mem -> Int -> Int)
squares = [| \ m0 n ->
  let fill m i = if i == n then m else fill (poke m i (i * i)) (i + 1)
      sumUp m i acc = if i == n then (acc, m) else sumUp m (i + 1) (acc + peek m i)
  in case sumUp (fill m0 0) 0 0 of
       (s, _) -> s |]

cMain :: String
cMain = unlines
  [ "int main(int argc, char **argv) {"
  , "  for (int i = 1; i < argc; i++) printf(\"%lld\\n\", (long long)squares(0, atoll(argv[i])));"
  , "  return 0;"
  , "}" ]

main :: IO ()
main = do
  putStrLn "---- squares, reflected"
  putStr (lowString (lowPretty (reflect squares)))
  putStrLn "---- squares, C"
  let c = lowString (toC "squares" (reflect squares))
  putStr c
  writeFile "LowMem.squares.c" (c ++ cMain)
  putStrLn "---- squares, JavaScript"
  putStr (lowString (toJS "squares" (reflect squares)))
