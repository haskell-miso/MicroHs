-- A code generator from low code to C, as an example of a user written backend
-- for Staged.Low.  Since low code is first order, strict, and monomorphic,
-- the translation is direct (the primitives are those of the runtime system,
-- with the same meaning as in src/runtime/eval.c):
--  * Int, Word, Double, Float and Char are C scalars;
--  * a data type whose constructors all have no fields is an int (the tag);
--  * other data types are structs with a tag and a union of the fields,
--    allocated with malloc (and never freed: this example has no memory management);
--  * local functions (let and letrec bound lambdas) become C functions; the
--    variables of the enclosing scope they use are passed as extra arguments
--    (lambda lifting), which is always possible since functions never escape;
--  * a case is a switch, a let is a declaration;
--  * a heap cell (store, fetch, update) is a malloced array of words.
-- The main entry point is toC; the generated program has a function with
-- the given name that takes the free variables (and the parameters, if the
-- program is a function) and returns the result.
module Staged.Low.C(toC) where
import Prelude
import Data.Char(ord, isAsciiLower, isAsciiUpper, isDigit)
import Data.Maybe(fromMaybe)
import Data.List(intercalate, nub)
import Staged.Low

-- The output: function definitions (in order), and the statements of the current function.
data CS = CS { csFuns :: [String], csStmts :: [String], csUniq :: Int, csDecls :: [String] }

newtype C a = C (CS -> (a, CS))

unC :: C a -> CS -> (a, CS)
unC (C f) = f

instance Functor C where
  fmap f (C g) = C $ \ s -> case g s of (a, s') -> (f a, s')
