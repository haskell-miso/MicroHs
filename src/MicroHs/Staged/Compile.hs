-- See LICENSE file for full license.
--
-- Whole program optimization (mhs -wpo): compile a whole program to C with
-- a staged call by need interpreter, instead of to combinators.
--
-- The definitions of the program are decoded on demand from their combinator
-- code (MicroHs.Staged.Decode) and interpreted at compile time, starting from
-- main; what cannot be done at compile time becomes C code, which uses the
-- primitives of the runtime system (src/runtime/eval.c).  See doc/wpo.md.
module MicroHs.Staged.Compile(compileWPO) where
import qualified Prelude(); import MHSPrelude
import MicroHs.Desugar(LDef)
import MicroHs.Exp
import Data.List(nub)
import MicroHs.Expr(Lit(..), showLit)
import MicroHs.Flags
import MicroHs.Ident
import MicroHs.Staged.Decode

-- Compile the program whose main is the given name to C
compileWPO :: Flags -> [LDef] -> Ident -> IO String
compileWPO flags allDefs mainName = do
  let defs = mkDefs allDefs
      reach = reachable defs mainName
  dumpIf flags Dwpo $ do
    putStrLn ("wpo: " ++ show (length reach) ++ " definitions reachable from " ++ showIdent mainName)
    mapM_ (\ (i, e) -> putStrLn (showIdent i ++ " = " ++ showE 0 e "")) reach
    putStrLn ("wpo: primitives used: " ++ unwords (nub (concatMap (prims . snd) reach)))
  error "mhs -wpo: code generation is not implemented yet"

-- Print a decoded expression (lambda calculus)
showE :: Int -> Exp -> ShowS
showE p e =
  case e of
    Var i -> showString (showIdent i)
    Lit l -> showString (showLit l)
    Lam i b -> showParen (p > 0) $ showString "\\" . showString (showIdent i) . showString " -> " . showE 0 b
    App f a -> showParen (p > 1) $ showE 1 f . showString " " . showE 2 a

-- The primitives and foreign functions an expression uses
prims :: Exp -> [String]
prims e =
  case e of
    App f a -> prims f ++ prims a
    Lam _ b -> prims b
    Lit (LPrim p) -> [p]
    Lit (LForImp _ _ c _) -> ["ffi:" ++ c]
    Lit l@(LExn _) -> [showLit l]
    _ -> []
