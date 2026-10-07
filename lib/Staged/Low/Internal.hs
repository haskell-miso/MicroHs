-- Closure-free two-level type theory: the representation of low code.
--
-- This module is the interface between the compiler and the library: the code
-- that the compiler generates for a Low quotation builds values of LowExp with
-- the functions below, and the type checker solves LowRep constraints by
-- building LowTy values.  MicroHs.Stage has mirrors of the data types, so
-- the constructors and their order must not change without changing Stage.hs.
-- The user facing interface is Staged.Low.
module Staged.Low.Internal(
  Low,
  LowTy(..), LowDecl(..), LowConDecl(..), LowCon(..), LowLit(..),
  LowAlt(..), LowExp(..),
  LowRep(..), LowTyP(..), lowTyOf,
  toLow, fromLow,
  hLamT, lowFunRest, lowFunResult, lowNth, lowLitFromInteger, lowLitFromRational, tUnit,
  ) where
import Prelude
import Data.Int(Int64)
import Primitives(Low)

-- The types of low code.
data LowTy
  = TInt | TWord | TInt64 | TWord64 | TDouble | TFloat | TChar
  | TFun [LowTy] LowTy             -- a first order function type (computation type)
  | TData String [LowTy] LowDecl   -- a data type: name, type arguments, declaration
  | TParam Int                     -- a type parameter, only inside a LowDecl
  | TOther String                  -- a type that low code cannot handle

-- The declaration of a data type.  The field types refer to the parameters with TParam.
data LowDecl = LowDecl { declName :: String, declArity :: Int, declNewtype :: Bool, declCons :: [LowConDecl] }

data LowConDecl = LowConDecl { conDeclName :: String, conDeclTag :: Int, conDeclFields :: [LowTy] }

-- A constructor as used in code: name, tag (number among the constructors of the type), arity, newtype.
data LowCon = LowCon { conName :: String, conTag :: Int, conArity :: Int, conNewtype :: Bool }

data LowLit = LitInt Int | LitInt64 Int64 | LitDouble Double | LitFloat Float | LitChar Char | LitString String

-- Low code with HOAS binders, as built by the compiler generated code.
-- The type of a variable is recorded when it is bound (HVar, HLam, HLetRec);
-- the types of other variables are determined by the read back (Staged.Low.reflect).
data LowExp
  = HVar Int String LowTy                              -- a variable: de Bruijn level, name, type
  | HLam String LowTy (LowExp -> LowExp)
  | HApp LowExp [LowExp]
  | HLet String (Maybe LowTy) LowExp (LowExp -> LowExp)
  | HLetRec [(String, LowTy)] ([LowExp] -> ([LowExp], LowExp))
  | HCase LowExp [LowCon] [LowAlt] (Maybe LowExp)      -- scrutinee, all constructors of the type, alternatives, default
  | HCon LowCon LowTy [LowExp]                         -- constructor application; the type is the (function) type of the constructor
  | HLit LowLit LowTy
  | HPrim String LowTy                                 -- a primitive of the runtime system
  | HForeign String String LowTy                       -- a foreign function: Haskell name, C name
  | HFail String                                       -- a failed pattern match, or error

data LowAlt = LowAlt LowCon [String] ([LowExp] -> LowExp)

instance Eq LowTy where
  TInt == TInt = True
  TWord == TWord = True
  TInt64 == TInt64 = True
  TWord64 == TWord64 = True
  TDouble == TDouble = True
  TFloat == TFloat = True
  TChar == TChar = True
  TFun as r == TFun bs s = as == bs && r == s
  TData n as _ == TData m bs _ = n == m && as == bs
  TParam i == TParam j = i == j
  TOther s == TOther t = s == t
  _ == _ = False

