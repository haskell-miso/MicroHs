module LowInstance(main) where
import Staged.Low

-- A user class whose methods make low code, with an instance that has a
-- context.  The splice uses the instance dictionaries, which are meta level;
-- they must not be left behind in the object code.
class Size a where
  size :: a -> Low Int

instance Size Int where
  size _ = [| 1 |]

instance (Size a, Size b) => Size (a, b) where
  size (x, y) = [| ~(size x) + ~(size y) |]

instance Size a => Size [a] where
  size [] = [| 0 |]
  size (x : xs) = [| ~(size x) + ~(size xs) |]

main :: IO ()
main = do
  print ~(size (1 :: Int, 2 :: Int))
  print ~(size [(1 :: Int, 2 :: Int), (3, 4), (5, 6)])