instance Applicative C where
  pure a = C $ \ s -> (a, s)
  C f <*> C a = C $ \ s -> case f s of (g, s') -> case a s' of (b, s'') -> (g b, s'')
instance Monad C where
  C g >>= f = C $ \ s -> case g s of (a, s') -> unC (f a) s'

emit :: String -> C ()
emit l = C $ \ s -> ((), s{ csStmts = l : csStmts s })

freshC :: String -> C String
freshC b = C $ \ s -> (b ++ "_" ++ show (csUniq s), s{ csUniq = csUniq s + 1 })

addFun :: String -> C ()
addFun f = C $ \ s -> ((), s{ csFuns = f : csFuns s })

-- Run the statements of a function body in a fresh statement buffer.
block :: C a -> C (a, [String])
block act = C $ \ s ->
  case unC act s{ csStmts = [] } of
    (a, s') -> ((a, reverse (csStmts s')), s'{ csStmts = csStmts s })

-- C types

cType :: LowTy -> String
cType t =
  case t of
    TInt -> "int64_t"
    TWord -> "uint64_t"
    TInt64 -> "int64_t"
    TWord64 -> "uint64_t"
    TDouble -> "double"
    TFloat -> "float"
    TChar -> "int32_t"
    TData n _ d | isEnum d -> "int"
                | otherwise -> "struct " ++ cName n ++ "*"
    TFun _ _ -> "void*"       -- never happens: functions are not values
    _ -> "void*"

isEnum :: LowDecl -> Bool
isEnum d = all (null . conDeclFields) (declCons d)

cName :: String -> String
cName = concatMap esc . baseName
  where esc c | isAsciiLower c || isAsciiUpper c || isDigit c = [c]
              | c == '_' = "_"
              | c == '(' = "T"
              | c == ')' = ""
              | c == ',' = "c"
              | c == '[' = "L"
              | c == ']' = "ist"
              | c == ':' = "Cons"
              | c == '\'' = "_q"
              | otherwise = "_" ++ show (ord c) ++ "_"

cVar :: String -> String
cVar = cName

-- The declaration of a data type (not for enumerations).
-- Type parameters are instantiated per use, so a type with parameters becomes a
-- struct per instantiation; for simplicity this example uses void* for parameters.
cDecl :: LowDecl -> String
cDecl d
  | isEnum d = "/* " ++ declName d ++ ": " ++ intercalate ", " [ cName (conDeclName c) ++ "=" ++ show (conDeclTag c) | c <- declCons d ] ++ " */"
  | otherwise =
      "struct " ++ cName (declName d) ++ " { int tag; union { " ++
      concat [ "struct { " ++ concat [ cType (param t) ++ " f" ++ show i ++ "; " | (i, t) <- zip [0 :: Int ..] (conDeclFields c) ] ++ "} " ++ cName (conDeclName c) ++ "; "
             | c <- declCons d, not (null (conDeclFields c)) ] ++
      "} u; };"
  where param (TParam _) = TOther "void*"
        param t = t

-- The environment: the variables in scope with their types, and the lifted
-- functions with the variables they capture.
data Env = Env { eVars :: [(String, LowTy)], eFuns :: [(String, [(String, LowTy)])] }

addVars :: [(String, LowTy)] -> Env -> Env
addVars xs env = env{ eVars = xs ++ eVars env }

addFunCaps :: String -> [(String, LowTy)] -> Env -> Env
addFunCaps f caps env = env{ eFuns = (f, caps) : eFuns env }

-- Code generation.  gen returns a C expression for the value of the term,
-- after emitting the statements that compute it.

gen :: Env -> LowTerm -> C String
gen env at =
  case at of
    LVar x _ -> return (cVar x)
    LLit l _ -> return (cLit l)
    LPrim p _ -> return p
    LForeign _ c _ -> return c
    LApp f as -> do
      as' <- mapM (gen env) as
      case f of
        LPrim p _ -> return (prim p as')
        LForeign _ c _ -> return (c ++ "(" ++ intercalate ", " as' ++ ")")
        LVar g _ ->
          -- a call of a local function: pass the captured variables too
          let caps = [ cVar v | (v, _) <- fromMaybe [] (lookup g (eFuns env)) ]
          in  return (cVar g ++ "(" ++ intercalate ", " (caps ++ as') ++ ")")
        _ -> return "/* bad call */0"
    LLam _ _ -> return "/* lambda */0"
    LLet x t e b
      | TFun _ _ <- t -> do
          let caps = capturedOf env e
              env' = addFunCaps x caps (addVars [(x, t)] env)
          defineFun env' x caps e
          gen env' b
      | otherwise -> do
          e' <- gen env e
          emit (cType t ++ " " ++ cVar x ++ " = " ++ e' ++ ";")
          gen (addVars [(x, t)] env) b
    LLetRec bs b -> do
      -- all the functions of the group capture the same variables
      let caps = nub (concat [ capturedOf env e | (_, _, e) <- bs ])
          env' = foldr (\ (x, _, _) -> addFunCaps x caps) (addVars [ (x, t) | (x, t, _) <- bs ] env) bs
      -- prototypes first, so that the functions can call each other
      mapM_ (\ (x, t, e) -> protoFun x t caps e) bs
      mapM_ (\ (x, _, e) -> defineFun env' x caps e) bs
      gen env' b
    LCase s cons alts d -> do
      s' <- gen env s
      let st = typeOf s
      r <- freshC "r"
      emit (cType (typeOf at) ++ " " ++ r ++ ";")
      case (st, cons) of
        (TData _ _ decl, _) | declNewtype decl, [(_, [(x, t)], b)] <- alts -> do
          emit (cType t ++ " " ++ cVar x ++ " = " ++ s' ++ ";")
          b' <- gen (addVars [(x, t)] env) b
          emit (r ++ " = " ++ b' ++ ";")
        (TData _ _ decl, _) -> do
          let tag = if isEnum decl then s' else s' ++ "->tag"
          emit ("switch (" ++ tag ++ ") {")
          mapM_ (\ (c, xs, b) -> do
                   emit ("case " ++ show (conTag c) ++ ": {")
                   mapM_ (\ (i, (x, t)) -> emit (cType t ++ " " ++ cVar x ++ " = " ++ s' ++ "->u." ++ cName (conName c) ++ ".f" ++ show i ++ ";")) (zip [0 :: Int ..] xs)
                   (b', ss) <- block (gen (addVars xs env) b)
                   mapM_ emit ss
                   emit (r ++ " = " ++ b' ++ "; break; }")) alts
          case d of
            Just e | length alts < length cons -> do
              emit "default: {"
              (e', ss) <- block (gen env e)
              mapM_ emit ss
              emit (r ++ " = " ++ e' ++ "; break; }")
            _ -> emit "default: abort();"      -- cannot happen: all constructors are covered
          emit "}"
        _ -> emit ("/* case on " ++ show st ++ " */")
      return r
    LCon c t as -> do
      as' <- mapM (gen env) as
      case t of
        TData n _ decl
          | isEnum decl -> return (show (conTag c))
          | declNewtype decl -> return (head as')
          | otherwise -> do
              v <- freshC "c"
              let sn = "struct " ++ cName n
              emit (sn ++ "* " ++ v ++ " = malloc(sizeof(" ++ sn ++ "));")
              emit (v ++ "->tag = " ++ show (conTag c) ++ ";")
              mapM_ (\ (i, a) -> emit (v ++ "->u." ++ cName (conName c) ++ ".f" ++ show i ++ " = " ++ a ++ ";")) (zip [0 :: Int ..] as')
              return v
        _ -> return "/* bad constructor */0"
    LFail m -> do
      emit ("fprintf(stderr, \"%s\\n\", " ++ show m ++ "); abort();")
      return "0"
    -- the heap: a cell is an array of words
    LStore as -> do
      as' <- mapM (gen env) as
      v <- freshC "n"
      emit ("int64_t *" ++ v ++ " = malloc(" ++ show (length as) ++ " * sizeof(int64_t));")
      mapM_ (\ (i, a) -> emit (v ++ "[" ++ show i ++ "] = " ++ a ++ ";")) (zip [0 :: Int ..] as')
      return ("(int64_t)" ++ v)
    LFetch q i -> do
      -- read now: an update later must not change the value
      q' <- gen env q
      v <- freshC "f"
      emit ("int64_t " ++ v ++ " = ((int64_t *)" ++ q' ++ ")[" ++ show i ++ "];")
      return v
    LUpdate q as -> do
      q' <- gen env q
      as' <- mapM (gen env) as
      v <- freshC "u"
      emit ("int64_t *" ++ v ++ " = (int64_t *)" ++ q' ++ ";")
      mapM_ (\ (i, a) -> emit (v ++ "[" ++ show i ++ "] = " ++ a ++ ";")) (zip [0 :: Int ..] as')
      return "0"

-- Functions are lambda lifted to C functions.  The captured variables are the
-- free variables of the body that are bound in the environment (except
-- functions), and the variables captured by the functions it calls.
capturedOf :: Env -> LowTerm -> [(String, LowTy)]
capturedOf env e =
  nub $ [ (v, t) | (v, _) <- fvs, Just t <- [lookup v (eVars env)], not (isFun t) ] ++
        concat [ caps | (v, _) <- fvs, Just caps <- [lookup v (eFuns env)] ]
  where fvs = freeVars e
        isFun (TFun _ _) = True
        isFun _ = False

funSig :: String -> LowTy -> [(String, LowTy)] -> LowTerm -> String
funSig x t caps e =
  case (t, e) of
    (TFun _ r, LLam xs _) ->
      "static " ++ cType r ++ " " ++ cVar x ++ "(" ++ intercalate ", " [ cType pt ++ " " ++ cVar p | (p, pt) <- caps ++ xs ] ++ ")"
    _ -> "static void " ++ cVar x ++ "(void)"

protoFun :: String -> LowTy -> [(String, LowTy)] -> LowTerm -> C ()
protoFun x t caps e = addFun (funSig x t caps e ++ ";")

defineFun :: Env -> String -> [(String, LowTy)] -> LowTerm -> C ()
defineFun env x caps e =
  case e of
    LLam xs b -> do
      let t = typeOf e
      (r, ss) <- block (gen (addVars (xs ++ caps) env) b)
      addFun (funSig x t caps e ++ " {\n" ++ unlines (map ("  " ++) ss) ++ "  return " ++ r ++ ";\n}")
    _ -> addFun ("/* " ++ x ++ " is not a function */")

cLit :: LowLit -> String
cLit l =
  case l of
    LitInt i -> show i
    LitInt64 i -> show i
    LitDouble d -> show d
    LitFloat f -> show f
    LitChar c -> show (ord c)
    LitString s -> show s ++ "/* a Haskell string: a list of Char */"

-- The primitives of the runtime system that low code can use.
prim :: String -> [String] -> String
prim p as =
  case (p, as) of
    ("+", [a, b]) -> bin "+" a b
    ("-", [a, b]) -> bin "-" a b
    ("*", [a, b]) -> bin "*" a b
    ("quot", [a, b]) -> bin "/" a b
    ("rem", [a, b]) -> bin "%" a b
    ("subtract", [a, b]) -> bin "-" b a
    ("neg", [a]) -> "(-" ++ a ++ ")"
    ("==", [a, b]) -> bin "==" a b
    ("/=", [a, b]) -> bin "!=" a b
    ("<", [a, b]) -> bin "<" a b
    ("<=", [a, b]) -> bin "<=" a b
    (">", [a, b]) -> bin ">" a b
    (">=", [a, b]) -> bin ">=" a b
    ("u+", [a, b]) -> bin "+" a b
    ("u-", [a, b]) -> bin "-" a b
    ("u*", [a, b]) -> bin "*" a b
    ("uquot", [a, b]) -> bin "/" a b
    ("urem", [a, b]) -> bin "%" a b
    ("u<", [a, b]) -> bin "<" a b
    ("u<=", [a, b]) -> bin "<=" a b
    ("u>", [a, b]) -> bin ">" a b
    ("u>=", [a, b]) -> bin ">=" a b
    ("and", [a, b]) -> bin "&" a b
    ("or", [a, b]) -> bin "|" a b
    ("xor", [a, b]) -> bin "^" a b
    ("shl", [a, b]) -> bin "<<" a b
    ("shr", [a, b]) -> bin ">>" a b
    ("d+", [a, b]) -> bin "+" a b
    ("d-", [a, b]) -> bin "-" a b
    ("d*", [a, b]) -> bin "*" a b
    ("d/", [a, b]) -> bin "/" a b
    ("dneg", [a]) -> "(-" ++ a ++ ")"
    ("d==", [a, b]) -> bin "==" a b
    ("d/=", [a, b]) -> bin "!=" a b
    ("d<", [a, b]) -> bin "<" a b
    ("d<=", [a, b]) -> bin "<=" a b
    ("d>", [a, b]) -> bin ">" a b
    ("d>=", [a, b]) -> bin ">=" a b
    ("f+", [a, b]) -> bin "+" a b
    ("f-", [a, b]) -> bin "-" a b
    ("f*", [a, b]) -> bin "*" a b
    ("f/", [a, b]) -> bin "/" a b
    ("fneg", [a]) -> "(-" ++ a ++ ")"
    ("f==", [a, b]) -> bin "==" a b
    ("f<", [a, b]) -> bin "<" a b
    ("itod", [a]) -> "((double)" ++ a ++ ")"
    ("dtoi", [a]) -> "((int64_t)" ++ a ++ ")"
    ("itof", [a]) -> "((float)" ++ a ++ ")"
    ("ftoi", [a]) -> "((int64_t)" ++ a ++ ")"
    ("ord", [a]) -> a
    ("chr", [a]) -> a
    ("seq", [_, b]) -> b
    _ -> "/* unknown primitive " ++ p ++ " */" ++ p ++ "(" ++ intercalate ", " as ++ ")"
  where bin o a b = "(" ++ a ++ " " ++ o ++ " " ++ b ++ ")"

-- Generate a C program: the data type declarations, the lifted functions, and
-- the entry function with the given name.  The entry function takes the free
-- variables of the program, and the parameters of the program if it is a function.
toC :: String -> LowProg -> String
toC name p =
  let free = progFree p
      (params, body) =
        case progBody p of
          LLam xs b -> (xs, b)
          b -> ([], b)
      env = Env (params ++ free) []
      ((r, ss), st) = unC (block (gen env body)) (CS [] [] 0 [])
      rty = cType (typeOf body)
      entry = rty ++ " " ++ name ++ "(" ++ intercalate ", " [ cType t ++ " " ++ cVar x | (x, t) <- params ++ free ] ++ ") {\n" ++
              unlines (map ("  " ++) ss) ++ "  return " ++ r ++ ";\n}"
  in  unlines $
        [ "#include <stdint.h>", "#include <stdlib.h>", "#include <stdio.h>", "#include <math.h>", "" ] ++
        map cDecl (progDecls p) ++ [""] ++
        reverse (csFuns st) ++ [""] ++
        [entry]