-- The declaration is not shown, since it can be recursive.
instance Show LowTy where
  showsPrec p t =
    case t of
      TInt -> showString "Int"
      TWord -> showString "Word"
      TInt64 -> showString "Int64"
      TWord64 -> showString "Word64"
      TDouble -> showString "Double"
      TFloat -> showString "Float"
      TChar -> showString "Char"
      TFun as r -> showParen (p > 0) $ foldr (\ a s -> showsPrec 1 a . showString " -> " . s) (showsPrec 0 r) as
      TData n [a] _ | base n == "[]" -> showChar '[' . showsPrec 0 a . showChar ']'
      TData n as _ | all (== ',') (base n), length as == length (base n) + 1 ->
        showChar '(' . foldr (.) id (zipWith (\ i a -> (if i == (0 :: Int) then id else showString ", ") . showsPrec 0 a) [0 ..] as) . showChar ')'
      TData n [] _ -> showString (base n)
      TData n as _ -> showParen (p > 10) $ showString (base n) . foldr (\ a s -> showChar ' ' . showsPrec 11 a . s) id as
      TParam i -> showChar '#' . shows i
      TOther s -> showString "{" . showString s . showString "}"

-- Operators (and tuple constructors) in parentheses.
paren :: String -> String
paren n@(c : _) | c == ',' || c == ':' = "(" ++ n ++ ")"
paren n = n

-- The name without the module qualifier.
base :: String -> String
base s =
  case break (== '.') s of
    (m, '.' : r) | not (null m) && all (\ c -> c /= '(' && c /= '[') m && not (null r) -> base r
    _ -> s

instance Show LowDecl where
  showsPrec _ (LowDecl n a nt cs) =
    showString (if nt then "newtype " else "data ") . showString (paren (base n)) .
    foldr (.) id [ showString " #" . shows i | i <- [0 .. a - 1] ] . showString " = " .
    foldr (.) id [ (if i == (0 :: Int) then id else showString " | ") . showString (paren (base (conDeclName c))) .
                   foldr (\ t s -> showChar ' ' . showsPrec 11 t . s) id (conDeclFields c)
                 | (i, c) <- zip [0 ..] cs ]

instance Show LowCon where
  showsPrec _ c = showString (conName c)

instance Eq LowCon where
  a == b = conName a == conName b

deriving instance Show LowLit
deriving instance Eq LowLit

-- The run time representation of a type, solved by the compiler for every type:
-- for a type variable a, a (LowRep a) constraint is needed.
newtype LowTyP a = LowTyP LowTy

class LowRep a where
  lowTyP :: LowTyP a

lowTyOf :: forall a . LowRep a => a -> LowTy
lowTyOf _ = case lowTyP :: LowTyP a of LowTyP t -> t

-- Low code is represented by LowExp.
toLow :: forall a . LowExp -> Low a
toLow = _primitive "I"

fromLow :: forall a . Low a -> LowExp
fromLow = _primitive "I"

-- A lambda, with the type of the variable taken from the function type t.
hLamT :: LowTy -> String -> (LowExp -> LowExp) -> LowExp
hLamT t x f = HLam x (arg t) f
  where arg (TFun (a : _) _) = a
        arg _ = TOther "argument of a non-function"

-- The type of a function after one argument.
lowFunRest :: LowTy -> LowTy
lowFunRest (TFun [_] r) = r
lowFunRest (TFun (_ : as) r) = TFun as r
lowFunRest t = t

lowFunResult :: LowTy -> LowTy
lowFunResult (TFun _ r) = r
lowFunResult t = t

lowNth :: forall a . Int -> [a] -> a
lowNth n xs = xs !! n

-- Numeric literals whose type was not known when they were type checked.
lowLitFromInteger :: Int -> LowTy -> LowExp
lowLitFromInteger n t =
  case t of
    TDouble -> HLit (LitDouble (fromIntegral n)) t
    TFloat -> HLit (LitFloat (fromIntegral n)) t
    TInt64 -> HLit (LitInt64 (fromIntegral n)) t
    TWord64 -> HLit (LitInt64 (fromIntegral n)) t
    _ -> HLit (LitInt n) t

lowLitFromRational :: Int -> Int -> LowTy -> LowExp
lowLitFromRational n d t =
  case t of
    TFloat -> HLit (LitFloat (fromIntegral n / fromIntegral d)) t
    _ -> HLit (LitDouble (fromIntegral n / fromIntegral d)) t

tUnit :: LowTy
tUnit = lowTyOf ()
