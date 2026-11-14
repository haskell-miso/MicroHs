module StaticPtrPoly(main) where
import Mhs.StaticPtr

-- Polymorphic static pointers; there is no Typeable constraint.
pLen :: StaticPtr ([a] -> Int)
pLen = static length

pId :: StaticPtr (a -> a)
pId = static id

pJust :: StaticPtr (a -> Maybe a)
pJust = static Just

-- The dictionary is known where the pointer is made.
pShow :: StaticPtr (Int -> String)
pShow = static show

-- A polymorphic enclosing function, the expression is still closed.
mk :: a -> (a, StaticPtr ([b] -> [b]))
mk x = (x, static reverse)

main :: IO ()
main = do
  print (deRefStaticPtr pLen "abc", deRefStaticPtr pLen [True, False])
  print (deRefStaticPtr pId (5 :: Int), deRefStaticPtr pId 'x')
  print (deRefStaticPtr pJust 'q')
  putStrLn (deRefStaticPtr pShow 42)
  print (deRefStaticPtr (snd (mk 'c')) [1, 2, 3 :: Int], deRefStaticPtr (snd (mk True)) "abc")
  -- Look up a polymorphic pointer by name and use it at a type of its own.
  case unsafeLookupStaticPtr (staticPtrName pLen) of
    Just p  -> print (deRefStaticPtr p [(), ()] :: Int)
    Nothing -> putStrLn "not found"
