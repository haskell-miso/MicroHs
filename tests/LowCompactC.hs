-- A compact C printer for low code (compare the example backend Staged.Low.C):
--
--  * a data type is a typedef'd struct, and each constructor a one line
--    helper function;
--  * code in tail position returns its value (no temporary per case), a case
--    on a type with one constructor reads its fields, a case on Bool is an if,
--    and a case that covers all constructors has no default;
--  * local functions are lambda lifted, as in Staged.Low.C.
--
-- With mutable = True it also compiles a state type St, threaded linearly
-- through the program (as the call by need compilers of LowFutamuraLazy do
-- for their heap), to a global mutable heap: St and Heap disappear, the
-- function fetch (Heap -> Int -> Cell) is heap[a], store (Heap -> Int ->
-- Cell -> Heap) is heap[a] = c, St n h sets the allocation pointer hp to n,
-- a case on St reads hp, and a Res v s is v.  This is the same program, since
-- every state is used once.
module LowCompactC(toCompactC) where
import Data.Char(ord, isAsciiLower, isAsciiUpper, isDigit)
import Data.List(intercalate, nub, sortBy)
import Data.Maybe(fromMaybe)
import Staged.Low

-- The output: the functions (in reverse order), the statements of the
-- current function (in reverse order), and a counter for names
data PS = PS [String] [String] Int

newtype P a = P (PS -> (a, PS))

runP :: P a -> PS -> (a, PS)
runP (P f) = f

instance Functor P where
  fmap f (P g) = P $ \ s -> case g s of (a, s') -> (f a, s')
