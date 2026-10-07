module StagedInferInst(main) where
import Staged

-- With a user instance for code types, x * y is valid meta code, so no
-- quotation may be inserted: the instance is used (it deliberately adds).
instance Num (Code Int) where
  x + y = [| ~x + ~y |]
  x * y = [| ~x + ~y |]
  fromInteger n = codeInt (fromInteger n)
  abs x = x
  signum x = x
  negate x = [| negate ~x |]

f :: Code Int -> Code Int
f x = x * x

g :: Int -> Int
g y = ~(f [| y |])

main :: IO ()
main = print (g 3)     -- the instance's * : 3 + 3 = 6
