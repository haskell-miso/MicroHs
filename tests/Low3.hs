module Low3(main) where
import Staged.Low
import Staged.Low.C(toC)

-- Examples from "Closure-Free Functional Programming in a Two-Level Type Theory"
-- (Kovacs, ICFP 2024), with Low as the closure free object language.

-----------------------------------------------------------------------
-- Pull streams (section 4, without the generic sums of products).
-- A stream is a state machine: an initial state and a step function, both
-- generating low code.  The state type is existential; it is a value type,
-- so it has a LowRep.  All the stream combinators run at compile time, and
-- a pipeline becomes a single first order loop: no closures, no lists.

data Step a s = Stop | Skip s | Yield a s

data Pull a = forall s . LowRep s => Pull (Low s) (Low s -> Gen (Step a (Low s)))

unG :: Gen a -> (a -> Low r) -> Low r
unG (Gen g) = g

range :: Low Int -> Low Int -> Pull (Low Int)
range lo hi = Pull lo $ \ s -> Gen $ \ k ->
  [| if ~s > ~hi then ~(k Stop) else ~(k (Yield s [| ~s + 1 |])) |]

mapP :: (a -> b) -> Pull a -> Pull b
mapP f (Pull s0 step) = Pull s0 $ \ s -> do
  st <- step s
  return $ case st of
             Stop -> Stop
             Skip s' -> Skip s'
             Yield a s' -> Yield (f a) s'

filterP :: (Low a -> Low Bool) -> Pull (Low a) -> Pull (Low a)
filterP p (Pull s0 step) = Pull s0 $ \ s -> do
  st <- step s
  case st of
    Yield a s' -> Gen $ \ k -> [| if ~(p a) then ~(k (Yield a s')) else ~(k (Skip s')) |]
    _ -> return st

-- Zipping two streams: the state is a pair of states.
zipWithP :: (a -> b -> c) -> Pull a -> Pull b -> Pull c
zipWithP f (Pull s1 st1) (Pull s2 st2) = Pull [| (~s1, ~s2) |] $ \ s -> Gen $ \ k ->
  [| case ~s of
       (x, y) -> ~(unG (st1 [| x |]) $ \ r1 -> case r1 of
         Stop -> k Stop
         Skip x' -> k (Skip [| (~x', y) |])
         Yield a x' -> unG (st2 [| y |]) $ \ r2 -> case r2 of
           Stop -> k Stop
           Skip y' -> k (Skip [| (x, ~y') |])
           Yield b y' -> k (Yield (f a b) [| (~x', ~y') |])) |]

-- The consumer: a loop, a recursive low function of the accumulator and the state.
foldlP :: LowRep b => (Low b -> a -> Low b) -> Low b -> Pull a -> Low b
foldlP f z (Pull s0 step) = runGen $ do
  loop <- genRec $ \ loop -> [| \ acc s -> ~(unG (step [| s |]) $ \ st -> case st of
                                  Stop -> [| acc |]
                                  Skip s' -> [| ~loop acc ~s' |]
                                  Yield a s' -> [| ~loop ~(f [| acc |] a) ~s' |]) |]
  return [| ~loop ~z ~s0 |]

sumP :: Pull (Low Int) -> Low Int
sumP = foldlP (\ acc x -> [| ~acc + ~x |]) [| 0 |]

-- The sum of the squares of the even numbers in 1 .. n.
sumEvenSquares :: Low (Int -> Int)
sumEvenSquares = [| \ n -> ~(sumP (mapP (\ x -> [| ~x * ~x |]) (filterP (\ x -> [| ~x `rem` 2 == 0 |]) (range [| 1 |] [| n |])))) |]

-- The dot product of two arithmetic sequences, by zipping.
dotSeq :: Low (Int -> Int)
dotSeq = [| \ n -> ~(sumP (zipWithP (\ a b -> [| ~a * ~b |]) (range [| 1 |] [| n |]) (range [| 10 |] [| 1000 |]))) |]

-----------------------------------------------------------------------
-- Monads by binding time improvement (section 3.3): Maybe in the object
-- language, a Maybe monad transformer at the meta level.  The binds are
-- computed at compile time; only the case splits remain.

data MaybeM a = NothingM | JustM a

newtype MaybeT a = MaybeT { runMaybeT :: Gen (MaybeM a) }

instance Functor MaybeT where
  fmap f (MaybeT g) = MaybeT (fmap (\ m -> case m of { NothingM -> NothingM; JustM a -> JustM (f a) }) g)
instance Applicative MaybeT where
  pure a = MaybeT (pure (JustM a))
  mf <*> ma = mf >>= \ f -> fmap f ma
instance Monad MaybeT where
  MaybeT g >>= f = MaybeT (g >>= \ m -> case m of { NothingM -> pure NothingM; JustM a -> runMaybeT (f a) })

-- up: case split an object level Maybe; down: build one.
up :: LowRep a => Low (Maybe a) -> MaybeT (Low a)
up m = MaybeT $ Gen $ \ k -> [| case ~m of { Nothing -> ~(k NothingM); Just a -> ~(k (JustM [| a |])) } |]

down :: LowRep a => MaybeT (Low a) -> Low (Maybe a)
down (MaybeT (Gen g)) = g (\ r -> case r of { NothingM -> [| Nothing |]; JustM a -> [| Just ~a |] })

safeDiv :: Low Int -> Low Int -> MaybeT (Low Int)
safeDiv x y = up [| if ~y == 0 then Nothing else Just (~x `quot` ~y) |]

-- (a / b) / c + 1, failing on a division by zero.
divDiv :: Low (Int -> Int -> Int -> Maybe Int)
divDiv = [| \ a b c -> ~(down $ do
                          q <- safeDiv [| a |] [| b |]
                          r <- safeDiv q [| c |]
                          return [| ~r + 1 |]) |]

-----------------------------------------------------------------------
-- Foreign C functions can be used in low code.

foreign import ccall "sqrt" c_sqrt :: Double -> Double

hypot :: Low (Double -> Double -> Double)
hypot = [| \ x y -> c_sqrt (x * x + y * y) |]

main :: IO ()
main = do
  putStrLn "---- sumEvenSquares"
  putStr ~(lowString (lowPretty (reflect sumEvenSquares)))
  putStr ~(lowString (toC "sum_even_squares" (reflect sumEvenSquares)))
  putStrLn "---- dotSeq"
  putStr ~(lowString (lowPretty (reflect dotSeq)))
  putStrLn "---- divDiv"
  putStr ~(lowString (lowPretty (reflect divDiv)))
  putStrLn "---- hypot"
  putStr ~(lowString (toC "hypot2" (reflect hypot)))
  putStrLn "---- run"
  print ((~sumEvenSquares) 10, (~dotSeq) 3)
  print ((~divDiv) 100 5 2, (~divDiv) 100 0 2, (~divDiv) 100 5 0)
  print ((~hypot) 3 4)
