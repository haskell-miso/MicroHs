module StagedInfer(main) where
import Staged
import qualified Staged.Low as L

-- The examples of Staged1 and Low1 without quotations and splices:
-- the type checker inserts them (see stageCoercion in TypeCheck.hs).

-- [| 1 |] and [| ~x * ~(power (n - 1) x) |]
power :: Int -> Code Int -> Code Int
power 0 _ = 1
power n x = x * power (n - 1) x

-- ~(power 3 [| x |])
cube :: Int -> Int
cube x = power 3 x

-- let n = 2 + 3 in ~(power n [| x |])
power5 :: Int -> Int
power5 x = let n = 2 + 3 in power n x

-- ~(codeInt (sum [1 .. 100]))
staticSum :: Int
staticSum = codeInt (sum [1 .. 100])

-- [| ~(codeInt k) * ~x * ~x + ~(sumSquares ks x) |]
sumSquares :: [Int] -> Code Int -> Code Int
sumSquares [] _ = 0
sumSquares (k : ks) x = codeInt k * x * x + sumSquares ks x

poly :: Int -> Int
poly x = sumSquares [1, 2, 3] x

-- The same with Low code.
powerL :: Int -> L.Low Int -> L.Low Int
powerL 0 _ = 1
powerL n x = x * powerL (n - 1) x

cubeL :: Int -> Int
cubeL x = powerL 3 x

main :: IO ()
main = do
  print (cube 3)
  print (power5 2)
  print staticSum
  print (poly 2)
  print (cubeL 3)