instance Applicative P where
  pure a = P $ \ s -> (a, s)
  P f <*> P a = P $ \ s -> case f s of (g, s') -> case a s' of (b, s'') -> (g b, s'')
instance Monad P where
  P g >>= f = P $ \ s -> case g s of (a, s') -> runP (f a) s'

emit :: String -> P ()
emit l = P $ \ (PS fs ss u) -> ((), PS fs (l : ss) u)

fresh :: String -> P String
fresh b = P $ \ (PS fs ss u) -> (b ++ show u, PS fs ss (u + 1))

addFun :: String -> P ()
addFun f = P $ \ (PS fs ss u) -> ((), PS (f : fs) ss u)

-- The statements of a block, in a fresh statement buffer
block :: P () -> P [String]
block act = P $ \ (PS fs ss u) ->
  case runP act (PS fs [] u) of
    ((), PS fs' ss' u') -> (reverse ss', PS fs' ss u')

-- Heap functions of the mutable translation
data HeapFn = HFetch | HStore

-- The environment: the mutable translation or not, the variables in scope
-- with their types, the lifted functions with their captured variables, and
-- the heap functions
data Env = Env Bool [(String, LowTy)] [(String, [(String, LowTy)])] [(String, HeapFn)] [(String, String)]
         [(String, Int)]       -- the known constructor tags of variables (in a branch of a case on them)

knownTag :: String -> Int -> Env -> Env
knownTag v k (Env m vs fs hs as ks) = Env m vs fs hs as ((v, k) : ks)

addVars :: [(String, LowTy)] -> Env -> Env
addVars xs (Env m vs fs hs as ks) = Env m (xs ++ vs) fs hs as ks

addCaps :: String -> [(String, LowTy)] -> Env -> Env
addCaps f caps (Env m vs fs hs as ks) = Env m vs ((f, caps) : fs) hs as ks

-- A variable that stands for an expression (used once, or another variable)
alias :: String -> String -> LowTy -> Env -> Env
alias x e ty (Env m vs fs hs as ks) = Env m ((x, ty) : vs) fs hs ((x, e) : as) ks

-- The number of occurrences of a variable
occurs :: String -> LowTerm -> Int
occurs x t =
  case t of
    LVar y _ -> if x == y then 1 else 0
    LApp f as -> occurs x f + sum (map (occurs x) as)
    LLam xs b -> if x `elem` map fst xs then 0 else occurs x b
    LLet y _ e b -> occurs x e + (if x == y then 0 else occurs x b)
    LLetRec bs b -> if x `elem` [ y | (y, _, _) <- bs ] then 0 else sum [ occurs x e | (_, _, e) <- bs ] + occurs x b
    LCase s _ alts d -> occurs x s + sum [ if x `elem` map fst ys then 0 else occurs x b | (_, ys, b) <- alts ] + maybe 0 (occurs x) d
    LCon _ _ as -> sum (map (occurs x) as)
    _ -> 0

-- An expression without effects (so it can be moved to where it is used)
pure' :: LowTerm -> Bool
pure' t =
  case t of
    LVar _ _ -> True
    LLit _ _ -> True
    LCon c ty as -> tyName ty /= "St" && all pure' as && conName c == conName c
    LApp (LPrim _ _) as -> all pure' as
    _ -> False

isIdent :: String -> Bool
isIdent = all (\ c -> isAsciiLower c || isAsciiUpper c || isDigit c || c == '_')

tyName :: LowTy -> String
tyName t = case t of { TData n _ _ -> baseName n; _ -> "" }

-- Types that the mutable translation removes
erased :: Bool -> LowTy -> Bool
erased m t = m && tyName t `elem` ["St", "Heap"]

isEnum :: LowDecl -> Bool
isEnum d = all (null . conDeclFields) (declCons d)

cTy :: Bool -> LowTy -> String
cTy m t =
  case t of
    TInt -> "int64_t"
    TWord -> "uint64_t"
    TInt64 -> "int64_t"
    TWord64 -> "uint64_t"
    TDouble -> "double"
    TFloat -> "float"
    TChar -> "int32_t"
    TData n _ d | isEnum d -> "int"
                | m && baseName n == "Res" -> "RV *"
                | otherwise -> cName n ++ " *"
    _ -> "void *"

cName :: String -> String
cName = concatMap esc . baseName
  where esc c | isAsciiLower c || isAsciiUpper c || isDigit c || c == '_' = [c]
              | c == '\'' = "_q"
              | otherwise = "_" ++ show (ord c) ++ "_"

-- Data types: a typedef, a struct, and a helper per constructor
decls :: Bool -> [LowDecl] -> [String]
decls m ds =
  [ unwords [ "typedef struct " ++ n ++ " " ++ n ++ ";" | d <- ds', let n = cName (declName d) ] | not (null ds') ] ++
  [ "struct " ++ cName (declName d) ++ " { int tag; union { " ++
      concat [ "struct { " ++ concat [ cTy m f ++ " f" ++ show i ++ "; " | (i, f) <- zip [0 :: Int ..] (conDeclFields c) ] ++ "} " ++ cName (conDeclName c) ++ "; "
             | c <- declCons d, not (null (conDeclFields c)) ] ++ "} u; };"
  | d <- ds' ] ++
  [ "static " ++ n ++ " *C_" ++ k ++ "(" ++ params ++ ") { " ++ n ++ " *p = malloc(sizeof *p); p->tag = " ++ show (conDeclTag c) ++ "; " ++
      concat [ "p->u." ++ k ++ ".f" ++ show i ++ " = a" ++ show i ++ "; " | (i, _) <- fs ] ++ "return p; }"
  | d <- ds', c <- declCons d, let n = cName (declName d)
                                   k = cName (conDeclName c)
                                   fs = zip [0 :: Int ..] (conDeclFields c)
                                   params = if null fs then "void" else intercalate ", " [ cTy m f ++ " a" ++ show i | (i, f) <- fs ] ]
  where ds' = [ d | d <- ds, not (isEnum d), not (m && baseName (declName d) `elem` ["St", "Heap", "Res"]) ]

-- An expression for the value of a term, after emitting the statements that
-- compute it
expr :: Env -> LowTerm -> P String
expr env@(Env m _ fs hs as0 _) t =
  case t of
    LVar x ty -> return (if erased m ty then "" else fromMaybe (cName x) (lookup x as0))
    LLit l _ -> return (lit l)
    LApp f as ->
      case f of
        LPrim p _ -> prim p <$> mapM (expr env) as
        LForeign _ c _ -> do { as' <- mapM (expr env) as; return (c ++ "(" ++ intercalate ", " as' ++ ")") }
        LVar g _ | Just HFetch <- lookup g hs, [h, a] <- as -> do
          _ <- expr env h
          a' <- expr env a
          return ("heap[" ++ a' ++ "]")
        LVar g _ | Just HStore <- lookup g hs -> heapEffect env t >> return ""
        LVar g _ -> do
          as' <- mapM (\ a -> (,) a <$> expr env a) as
          -- the captured variables; one that stands for an expression passes it
          let caps = [ fromMaybe (cName v) (lookup v as0) | (v, _) <- fromMaybe [] (lookup g fs) ]
          return (cName g ++ "(" ++ intercalate ", " (caps ++ [ e | (a, e) <- as', not (erased m (typeOf a)) ]) ++ ")")
        _ -> return "0"
    LCon c ty as
      | m && tyName ty == "St", [n, h] <- as -> do
          heapEffect env h
          case n of
            LVar "" _ -> return ()                    -- unchanged (see update)
            _ -> do { n' <- expr env n; emit ("hp = " ++ n' ++ ";") }
          return ""
      | m && tyName ty == "Res", [v, s] <- as -> do
          v' <- expr env v
          _ <- expr env s
          return v'
      | otherwise ->
          case ty of
            TData _ _ d | isEnum d -> return (show (conTag c))
            _ -> do { as' <- mapM (expr env) as; return ("C_" ++ cName (conName c) ++ "(" ++ intercalate ", " as' ++ ")") }
    LLet x ty e b -> do { env' <- letBind env x ty e; expr env' b }
    LLetRec bs b -> do { env' <- letRec env bs; expr env' b }
    LCase _ _ _ _ -> do
      r <- fresh "r"
      emit (cTy m (typeOf t) ++ " " ++ r ++ ";")
      tailT env (Just r) t
      return r
    LFail _ -> emit "abort();" >> return "0"
    _ -> return "0"

-- The heap of the mutable translation: the effect of the heap part of St n h
heapEffect :: Env -> LowTerm -> P ()
heapEffect env@(Env _ _ _ hs _ _) h =
  case h of
    LApp (LVar g _) [h', a, c] | Just HStore <- lookup g hs -> do
      heapEffect env h'
      a' <- expr env a
      c' <- expr env c
      emit ("heap[" ++ a' ++ "] = " ++ c' ++ ";")
    LVar _ _ -> return ()
    LCon _ _ [] -> return ()
    _ -> expr env h >> return ()

-- Code in tail position: return its value (Nothing), or set a variable
tailT :: Env -> Maybe String -> LowTerm -> P ()
tailT env@(Env m _ _ _ _ ks) dest t =
  case t of
    LLet x ty e b
      | notFun ty, pure' e, occurs x b <= 1 -> do
          -- used once (or not at all): use the expression where the variable is
          e' <- expr env e
          tailT (alias x e' ty env) dest b
    LLet x ty e b -> do { env' <- letBind env x ty e; tailT env' dest b }
    LLetRec bs b -> do { env' <- letRec env bs; tailT env' dest b }
    LCase s cons alts d ->
      case (typeOf s, alts) of
        (ty, [(_, [(n, nt), (h, ht)], b)]) | m && tyName ty == "St" -> do
          _ <- expr env s
          let env' = addVars [(n, nt), (h, ht)] env
          case b of
            -- allocation: St (n + 1) (store h n cell)
            LLet s1 st1 (LCon _ _ [LApp (LPrim "+" _) [LVar n' _, LLit (LitInt 1) _], LApp (LVar g _) [LVar h' _, LVar n'' _, cell]]) rest
              | n' == n, n'' == n, h' == h, isStore g -> do
                  c <- expr env' cell
                  emit ("int64_t " ++ cName n ++ " = alloc(" ++ c ++ ");")
                  tailT (addVars [(s1, st1)] env') dest rest
            _ | Just b' <- update n b -> tailT env' dest b'      -- hp is not changed
              | otherwise -> do
                  if occurs n b > 0 then emit ("int64_t " ++ cName n ++ " = hp;") else return ()
                  tailT env' dest b
        (ty, [(_, [(v, vt), (s', st)], b)]) | m && tyName ty == "Res" -> do
          e <- expr env s
          env' <- if isIdent e then return (alias v e vt env)
                  else do { emit (cTy m vt ++ " " ++ cName v ++ " = " ++ e ++ ";"); return (addVars [(v, vt)] env) }
          tailT (addVars [(s', st)] env') dest b
        (TData _ _ decl, _)
          | isEnum decl, sort2 alts -> do
              -- an if on a Bool (an else if for a chain)
              c <- expr env s
              let alt k = head [ b | (con, _, b) <- alts, conTag con == k ]
              emit ("if (" ++ c ++ ") {")
              indented (tailT env dest (alt 1))
              elseIf env dest (alt 0)
          | [(con, xs, b)] <- alts -> do
              -- one alternative (a match that cannot fail): read the fields
              e <- expr env s
              v <- atom m (typeOf s) e
              env' <- fields env v con xs b
              tailT env' dest b
          | otherwise -> do
              e <- expr env s
              v <- atom m (typeOf s) e
              case lookup v ks of
                -- the constructor is known: its alternative
                Just k | [(con, xs, b)] <- [ a | a@(c, _, _) <- alts, conTag c == k ] -> do
                  env' <- fields env v con xs b
                  tailT env' dest b
                _ -> switchOn env dest decl v cons alts d
        _ -> emit "abort();"
    LFail _ -> emit "abort();"
    _ -> do
      e <- expr env t
      case dest of
        Nothing -> emit ("return " ++ e ++ ";")
        Just r -> emit (r ++ " = " ++ e ++ ";")
  where
    isStore g = case lookup g (heapFns env) of { Just HStore -> True; _ -> False }
    notFun ty = case ty of { TFun _ _ -> False; _ -> True }
    sort2 as = length as == 2 && all (\ (_, xs, _) -> null xs) as && tyName (typeOf' as) == "Bool"
    typeOf' _ = case t of { LCase s _ _ _ -> typeOf s; _ -> TInt }

-- A switch on the tag of a value, for the alternatives of a case
switchOn :: Env -> Maybe String -> LowDecl -> String -> [LowCon] -> [(LowCon, [(String, LowTy)], LowTerm)] -> Maybe LowTerm -> P ()
switchOn env dest decl v _ alts d
  | Nothing <- dest, maybe True isFail d = do
      -- every alternative returns: an if per alternative, and the longest one
      -- last, without a test (a tag that is not one of these cannot occur)
      bodies <- mapM (\ (con, xs, b) -> do
                        ss <- block (do env' <- fields env v con xs b
                                        tailT (knownTag v (conTag con) env') dest b)
                        return (con, ss)) alts
      let sorted = sortBy (\ a b -> compare (length (snd a)) (length (snd b))) bodies
          tag = if isEnum decl then v else v ++ "->tag"
      mapM_ (\ (con, ss) -> case ss of
                              [l] -> emit ("if (" ++ tag ++ " == " ++ show (conTag con) ++ ") " ++ l)
                              _ -> do { emit ("if (" ++ tag ++ " == " ++ show (conTag con) ++ ") {"); mapM_ (emit . ("  " ++)) ss; emit "}" })
            (init sorted)
      mapM_ emit (snd (last sorted))
  where isFail e = case e of { LFail _ -> True; _ -> False }
switchOn env@(Env m _ _ _ _ _) dest decl v cons alts d = do
  emit ("switch (" ++ (if isEnum decl then v else v ++ "->tag") ++ ") {")
  mapM_ (\ (con, xs, b) -> do
           ss <- block (do env' <- fields env v con xs b
                           tailT (knownTag v (conTag con) env') dest b
                           maybe (return ()) (\ _ -> emit "break;") dest)
           case ss of
             [l] -> emit ("case " ++ show (conTag con) ++ ": " ++ l)
             _ -> do { emit ("case " ++ show (conTag con) ++ ": {"); mapM_ (emit . ("  " ++)) ss; emit "}" }) alts
  case d of
    Just (LFail _) -> emit "default: abort();"
    Just e' | length alts < length cons -> do
      emit "default: {"
      tailT env dest e'
      maybe (return ()) (\ _ -> emit "break;") dest
      emit "}"
    _ | length alts < length cons -> emit "default: abort();"
      | otherwise -> return ()
  emit "}"

heapFns :: Env -> [(String, HeapFn)]
heapFns (Env _ _ _ hs _ _) = hs

-- An update of the heap that does not allocate: St n (store ...) where n is
-- the allocation pointer just read, with nothing in between that could
-- allocate; it is the same term with St n replaced by a marker, so that only
-- the stores are printed
update :: String -> LowTerm -> Maybe LowTerm
update n b =
  case b of
    LCon c ty [v, st] | tyName ty == "Res", simple v -> LCon c ty . (\ x -> [v, x]) <$> upd st
    LApp f [v, st] | simple v -> (\ x -> LApp f [v, x]) <$> upd st
    LLet x ty st rest | occurs n rest == 0 -> (\ st' -> LLet x ty st' rest) <$> upd st
    _ -> Nothing
  where
    upd st = case st of
      LCon c ty [LVar n' _, h] | n' == n, tyName ty == "St" -> Just (LCon c ty [LVar "" TInt, h])
      _ -> Nothing
    simple e = case e of { LVar _ _ -> True; LCon _ _ as -> all simple as; LLit _ _ -> True; _ -> False }

-- The else branch of an if: an else if when it is an if itself
elseIf :: Env -> Maybe String -> LowTerm -> P ()
elseIf env dest b =
  case b of
    LCase s _ alts Nothing
      | TData _ _ decl <- typeOf s, isEnum decl, length alts == 2, tyName (typeOf s) == "Bool" -> do
          c <- expr env s
          let alt k = head [ e | (con, _, e) <- alts, conTag con == k ]
          emit ("} else if (" ++ c ++ ") {")
          indented (tailT env dest (alt 1))
          elseIf env dest (alt 0)
    _ -> do
      emit "} else {"
      indented (tailT env dest b)
      emit "}"

indented :: P () -> P ()
indented act = block act >>= mapM_ (emit . ("  " ++))

-- A variable for the value of an expression of a type
atom :: Bool -> LowTy -> String -> P String
atom m ty e =
  if all (\ c -> isAsciiLower c || isAsciiUpper c || isDigit c || c == '_') e then return e else do
    v <- fresh "s"
    emit (cTy m ty ++ " " ++ v ++ " = " ++ e ++ ";")
    return v

-- The fields of a constructor that are used in b: a field used once is
-- read where it is used (data is immutable), the others are read into
-- variables
fields :: Env -> String -> LowCon -> [(String, LowTy)] -> LowTerm -> P Env
fields env v con xs b = go env (zip [0 :: Int ..] xs)
  where
    go e [] = return e
    go e@(Env m _ _ _ _ _) ((i, (x, ty)) : rest) =
      let rd = v ++ "->u." ++ cName (conName con) ++ ".f" ++ show i
      in  case occurs x b of
            0 -> go (addVars [(x, ty)] e) rest
            1 -> go (alias x rd ty e) rest
            _ -> do { emit (cTy m ty ++ " " ++ cName x ++ " = " ++ rd ++ ";"); go (addVars [(x, ty)] e) rest }

-- A let: a local function is lambda lifted; a value is a declaration (or,
-- for an erased state, only its effect)
letBind :: Env -> String -> LowTy -> LowTerm -> P Env
letBind env@(Env m _ _ _ _ _) x ty e =
  case ty of
    TFun _ _ -> do
      let caps = captured env e
          env' = addCaps x caps (addVars [(x, ty)] env)
      defineFun env' x caps e
      return env'
    _ | erased m ty -> do { _ <- expr env e; return (addVars [(x, ty)] env) }
      | compound e -> do
          emit (cTy m ty ++ " " ++ cName x ++ ";")
          tailT env (Just (cName x)) e
          return (addVars [(x, ty)] env)
      | otherwise -> do
          e' <- expr env e
          emit (cTy m ty ++ " " ++ cName x ++ " = " ++ e' ++ ";")
          return (addVars [(x, ty)] env)

-- In a lifted function, its parameters are variables (not expressions of the
-- enclosing function)
unalias :: [String] -> Env -> Env
unalias xs (Env m vs fs hs as ks) = Env m vs fs hs [ a | a@(x, _) <- as, x `notElem` xs ] [ k | k@(x, _) <- ks, x `notElem` xs ]

compound :: LowTerm -> Bool
compound e = case e of { LCase _ _ _ _ -> True; LLet _ _ _ _ -> True; LLetRec _ _ -> True; _ -> False }

letRec :: Env -> [(String, LowTy, LowTerm)] -> P Env
letRec env@(Env m vs fs hs as0 ks) bs =
  let heapFn (x, ty, _) = case ty of
        TFun [h, i] c | m, tyName h == "Heap", TInt <- i, tyName c == "Cell" -> Just (x, HFetch)
        TFun [h, i, c] h' | m, tyName h == "Heap", TInt <- i, tyName c == "Cell", tyName h' == "Heap" -> Just (x, HStore)
        _ -> Nothing
      hfs = [ hf | Just hf <- map heapFn bs ]
      bs' = [ b | b@(x, _, _) <- bs, x `notElem` map fst hfs ]
      envH = Env m vs fs (hfs ++ hs) as0 ks
      caps = nub (concat [ captured envH e | (_, _, e) <- bs' ])
      env' = foldr (\ (x, _, _) -> addCaps x caps) (addVars [ (x, ty) | (x, ty, _) <- bs' ] envH) bs'
  in  do
    mapM_ (\ (x, ty, e) -> addFun (sig m x ty caps e ++ ";")) bs'
    mapM_ (\ (x, _, e) -> defineFun env' x caps e) bs'
    return env'

-- The captured variables of a function: its free variables bound in the
-- environment (not functions, not erased), and those of the functions it calls
captured :: Env -> LowTerm -> [(String, LowTy)]
captured (Env m vs fs _ _ _) e =
  nub $ [ (v, ty) | (v, _) <- fvs, Just ty <- [lookup v vs], not (isFun ty), not (erased m ty) ] ++
        concat [ caps | (v, _) <- fvs, Just caps <- [lookup v fs] ]
  where fvs = freeVars e
        isFun ty = case ty of { TFun _ _ -> True; _ -> False }

sig :: Bool -> String -> LowTy -> [(String, LowTy)] -> LowTerm -> String
sig m x ty caps e =
  case (ty, e) of
    (TFun _ r, LLam xs _) ->
      "static " ++ cTy m r ++ " " ++ cName x ++ "(" ++
        intercalate ", " [ cTy m pt ++ " " ++ cName p | (p, pt) <- caps ++ xs, not (erased m pt) ] ++ ")"
    _ -> "static void " ++ cName x ++ "(void)"

defineFun :: Env -> String -> [(String, LowTy)] -> LowTerm -> P ()
defineFun env@(Env m _ _ _ _ _) x caps e =
  case e of
    LLam xs b -> do
      ss <- block (tailT (addVars (xs ++ caps) (unalias (map fst (xs ++ caps)) env)) Nothing b)
      addFun (sig m x (typeOf e) caps e ++ " {\n" ++ unlines (map ("  " ++) ss) ++ "}")
    _ -> return ()

lit :: LowLit -> String
lit l = case l of
  LitInt i -> show i
  LitInt64 i -> show i
  LitDouble d -> show d
  LitFloat f -> show f
  LitChar c -> show (ord c)
  LitString s -> show s

prim :: String -> [String] -> String
prim p as =
  case (p, as) of
    ("quot", [a, b]) -> "(" ++ a ++ " / " ++ b ++ ")"
    ("rem", [a, b]) -> "(" ++ a ++ " % " ++ b ++ ")"
    ("neg", [a]) -> "(-" ++ a ++ ")"
    ("/=", [a, b]) -> "(" ++ a ++ " != " ++ b ++ ")"
    ("seq", [_, b]) -> b
    (_, [a, b]) | p `elem` ["+", "-", "*", "==", "<", "<=", ">", ">="] -> "(" ++ a ++ " " ++ p ++ " " ++ b ++ ")"
    _ -> p ++ "(" ++ intercalate ", " as ++ ")"

-- A C program: the data types, the functions, and the entry function
toCompactC :: Bool -> String -> LowProg -> String
toCompactC m name p =
  let (params, body) = case progBody p of { LLam xs b -> (xs, b); b -> ([], b) }
      env = Env m (params ++ progFree p) [] [] [] []
      (ss, PS fs _ _) = runP (block (tailT env Nothing body)) (PS [] [] 0)
      entry = cTy m (typeOf body) ++ " " ++ name ++ "(" ++ intercalate ", " [ cTy m ty ++ " " ++ cName x | (x, ty) <- params ++ progFree p ] ++ ") {\n" ++
              unlines (map ("  " ++) ss) ++ "}"
  in  unlines $
        [ "#include <stdint.h>", "#include <stdlib.h>" ] ++
        decls m (progDecls p) ++
        (if m then [ "static Cell *heap[1 << 20]; static int64_t hp;"
                   , "static int64_t alloc(Cell *c) { heap[hp] = c; return hp++; }" ] else []) ++
        reverse fs ++ [entry]
