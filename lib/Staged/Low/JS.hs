-- A code generator from low code to JavaScript, as an example of a user
-- written backend for Staged.Low.  Data values are arrays [tag, field, ...],
-- functions are JavaScript functions, a case is a switch on the tag.
-- The main entry point is toJS; the generated program defines a function with
-- the given name that takes the free variables of the program (and its
-- parameters, if it is a function) and returns the result.
module Staged.Low.JS(toJS) where
import Prelude
import Data.Char(ord)
import Data.List(intercalate)
import Staged.Low

-- Statements are collected in a list (in reverse), expressions are strings.
newtype J a = J (([String], Int) -> (a, ([String], Int)))

unJ :: J a -> ([String], Int) -> (a, ([String], Int))
unJ (J f) = f

instance Functor J where
  fmap f (J g) = J $ \ s -> case g s of (a, s') -> (f a, s')
instance Applicative J where
  pure a = J $ \ s -> (a, s)
  J f <*> J a = J $ \ s -> case f s of (g, s') -> case a s' of (b, s'') -> (g b, s'')
instance Monad J where
  J g >>= f = J $ \ s -> case g s of (a, s') -> unJ (f a) s'

emit :: String -> J ()
emit l = J $ \ (ls, n) -> ((), (l : ls, n))

freshJ :: String -> J String
freshJ b = J $ \ (ls, n) -> (b ++ "_" ++ show n, (ls, n + 1))

-- Run a statement block, and return its statements.
block :: J a -> J (a, [String])
block act = J $ \ (ls, n) ->
  case unJ act ([], n) of
    (a, (ls', n')) -> ((a, reverse ls'), (ls, n'))

jsName :: String -> String
jsName = concatMap esc . baseName
  where esc c | c >= 'a' && c <= 'z' || c >= 'A' && c <= 'Z' || c >= '0' && c <= '9' || c == '_' = [c]
              | c == '\'' = "_q"
              | otherwise = "_" ++ show (ord c) ++ "_"

-- The value of a term, after emitting the statements that compute it.
gen :: LowTerm -> J String
gen at =
  case at of
    LVar x _ -> return (jsName x)
    LLit l _ -> return (jsLit l)
    LPrim p _ -> return ("/* primitive " ++ p ++ " */")
    LForeign _ c _ -> return c
    LApp f as -> do
      as' <- mapM gen as
      case f of
        LPrim p _ -> return (prim p as')
        _ -> do
          f' <- gen f
          return (f' ++ "(" ++ intercalate ", " as' ++ ")")
    LLam xs b -> do
      (r, ss) <- block (gen b)
      return ("function(" ++ intercalate ", " (map (jsName . fst) xs) ++ ") {\n" ++ unlines (map ("  " ++) ss) ++ "  return " ++ r ++ "; }")
    LLet x _ e b -> do
      e' <- gen e
      emit ("const " ++ jsName x ++ " = " ++ e' ++ ";")
      gen b
    LLetRec bs b -> do
      mapM_ (\ (x, _, e) -> do
               e' <- gen e
               emit ("function " ++ jsName x ++ "() { return (" ++ e' ++ ").apply(null, arguments); }")) bs
      gen b
    LCase s cons alts d -> do
      s' <- gen s
      r <- freshJ "r"
      emit ("let " ++ r ++ ";")
      case typeOf s of
        TData _ _ decl | declNewtype decl, [(_, [(x, _)], b)] <- alts -> do
          emit ("const " ++ jsName x ++ " = " ++ s' ++ ";")
          b' <- gen b
          emit (r ++ " = " ++ b' ++ ";")
        _ -> do
          emit ("switch (" ++ s' ++ "[0]) {")
          mapM_ (\ (c, xs, b) -> do
                   emit ("case " ++ show (conTag c) ++ ": {")
                   mapM_ (\ (i, (x, _)) -> emit ("const " ++ jsName x ++ " = " ++ s' ++ "[" ++ show i ++ "];")) (zip [1 :: Int ..] xs)
                   (b', ss) <- block (gen b)
                   mapM_ emit ss
                   emit (r ++ " = " ++ b' ++ "; break; }")) alts
          case d of
            Just e | length alts < length cons -> do
              emit "default: {"
              (e', ss) <- block (gen e)
              mapM_ emit ss
              emit (r ++ " = " ++ e' ++ "; break; }")
            _ -> return ()
          emit "}"
      return r
    LCon c _ as -> do
      as' <- mapM gen as
      return ("[" ++ intercalate ", " (show (conTag c) : as') ++ "]")
    LFail m -> return ("(() => { throw new Error(" ++ show m ++ "); })()")

jsLit :: LowLit -> String
jsLit l =
  case l of
    LitInt i -> show i
    LitInt64 i -> show i
    LitDouble d -> show d
    LitFloat f -> show f
    LitChar c -> show (ord c)
    LitString s -> foldr (\ c r -> "[1, " ++ show (ord c) ++ ", " ++ r ++ "]") "[0]" s

prim :: String -> [String] -> String
prim p as =
  case (p, as) of
    ("+", [a, b]) -> bin "+" a b
    ("-", [a, b]) -> bin "-" a b
    ("*", [a, b]) -> bin "*" a b
    ("quot", [a, b]) -> "Math.trunc(" ++ a ++ " / " ++ b ++ ")"
    ("rem", [a, b]) -> bin "%" a b
    ("subtract", [a, b]) -> bin "-" b a
    ("neg", [a]) -> "(-" ++ a ++ ")"
    ("==", [a, b]) -> bin "===" a b
    ("/=", [a, b]) -> bin "!==" a b
    ("<", [a, b]) -> bin "<" a b
    ("<=", [a, b]) -> bin "<=" a b
    (">", [a, b]) -> bin ">" a b
    (">=", [a, b]) -> bin ">=" a b
    ("d+", [a, b]) -> bin "+" a b
    ("d-", [a, b]) -> bin "-" a b
    ("d*", [a, b]) -> bin "*" a b
    ("d/", [a, b]) -> bin "/" a b
    ("dneg", [a]) -> "(-" ++ a ++ ")"
    ("d==", [a, b]) -> bin "===" a b
    ("d/=", [a, b]) -> bin "!==" a b
    ("d<", [a, b]) -> bin "<" a b
    ("d<=", [a, b]) -> bin "<=" a b
    ("d>", [a, b]) -> bin ">" a b
    ("d>=", [a, b]) -> bin ">=" a b
    ("itod", [a]) -> a
    ("dtoi", [a]) -> "Math.trunc(" ++ a ++ ")"
    ("ord", [a]) -> a
    ("chr", [a]) -> a
    ("seq", [_, b]) -> b
    _ -> "/* unknown primitive " ++ p ++ " */" ++ p ++ "(" ++ intercalate ", " as ++ ")"
  where bin o a b = "(" ++ a ++ " " ++ o ++ " " ++ b ++ ")"

-- Generate a JavaScript function with the given name.
toJS :: String -> LowProg -> String
toJS name p =
  let (params, body) =
        case progBody p of
          LLam xs b -> (xs, b)
          b -> ([], b)
      args = map (jsName . fst) (params ++ progFree p)
      ((r, ss), _) = unJ (block (gen body)) ([], 0)
  in  unlines $
        [ "// " ++ show d | d <- progDecls p ] ++
        [ "function " ++ name ++ "(" ++ intercalate ", " args ++ ") {" ] ++
        map ("  " ++) ss ++
        [ "  return " ++ r ++ ";", "}" ]
