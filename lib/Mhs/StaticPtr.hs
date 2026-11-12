-- Static pointers.
--
-- The expression
--   static e
-- where e is closed (it only uses top level identifiers) has type StaticPtr t
-- when e has type t.  The compiler moves e to a top level definition of its own
-- and gives it a name that is the same in every run of the program, so the name
-- can be sent to another instance of the same program and be looked up there.
--
-- 'static' is only a keyword when the program has no 'static' of its own in scope.
-- There is no Typeable constraint on t.
--
-- GHC.StaticPtr can be implemented on top of this by using a fingerprint
-- of the name as the StaticKey.
module Mhs.StaticPtr(
  StaticPtr,
  staticPtrName,
  deRefStaticPtr,
  unsafeLookupStaticPtr,
  staticPtrNames,
  _static, _mkStaticPtr, _staticPtrTable,
  ) where
import qualified Prelude()              -- do not import Prelude
import Primitives
import Control.Error
import Data.Char
import Data.Eq
import Data.List
import Data.Maybe_Type

data StaticPtr a = StaticPtr String a
  deriving ()  -- no Typeable, Mhs.Builtin imports this module

-- | The name of a static pointer, it identifies the pointer in the program.
staticPtrName :: forall a . StaticPtr a -> String
staticPtrName (StaticPtr n _) = n

deRefStaticPtr :: forall a . StaticPtr a -> a
deRefStaticPtr (StaticPtr _ a) = a

-- | Find the static pointer with the given name.
-- Unsafe, because nothing checks that the type is the type of the pointer.
unsafeLookupStaticPtr :: forall a . String -> Maybe (StaticPtr a)
unsafeLookupStaticPtr n = primUnsafeCoerce (find (\ p -> staticPtrName p == n) _staticPtrTable)

-- | The names of all the static pointers in the program.
staticPtrNames :: [String]
staticPtrNames = map staticPtrName _staticPtrTable

-- What 'static' is while type checking.
-- The desugarer replaces every 'static e' with a top level definition
--   f$staticN = _mkStaticPtr "M.f$staticN" e
_static :: forall a . a -> StaticPtr a
_static _ = error "static"

_mkStaticPtr :: forall a . String -> a -> StaticPtr a
_mkStaticPtr = StaticPtr

-- All the static pointers in the program.
-- This definition is replaced when the program is linked.
_staticPtrTable :: [StaticPtr ()]
_staticPtrTable = []
