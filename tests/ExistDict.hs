{-# LANGUAGE ScopedTypeVariables, ExistentialQuantification, ConstraintKinds, LambdaCase #-}
module ExistDict(main) where
import Unsafe.Coerce

-- The context of an existential constructor also constrains a parameter (Eq p).
-- When the constructor is matched where p is not known yet, the dictionaries
-- for the existential variables must still be available.
data T p m a = T p
data Box p = forall m a . (Eq p, Show m, Read a, Show a) => Box (T p m a)

type C p a = (Eq p, Read a, Show a)
data Box2 p = forall a . C p a => Box2 (T p () a)

box :: Box ()
box = Box (T () :: T () Int Int)

box2 :: Box2 ()
box2 = Box2 (T () :: T () () Double)

-- The type of the result is chosen by the caller, as with unsafeLookupStaticPtr.
lookupAny :: forall x y . y -> IO (Maybe x)
lookupAny y = pure (Just (unsafeCoerce y))

decode :: forall p m a . (Read a, Show a) => T p m a -> String -> String
decode _ s = show (read s :: a)

main :: IO ()
main = do
  -- With a pattern signature.
  lookupAny box >>= \case
    Nothing -> putStrLn "not found"
    Just b -> case b of
      Box (_ :: T p m a) -> putStrLn (show (read "42" :: a))
  -- Without a pattern signature.
  lookupAny box >>= \case
    Nothing -> putStrLn "not found"
    Just b -> case b of
      Box t -> putStrLn (decode t "43")
  -- A constraint synonym.  (Other names than above: pattern type variables
  -- of one statement are still in scope in the next.)
  lookupAny box2 >>= \case
    Nothing -> putStrLn "not found"
    Just b -> case b of
      Box2 (_ :: T q () b) -> putStrLn (show (read "1.5" :: b))
  -- The parameter's dictionary is used once the parameter is known.
  case box of
    Box (T p) -> print (p == ())
