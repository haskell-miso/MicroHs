-- Two-level type theory: staging.
--
-- After type checking and desugaring, a module contains three kinds of definitions:
--  * meta level definitions (stage LMeta): only exist at compile time.
--    They are kept (as combinators) in tMetaDefs so that importing modules can run them.
--  * object level definitions (stage LObj): run time code.  They can contain splices
--    (~e, marked by the pseudo primitive "$splice") which are evaluated here.
--  * stage polymorphic definitions: ordinary code, usable at both stages.
--
-- Staging follows Kovács, "Staged Compilation with Two-Level Type Theory" (ICFP 2022),
-- section 4, with the meta level evaluator being the ordinary runtime system:
--  * Meta level code is compiled to combinators and run by the runtime system, in the
--    same way as the interactive system runs code (MicroHs.Translate).  So compile time
--    code has exactly the run time semantics, and can use everything the runtime can
--    (e.g., the FFI).  A quotation is compiled to code that builds a value of type Code,
--    with the object level binders as functions (HOAS).
--  * The object level "evaluator" (eval0) runs in the compiler.  It only renames
--    variables and executes splices, and the result is read back (quote0) with
--    de Bruijn levels, so generated code never captures variables.
module MicroHs.Stage(
  stageModule,
  ) where
import qualified Prelude(); import MHSPrelude
import Data.Char(ord)
import Data.Int(Int64)
import Data.List(partition, nub, isPrefixOf)
import Data.Maybe
import Unsafe.Coerce(unsafeCoerce)
import MicroHs.Abstract(compileOpt)
import MicroHs.Desugar(LDef, quotePrim, splicePrim, hasSplice)
import MicroHs.EncodeData(SPat(..), encConstr, encList, encCase, encTuple, encTupleSel)
import MicroHs.Exp
import MicroHs.Expr(Lit(..), Level(..), Con(..), ImpEnt(..), showLit, HasLoc(..), errorMessage, getTupleConstr)
import MicroHs.Ident
import qualified MicroHs.IdentMap as M
import MicroHs.Names
import MicroHs.State
import MicroHs.TCMonad(LevelTable, ClassTable, ClassInfo(..))
import MicroHs.Translate(translateMap, translateWithMap)
import MicroHs.TypeCheck(TModule, tBindingsOf, tMetaDefs, setBindings, setMetaDefs, impossible, mkClassConstructor)

