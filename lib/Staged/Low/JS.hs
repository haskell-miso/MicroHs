-- A code generator from low code to JavaScript, as an example of a user
-- written backend for Staged.Low.  A value of a data type whose constructors
-- have no fields (e.g. Bool) is its tag (a number), other data values are
-- arrays [tag, field, ...], a newtype is its field.  Local functions are
-- JavaScript functions, a case is a switch on the tag.
-- The main entry point is toJS; the generated program defines a function with
-- the given name that takes the free variables of the program (and its
-- parameters, if it is a function) and returns the result.
module Staged.Low.JS(toJS) where
import Prelude
import Data.Char(ord, isAsciiLower, isAsciiUpper, isDigit)
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
  where esc c | isAsciiLower c || isAsciiUpper c || isDigit c || c == '_' = [c]
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
      f <- freshJ "f"
      defFun f xs b
      return f
    LLet x _ (LLam xs e) b -> do
      defFun (jsName x) xs e
      gen b
    LLet x _ e b -> do
      e' <- gen e
      emit ("const " ++ jsName x ++ " = " ++ e' ++ ";")
      gen b
    LLetRec bs b -> do
      -- function declarations are hoisted, so they can call each other
      mapM_ (\ (x, _, e) ->
               case e of
                 LLam xs e' -> defFun (jsName x) xs e'
                 _ -> do { e' <- gen e; emit ("const " ++ jsName x ++ " = " ++ e' ++ ";") }) bs
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
        st -> do
          emit ("switch (" ++ (if isEnumTy st then s' else s' ++ "[0]") ++ ") {")
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
    LCon c t as -> do
      as' <- mapM gen as
      case t of
        _ | conNewtype c, [a] <- as' -> return a
        _ | isEnumTy t -> return (show (conTag c))
        _ -> return ("[" ++ intercalate ", " (show (conTag c) : as') ++ "]")
    LFail m -> return ("(() => { throw new Error(" ++ show m ++ "); })()")

-- A function declaration.
defFun :: String -> [(String, LowTy)] -> LowTerm -> J ()
defFun f xs b = do
  (r, ss) <- block (gen b)
  emit ("function " ++ f ++ "(" ++ intercalate ", " (map (jsName . fst) xs) ++ ") {")
  mapM_ (emit . ("  " ++)) ss
  emit ("  return " ++ r ++ ";")
  emit "}"

isEnumTy :: LowTy -> Bool
isEnumTy (TData _ _ d) = not (declNewtype d) && all (null . conDeclFields) (declCons d)
isEnumTy _ = False

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
    ("==", [a, b]) -> cmp "===" a b
    ("/=", [a, b]) -> cmp "!==" a b
    ("<", [a, b]) -> cmp "<" a b
    ("<=", [a, b]) -> cmp "<=" a b
    (">", [a, b]) -> cmp ">" a b
    (">=", [a, b]) -> cmp ">=" a b
    ("d+", [a, b]) -> bin "+" a b
    ("d-", [a, b]) -> bin "-" a b
    ("d*", [a, b]) -> bin "*" a b
    ("d/", [a, b]) -> bin "/" a b
    ("dneg", [a]) -> "(-" ++ a ++ ")"
    ("d==", [a, b]) -> cmp "===" a b
    ("d/=", [a, b]) -> cmp "!==" a b
    ("d<", [a, b]) -> cmp "<" a b
    ("d<=", [a, b]) -> cmp "<=" a b
    ("d>", [a, b]) -> cmp ">" a b
    ("d>=", [a, b]) -> cmp ">=" a b
    ("itod", [a]) -> a
    ("dtoi", [a]) -> "Math.trunc(" ++ a ++ ")"
    ("ord", [a]) -> a
    ("chr", [a]) -> a
    ("seq", [_, b]) -> b
    _ -> "/* unknown primitive " ++ p ++ " */" ++ p ++ "(" ++ intercalate ", " as ++ ")"
  where bin o a b = "(" ++ a ++ " " ++ o ++ " " ++ b ++ ")"
        cmp o a b = "(" ++ a ++ " " ++ o ++ " " ++ b ++ " ? 1 : 0)"    -- a Bool is its tag

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
