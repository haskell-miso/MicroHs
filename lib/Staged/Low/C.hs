-- A code generator from low code to C, as an example of a user written backend
-- for Staged.Low.  Since low code is first order, strict, and monomorphic,
-- the translation is direct:
--  * Int, Word, Double, Float and Char are C scalars;
--  * a data type whose constructors all have no fields is an int (the tag);
--  * other data types are structs with a tag and a union of the fields,
--    allocated with malloc (and never freed: this example has no memory management);
--  * local functions (let and letrec bound lambdas) become C functions; the
--    variables of the enclosing scope they use are passed as extra arguments
--    (lambda lifting), which is always possible since functions never escape;
--  * a case is a switch, a let is a declaration;
--  * a call of the function itself in tail position is a jump to the start
--    of the function (its body is a loop), so a loop does not use the C stack;
--  * memory (Staged.Low.Mem) is one global array of words; a Mem value is a
--    dummy int (the C compiler removes it), peek and poke are an array access
--    and an assignment, and a pair with a Mem component is its other component.
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
    _ | isMemTy t -> "int"
    TData _ as _ | Just i <- memTupleIndex t -> cType (as !! i)
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
    LApp (LPrim "$peek" _) [m, a] -> do
      _ <- gen env m
      a' <- gen env a
      return ("mhs_mem[" ++ a' ++ "]")
    LApp (LPrim "$poke" _) [m, a, w] -> do
      _ <- gen env m
      a' <- gen env a
      w' <- gen env w
      emit ("mhs_mem[" ++ a' ++ "] = " ++ w' ++ ";")
      return "0"
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
        _ | Just i <- memTupleIndex st, [(_, xs, b)] <- alts -> do
          -- a pair with a Mem component: the other component is the value
          mapM_ (\ (j, (x, t)) -> emit (cType t ++ " " ++ cVar x ++ " = " ++ (if j == i then s' else "0") ++ ";")) (zip [0 :: Int ..] xs)
          b' <- gen (addVars xs env) b
          emit (r ++ " = " ++ b' ++ ";")
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
        _ | Just i <- memTupleIndex t -> return (as' !! i)
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
    LLam xs b
      | hasSelfTail x b -> do
          -- the body is a loop: a call of x in tail position assigns the
          -- parameters and continues
          let t = typeOf e
              params = [ (cVar p, cType pt) | (p, pt) <- caps ++ xs ]
          (mr, ss) <- block (genT (addVars (xs ++ caps) env) (x, params) b)
          addFun (funSig x t caps e ++ " {\n  for (;;) {\n" ++ unlines (map ("    " ++) ss) ++
                  maybe "" (\ r -> "    return " ++ r ++ ";\n") mr ++ "  }\n}")
      | otherwise -> do
          let t = typeOf e
          (r, ss) <- block (gen (addVars (xs ++ caps) env) b)
          addFun (funSig x t caps e ++ " {\n" ++ unlines (map ("  " ++) ss) ++ "  return " ++ r ++ ";\n}")
    _ -> addFun ("/* " ++ x ++ " is not a function */")

-- Does a term call x in tail position?
hasSelfTail :: String -> LowTerm -> Bool
hasSelfTail x at =
  case at of
    LApp (LVar g _) _ -> g == x
    LLet _ _ _ b -> hasSelfTail x b
    LLetRec _ b -> hasSelfTail x b
    LCase _ _ alts d -> any (\ (_, _, b) -> hasSelfTail x b) alts || maybe False (hasSelfTail x) d
    _ -> False

-- A term in tail position of the function (its name, and its C parameters
-- with their types): a call of the function is assignments to the
-- parameters and a continue (Nothing: the term does not return here), the
-- others are generated as usual, with their alternatives in tail position.
genT :: Env -> (String, [(String, String)]) -> LowTerm -> C (Maybe String)
genT env self@(x, params) at =
  case at of
    LApp (LVar g _) as | g == x -> do
      as' <- mapM (gen env) as
      let caps = [ cVar v | (v, _) <- fromMaybe [] (lookup g (eFuns env)) ]
      -- the new values first (an argument can use a parameter), then the parameters
      ts <- mapM (\ ((_, pt), a) -> do { t <- freshC "t"; emit (pt ++ " " ++ t ++ " = " ++ a ++ ";"); return t }) (zip params (caps ++ as'))
      mapM_ (\ ((p, _), t) -> emit (p ++ " = " ++ t ++ ";")) (zip params ts)
      emit "continue;"
      return Nothing
    LLet y t e b
      | TFun _ _ <- t -> do
          let caps = capturedOf env e
              env' = addFunCaps y caps (addVars [(y, t)] env)
          defineFun env' y caps e
          genT env' self b
      | otherwise -> do
          e' <- gen env e
          emit (cType t ++ " " ++ cVar y ++ " = " ++ e' ++ ";")
          genT (addVars [(y, t)] env) self b
    LLetRec bs b -> do
      let caps = nub (concat [ capturedOf env e | (_, _, e) <- bs ])
          env' = foldr (\ (y, _, _) -> addFunCaps y caps) (addVars [ (y, t) | (y, t, _) <- bs ] env) bs
      mapM_ (\ (y, t, e) -> protoFun y t caps e) bs
      mapM_ (\ (y, _, e) -> defineFun env' y caps e) bs
      genT env' self b
    LCase s cons alts d -> do
      s' <- gen env s
      let st = typeOf s
      r <- freshC "r"
      emit (cType (typeOf at) ++ " " ++ r ++ ";")
      -- an alternative: its value is the result, or it continued
      let alt env2 b = do
            mb <- genT env2 self b
            case mb of
              Just b' -> emit (r ++ " = " ++ b' ++ ";")
              Nothing -> return ()
      case (st, cons) of
        _ | Just i <- memTupleIndex st, [(_, xs, b)] <- alts -> do
          mapM_ (\ (j, (y, t)) -> emit (cType t ++ " " ++ cVar y ++ " = " ++ (if j == i then s' else "0") ++ ";")) (zip [0 :: Int ..] xs)
          alt (addVars xs env) b
        (TData _ _ decl, _) | declNewtype decl, [(_, [(y, t)], b)] <- alts -> do
          emit (cType t ++ " " ++ cVar y ++ " = " ++ s' ++ ";")
          alt (addVars [(y, t)] env) b
        (TData _ _ decl, _) -> do
          let tag = if isEnum decl then s' else s' ++ "->tag"
          emit ("switch (" ++ tag ++ ") {")
          mapM_ (\ (c, xs, b) -> do
                   emit ("case " ++ show (conTag c) ++ ": {")
                   mapM_ (\ (i, (y, t)) -> emit (cType t ++ " " ++ cVar y ++ " = " ++ s' ++ "->u." ++ cName (conName c) ++ ".f" ++ show i ++ ";")) (zip [0 :: Int ..] xs)
                   ((), ss) <- block (alt (addVars xs env) b)
                   mapM_ emit ss
                   emit "break; }") alts
          case d of
            Just e | length alts < length cons -> do
              emit "default: {"
              ((), ss) <- block (alt env e)
              mapM_ emit ss
              emit "break; }"
            _ -> emit "default: abort();"
          emit "}"
        _ -> emit ("/* case on " ++ show st ++ " */")
      return (Just r)
    _ -> Just <$> gen env at

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
        (if usesMem (progBody p) then
           [ "/* the memory of the program (Staged.Low.Mem) */"
           , "#ifndef MHS_MEM_WORDS", "#define MHS_MEM_WORDS (1 << 20)", "#endif"
           , "static int64_t mhs_mem[MHS_MEM_WORDS];", "" ]
         else []) ++
        map cDecl (progDecls p) ++ [""] ++
        reverse (csFuns st) ++ [""] ++
        [entry]
