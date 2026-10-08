-- See LICENSE file for full license.
--
-- Whole program optimization (mhs -wpo): the definitions of a program,
-- decoded on demand from their combinator code into lambda expressions for
-- the staged interpreter (MicroHs.Staged.Eval).
--
-- The definitions of all the modules of a program (including those from
-- packages) are combinator code: Exp without lambdas, where the combinators
-- are primitives (Lit (LPrim "S"), ...).  A combinator is a closed lambda
-- expression with the reduction rule of the runtime system (src/runtime/eval.c),
-- e.g. S x y z = x z (y z), so decoding replaces each by its lambda
-- expression.  Arguments are shared variables, as the runtime system shares
-- nodes, so call by need is kept.  Y (recursion) and the other primitives stay
-- primitives; the interpreter implements them.
module MicroHs.Staged.Decode(
  Defs, mkDefs, lookupDef, decode, reachable,
  ) where
import qualified Prelude(); import MHSPrelude
import Data.Char(isDigit, ord)
import Data.List(nub)
import MicroHs.Desugar(LDef)
import MicroHs.Exp
import MicroHs.Expr(Lit(..))
import MicroHs.Ident
import qualified MicroHs.IdentMap as M

-- The definitions of a program; each is decoded (lazily) the first time it
-- is used
newtype Defs = Defs (M.Map Exp)

mkDefs :: [LDef] -> Defs
mkDefs ds = Defs (M.fromList [ (i, decodeDef i e) | (i, e) <- ds ])

-- The decoded definition of a name, if it has one
lookupDef :: Ident -> Defs -> Maybe Exp
lookupDef i (Defs m) = M.lookup i m

-- Replace the combinators of an expression by lambda expressions
decode :: Exp -> Exp
decode = decodeDef (mkIdent "")

-- Replace the combinators of a definition by lambda expressions.  Every
-- lambda gets binders of its own (named after the definition and the
-- position of the combinator), so a lambda is identified by its first binder.
decodeDef :: Ident -> Exp -> Exp
decodeDef i e0 = fst (go e0 (0 :: Int))
  where
    go e n =
      case e of
        App f a -> let (f', n1) = go f n; (a', n2) = go a n1 in (App f' a', n2)
        Lam x b -> let (b', n1) = go b n in (Lam x b', n1)
        Lit (LPrim p) | Just l <- combinator (showIdent i ++ "$" ++ show n ++ "$") p -> (l, n + 1)
        _ -> (e, n)

-- The definitions reachable from a name (for -ddump-wpo)
reachable :: Defs -> Ident -> [(Ident, Exp)]
reachable defs i0 = go [] [i0]
  where
    go done [] = reverse done
    go done (i : is)
      | i `elem` map fst done = go done is
      | otherwise =
          case lookupDef i defs of
            Nothing -> go done is
            Just e -> go ((i, e) : done) (is ++ nub (freeVars e))

-- A combinator as a lambda expression, with the rule of the runtime system
combinator :: String -> String -> Maybe Exp
combinator pre p =
  case p of
    "S"   -> Just $ lam "xyz"   $ app [x, z, app [y, z]]
    "S'"  -> Just $ lam "xyzw"  $ app [x, app [y, w], app [z, w]]
    "K"   -> Just $ lam "xy"    x
    "A"   -> Just $ lam "xy"    y
    "U"   -> Just $ lam "xy"    $ app [y, x]
    "I"   -> Just $ lam "x"     x
    "B"   -> Just $ lam "xyz"   $ app [x, app [y, z]]
    "B'"  -> Just $ lam "xyzw"  $ app [x, y, app [z, w]]
    "Z"   -> Just $ lam "xyz"   $ app [x, y]
    "J"   -> Just $ lam "xyz"   $ app [z, x]
    "L"   -> Just $ lam "xyz"   $ app [y, x]
    "KK"  -> Just $ lam "xyz"   y
    "KA"  -> Just $ lam "xyz"   z
    "C"   -> Just $ lam "xyz"   $ app [x, z, y]
    "C'"  -> Just $ lam "xyzw"  $ app [x, app [y, w], z]
    "P"   -> Just $ lam "xyz"   $ app [z, x, y]
    "R"   -> Just $ lam "xyz"   $ app [y, z, x]
    "O"   -> Just $ lam "xyzw"  $ app [w, x, y]
    "K2"  -> Just $ lam "xyz"   x
    "K3"  -> Just $ lam "xyzw"  x
    "K4"  -> Just $ lam "xyzwv" x
    "C'B" -> Just $ lam "xyzw"  $ app [x, z, app [y, w]]
    'T' : n | Just k <- number n, k >= 3, k <= 16 ->
      -- Tk x1 ... xk f = f x1 ... xk
      let xs = [ v ("t" ++ show i) | i <- [1 .. k] ]
      in  Just $ lams' (map vi (xs ++ [v "f"])) (app (v "f" : xs))
    'T' : 'A' : 'G' : n | Just k <- number n ->
      -- TAGk x y = y k x
      Just $ lam "xy" $ app [y, Lit (LInt k), x]
    _ -> Nothing
  where
    v s = Var (mkIdent ("wpo$" ++ pre ++ s))
    vi (Var i) = i
    vi _ = undefined
    x = v "x"; y = v "y"; z = v "z"; w = v "w"
    lam cs b = lams' [ vi (v [c]) | c <- cs ] b
    lams' is b = foldr Lam b is
    app es = foldl1 App es
    number s | not (null s) && all isDigit s = Just (foldl (\ a c -> a * 10 + ord c - ord '0') 0 s)
             | otherwise = Nothing