-- Stage a desugared module.
-- Returns the module with the meta level definitions moved to tMetaDefs and all
-- splices in object level definitions executed, together with the list of staged definitions,
-- and the compiled meta level code of the module.  Forcing the latter finds the staging
-- errors in the module; forcing a staged definition runs its splices.
stageModule :: LevelTable -> ClassTable -> [TModule [LDef]] -> TModule [LDef] -> (TModule [LDef], [LDef], [Exp])
stageModule levels classes imported dmdl =
  let defs = tBindingsOf dmdl
      isMeta (i, _) = M.lookup i levels == Just LMeta
      (metas, objs) = partition isMeta defs
      -- What the compilation of low code needs: all definitions (to find primitives) and the class methods.
      lenv = LowEnv { leDefs = M.fromList (concat [ tBindingsOf tm ++ tMetaDefs tm | tm <- imported ] ++ defs)
                    , leMethods = M.fromList [ (qualIdent (qualOf cls) m, (mkClassConstructor cls, length supers + j))
                                             | (cls, ClassInfo _ supers _ meths _) <- M.toList classes
                                             , (j, (m, _)) <- zip [0 ..] meths ] }
      -- Meta level definitions: compile the quotations and turn them into combinators.
      metas' = [ (i, compileOpt (metaExp lenv (getSLoc i) M.empty e)) | (i, e) <- metas ]
      -- Object level definitions: take out the splices.
      (objs', (_, rsplices)) = runState (mapM (prepDef lenv) objs) (0, [])
      -- Everything a compile time computation might need:
      -- the imported modules, and the definitions of this module that have no splices.
      tmap = translateMap $ codeConstrs ++ [codeToLow] ++ concat [ tBindingsOf tm ++ tMetaDefs tm | tm <- imported ]
      here = metas' ++ [ (i, compileOpt e) | (i, e) <- objs, not (hasSplice e) ]
      -- All the splices of the module are loaded into the runtime together.
      fns :: [SpliceFn]
      fns = unsafeCoerce $ translateWithMap tmap (here, compileOpt (encList (reverse rsplices)))
      stage (i, e) | hasSplice e = (i, quote0 0 $ eval0 fns M.empty e)
                   | otherwise   = (i, e)
      objs'' = map stage objs'
      staged = [ d | (d, (_, e)) <- zip objs'' objs, hasSplice e ]
      noRun (i, _) = errorMessage (getSLoc i)
                       "splices are run by the MicroHs runtime, so they need a compiler that is compiled with mhs"
  in  case staged of
        d : _ | not compiledWithMhs -> noRun d
        _ -> (setMetaDefs (setBindings dmdl objs'') metas', staged, map snd metas' ++ rsplices)

stageError :: forall a . SLoc -> String -> a
stageError loc msg = errorMessage loc $ "staging error: " ++ msg

-----------------------------------------------
-- Object level code

-- Object level code, with HOAS binders.
-- Values of this type are also built by meta level code running in the runtime system.
-- There is no source definition of the type for that code, instead the constructor
-- functions are generated here (codeConstrs), with the encoding the compiler itself uses.
-- So the constructors below, their order, and their arities must agree with codeConTable.
data Code
  = CVar Int String              -- de Bruijn level and base name; only made by quote0
  | CExp Exp                     -- a global variable or a literal; only made by eval0
  | CGlobal String               -- global variable
  | CApp Code Code
  | CLam String (Code -> Code)
  | CInt Int                     -- literals
  | CInt64 Int64
  | CDbl Double
  | CFlt Float
  | CChr Char
  | CStr String
  | CPrim String
  | CLow LowExpV                 -- low code (closure free code), see lowToExp

-- Name and arity of the constructors of Code, in order.
codeConTable :: [(String, Int)]
codeConTable =
  [ ("var", 2), ("exp", 1), ("global", 1), ("app", 2), ("lam", 2)
  , ("int", 1), ("int64", 1), ("dbl", 1), ("flt", 1), ("chr", 1), ("str", 1), ("prim", 1), ("low", 1) ]

-- $Code.toLow :: Code -> LowTy -> LowExp
-- Turn an object level variable (always a CVar) into a low code variable with the given type.
codeToLow :: LDef
codeToLow =
  let c = mkIdent "$c"; t = mkIdent "$t"; l = mkIdent "$l"; x = mkIdent "$x"
      cti = [ (codeCon s, a) | (s, a) <- codeConTable ]
      alt = (SPat (ConData cti (codeCon "var") []) [l, x], apps (Var (lowIdent "HVar")) [Var l, Var x, Var t])
      err = App (Var (mkIdent "Control.Error.error")) (Lit (LStr "$Code.toLow: not a variable"))
  in  (mkIdent "$Code.toLow", compileOpt (Lam c (Lam t (encCase (Var c) [alt] err))))

-- The constructor functions of Code for the code run by the runtime system.
codeConstrs :: [LDef]
codeConstrs = [ (codeCon s, compileOpt (encConstr i n (replicate a False))) | (i, (s, a)) <- zip [0..] codeConTable ]
  where n = length codeConTable

codeCon :: String -> Ident
codeCon s = mkIdent ("$Code." ++ s)

con1 :: String -> Exp -> Exp
con1 s = App (Var (codeCon s))

con2 :: String -> Exp -> Exp -> Exp
con2 s a = App (App (Var (codeCon s)) a)

-----------------------------------------------
-- Compiling meta level code

-- How a local variable is bound.
data Bind
  = BMeta                -- meta level variable
  | BObj (Maybe Exp)     -- object level variable (it is bound to Code when in meta level code).
                         -- When it is let bound to a expression that does not depend on the
                         -- object level, that expression is also its value at the meta level.
                         -- (This happens for the dictionary bindings the type checker inserts.)
  | BLow                 -- variable bound inside a Low quotation (bound to low code in meta level code)

type BEnv = M.Map Bind

-- Compile meta level code: quotations become code that builds a Code value.
metaExp :: LowEnv -> SLoc -> BEnv -> Exp -> Exp
metaExp lenv loc env ae =
  case ae of
    Var i ->
      case M.lookup i env of
        Just (BObj (Just e)) -> e
        Just (BObj Nothing) -> stageError loc $ "object level variable used at compile time: " ++ showIdent i
        Just BLow -> stageError loc $ "low code variable used at compile time: " ++ showIdent i
        _ -> ae
    App (Lit (LPrim p)) e | p == quotePrim -> quoteExp lenv loc env e
                          | p == lowQuotePrim -> lowQuoteExp lenv loc env e
                          | p == splicePrim -> stageError loc "splice at meta level"
    App f a -> App (metaExp lenv loc env f) (metaExp lenv loc env a)
    Lam x e -> Lam x (metaExp lenv loc (M.insert x BMeta env) e)
    -- Cross stage persistence of literals (Staged.codeInt etc)
    Lit (LPrim "$liftInt") -> Var (codeCon "int")
    Lit (LPrim "$liftDouble") -> Var (codeCon "dbl")
    Lit (LPrim "$liftFloat") -> Var (codeCon "flt")
    Lit (LPrim "$liftString") -> Var (codeCon "str")
    Lit _ -> ae

-- Compile quoted object level code to meta level code that builds it.
-- Object level binders become meta level functions on Code.
quoteExp :: LowEnv -> SLoc -> BEnv -> Exp -> Exp
quoteExp lenv loc env ae =
  case ae of
    Var i ->
      case M.lookup i env of
        Nothing -> con1 "global" (Lit (LStr (unIdent i)))
        Just (BObj _) -> ae
        Just BMeta -> stageError loc $ "meta level variable used in object code: " ++ showIdent i
        Just BLow -> stageError loc $ "low code variable used in object code: " ++ showIdent i
    App (Lit (LPrim p)) e | p == splicePrim -> metaExp lenv loc env e
                          | p == quotePrim || p == lowQuotePrim -> stageError loc "quotation at object level"
    App (Lam x b) a -> con2 "app" (lam x (BObj (metaView env a)) b) (quoteExp lenv loc env a)
    App f a -> con2 "app" (quoteExp lenv loc env f) (quoteExp lenv loc env a)
    Lam x e -> lam x (BObj Nothing) e
    Lit l ->
      case l of
        LInt _    -> con1 "int" ae
        LInt64 _  -> con1 "int64" ae
        LDouble _ -> con1 "dbl" ae
        LFloat _  -> con1 "flt" ae
        LChar _   -> con1 "chr" ae
        LStr _    -> con1 "str" ae
        LPrim p   -> con1 "prim" (Lit (LStr p))
        _ -> stageError loc $ "literal not supported in a quotation: " ++ showLit l
  where lam x b e = con2 "lam" (Lit (LStr (unIdent x))) (Lam x (quoteExp lenv loc (M.insert x b env) e))

-- The value of an object level expression at the meta level,
-- if it does not depend on anything at the object level.
metaView :: BEnv -> Exp -> Maybe Exp
metaView env ae =
  case ae of
    Var i ->
      case M.lookup i env of
        Just (BObj m) -> m
        Just BLow -> Nothing
        _ -> Just ae
    App f a -> App <$> metaView env f <*> metaView env a
    Lam x e -> Lam x <$> metaView (M.insert x BMeta env) e
    Lit (LPrim p) | p == quotePrim || p == splicePrim || p == lowQuotePrim -> Nothing
    Lit _ -> Just ae

-----------------------------------------------
-- Taking out the splices

-- Replace each splice ~e in an object level definition by
--   $splice n x1 ... xk
-- where n is the number of the splice and x1 ... xk are the object level variables in e.
-- Splice number n is the meta level function \ x1 ... xk -> e.
prepDef :: LowEnv -> LDef -> State (Int, [Exp]) LDef
prepDef lenv (i, e) | hasSplice e = (,) i <$> prepExp lenv (getSLoc i) M.empty e
                    | otherwise   = return (i, e)

prepExp :: LowEnv -> SLoc -> BEnv -> Exp -> State (Int, [Exp]) Exp
prepExp lenv loc env ae =
  case ae of
    App (Lit (LPrim p)) e
      | p == splicePrim -> do
          let e' = metaExp lenv loc env e
              xs = nub [ x | x <- freeVars e', isJust (M.lookup x env) ]
          (n, ss) <- get
          put (n + 1, lams xs e' : ss)
          return $ App (Lit (LPrim splicePrim)) (apps (Lit (LInt n)) (map Var xs))
      | p == quotePrim || p == lowQuotePrim -> stageError loc "quotation at object level"
    App (Lam x b) a -> do
      a' <- prepExp lenv loc env a
      b' <- prepExp lenv loc (M.insert x (BObj (metaView env a)) env) b
      return (App (Lam x b') a')
    App f a -> App <$> prepExp lenv loc env f <*> prepExp lenv loc env a
    Lam x e -> Lam x <$> prepExp lenv loc (M.insert x (BObj Nothing) env) e
    _ -> return ae

-----------------------------------------------
-- Object level evaluation: rename variables, execute splices.

-- The splice functions are in the first argument.
eval0 :: [SpliceFn] -> M.Map Code -> Exp -> Code
eval0 fns env ae =
  case ae of
    Var i -> fromMaybe (CExp ae) (M.lookup i env)
    App (Lit (LPrim p)) e | p == splicePrim ->
      case getApp e of
        (Lit (LInt n), as) -> runSplice (fns !! n) (map (eval0 fns env) as)
        _ -> impossible
    App f a -> CApp (eval0 fns env f) (eval0 fns env a)
    Lam x e -> CLam (unIdent x) $ \ c -> eval0 fns (M.insert x c env) e
    Lit _ -> CExp ae
  where
    getApp (App f a) = case getApp f of (h, as) -> (h, as ++ [a])
    getApp e = (e, [])

-- Run a splice function (a value in the runtime system) on the code of its variables.
runSplice :: SpliceFn -> [Code] -> Code
runSplice f [] = unsafeCoerce f
runSplice f (c : cs) = runSplice ((unsafeCoerce f :: Code -> SpliceFn) c) cs

-- A splice function in the runtime system; it takes some Code arguments and returns Code.
data SpliceFn

-- Read back object level code to an expression.
-- Binders are named after the original variable and the de Bruijn level.
quote0 :: Int -> Code -> Exp
quote0 d ac =
  case ac of
    CVar l x -> Var (lvlIdent l x)
    CExp e -> e
    CGlobal i -> Var (mkIdent i)
    CApp f a -> App (quote0 d f) (quote0 d a)
    CLam x f | isDummyIdent (mkIdent x) -> Lam dummyIdent (quote0 (d + 1) (f (CVar d x)))
             | otherwise -> Lam (lvlIdent d x) (quote0 (d + 1) (f (CVar d x)))
    CInt i -> Lit (LInt i)
    CInt64 i -> Lit (LInt64 i)
    CDbl x -> Lit (LDouble x)
    CFlt x -> Lit (LFloat x)
    CChr c -> Lit (LChar c)
    CStr s -> Lit (LStr s)
    CPrim p -> Lit (LPrim p)
    CLow v -> lowToExp 0 v

lvlIdent :: Int -> String -> Ident
lvlIdent l x = mkIdent (x ++ uniqIdentSep ++ "s" ++ show l)

-----------------------------------------------
-- Low code (closure free code), see lib/Staged/Low/Internal.hs and doc/2ltt.md.
--
-- A Low quotation is compiled (lowQuoteExp) to meta level code that builds the
-- representation of the low code: the data type LowExp of Staged.Low.Internal,
-- with HOAS binders, and with the types the type checker recorded.
-- The code is structured: cases, constructors, lets and recursive lets are kept
-- (the desugarer marks them, see MicroHs.Names), so that the code can be
-- reflected, and used by user written code generators.
--
-- Low code spliced into object code is read back (lowToExp) as ordinary
-- code with the strict semantics of low code.

-- What compiling low code needs to know about the program.
data LowEnv = LowEnv {
  leDefs    :: M.Map Exp,                -- all global definitions
  leMethods :: M.Map (Ident, Int)        -- class method -> (dictionary constructor, index of the method in it)
  }

getAppE :: Exp -> (Exp, [Exp])
getAppE = go []
  where go as (App f a) = go (a : as) f
        go as e = (e, as)

-- The library constructor and helper functions.
lowV :: String -> Exp
lowV s = Var (lowIdent s)

lowStr :: String -> Exp
lowStr = Lit . LStr

-- Compile a Low quotation to meta level code that builds its representation.
lowQuoteExp :: LowEnv -> SLoc -> BEnv -> Exp -> Exp
lowQuoteExp lenv loc env ae =
  case getAppE ae of
    (Lit (LPrim p), as)
      | p == splicePrim, e : args <- as -> apply (metaExp lenv loc env e) args   -- the meta level value is the low code
      | p == quotePrim || p == lowQuotePrim -> stageError loc "quotation inside a quotation"
      | p == lowTyPrim, t : e : args <- as -> lowLeaf lenv loc env (meta t) e args
      | p == lowLamPrim, tys : lam : args <- as ->
          apply (lowLams (decodeList loc tys) lam) args
      | p == lowLetPrim, t : Lam x b : e : args <- as ->
          apply (apps (lowV "HLet") [lowStr (unIdent x), App (Var identJust) (meta t), lowFun (meta t) e, Lam x (recL x b)]) args
      | p == lowConPrim, [Lit (LStr "()"), _, _, _, _] <- as ->
          apps (lowV "HCon") [apps (lowV "LowCon") [lowStr "()", Lit (LInt 0), Lit (LInt 0), boolExp False], lowV "tUnit", encList []]
      | p == lowLetRecPrim, Lit (LInt n) : tys : fn : args <- as ->
          let ts = decodeList loc tys
              (xs, body) = peelLams n fn
              env' = foldr (\ x -> M.insert x BLow) env xs
              vs = mkIdent "$lowvs"
              (es, b) = case getAppE body of
                          (Lit (LPrim q), eb) | q == lowRecBodyPrim, length eb == n + 1 -> (init eb, last eb)
                          _ -> stageError loc "bad recursive let in low code"
              rhss = encList (zipWith (lowFunE lenv loc env') (map meta ts) es)
              bind = foldr (\ (k, x) r -> App (Lam x r) (apps (lowV "lowNth") [Lit (LInt k), Var vs])) (encTuple [rhss, lowQuoteExp lenv loc env' b]) (zip [0 ..] xs)
          in  apply (apps (lowV "HLetRec") [encList (zipWith (\ x t -> encTuple [lowStr (unIdent x), meta t]) xs ts), Lam vs bind]) args
      | p == lowCasePrim, x : cons : Lit (LInt k) : rest <- as, length rest >= k + 1 ->
          let (alts, dflt) = (take k rest, rest !! k)
              args = drop (k + 1) rest
              (nt, cs) = case getAppE cons of
                           (Lit (LPrim q), Lit (LInt b) : cas) | q == lowConsPrim -> (b /= 0, pairs cas)
                           _ -> stageError loc "bad case in low code"
              pairs (Lit (LStr c) : Lit (LInt a) : r) = (c, a) : pairs r
              pairs [] = []
              pairs _ = stageError loc "bad case in low code"
              con (tag, (c, a)) = apps (lowV "LowCon") [lowStr c, Lit (LInt tag), Lit (LInt a), boolExp nt]
              conTable = zip [0 ..] cs
              alt a =
                case getAppE a of
                  (Lit (LPrim q), [Lit (LStr c), Lit (LInt tag), fn]) | q == lowAltPrim ->
                    let ar = case lookup tag conTable of
                               Just (_, n) -> n
                               Nothing -> stageError loc "bad case alternative in low code"
                        (ys, b) = peelLams ar fn
                        env' = foldr (\ y -> M.insert y BLow) env ys
                        vs = mkIdent "$lowvs"
                        bind = foldr (\ (j, y) r -> App (Lam y r) (apps (lowV "lowNth") [Lit (LInt j), Var vs])) (lowQuoteExp lenv loc env' b) (zip [0 ..] ys)
                    in  apps (lowV "LowAlt") [con (tag, (c, ar)), encList (map (lowStr . unIdent) ys), Lam vs bind]
                  _ -> stageError loc "bad case alternative in low code"
          in  apply (apps (lowV "HCase") [rec x, encList (map con conTable), encList (map alt alts), App (Var identJust) (rec dflt)]) args
      | p == lowFailPrim, [Lit (LStr msg)] <- as -> App (lowV "HFail") (lowStr msg)
    (Lam x b, e : args) -> apply (apps (lowV "HLet") [lowStr (unIdent x), Var identNothing, rec e, Lam x (recL x b)]) args
    (Lam _ _, []) -> stageError loc "lambda without a type in low code"
    (Var i, args) ->
      case M.lookup i env of
        Just BLow -> apply (Var i) args
        Just (BObj _) -> stageError loc $ "object level variable without a type in low code: " ++ showIdent i
        Just BMeta -> stageError loc $ "meta level variable used in low code: " ++ showIdent i
        Nothing -> stageError loc $ "cannot use " ++ showIdent i ++ " in low code: only primitives, constructors, and local definitions are allowed"
    (Lit l, _) -> stageError loc $ "bad low code " ++ showLit l
    _ -> stageError loc "bad low code"
  where
    rec = lowQuoteExp lenv loc env
    recL x = lowQuoteExp lenv loc (M.insert x BLow env)
    meta = metaExp lenv loc env
    apply f [] = f
    apply f args = apps (lowV "HApp") [f, encList (map rec args)]
    -- a lambda with the types of its variables:  HLam "x" t (\ x -> ...)
    lowLams ts lam =
      case (ts, lam) of
        ([], _) -> rec lam
        (t : ts', Lam x b) -> apps (lowV "HLam") [lowStr (unIdent x), meta t, Lam x (lowLams' ts' (M.insert x BLow env) b)]
        _ -> stageError loc "bad lambda in low code"
    lowLams' ts env' lam =
      case (ts, lam) of
        ([], _) -> lowQuoteExp lenv loc env' lam
        (t : ts', Lam x b) -> apps (lowV "HLam") [lowStr (unIdent x), meta t, Lam x (lowLams' ts' (M.insert x BLow env') b)]
        _ -> stageError loc "bad lambda in low code"
    lowFun t e = lowFunE lenv loc env t e
    peelLams :: Int -> Exp -> ([Ident], Exp)
    peelLams 0 e = ([], e)
    peelLams n (Lam x e) = let (xs, b) = peelLams (n - 1) e in (x : xs, b)
    peelLams _ _ = stageError loc "bad binder in low code"

-- Compile a definition with a known (meta level) type t: lambdas get their types from it.
lowFunE :: LowEnv -> SLoc -> BEnv -> Exp -> Exp -> Exp
lowFunE lenv loc env t ae =
  case ae of
    Lam x b -> apps (lowV "hLamT") [t, lowStr (unIdent x), Lam x (lowFunE lenv loc (M.insert x BLow env) (App (lowV "lowFunRest") t) b)]
    _ -> lowQuoteExp lenv loc env ae

identJust, identNothing :: Ident
identJust = mkIdent "Data.Maybe_Type.Just"
identNothing = mkIdent "Data.Maybe_Type.Nothing"

boolExp :: Bool -> Exp
boolExp b = Var (mkIdent (if b then "Data.Bool_Type.True" else "Data.Bool_Type.False"))

-- Decode a desugared list literal [t1, ..., tn] (Scott encoded).
decodeList :: SLoc -> Exp -> [Exp]
decodeList loc ae =
  case ae of
    App (App (Lit (LPrim "O")) x) r -> x : decodeList loc r
    Lit (LPrim "K") -> []
    _ -> stageError loc "bad list in low code"

-- A leaf of low code: a variable, constructor, literal, or primitive (as a class method), with its type.
lowLeaf :: LowEnv -> SLoc -> BEnv -> Exp -> Exp -> [Exp] -> Exp
lowLeaf lenv loc env t ae args =
  case getAppE ae of
    -- a marked head inside a marked application (numeric literals)
    (Lit (LPrim p), t' : e' : more) | p == lowTyPrim -> lowLeaf lenv loc env (metaExp lenv loc env t') e' (more ++ args)
    (Var i, []) ->
      case M.lookup i env of
        Just BLow -> apply (Var i)
        Just (BObj Nothing) -> apply (apps (Var (mkIdent "$Code.toLow")) [Var i, t])
        Just (BObj (Just _)) -> stageError loc $ "compile time value used in low code: " ++ showIdent i
        Just BMeta -> stageError loc $ "meta level variable used in low code: " ++ showIdent i
        Nothing -> global
    (Lit (LPrim p), [Lit (LStr c), Lit (LInt tag), Lit (LInt _), Lit (LInt ar), Lit (LInt nt)]) | p == lowConPrim ->
      let con = apps (lowV "LowCon") [lowStr c, Lit (LInt tag), Lit (LInt ar), boolExp (nt /= 0)]
      in  apps (lowV "HCon") [con, t, encList args']
    (Lit l, []) ->
      let lit s e = apps (lowV "HLit") [App (lowV s) e, t]
      in  apply $
          case l of
            LInt _ -> lit "LitInt" ae
            LInt64 _ -> lit "LitInt64" ae
            LDouble _ -> lit "LitDouble" ae
            LFloat _ -> lit "LitFloat" ae
            LChar c -> lit "LitChar" (Lit (LInt (ord c)))     -- a Char is a Word at run time
            LStr _ -> lit "LitString" ae
            _ -> stageError loc $ "literal not supported in low code: " ++ showLit l
    _ -> global
  where
    args' = map (lowQuoteExp lenv loc env) args
    apply f = if null args then f else apps (lowV "HApp") [f, encList args']
    (hd, as) = getAppE (stripTy ae)
    global =
      case (hd, as ++ map stripTy args) of
        -- error "msg"
        (Var e, [Lit (LStr msg)]) | e == mkIdent "Control.Error.error" -> App (lowV "HFail") (lowStr msg)
        (Var e, [Lit (LStr l), Lit (LStr msg)]) | e == mkIdent "Control.Error._errorLoc" -> App (lowV "HFail") (lowStr (l ++ msg))
        -- Numeric literals at a type that was unknown when they were checked: fromInteger dict (_intToInteger n)
        (Var m, [_, App (Var f) (Lit (LInt n))]) | m == mkIdent "Data.Num.fromInteger", f == mkIdent "Data.Integer_Type._intToInteger" ->
          apps (lowV "lowLitFromInteger") [Lit (LInt n), App (lowV "lowFunResult") t]
        (Var m, [_, App (App (Var f) (App (Var g) (Lit (LInt n)))) (App (Var g') (Lit (LInt d)))])
          | m == mkIdent "Data.Fractional.fromRational", f == mkIdent "Data.Ratio_Type._mkRational", g == mkIdent "Data.Integer_Type._intToInteger", g' == g ->
          apps (lowV "lowLitFromRational") [Lit (LInt n), Lit (LInt d), App (lowV "lowFunResult") t]
        _ ->
          let prim p = apply (apps (lowV "HPrim") [lowStr p, t])
              ffi (g, c) = apply (apps (lowV "HForeign") [lowStr (unIdent g), lowStr c, t])
          in  either (stageError loc) (either prim ffi) (resolveGlobal lenv env ae)

dropModule :: String -> String
dropModule s = case break (== '.') s of
                 (_, r@('.' : _)) -> r
                 _ -> s

-- Remove the type marks ($lowty t e) from an expression (used to recognize literals).
stripTy :: Exp -> Exp
stripTy e =
  case getAppE e of
    (Lit (LPrim p), _ : x : as) | p == lowTyPrim -> apps (stripTy x) (map stripTy as)
    (h, as) -> apps h (map stripTy as)

-- Find the primitive (Left) or foreign function (Right: Haskell name, C name) that a
-- global variable, or a class method at an instance, stands for.
resolveGlobal :: LowEnv -> BEnv -> Exp -> Either String (Either String (Ident, String))
resolveGlobal lenv env = resolve (0 :: Int)
  where
    resolve n _ | n > 20 = Left "cannot resolve the definition of a global in low code"
    resolve n ae =
      case ae of
        Lit (LPrim p) -> Right (Left p)
        Var g ->
          case M.lookup g (leDefs lenv) of
            Just d | Just c <- findForImp d -> Right (Right (g, c))
                   | otherwise ->
                     case resolve (n + 1) d of
                       Left _ -> Left $ "cannot use " ++ showIdent g ++ " in low code: it is not a primitive (low code can only use primitives, constructors, and local definitions)"
                       r -> r
            Nothing -> Left $ "cannot use " ++ showIdent g ++ " in low code: only primitives, constructors, and local definitions are allowed"
                           ++ (if "Integer" `isPrefixOf` unQualString (unIdent g) || ".Integer" `isPrefixOf` dropModule (unIdent g) then
                                 "\n  (numeric literals default to Integer; use a type annotation such as (0 :: Int))" else "")
        -- eta reduce  \ x -> f x
        Lam x (App f (Var y)) | x == y -> resolve (n + 1) f
        -- a class method applied to a dictionary
        App (Var m) d | Just (dcon, ix) <- M.lookup m (leMethods lenv) ->
          case dictExp d of
            Just de ->
              case getAppE de of
                (Var c, fields) | c == dcon, ix < length fields ->
                  case resolve (n + 1) (fields !! ix) of
                    Left _ -> Left notPrim
                    r -> r
                _ -> Left notPrim
              where notPrim = "the method " ++ showIdent m ++ " is not a primitive in this instance, so it cannot be used in low code"
            Nothing -> Left $ "the method " ++ showIdent m ++ " cannot be used in low code: its instance is not known"
        _ -> Left "cannot use this expression in low code: only primitives, constructors, and local definitions are allowed"
    -- the definition of a dictionary
    dictExp d =
      case d of
        Var i ->
          case M.lookup i env of
            Just (BObj (Just e)) -> dictExp e
            Just _ -> Nothing
            Nothing -> M.lookup i (leDefs lenv)
        App _ _ -> Nothing      -- an instance with a context
        _ -> Nothing
    findForImp d =
      case d of
        Lit (LForImp _ (ImpStatic _ _ c) _ _) -> Just c
        Lit _ -> Nothing
        App f a -> case findForImp f of { Nothing -> findForImp a; r -> r }
        Lam _ e -> findForImp e
        Var _ -> Nothing

-----------------------------------------------
-- Reading back low code.

-- Mirrors of the types in lib/Staged/Low/Internal.hs; they must have the same
-- constructors in the same order with the same arities.
-- Values of these types are built by meta level code in the runtime system.
data LowExpV
  = VVar Int String LowTyV
  | VLam String LowTyV (LowExpV -> LowExpV)
  | VApp LowExpV [LowExpV]
  | VLet String (Maybe LowTyV) LowExpV (LowExpV -> LowExpV)
  | VLetRec [(String, LowTyV)] ([LowExpV] -> ([LowExpV], LowExpV))
  | VCase LowExpV [LowConV] [LowAltV] (Maybe LowExpV)
  | VCon LowConV LowTyV [LowExpV]
  | VLit LowLitV LowTyV
  | VPrim String LowTyV
  | VForeign String String LowTyV
  | VFail String

data LowTyV              -- never inspected here

data LowConV = LowConV String Int Int Bool     -- name, tag, arity, newtype

data LowAltV = LowAltV LowConV [String] ([LowExpV] -> LowExpV)

data LowLitV = VInt Int | VInt64 Int64 | VDouble Double | VFloat Float | VChar Char | VString String

-- Read back low code as an expression, with the strict semantics of low code:
-- function arguments, let bound values, and constructor fields are evaluated.
-- The variables bound here get names x$l<n>; object level variables from
-- outside the low code are named like quote0 does.
lowToExp :: Int -> LowExpV -> Exp
lowToExp d av =
  case av of
    VVar l x _ -> Var (lowVarIdent l x)
    VLam x _ f -> Lam (lowBinder d x) (lowToExp (d + 1) (f (lowVarV d x)))
    VApp f as -> strictCall d (apps (lowToExp d f)) (map (lowToExp d) as)
    VLet x _ e f ->
      let x' = lowBinder d x
      in  App (Lam x' (eSeq (Var x') (lowToExp (d + 1) (f (lowVarV d x))))) (lowToExp d e)
    VLetRec xts f ->
      let n = length xts
          xs = [ lowBinder (d + i) x | (i, (x, _)) <- zip [0 ..] xts ]
          (es, body) = f [ lowVarV (d + i) x | (i, (x, _)) <- zip [0 ..] xts ]
          d' = d + n
          es' = map (lowToExp d') es
          body' = lowToExp d' body
      in  case (xs, es') of
            ([x], [e]) -> App (Lam x body') (App (Lit (LPrim "Y")) (Lam x e))
            _ ->
              let v = mkIdent ("$r" ++ show d)
                  bnds b = foldr (\ (m, x) r -> App (Lam x r) (encTupleSel m n (Var v))) b (zip [0 ..] xs)
              in  App (Lam v (bnds body')) (App (Lit (LPrim "Y")) (Lam v (bnds (encTuple es'))))
    VCase s cons alts dflt ->
      let s' = lowToExp d s
          cti = [ (mkIdent c, a) | LowConV c _ a _ <- cons ]
          isNew = or [ nt | LowConV _ _ _ nt <- cons ]
          alt (LowAltV (LowConV c _ a _) names f) =
            let xs = [ lowBinder (d + i) x | (i, x) <- zip [0 ..] names ]
                b = lowToExp (d + a) (f [ lowVarV (d + i) x | (i, x) <- zip [0 ..] names ])
            in  (SPat (ConData cti (mkIdent c) []) xs, b)
          dflt' = maybe (lowFailExp "incomplete case in low code") (lowToExp d) dflt
          cas sv =
            case (isNew, map alt alts) of
              (True, [(SPat _ [x], b)]) -> App (Lam x b) sv
              (True, _) -> lowFailExp "bad newtype case in low code"
              (False, pes) -> encCase sv pes dflt'
      in  case s' of
            Var _ -> eSeq s' (cas s')
            _ -> let sv = mkIdent ("$s" ++ show d) in App (Lam sv (eSeq (Var sv) (cas (Var sv)))) s'
    VCon (LowConV c _ _ _) _ args ->
      -- tuples have no constructor functions
      let con = case getTupleConstr (mkIdent c) of
                  Just _ -> encTuple
                  Nothing -> apps (Var (mkIdent c))
      in  strictCall d con (map (lowToExp d) args)
    VLit l _ ->
      case l of
        VInt i -> Lit (LInt i)
        VInt64 i -> Lit (LInt64 i)
        VDouble x -> Lit (LDouble x)
        VFloat x -> Lit (LFloat x)
        VChar c -> Lit (LInt (ord c))
        VString s -> Lit (LStr s)
    VPrim p _ -> Lit (LPrim p)
    VForeign g _ _ -> Var (mkIdent g)
    VFail msg -> lowFailExp msg

lowFailExp :: String -> Exp
lowFailExp msg = App (Var (mkIdent "Control.Exception.Internal.patternMatchFail")) (Lit (LStr msg))

-- Variables bound by the read back are marked (the name starts with "$l"),
-- the other variables are object level variables from outside the low code.
lowVarV :: Int -> String -> LowExpV
lowVarV d x = VVar d ("$l" ++ x) (undefined :: LowTyV)

lowBinder :: Int -> String -> Ident
lowBinder d x = mkIdent (x ++ uniqIdentSep ++ "l" ++ show d)

lowVarIdent :: Int -> String -> Ident
lowVarIdent l x | "$l" `isPrefixOf` x = lowBinder l (drop 2 x)
                | otherwise = lvlIdent l x

eSeq :: Exp -> Exp -> Exp
eSeq a b = App (App (Lit (LPrim "seq")) a) b

-- A call (or constructor application) with all the arguments evaluated first.
strictCall :: Int -> ([Exp] -> Exp) -> [Exp] -> Exp
strictCall d f as = go [] (zip [0 :: Int ..] as)
  where
    go acc [] = f (reverse acc)
    go acc ((i, a) : rest) =
      case a of
        Lit _ -> go (a : acc) rest
        Var _ -> eSeq a (go (a : acc) rest)
        _ -> let x = mkIdent ("$a" ++ show d ++ "_" ++ show i)
             in  App (Lam x (eSeq (Var x) (go (Var x : acc) rest))) a
