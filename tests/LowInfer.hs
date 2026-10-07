module LowInfer(main) where
import Staged.Low
import Staged.Low.C(toC)
import Staged.Low.JS(toJS)

-- The examples of Low2 without quotations and splices:
-- the type checker inserts them (see stageCoercion in TypeCheck.hs).

sumSq :: Low (Int -> Int)
sumSq = \ n -> runGen $ do
          go <- genRec $ \ go -> \ i acc -> if i > n then acc else go (i + 1) (acc + i * i)
          return (go 1 0)

data Shape = Circle Double | Rect Double Double

scaledArea :: Low (Double -> Shape -> Double)
scaledArea = \ k s -> let scale x = x * k in
                      case s of
                        Circle r -> scale (3.0 * r * r)
                        Rect w h -> scale (w * h)

firstBig :: Low (Int -> [Int] -> Maybe Int)
firstBig = \ n xs ->
             let big = (<) n
                 go l = case l of
                          [] -> Nothing
                          x : r -> if big x then Just x else go r
             in go xs

sumSquares :: Int -> Int
sumSquares = sumSq

main :: IO ()
main = do
  putStrLn "---- sumSq, reflected"
  putStr (lowString (lowPretty (reflect sumSq)))
  putStrLn "---- sumSq, C"
  putStr (lowString (toC "sumsq" (reflect sumSq)))
  putStrLn "---- sumSq, JavaScript"
  putStr (lowString (toJS "sumsq" (reflect sumSq)))
  putStrLn "---- scaledArea, reflected"
  putStr (lowString (lowPretty (reflect scaledArea)))
  putStrLn "---- scaledArea, C"
  putStr (lowString (toC "scaled_area" (reflect scaledArea)))
  putStrLn "---- firstBig, reflected"
  putStr (lowString (lowPretty (reflect firstBig)))
  putStrLn "---- firstBig, JavaScript"
  putStr (lowString (toJS "firstBig" (reflect firstBig)))
  putStrLn "---- run"
  print (sumSquares 10, scaledArea 2 (Rect 3 4), firstBig 5 [1, 7, 3, 9])
