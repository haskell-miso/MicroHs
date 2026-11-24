module StaticPtr(main) where
import Data.List(sort)
import Mhs.StaticPtr

inc :: Int -> Int
inc = (+ 1)

class Describe a where
  describe :: a -> String

instance Describe Bool where
  describe b = "bool " ++ show b

-- A static pointer at the top level.
pInc :: StaticPtr (Int -> Int)
pInc = static inc

-- Two static pointers in one definition.
pair :: Int -> (StaticPtr (Int -> Int), StaticPtr String)
pair _ = (static (inc . inc), static "hello")

-- The dictionary is known, so the expression is closed.
pDesc :: StaticPtr (Bool -> String)
pDesc = static describe

-- Nested.
pNest :: StaticPtr (StaticPtr Int)
pNest = static (static 42)

main :: IO ()
main = do
  print $ deRefStaticPtr pInc 1
  let (p2, ps) = pair 0
  print $ deRefStaticPtr p2 1
  putStrLn $ deRefStaticPtr ps
  putStrLn $ deRefStaticPtr pDesc True
  print $ deRefStaticPtr (deRefStaticPtr pNest)
  -- The same static form always gives the same name
  print $ staticPtrName (fst (pair 1)) == staticPtrName p2
  mapM_ putStrLn $ sort staticPtrNames
  -- Send the name, look it up on the other side.
  case unsafeLookupStaticPtr (staticPtrName p2) of
    Just p  -> print (deRefStaticPtr p (10 :: Int) :: Int)
    Nothing -> putStrLn "not found"
  case unsafeLookupStaticPtr "nope" :: Maybe (StaticPtr Int) of
    Just _  -> putStrLn "found"
    Nothing -> putStrLn "not found"
