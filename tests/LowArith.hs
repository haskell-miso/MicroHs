module LowArith(main) where
-- An interpreter and a compiler for a small language of assignments, from one
-- implementation: eval works for any Num, so it interprets with Word and
-- compiles with Low Word, whose operations build code.
import Staged.Low
import Staged.Low.C(toC)
import Data.Char

type List a = [a]

data Arg where
  Num :: Word   -> Arg
  Var :: String -> Arg

data Exp where
  Val :: String -> Arg -> Exp
  Add :: String -> Arg -> Arg -> Exp
  Mul :: String -> Arg -> Arg -> Exp

data Env a where
  EmptyEnv :: Env a
  EntryEnv :: String -> a -> Env a -> Env a

-- Low Word is a number: the operations build code.
instance Num (Low Word) where
  x + y = [| ~x + ~y |]
  x - y = [| ~x - ~y |]
  x * y = [| ~x * ~y |]
  abs x = x
  signum x = [| if ~x == 0 then 0 else 1 |]
  fromInteger n = lowWord (fromInteger n)

parse :: List String -> List Exp
parse (name : "=" : arg : ";" : s) = Val name (parseArg arg) : parse s
parse (name : "=" : a1 : "+" : a2 : ";" : s) = Add name (parseArg a1) (parseArg a2) : parse s
parse (name : "=" : a1 : "*" : a2 : ";" : s) = Mul name (parseArg a1) (parseArg a2) : parse s
parse _ = []

parseArg :: String -> Arg
parseArg s | all isDigit s = Num (read s)
           | otherwise     = Var s

envLookup :: Env a -> String -> a
envLookup (EntryEnv n v e) name = if n == name then v else envLookup e name
envLookup EmptyEnv name = error $ "envLookup - unknown name: " ++ name

envInsert :: Env a -> String -> a -> Env a
envInsert e name value = EntryEnv name value e

lastEntry :: Env a -> a
lastEntry (EntryEnv _ v _) = v

-- One implementation, for any kind of number.

evalArg :: Num w => Arg -> Env w -> w
evalArg (Var name) env = envLookup env name
evalArg (Num n) env = fromIntegral n

evalExp :: Num w => Exp -> Env w -> Env w
evalExp (Val name arg) env = envInsert env name (evalArg arg env)
evalExp (Add name arg1 arg2) env = envInsert env name (evalArg arg1 env + evalArg arg2 env)
evalExp (Mul name arg1 arg2) env = envInsert env name (evalArg arg1 env * evalArg arg2 env)

eval :: Num w => List Exp -> Env w -> Env w
eval [] env = env
eval (exp : l) env = eval l (evalExp exp env)

-- The interpreter and the compiler differ only in their types.

interp :: List Exp -> Env Word -> Env Word
interp = eval

comp :: List Exp -> Env (Low Word) -> Env (Low Word)
comp = eval

src :: String
src = "x = 2 ; v1 = x ; v2 = v1 ; v3 = v2 ; v4 = v3 ; b = v4 ; y = x + 2 ; a = 12 ; z = y * b ; w = 12 * z ; q = w * 2 ;"

ast :: List Exp
ast = parse (words src)

prg :: Low Word
prg = lastEntry (comp ast EmptyEnv)

main :: IO ()
main = do
  print (lastEntry (interp ast EmptyEnv))
  print ~prg
  putStr ~(lowString (lowPretty (reflect prg)))
  putStr ~(lowString (toC "arith" (reflect prg)))
