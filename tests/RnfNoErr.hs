module RnfNoErr(main) where
import Primitives(primRnfNoErr)
import qualified Data.ByteString as BS

-- cprint first evaluates its argument with primRnfNoErr, which evaluates as
-- much as it can, also inside function bodies, but must not raise an
-- exception or do IO.  These used to stop the program.

-- Building the error message packs a ByteString with performIO, which
-- primRnfNoErr does not run (was: ERR: evalbstr, bad tag AP).
f1 :: Int -> Int
f1 x = if x > 0 then x else error "boom"

-- An exception raised by the runtime system (was: uncaught exception: DivideByZero).
f2 :: Int -> Int
f2 x = x + 1 `div` 0

-- An exception in the argument of a ByteString primitive.
f3 :: Int -> Int
f3 x = x + BS.length (error "no bytestring")

-- An IO action.  It must not be run: evaluating its graph reaches the C
-- calls that do the output (was: ERR: evalforptr, bad tag AP, or the output
-- happened and the rest of main was lost).
io :: IO ()
io = print (1 :: Int)

check :: String -> a -> IO ()
check s f = primRnfNoErr f `seq` putStrLn (s ++ " ok")

main :: IO ()
main = do
  check "f1" f1
  check "f2" f2
  check "f3" f3
  check "io" io
  -- the functions still work
  print (f1 5)
  -- and the evaluation of data is unchanged
  let xs = [1, 2 + 3, 4] :: [Int]
  primRnfNoErr xs `seq` print xs
