module Low1(main) where
import Staged.Low

-- Closure free staging: the quotations have type (Low t), so the generated
-- code is first order and strict, and can be reflected (see Low2).

-- The "hello world" of staging, with Low instead of Code.
power :: Int -> Low Int -> Low Int
power 0 _ = [| 1 |]
power n x = [| ~x * ~(power (n - 1) x) |]

-- Low code spliced into ordinary code runs as ordinary code.
cube :: Int -> Int
cube x = ~(power 3 [| x |])

-- A loop: a recursive low function, made with genRec.
sumSq :: Low Int -> Low Int
sumSq n = runGen $ do
  go <- genRec $ \ go -> [| \ i acc -> if i > ~n then acc else ~go (i + 1) (acc + i * i) |]
  return [| ~go 1 0 |]

sumSquares :: Int -> Int
sumSquares n = ~(sumSq [| n |])

-- Local functions, lets and literals.
fac :: Int -> Int
fac n = ~([| let go i acc = if i == 0 then acc else go (i - 1) (acc * i) in go n 1 |])

-- Data types: a user defined type, Maybe, lists, tuples, Bool, Double.
data Shape = Circle Double | Rect Double Double

area :: Low Shape -> Low Double
area s = [| case ~s of { Circle r -> 3.0 * r * r; Rect w h -> w * h } |]

areaOf :: Shape -> Double
areaOf s = ~(area [| s |])

lenL :: Low [Int] -> Low Int
lenL xs = runGen $ do
  go <- genRec $ \ go -> [| \ l acc -> case l of { [] -> acc; _ : r -> ~go r (acc + 1) } |]
  return [| ~go ~xs 0 |]

len :: [Int] -> Int
len xs = ~(lenL [| xs |])

swap :: (Int, Int) -> (Int, Int)
swap p = ~([| case ~([| p |]) of (a, b) -> (b, a) |])

safeDiv :: Int -> Int -> Maybe Int
safeDiv x y = ~([| if y == 0 then Nothing else Just (x `quot` y) |])

-- A polymorphic generator: the type variable needs LowRep (it is a value type in the low code).
twice :: LowRep a => Low (a -> a) -> Low a -> Low a
twice f x = genLet x $ \ y -> [| ~f (~f ~y) |]

incTwice :: Int -> Int
incTwice n = ~(twice [| \ k -> k + 1 |] [| n |])

-- Guards and nested patterns use the full pattern match compiler.
classify :: Int -> Maybe (Int, Int) -> String
classify n mp = ~([| case mp of
                       Just (a, b) | a > n -> "big"
                                   | b > n -> "medium"
                       Just _ -> "small"
                       Nothing -> "none" |])

-- Strictness: low code is call by value.  A let is evaluated before its body.
strict :: Int -> Int
strict n = ~([| let x = n * 2 in let y = x + 1 in y * y |])

-- Compile time values turned into low code.
constants :: (Int, Double, Char, String, Bool)
constants = ~([| (~(lowInt (2 + 3)), ~(lowDouble 2.5), ~(lowChar 'x'), ~(lowString "hi"), ~(lowBool True)) |])

main :: IO ()
main = do
  print (cube 3)
  print (sumSquares 10)
  print (fac 10)
  print (areaOf (Circle 2), areaOf (Rect 2 3))
  print (len [1, 2, 3, 4])
  print (swap (1, 2))
  print (safeDiv 7 2, safeDiv 1 0)
  print (incTwice 5)
  print (classify 5 (Just (10, 1)), classify 5 (Just (1, 10)), classify 5 (Just (1, 1)), classify 5 Nothing)
  print (strict 10)
  print constants
