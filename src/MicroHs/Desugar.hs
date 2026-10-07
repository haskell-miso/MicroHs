-- Copyright 2023 Lennart Augustsson
-- See LICENSE file for full license.
{-# OPTIONS_GHC -Wno-incomplete-uni-patterns -Wno-unused-imports -Wno-dodgy-imports #-}
module MicroHs.Desugar(
  desugar,
  LDef, showLDefs,
  encodeInteger,
  quotePrim, splicePrim, hasSplice,
  lowUnit,
  ) where
import qualified Prelude(); import MHSPrelude
import Data.Char
import Data.Function
import Data.Integer(_integerToIntList)
import Data.List
import Data.Maybe
import Data.Ratio
import Debug.Trace

import MicroHs.EncodeData
import MicroHs.Expr
import MicroHs.Exp
import MicroHs.Flags
import MicroHs.Graph
import MicroHs.Ident
import MicroHs.List
import MicroHs.Names
import MicroHs.State as S
import MicroHs.TypeCheck
import Text.PrettyPrint.HughesPJLiteClass(prettyShow)

type LDef = (Ident, Exp)

-- Pseudo primitives marking quotations and splices in desugared code.
quotePrim :: String
quotePrim = "$quote"
splicePrim :: String
splicePrim = "$splice"

-- Desugaring mode: inside a Low quotation (closure-free code) the desugarer
-- keeps the structure of the code: case expressions, constructors, lets and
-- recursive lets are marked with pseudo primitives (see MicroHs.Names), and
-- let bound expressions are never inlined.  MicroHs.Stage turns the marked
-- code into the representation of low code.
type Low = Bool
-- Type annotations of let bound variables, from the type checker.
type Anns = [(Ident, Exp)]

desugar :: Flags -> TModule [EDef] -> TModule [LDef]
desugar flags tm =
  setBindings tm $ map lazier $ checkDup $ concat $ zipWith (dsDef flags (tModuleName tm)) [1..] (tBindingsOf tm)

dsDef :: Flags -> IdentModule -> Int -> EDef -> [LDef]
dsDef flags mn ffiNo adef =
  case adef of
    Data _ cs _ ->
      let
        n = length cs
        dsConstr i (Constr _ ctx c _ ets) =
          let
            ss = (if null ctx then [] else [False]) ++
                 map fst (either id (map snd) ets)   -- strict flags
          in (qualIdent mn c, encConstr i n ss)
      in  zipWith dsConstr [0::Int ..] cs
    Newtype _ (Constr _ _ c _ _) _ -> [ (qualIdent mn c, Lit (LPrim "I")) ]
    Fcn f eqns -> [(f, wrapTick (useTicks flags) f $ dsEqns False (getSLoc f) eqns)]
    ForImp cc ie i t -> [(i, ccall t $ Lit $ mkForImp mn ffiNo cc ie i t)]
    -- Foreign exports don't fit very well into the desugared syntax.
    -- We represent
    --   foreign export "foo" bar :: ty
    -- with
    --   foo = FE bar' ty'
    -- where bar' is the desugared expression for bar, and ty' is the C type
    -- (currently just a newtype of an EType).
    ForExp cc (Just s) e t ->  [(mkIdentSLoc l s, mkForExp (cc == Cjavascript) e' (CType t))]
      where l = getSLoc e
            e' = dsExpr False e
    Class ctx (c, _) _ bs ->
      let f = mkIdent "$f"
          meths :: [Ident]
          meths = [ qualIdent mn i | (Sign is _) <- bs, i <- is ]
          supers :: [Ident]
          supers = [ qualIdent mn $ mkSuperSel c i | i <- [1 .. length ctx] ]
          xs = [ mkIdent ("$x" ++ show j) | j <- [ 1 .. length ctx + length meths ] ]
      in  (qualIdent mn $ mkClassConstructor c, lams xs $ Lam f $ apps (Var f) (map Var xs)) :
          zipWith (\ i x -> (i, Lam f $ App (Var f) (lams xs $ Var x))) (supers ++ meths) xs
    _ -> []

-- Code for a 'foreign import'.
-- If the function is impure then wrap a performIO around the call.
ccall :: EType -> Exp -> Exp
ccall t f =
  case getArrows t of
    (_, EApp (EVar io) _) | io == identIO ->
      f
    (as, _) ->
      -- pure function, need a performIO.
      --   ^f  -->  \ x1 ... xn -> performIO (^f x1 ... xn)
      let xs = map (\ i -> mkIdent $ '_' : show i) [1..length as]
          perf = Lit $ LPrim "IO.performIO"
          call = App perf $ apps f (map Var xs)
      in  foldr Lam call xs

wrapTick :: Bool -> Ident -> Exp -> Exp
wrapTick False _ ee = ee
wrapTick True  i ee = wrap ee
  where tick = Lit (LTick (unIdent i))
        wrap (Lam x e) = Lam x (wrap e)
        wrap e = App tick e
{- This kills the automagic specialization.
wrapTick True  i ee = wrap 0 ee
  where wrap n e = App (Lit (LTick (unIdent i ++ "-" ++ show (n::Int)))) e'
          where e' = case e of
                       Lam x a -> Lam x (wrap (n+1) a)
                       _ -> e
-}

dsBind :: Low -> Anns -> Ident -> EBind -> [LDef]
dsBind low anns v abind =
  case abind of
    -- Dictionaries (and type representations) are meta level values, also in low code.
    Fcn f eqns | isDictIdent f -> [(f, dsEqns False (getSLoc f) eqns)]
    Fcn f eqns -> [(f, dsEqns low (getSLoc f) eqns)]
    PatBind p e -> dsPatBind low anns v p e
    _ -> []

-- Desugaring ~p in case introduces PatBind, so we need to get rid of it again.
dsPatBind :: Low -> Anns -> Ident -> EPat -> Expr -> [LDef]
dsPatBind low _ v p e =
  let de = (v, dsExpr low e)
      ds = [ (i, dsExpr low (ECase (EVar v) [(p, oneAlt $ EVar i)])) | i <- patVars p ]
  in  de : ds

dsEqns :: Low -> SLoc -> [Eqn] -> Exp
dsEqns low loc eqns =
  case eqns of
    Eqn aps _ : _ ->
      let
        vs = allVarsBind $ Fcn (mkIdent "") eqns
        qs = take (length aps) $ newVars "$q" vs
        -- In low code keep the names of the variables of a single equation (they are reflected).
        xs = case eqns of
               [Eqn ps _] | low -> zipWith keepName ps qs
               _ -> qs
        keepName (EVar x) q | not (isDummyIdent x) && not (isConIdent x) && length (filter (isVarNamed x) aps) == 1 = x
                            | otherwise = q
        keepName _ q = q
        isVarNamed x (EVar y) = x == y
        isVarNamed _ _ = False
        mkArm (Eqn ps alts) =
          let ps' = map dsPat ps
          in  (ps', id, dsAlts low alts)
        ex = dsCaseExp low loc (vs ++ xs) (map Var xs) (map mkArm eqns)
        -- optCase recognizes encoded ifs; low code keeps its own structure.
        ex' = if low then ex else optCase ex
      in foldr Lam ex' xs
    _ -> eMatchErr low loc

dsAlts :: Low -> EAlts -> (Exp -> Exp)
dsAlts low (EAlts alts bs) = dsBinds low [] bs . dsAltsL low alts

dsAltsL :: Low -> [EAlt] -> (Exp -> Exp)
dsAltsL _   []                 dflt = dflt
dsAltsL low [([], e)]             _ = dsExpr low e  -- fast special case
dsAltsL low ((ss, rhs) : alts) dflt =
  let
    erest = dsAltsL low alts dflt
    x = newVar (allVarsExp erest)
  in if low then
       -- In low code the rest of the alternatives is a join point: a function.
       lowJoin x erest (dsExpr low $ dsAlt (EApp (EVar x) lowUnitExpr) ss rhs)
     else
       eLet False x erest (dsExpr low $ dsAlt (EVar x) ss rhs)

lowUnitExpr :: Expr
lowUnitExpr = tupleCon noSLoc 0

-- Bind a join point in low code:  let x = \ _ -> e in body
-- The strict semantics of low code must not evaluate e unless it is used.
lowJoin :: Ident -> Exp -> Exp -> Exp
lowJoin x _ body | x `notElem` freeVars body = body      -- an unused alternative (e.g. an impossible match failure)
lowJoin x e body =
  let u = newVar (allVarsExp e)
      lam = App (App (Lit (LPrim lowLamPrim)) (encList [Var (lowIdent "tUnit")])) (Lam u e)
  in  App (Lam x body) lam

dsAlt :: Expr -> [EStmt] -> Expr -> Expr
dsAlt _ [] rhs = rhs
dsAlt dflt (SBind p e : ss) rhs = ECase e [(p, EAlts [(ss, rhs)] []), (EVar dummyIdent, oneAlt dflt)]
dsAlt dflt (SThen (EVar i) : ss) rhs | isIdent "Data.Bool.otherwise" i = dsAlt dflt ss rhs
dsAlt dflt (SThen e   : ss) rhs = EIf e (dsAlt dflt ss rhs) dflt
dsAlt dflt (SLet bs   : ss) rhs = ELet bs (dsAlt dflt ss rhs)
dsAlt _    (SRec _ : _) _ = impossible

dsBinds :: Low -> Anns -> [EBind] -> Exp -> Exp
dsBinds _ _ [] ret = ret
{-
dsBinds ads@(PatBind (ELazy False p) e : ds) ret =
  -- Turn a strict let/where into a case.
  -- XXX This does no reordering of bindings.
  let rest = dsBinds ds ret
      used = allVarsExp ret ++ allVarsExpr (ELet ads (ETuple []))
  in  dsCaseExp (getSLoc p) used [dsExpr e] [([dsPat p], const rest)]
-}
dsBinds low anns ads ret =
  let
    avs = concatMap allVarsBind ads
    pvs = newVars "$p" avs
    mvs = newVars "$m" avs
    ds = concat $ zipWith (dsBind low anns) pvs ads
    node ie@(i, e) = (ie, i, freeVars e)
    gr = map node $ checkDup ds
    asccs = stronglyConnComp gr
    loop _ [] = ret
    loop vs (AcyclicSCC (i, e) : sccs) =
      letE low anns i e $ loop vs sccs
    loop vs (CyclicSCC [(i, e)] : sccs) =
      case if low then (i, e) else lazier (i, e) of
        (i', e')
          | i' `elem` freeVars e' -> letRecE low anns i' e' $ loop vs sccs
          | otherwise -> letE low anns i' e' $ loop vs sccs
    loop vvs (CyclicSCC ies : sccs) =
      let (v:vs) = vvs in
      mutualRec low anns v ies (loop vs sccs)
  in loop mvs asccs

letE :: Low -> Anns -> Ident -> Exp -> Exp -> Exp
letE True anns i e b | Just t <- lookup i anns = apps (Lit (LPrim lowLetPrim)) [t, Lam i b, e]  -- $lowlet t (\ i -> b) e
letE low _ i e b = eLet low i e b          -- do some minor optimizations
             --App (Lam i b) e

-- Do a single recursive definition 'let i = e in b'
-- by 'let i = Y (\i.e) in b'
letRecE :: Low -> Anns -> Ident -> Exp -> Exp -> Exp
letRecE True anns i e b = lowLetRec anns [(i, e)] b
letRecE low _ i e b = letE low [] i (App (Lit (LPrim "Y")) (Lam i e)) b

-- Recursive definitions in low code:
--   $lowletrec n [t1 .. tn] (\ x1 ... xn -> $lowrecbody e1 ... en body)
lowLetRec :: Anns -> [LDef] -> Exp -> Exp
lowLetRec anns ies body =
  let (is, es) = unzip ies
      ty i = fromMaybe (Lit (LPrim "$lowunknown")) (lookup i anns)
  in  apps (Lit (LPrim lowLetRecPrim)) [Lit (LInt (length is)), encList (map ty is), lams is (apps (Lit (LPrim lowRecBodyPrim)) (es ++ [body]))]

-- Do mutual recursion by tupling up all the definitions.
--  let f = ... g ...
--      g = ... f ...
--  in  body
-- turns into
--  letrec v =
--        let f = sel_0_2 v
--            g = sel_1_2 v
--        in  (... g ..., ... f ...)
--  in
--    let f = sel_0_2 v
--        g = sel_1_2 v
--    in  body
mutualRec :: Low -> Anns -> Ident -> [LDef] -> Exp -> Exp
mutualRec True anns _ ies body = lowLetRec anns ies body
mutualRec _ _ v ies body =
  let (is, es) = unzip ies
      n = length is
      ev = Var v
      one m i = letE False [] i (encTupleSel m n ev)
      bnds = foldr (.) id $ zipWith one [0..] is
  in  letRecE False [] v (bnds $ encTuple es) $
      bnds body

-- In case we are cross compiling for a 32 bit platform we don't want integers that are too big.
-- So we use the 32 bit bounds on the int encoding.
encodeInteger :: Integer -> Exp
encodeInteger i | -0x80000000 <= i && i <= 0x7fffffff  =
--  trace ("*** small integer " ++ show i) $
  App (Var (mkIdent "Data.Integer_Type._intToInteger")) (Lit (LInt (fromInteger i)))
                | otherwise =
--  trace ("*** large integer " ++ show i) $
  App (Var (mkIdent "Data.Integer._intListToInteger")) (encList (map (Lit . LInt) (_integerToIntList i)))

encodeRational :: Rational -> Exp
encodeRational r =
  App (App (Var (mkIdent "Data.Ratio_Type._mkRational")) (encodeInteger (numerator r))) (encodeInteger (denominator r))

dsExpr :: Low -> Expr -> Exp
dsExpr low aexpr =
  case aexpr of
    -- Change calls to error&undefined to include location
    EVar f | f == mkIdent "Control.Error.undefined" ->
      dsExpr low $ addLoc (mkIdentSLoc (getSLoc f) "Control.Error._undefinedLoc")
    EVar f | f == mkIdent "Control.Error.error" ->
      dsExpr low $ addLoc (mkIdentSLoc (getSLoc f) "Control.Error._errorLoc")

    EVar i -> Var i
    EApp (EApp (EVar app) (EListish (LCompr e stmts))) l | app == iapp ->
      dsExpr low $ dsCompr e stmts l
    -- Low code markers from the type checker.  The annotations are meta level code.
    EApp (EApp (ELit _ (LPrim p)) (EListish (LList anns))) (ELet ads e) | p == lowLetPrim ->
      dsBinds low [ (mkIdent n, dsExpr False a) | ETuple [ELit _ (LStr n), a] <- anns ] ads (dsExpr low e)
    EApp (EApp (ELit _ (LPrim p)) ann) e | p `elem` lowTypeMarkers ->
      App (App (Lit (LPrim p)) (dsExpr False ann)) (dsExpr low e)
    EApp f a -> App (dsExpr low f) (dsExpr low a)
    ELam l qs -> dsEqns low l qs
    ELit l (LExn s) -> Var (mkIdentSLoc l s)
    ELit _ (LChar c) | not low -> Lit (LInt (ord c))
    ELit _ (LInteger i) -> encodeInteger i
    ELit _ (LRat i) -> encodeRational i
    ELit _ l -> Lit l
    ECase e as -> dsCase low (getSLoc aexpr) e as
    ELet ads e -> dsBinds low [] ads (dsExpr low e)
    ETuple es | low -> apps (lowConExp (tupleCon (getSLoc aexpr) (length es))) (map (dsExpr low) es)
              | otherwise -> encTuple $ map (dsExpr low) es
    EIf e1 e2 e3 | low -> lowIf (dsExpr low e1) (dsExpr low e2) (dsExpr low e3)
                 | otherwise -> encIf (dsExpr low e1) (dsExpr low e2) (dsExpr low e3)
    EListish (LList es) | low -> dsExpr low $ foldr (\ e r -> EApp (EApp conCons e) r) conNil es
                        | otherwise -> encList $ map (dsExpr low) es
    EListish (LCompr e stmts) -> dsExpr low $ dsCompr e stmts (EListish (LList []))
    -- Staging markers, interpreted by MicroHs.Stage.
    -- A quotation is desugared in the mode of its kind (Code or Low).
    EQuote (Just k) e | isLowKind k -> App (Lit (LPrim lowQuotePrim)) (dsExpr True e)
                      | otherwise   -> App (Lit (LPrim quotePrim)) (dsExpr False e)
    -- Low code spliced into object code (or a Code quotation) is converted to Code.
    ESplice (Just k) e | not low && isLowKind k -> App (Lit (LPrim splicePrim)) (App (Var (mkIdent "$Code.low")) (dsExpr False e))
                       | otherwise -> App (Lit (LPrim splicePrim)) (dsExpr False e)
    EQuote Nothing _ -> impossiblePP aexpr
    ESplice Nothing _ -> impossiblePP aexpr
    EStaged _ _ _ e -> dsExpr low e    -- should have been resolved by the type checker
    ECon _ | low -> lowConExp aexpr
    ECon c ->
        case getTupleConstr (conIdent c) of
          Just n ->
            let
              xs = [mkIdent ("x" ++ show i) | i <- [1 .. n] ]
              body = encTuple $ map Var xs
            in foldr Lam body xs
          Nothing -> Var (conIdent c)
    _ -> impossiblePP aexpr
  where addLoc i = EApp (EVar i) (ELit l (LStr (prettyShow l ++ ": "))) where l = getSLoc i
        iapp = mkIdent "Data.List_Type.++"

isLowKind :: EType -> Bool
isLowKind (EVar c) = c == identLow
isLowKind _ = False

-- A constructor in low code:  $lowcon "C" tag ncons arity newtype
lowConExp :: Expr -> Exp
lowConExp (ECon c) =
  let (i, tag, n, ar, nt) =
        case c of
          ConData cti ci _ ->
            case lookup ci cti of
              Just a -> (ci, length (takeWhile ((/= ci) . fst) cti), length cti, a, 0)
              Nothing -> impossible
          ConNew ci _ -> (ci, 0, 1, 1, 1)
          ConSyn{} -> impossible
  in  apps (Lit (LPrim lowConPrim)) [Lit (LStr (unIdent i)), Lit (LInt tag), Lit (LInt n), Lit (LInt ar), Lit (LInt nt)]
lowConExp e = impossiblePP e

-- The unit value in low code.
lowUnit :: Exp
lowUnit = lowConExp (tupleCon noSLoc 0)

-- if in low code: a case on Bool.
lowIf :: Exp -> Exp -> Exp -> Exp
lowIf c t e =
  let cti = [(identFalse, 0), (identTrue, 0)]
  in  lowCase c [(SPat (ConData cti identFalse []) [], e), (SPat (ConData cti identTrue []) [], t)] (lowFail "if")

identFalse, identTrue :: Ident
identFalse = mkIdent "Data.Bool_Type.False"
identTrue = mkIdent "Data.Bool_Type.True"

-- A case in low code:
--   $lowcase x ($lowcons "C1" a1 ... "Cn" an) k alt1 ... altk dflt
-- where the alternatives are   $lowalt "Ci" i (\ x1 ... xai -> e)
lowCase :: Exp -> [(SPat, Exp)] -> Exp -> Exp
lowCase var pes dflt =
  case pes of
    (SPat (ConData cti _ _) _, _) : _ ->
      let cons = apps (Lit (LPrim lowConsPrim)) (Lit (LInt 0) : concat [ [Lit (LStr (unIdent c)), Lit (LInt a)] | (c, a) <- cti ])
          alt (SPat (ConData _ c _) xs, e) =
            apps (Lit (LPrim lowAltPrim)) [Lit (LStr (unIdent c)), Lit (LInt (length (takeWhile ((/= c) . fst) cti))), lams xs e]
          alt _ = impossible
      in  apps (Lit (LPrim lowCasePrim)) (var : cons : Lit (LInt (length pes)) : map alt pes ++ [dflt])
    (SPat (ConNew c _) [x], e) : _ ->
      let cons = apps (Lit (LPrim lowConsPrim)) [Lit (LInt 1), Lit (LStr (unIdent c)), Lit (LInt 1)]
          alt = apps (Lit (LPrim lowAltPrim)) [Lit (LStr (unIdent c)), Lit (LInt 0), Lam x e]
      in  apps (Lit (LPrim lowCasePrim)) [var, cons, Lit (LInt 1), alt, dflt]
    _ -> impossible

-- A failed pattern match in low code.
lowFail :: String -> Exp
lowFail msg = App (Lit (LPrim lowFailPrim)) (Lit (LStr msg))

dsCompr :: Expr -> [EStmt] -> Expr -> Expr
dsCompr e [] l = EApp (EApp conCons e) l
dsCompr e (SThen c : ss) l = EIf c (dsCompr e ss l) l
dsCompr e (SLet ds : ss) l = ELet ds (dsCompr e ss l)
-- Special case for the idiom [ ... | ..., p <- [x], ... ].  This is a little more efficient.
dsCompr e (SBind p (EListish (LList [x])) : ss) l = ECase x [(p, oneAlt $ dsCompr e ss l), (EVar dummyIdent, oneAlt l)]
dsCompr e xss@(SBind p g : ss) l = ELet [hdef] (EApp eh g)
  where
    hdef = Fcn h [eqn1, eqn2, eqn3]
    eqn1 = eEqn [conNil] l
    eqn2 = eEqn [EApp (EApp conCons p) vs] (dsCompr e ss (EApp eh vs))
    eqn3 = eEqn [EApp (EApp conCons u) vs]               (EApp eh vs)
    u = EVar dummyIdent
    h = head $ newVars "$h" allVs
    eh = EVar h
    vs = EVar $ head $ newVars "$vs" allVs
    allVs = allVarsExpr (EListish (LCompr (ETuple [e,l]) xss))  -- all used identifiers
dsCompr _ (SRec _ : _) _ = impossible

-- Handle special syntax for lists and tuples.
dsPat :: HasCallStack =>
         EPat -> EPat
dsPat apat =
  case apat of
    EVar _ -> apat
    ECon _ -> apat
    EApp f a -> EApp (dsPat f) (dsPat a)
    EListish (LList ps) -> dsPat $ foldr (EApp . EApp conCons) conNil ps
    ETuple ps -> dsPat $ foldl EApp (tupleCon (getSLoc apat) (length ps)) ps
    EAt i p -> EAt i (dsPat p)
    ELit loc (LStr cs) | length cs < 2 -> dsPat (EListish (LList (map (ELit loc . LChar) cs)))
    ELit _ _ -> apat
    ENegApp _ -> apat
    EViewPat e p -> EViewPat e (dsPat p)
    ELazy b pat -> ELazy b (dsPat pat)
    _ -> impossible

newVars :: String -> [Ident] -> [Ident]
newVars s is = deleteAllsBy (==) [ mkIdent (s ++ show i) | i <- [1::Int ..] ] is

newVar :: [Ident] -> Ident
newVar = head . newVars "$v"

showLDefs :: [LDef] -> String
showLDefs = unlines . map showLDef

showLDef :: LDef -> String
showLDef a =
  case a of
    (i, e) -> showIdent i ++ " = " ++ prettyShow e

----------------

dsCase :: HasCallStack => Low -> SLoc -> Expr -> [ECaseArm] -> Exp
dsCase low loc ae as =
  dsCaseExp low loc usedVars [dsExpr low ae] (map mkArm as)
  where
    usedVars = allVarsExpr (ECase ae as)
    mkArm :: ECaseArm -> Arm
    mkArm (p, alts) =
      let p' = dsPat p
      in  ([p'], id, dsAlts low alts)

type MState = [Ident]  -- supply of unused variables.

type M a = State MState a
type Arm = ([EPat], Exp -> Exp, Exp -> Exp)  -- Patterns, a substitution,
                                             -- and a function that expects the default (which might be ignored).
type Matrix = [Arm]

newIdents :: Int -> M [Ident]
newIdents n = do
  is <- get
  put (drop n is)
  return (take n is)

newIdent :: M Ident
newIdent = do
  is <- get
  put (tail is)
  return (head is)

dsCaseExp :: HasCallStack => Low -> SLoc -> [Ident] -> [Exp] -> Matrix -> Exp
dsCaseExp low loc used ss mtrx =
  let
    supply = newVars "$x" used
    ds xs aes =
      case aes of
        []   -> dsMatrixL low (eMatchErr low loc) (reverse xs) mtrx
        e:es -> letBind low (return e) $ \ x -> ds (x:xs) es
  in evalState (ds [] ss) supply

-- Handle lazy and strict bindings
dsMatrixL :: HasCallStack =>
             Low -> Exp -> [Exp] -> Matrix -> M Exp
dsMatrixL low dflt is arms = dsMatrix low dflt is (map (dsLazy low) arms)

dsLazy :: Low -> Arm -> Arm
dsLazy low (ps, sub, rhs) =
  -- Accumulate lazy bindings and strict bindings
  let ((_, rbs, ris), ps') = mapAccumL lazy (1, [], []) ps
      lazy :: (Int, [EBind], [Exp]) -> EPat -> ((Int, [EBind], [Exp]), EPat)
      lazy s@(n, bs, is) ap =
        case ap of
          ELazy False p'@(EVar i) | not (isDummyIdent i)        -- XXX !_ doesn't work
                                  -> ((n, bs, Var i : is), p')
          ELazy False p'          -> lazy (n, bs, is) p'        -- ignore ! on non-variables for now
          ELazy True  p'          -> ((n+1, b:bs, is), EVar v)
            where v = mkIdent ("~" ++ show n)
                  b = PatBind p' (EVar v)
          EVar _                  -> (s, ap)
          EViewPat e p            -> (s', EViewPat e p') where (s', p')  = lazy s p
          ECon _                  -> (s, ap)
          EApp p1 p2              -> (s'', EApp p1' p2') where (s', p1') = lazy s p1; (s'', p2') = lazy s' p2
          EAt i p                 -> (s', EAt i p')      where (s', p')  = lazy s p
          _                       -> impossible
  in  (ps', sub, \ d -> dsBinds low [] (reverse rbs) $ foldr eSeq (rhs d) (reverse ris))

eSeq :: Exp -> Exp -> Exp
eSeq e1 e2 = App (App (Lit (LPrim "seq")) e1) e2

-- XXX quadratic.  but only used for short lists
groupEq :: forall a . (a -> a -> Bool) -> [a] -> [[a]]
groupEq eq axs =
  case axs of
    [] -> []
    x:xs ->
      case partition (eq x) xs of
        (es, ns) -> (x:es) : groupEq eq ns

-- Desugar a pattern matrix.
-- The input is a (usually identifier) vector e1, ..., en
-- and patterns matrix p11, ..., p1n   -> e1
--                     p21, ..., p2n
--                     pm1, ..., pmn   -> em
-- Note that the RHSs are of type Exp.
dsMatrix :: HasCallStack =>
            Low -> Exp -> [Exp] -> Matrix -> M Exp
--dsMatrix dflt is aarms | trace (show (dflt, is)) False = undefined
dsMatrix _   dflt _ [] = return dflt
dsMatrix _   dflt []         aarms =
  -- We can have several arms if there are guards.
  -- Combine them in order.
  return $ foldr (\ (_, sub, rhs) -> sub . rhs) dflt aarms
dsMatrix low dflt iis@(i:is) aarms@(aarm : _) =
  case leftMost aarm of
    EVar _ -> do
      -- Find all variables, substitute with i, and proceed
      let (vars, nvars) = span (isPVar . leftMost) aarms
          vars' = map (sub . unAt i) vars
          sub (EVar x : ps, sb, rhs) = (ps, substAlpha x i . sb, rhs)
          sub _ = impossible
      letBindJoin low (dsMatrix low dflt iis nvars) $ \ drest ->
        dsMatrix low drest is vars'
    -- Collect identical transformations, do the transformation and proceed.
    EViewPat e _ -> do
      let e' = case unAt i aarm of (_, sub, _) -> sub (dsExpr low e)
      let (views, nviews) = span (isPView e') (map (unAt i) aarms)
      letBindJoin low (dsMatrix low dflt iis nviews) $ \ drest ->
        letBind low (return $ App e' i) $ \ vi -> do
        let views' = map unview views
            unview (EViewPat _ p:ps, sub, rhs) = (p:ps, sub, rhs)
            unview _ = impossible
        dsMatrix low drest (vi:is) views'

    -- Collect all constructors, group identical ones.
    _ -> do             -- must be ECon/EApp
      let
        (cons, ncons) = span (isPCon . leftMost) aarms
      letBindJoin low (dsMatrix low dflt iis ncons) $ \ drest -> do
        let
          idOf (p:_, _, _) = pConOf p
          idOf _ = impossible
          grps = groupEq (on (==) idOf) $ map (unAt i) cons
          oneGroup grp = do
            let
              con = pConOf $ leftMost $ head grp
            xs <- newIdents (conArity con)
            let
              one (p : ps, sub, e) = (pArgs p ++ ps, sub, e)
              one _ = impossible
            cexp <- dsMatrix low drest (map Var xs ++ is) (map one grp)
            return (SPat con xs, cexp)
        narms <- mapM oneGroup grps
        return $ mkCase low i narms drest
  where
    leftMost (p:_, _, _) = skipEAt p  -- pattern in first column
    leftMost _ = impossible
    skipEAt (EAt _ p) = skipEAt p
    skipEAt p = p
    isPCon (EVar _) = False
    isPCon (EViewPat _ _) = False
    isPCon _ = True
    isPVar (EVar _) = True
    isPVar _ = False
    isPView :: Exp -> Arm -> Bool
    isPView e (EViewPat ee _:_, sub, _) = e == sub (dsExpr low ee)
    isPView _ _ = False

unAt :: Exp{-Ident-} -> Arm -> Arm
unAt ii (EAt x p : ps, sub, rhs) = unAt ii (p:ps, substAlpha x ii . sub, rhs)
unAt _ arm = arm

mkCase :: Low -> Exp -> [(SPat, Exp)] -> Exp -> Exp
mkCase low var pes dflt =
  --trace ("mkCase " ++ show pes) $
  case pes of
    [] -> dflt
    _ | low -> lowCase var pes dflt
    [(SPat (ConNew _ _) [x], arhs)] -> eLet low x var arhs
    _ -> encCase var pes dflt

eMatchErr :: Low -> SLoc -> Exp
eMatchErr True loc = lowFail (prettyShow loc)
eMatchErr _ loc =
  let exn = mkIdentSLoc loc "Control.Exception.Internal.patternMatchFail"
      msg = LStr $ prettyShow loc
  in  App (Var exn) (Lit msg)

-- If the first expression isn't a variable/literal, then use
-- a let binding and pass variable to f.
letBind :: Low -> M Exp -> (Exp -> M Exp) -> M Exp
letBind low me f = do
  e <- me
  if cheap e then
    f e
   else do
    x <- newIdent
    r <- f (Var x)
    return $ eLet low x e r

-- Like letBind, but for the default alternatives of a match (join points).
-- In low code these must be functions, so that the (strict) code does
-- not evaluate the alternative unless it is needed.
letBindJoin :: Low -> M Exp -> (Exp -> M Exp) -> M Exp
letBindJoin False me f = letBind False me f
letBindJoin True me f = do
  e <- me
  if cheap e then
    f e
   else do
    x <- newIdent
    r <- f (App (Var x) lowUnit)
    return $ lowJoin x e r

cheap :: Exp -> Bool
cheap ae =
  case ae of
    Var _ -> True
    Lit (LInt _) -> True
--    Lit _ -> True  -- inlining all literals can reduce sharing
    _ -> False

eLet :: Low -> Ident -> Exp -> Exp -> Exp
eLet _ i e b | cheap e = substExp i e b    -- always inline variables and literals
eLet low i e b =
  if i == dummyIdent then
    b
  else
    case b of
      Var j | i == j -> e
      _ ->
        case filter (== i) (freeVars b) of
          []  -> b                -- no occurences, no need to bind
          -- The single use substitution is essential for performance.
          -- But not when the body contains a splice: the variable may be quoted
          -- inside the splice, and the code generated by the splice can use it
          -- any number of times (this is what let insertion relies on).
          -- Not in low code either: a let is evaluated once, and before its body.
          -- (Except for dictionaries, which are meta level values.)
          [_] | not (hasSplice b), not low || isDict i -> substExp i e b   -- single occurrence, substitute  XXX could be worse if under lambda
          _ | low && isDict i -> substExp i e b
          _   -> App (Lam i b) e  -- just use a beta redex
  where isDict = isDictIdent

isDictIdent :: Ident -> Bool
isDictIdent j = dictPrefixDollar `isPrefixOf` unIdent j

-- Does the expression contain a splice?
hasSplice :: Exp -> Bool
hasSplice (Lit (LPrim p)) = p == splicePrim
hasSplice (App f a) = hasSplice f || hasSplice a
hasSplice (Lam _ e) = hasSplice e
hasSplice _ = False

-- Change from x to y inside e.
substAlpha :: Ident -> Exp -> Exp -> Exp
substAlpha x y e =
  if x == dummyIdent then
    e
  else
    substExp x y e

pConOf :: HasCallStack =>
          EPat -> Con
pConOf apat =
  case apat of
    ECon c -> c
    EAt _ p -> pConOf p
    EApp p _ -> pConOf p
    _ -> impossiblePP apat

pArgs :: EPat -> [EPat]
pArgs apat =
  case apat of
    ECon _ -> []
    EApp f a -> pArgs f ++ [a]
    ELit _ _ -> []
    _ -> impossible

getDups :: (Ord a) => [a] -> [[a]]
getDups = filter ((> 1) . length) . groupSort

checkDup :: [LDef] -> [LDef]
checkDup ds =
  case getDups $ filter (/= dummyIdent) $ map fst ds of
    [] -> ds
    (i1:_i2:_) : _ ->
      errorMessage (getSLoc i1) $ "duplicate definition " ++ showIdent i1
        -- XXX mysteriously the location for i2 is the same as i1
        -- ++ ", also at " ++ showSLoc (getSLoc i2)
    _ -> error "checkDup"

-- Make recursive definitions lazier.
-- The idea is that we have
--  f x y = ... (f x) ...
-- we turn this into
--  f x = letrec f' y = ... f' ... in f'
-- thus avoiding the extra argument passing.
-- This gives a small speedup with overloading.
lazier :: LDef -> LDef
lazier def@(fcn, l@(Lam _ _)) =
  let fcn' = addIdentSuffix fcn "@"
      vfcn' = Var fcn'
      args :: Exp -> (Exp, [Ident])
      args (Lam x b) = -- (x:) <$> args b
        let (e, xs) = args b
        in  (e, x:xs)
      args e = (e, [])
      (body, as) = args l
      -- Find min # of args that are unchanged in a recursive call.
      -- Here 0 == no recursive calls seen (or only 0-matched calls seen).
      -- We ignore recursive calls with 0 matched args.
      minn :: Int -> Int -> Int
      minn 0 b = b
      minn a 0 = a
      minn a b = min a b
      minMatch :: [Ident] -> Exp -> Int
      minMatch _ (Lam i _) | i `elem` as = 0   -- name capture, so ignore matches
      minMatch _ (Lam _ e) = minMatch [] e
      minMatch vs (App f (Var v)) = minMatch (v:vs) f
      minMatch _ (App f a) = minMatch [] f `minn` minMatch [] a
      minMatch [] (Var _) = 0
      minMatch vs (Var v) | v == fcn = length (takeWhile id (zipWith (==) vs as))
      minMatch _ _ = 0
      arity = minMatch [] body
      (drops, keeps) = splitAt arity as
      -- reverse n-ary apply
      app :: [Ident] -> Exp -> Exp
      app vs e = apps e (map Var vs)
      -- Replace n recursive args with call to vfcn'
      repl :: [Ident] -> Exp -> Exp
      repl vs (Lam i e) = app vs $ Lam i $ repl [] e
      repl vs (App f (Var v)) = repl (v:vs) f
      repl vs (App f a) = app vs $ App (repl [] f) (repl [] a)
      repl [] (Var v) = Var v
      repl vs (Var v)
        | v == fcn && take arity vs == drops = app (drop arity vs) vfcn'
      repl vs e = app vs e
  in  if arity > 0
      then (fcn, lams drops $ letRecE False [] fcn' (lams keeps (repl [] body)) vfcn')
      else def
lazier def = def

---------

-- "[static] [name.h] [&] [expr]"
-- "[static] [name.h] value [expr]"
-- "dynamic"
-- "wrapper"
-- When the calling convention is ccall the 'expr' has to be a name,
-- with capi it can be any C expression.
parseImpEnt :: SLoc -> CallConv -> String -> String -> ImpEnt
parseImpEnt _ Cjavascript _ s = ImpJS s
parseImpEnt loc _cc ui s =
  case words s of
    ["dynamic"] -> ImpDynamic
    ["wrapper"] -> ImpWrapper
    "static" : r -> rest [] r
    r            -> rest [] r
 where rest incs (inc : r) | ".h" `isSuffixOf` inc = rest  (incs ++ [inc])  r
       rest incs r                                 = rest' (ImpStatic incs) r
       rest' c ("&"     : r) = rest'' (c IPtr) r
       rest' c ['&'     : r] = rest'' (c IPtr) [r]
       rest' c ("value" : r) = rest'' (c IValue) [unwords r]
       rest' c r             = rest'' (c IFunc) r
       rest'' c [] = c ui
       rest'' c [n] = c n
       rest'' _ _ = badForImp loc

badForImp :: SLoc -> a
badForImp loc = errorMessage loc "bad foreign import"

mkForImp :: IdentModule -> Int -> CallConv -> Maybe String -> Ident -> EType -> Lit
mkForImp _ _ Cjavascript Nothing i _ = badForImp (getSLoc i)
mkForImp mn no cc ms i ty =
  let cty = CType ty
      loc = getSLoc i
      ui  = unIdent (unQualIdent i)
      isValidC (c:cs) = isAlpha c && all (\ d -> isAlphaNum d || d == '_') cs
      isValidC _ = False
      impent = parseImpEnt loc cc ui $ fromMaybe "" ms
      fno = show no
      cid =
        case impent of
          ImpStatic _ _ n ->
            if isValidC n then n else fno
          _ -> fno
  in  LForImp mn impent cid cty

-- Pattern matching against a number of Int/Char constants, e.g.
--  case e of 1->2; 2->3; 3->4; _->5
-- make each match turn into view pattern  ((1 ==) -> True) -> 2; ((2 ==) -> True) -> 3 etc.
-- This is quite slow when there are many case arms.
-- Recognize this case and turn it into a binary search instead.
-- Sadly, it only works for Char/Int/Word in this simple version.
optCase :: Exp -> Exp
optCase ae = opt [] ae
  where opt arms e | Just (eq, texp, fexp) <- getEncIf e
                   , Just (var, lit) <- getEqExp eq = opt ((var, (lit, texp)) : arms) fexp
        opt arms@((var, _):_) dflt | length arms >= binLimit && all ((var ==) . fst) arms
                                   , let kes = sortBy (compare `on` fst) (map snd arms)
                                   , length kes == length (groupBy ((==) `on` fst) kes)  -- no duplicated labels
                                   = tree var kes dflt
        opt _ _ = ae

        getEqExp (App (App (App (Var sel) (Var dict)) (Lit (LInt lit))) var@(Var _))
          |  unIdent sel  == "Data.Eq.=="
          && (unIdent dict == "inst$Data.Eq.Eq@Primitives.Char" ||
              unIdent dict == "inst$Data.Eq.Eq@Primitives.Int" ||
              unIdent dict == "inst$Data.Eq.Eq@Primitives.Word")
          = Just (var, lit)
        getEqExp _ = Nothing

        tree var kes dflt | l < binLimit = linear var kes dflt
                      | otherwise =
                        case splitAt (l `quot` 2) kes of
                          (lo, hi@((k,_):_)) -> encIf (gtInt k var) (tree var lo dflt) (tree var hi dflt)
                          _ -> undefined
                      where l = length kes
        linear _ [] dflt = dflt
        linear var ((k, rhs):kes) dflt = encIf (eqInt k var) rhs (linear var kes dflt)

        eqInt :: Int -> Exp -> Exp
        eqInt i x = app2 (Lit (LPrim "==")) (Lit (LInt i)) x
        gtInt :: Int -> Exp -> Exp
        gtInt i x = app2 (Lit (LPrim ">")) (Lit (LInt i)) x

-- Switch to binary search with >= binLimit arms
-- Experimentally, this seems to be the sweet spot.
binLimit :: Int
binLimit = 7
