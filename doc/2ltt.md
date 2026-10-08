# Two-level type theory in MicroHs

This branch adds staged compilation to MicroHs in the style of
András Kovács' two-level type theory (2LTT):

* *Staged Compilation with Two-Level Type Theory*, ICFP 2022
  ([demo implementation](https://github.com/AndrasKovacs/staged/tree/main/demo))
* *Closure-Free Functional Programming in a Two-Level Type Theory*, ICFP 2024

MicroHs is not dependently typed, so this is the Haskell 98 fragment of 2LTT:
two stages, a `Code` type connecting them, and the rule that every type and
term former stays within one stage.

## The language

There are two stages:

* the **meta level** (compile time, stage 1 in the papers), and
* the **object level** (run time, stage 0).

Three constructs connect the stages (the `Staged` module exports `Code`):

```haskell
Code a      -- the meta level type of object level code of type a   (⇑A in the papers)
[| e |]     -- quotation: if e :: a at the object level then [| e |] :: Code a at the meta level
~e          -- splice:    if e :: Code a at the meta level then ~e :: a at the object level
```

with the definitional equalities `~[| e |] = e` and `[| ~e |] = e`.
A splice binds tighter than application: `~f x` is `(~f) x`.

Everything else is ordinary Haskell.  The stage of a term is determined by its
type: a type that mentions `Code` is a meta level type; all other types
(including `IO`, `Ptr` and the other runtime system types) are
*stage polymorphic* and can be used at either stage.  Likewise a top level
definition whose body uses a quotation is meta level, one that uses a splice is
object level, and anything else (including the entire Prelude) is stage
polymorphic.

```haskell
import Staged

power :: Int -> Code Int -> Code Int          -- meta level: runs in the compiler
power 0 _ = [| 1 |]
power n x = [| ~x * ~(power (n - 1) x) |]

cube :: Int -> Int                            -- object level: ordinary run time code
cube x = ~(power 3 [| x |])                   -- compiles to  cube x = x * (x * (x * 1))
```

Meta level code is run by the compiler, and never exists at run time;
object level code is compiled as usual after all splices have been executed.
The compiler runs meta level code with the ordinary MicroHs runtime system (the
same way the interactive system runs code), so compile time code behaves exactly
like run time code and can use all of the library, including the parts that
use the FFI (`Integer`, `show` for `Double`, ...).  It follows that splices
need a compiler that is itself compiled with MicroHs; the GHC compiled
compiler (`gmhs`) reports an error for a module with a splice.
The result of staging can be inspected with `mhs -ddump-stage`.

### Mixed stages

Because function types are homogeneous (`a -> b` has `a` and `b` at the same
stage), a meta level function cannot take or return object level values
directly; it takes and returns `Code`.  The constructs that *can* mix stages
are bindings and case analysis:

* `let x = e in b` (and `where` without guards): the binding and the body may be
  at different stages.  A meta level binding with an object level body
  evaluates `e` at compile time (as in `power5` below).  An object level
  binding with a meta level body of type `Code t` puts the binding into the
  generated code (as in `gen` below).

* `case e of alts` and `if c then t else e`: the scrutinee (with the patterns
  and guards) and the branches may be at different stages.  A meta level
  scrutinee with object level branches is a compile time choice between pieces
  of code.  An object level scrutinee with meta level branches of type `Code t`
  generates a case expression.

```haskell
power5 :: Int -> Int
power5 x = let n = 2 + 3 in ~(power n [| x |])     -- n is computed by the compiler

gen :: Code a -> Gen (Code a)                       -- let insertion (from the Staged module)
gen c = Gen $ \ k -> [| let x = ~c in ~(k [| x |]) |]

safeDiv :: Code Int -> Code Int -> Code Int
safeDiv x y = [| case ~y of { 0 -> 0; d -> ~x `div` d } |]
```

The type checker makes these explicit by inserting quotations and splices,
exactly as Kovács' elaborator does for `let`:
`let n = 2 + 3 in ~e` becomes `~(let n = 2 + 3 in [| ~e |])`.

What is *not* allowed, as in 2LTT:

* cross stage persistence: a meta level value cannot be used in object code
  except through the literal serialization functions `codeInt`, `codeChar`,
  `codeString`, ... (and your own, e.g. `codeBool`);
* inspecting code: a `Code a` value is opaque;
* using an object level variable at the meta level other than quoted;
* eliminating object level data with a meta level result, e.g.
  `case (x :: object Int) of 0 -> (meta thing)`.  Use the `Gen` monad and
  generate a `case` instead.

Type class constraints are at the stage of their type: `Show a => Code a -> Code String`
is rejected (`a` would be at both stages); write `Code (a -> String) -> Code a -> Code String`
or use a concrete type.  Overloaded operations on concrete types work at both stages,
e.g. `show (sum [1..100 :: Int])` can be computed at compile time.

### Inferred quotations and splices

Most quotations and splices can be left out; the type checker inserts them,
following the coercive subtyping of Kovács' demo implementation
(`A ≤ Code A` inserts a quotation, `Code A ≤ A` a splice):

```haskell
power :: Int -> Code Int -> Code Int
power 0 _ = 1                          -- [| 1 |]
power n x = x * power (n - 1) x        -- [| ~x * ~(power (n - 1) x) |]

cube :: Int -> Int
cube x = power 3 x                     -- ~(power 3 [| x |])
```

The rules, in `stageCoercion`:

* At the meta level, an expression checked against `Code t` (or `Low t`) that
  cannot have that type itself is quoted.  That is a literal, an object level
  variable, or an application whose head cannot return code: its result type
  is a type constructor other than `Code`/`Low`, or a type variable
  constrained by a class with no instance a code type can match, as for
  `x * y` (with an `instance Num (Code Int)` it is meta code, and is left
  alone).  A lambda checked against `Code t` is quoted too, so
  `f :: Low (Int -> Int); f = \ n -> n + 1` is `[| \ n -> n + 1 |]`.
* At the object level, a meta level variable, or an application with one at the
  head, whose result is `Code t` (or `Low t`) is spliced.
* Code is not a function, so a meta level variable `c :: Code t` applied to
  arguments has its head spliced: at the object level `c x y` is `~c x y`, at
  the meta level it is `[| ~c x y |]`.
* `f $ x` is treated as `f x`.
* A definition whose stage is not known yet (no `Code` in its signature) is
  fixed to the object level when its body is a meta level application with a
  code result, checked against a type that is not code, as for `cube`, or an
  applied meta level code variable checked against such a type, as for
  `run t = eval [] t` with `eval :: Low ([Val] -> Term -> Val)`.

A coercion is only inserted where checking the expression as written would
fail, so it never changes the meaning of a program that type checks without
it.  When the meta level reading is possible, it is used: in
`maybe [| 0 |] f m :: Code Int` the `maybe` runs at compile time.  Write the
quotations and splices to get the other reading.  `tests/StagedInfer.hs` has
the examples of `Staged1` and `Low1` without annotations, `tests/LowInfer.hs`
those of `Low2`, and `-ddump-stage` shows the result.

Not inferred yet: a `case` on code (`case y of 0 -> ...` with `y :: Code Int`,
which should become an object level `case`), and the coercion between
`Code (a -> b)` and `Code a -> Code b` (eta expansion) that the demo has.

### Library

`lib/Staged.hs` provides `Code`, the serialization functions `codeInt`, `codeWord`,
`codeChar`, `codeDouble`, `codeFloat`, `codeString`, `codeBool`, `codeInteger`,
`codeList` (the code for a list, from the code of its elements), and the code
generation monad `Gen` with `runGen`, `gen` (let insertion) and `genLet`.

## Closure-free code: `Low`

Besides `Code`, there is a second kind of object code, `Low`, in the style of

* *Closure-Free Functional Programming in a Two-Level Type Theory*, ICFP 2024

The paper's object language has two sorts of types: *value types* (first order
data) and *computation types* (functions from values).  Functions are never
values: they cannot be passed as arguments, stored in data, or returned
partially applied, so the generated code needs no closures at run time, and
it can be compiled like C.  All the higher order programming (streams, monads,
code generators) happens at the meta level, and disappears during staging.

```haskell
import Staged.Low

Low a       -- the meta level type of closure free object code of type a
```

Quotations and splices are shared with `Code`: which kind of code a quotation
is, is determined by its type.  `[| e |] :: Low t` is a Low quotation, and
inside it only `Low` code can be spliced.  A `Low t` can be spliced wherever
a `Code t` can (object code, or a Code quotation): low code is a subset of
ordinary code.  (A quotation whose type is not determined by its uses is a
`Code` quotation; give signatures to generators.)

```haskell
power :: Int -> Low Int -> Low Int
power 0 _ = [| 1 |]
power n x = [| ~x * ~(power (n - 1) x) |]

sumSq :: Low Int -> Low Int                   -- a loop: a recursive low function
sumSq n = runGen $ do
  go <- genRec $ \ go -> [| \ i acc -> if i > ~n then acc else ~go (i + 1) (acc + i * i) |]
  return [| ~go 1 0 |]

sumSquares :: Int -> Int                      -- ordinary code; the low code is spliced in
sumSquares n = ~(sumSq [| n |])
```

Low code is a subset of Haskell, checked by the type checker:

* *Value types* are `Int`, `Word`, `Int64`, `Word64`, `Double`, `Float`,
  `Char`, type variables, and data types (including tuples, lists, `Maybe`,
  `Bool`, user data types and newtypes) whose fields are value types; no
  existentials, no functions in data.
* Lambda bound variables, and the scrutinees of `case`, have value types.
  Any other variable, and the quoted type, has a *low type*: a value type or
  a first order function type `V1 -> ... -> Vn -> V` (a computation type).
  Local functions (`let`, `where`, recursive or not) are fine; a function is
  called with all its arguments (partial applications are eta expanded).
* No overloading: a class constraint in low code must be solved by a known
  instance whose method is a primitive, e.g. `+`, `*`, `==`, `<`, `quot` on
  `Int`, `/` on `Double`.  Other global functions are not available in low
  code, only constructors, primitives, foreign imported C functions, and
  local definitions.  (The meta level has all of Haskell.)
* Low code is *strict*: `let` bound values, function arguments, and
  constructor fields are evaluated.  Functions are call by name, as in the
  paper, which is harmless since they are only ever called.
* A type variable in low code is a value type.  A generator that is
  polymorphic in such a type needs a `LowRep a` constraint (the paper's
  `{A : ValTy}`); the compiler solves `LowRep` for every concrete type.

```haskell
twice :: LowRep a => Low (a -> a) -> Low a -> Low a
twice f x = genLet x $ \ y -> [| ~f (~f ~y) |]
```

### Reflection

Low code is first order data, so it can be inspected: `reflect` turns a
`Low a` into a `LowProg`, a syntax tree where every binder has its type,
all calls are saturated, and functions only occur as the right hand sides of
lets (or as the whole program).  User written code generators can produce
C, JavaScript, Verilog, ... from it; `Staged.Low.C` and `Staged.Low.JS` are
small examples.  The generated text is ordinary compile time data:

```haskell
sumSqC :: String
sumSqC = ~(lowString (toC "sumsq" (reflect [| \ n -> ~(sumSq [| n |]) |])))
```

```haskell
data LowTy   = TInt | TWord | ... | TFun [LowTy] LowTy | TData String [LowTy] LowDecl | ...
data LowTerm = LVar String LowTy | LLit LowLit LowTy | LPrim String LowTy | LForeign String String LowTy
             | LApp LowTerm [LowTerm] | LLam [(String, LowTy)] LowTerm
             | LLet String LowTy LowTerm LowTerm | LLetRec [(String, LowTy, LowTerm)] LowTerm
             | LCase LowTerm [LowCon] [(LowCon, [(String, LowTy)], LowTerm)] (Maybe LowTerm)
             | LCon LowCon LowTy [LowTerm] | LFail String
data LowProg = LowProg { progType :: LowTy, progFree :: [(String, LowTy)], progDecls :: [LowDecl], progBody :: LowTerm }
```

Reflection breaks the paper's generativity (a meta program could look inside
code), so only use it at the end of a generator.

### Library

`lib/Staged/Low.hs` provides `Low`, `LowRep`, the types above, `reflect`,
`typeOf`, `lowPretty`, the code generation monad `Gen` with `runGen`, `gen`,
`genRec` (a recursive definition) and `genLet`, and `lowInt`, `lowDouble`,
`lowChar`, `lowString`, `lowBool`, ... for compile time values.

### Examples

`tests/Low1.hs` (basics), `tests/Low2.hs` (reflection, C and JavaScript
output) and `tests/Low3.hs` (the paper's pull streams with an existential
state type, fused into a single loop also for `zipWith`; the `MaybeT`
binding time improvement of section 3.3; a foreign C function).
`tests/LowLambda.hs` is a call by need (lazy) interpreter for the untyped
lambda calculus as low code, without quotations or splices.  Closures and
thunks are data (an environment and a term), and the heap of thunks is
threaded through the interpreter (store passing, as in Launchbury's natural
semantics), so the interpreter compiles to first order C.
`tests/LowFutamura.hs` is the first Futamura projection: the same interpreter
with the term at the meta level (`peval :: Term -> [SVal] -> SVal`), so
applying it to a program runs the interpreter in the compiler and leaves low
code for the program alone.  Factorial compiles to a single recursive C
function, a non-recursive program to straight line code, and a program whose
input is known (`factorial 10`) to a constant.  Object level closures are
compile time functions and call by need comes from the lazy meta level;
recursion on a run time value needs the `Fix` term, which becomes a `genRec`
loop (unfolding the Y combinator on a run time value would not terminate).
`tests/lowerr.test` shows the error messages.

### Not done, and recommendations

* Low code spliced into a program still runs as combinators.  The next step
  is a backend in the compiler that compiles a Low splice to C (e.g. with
  `Staged.Low.C`), links it, and calls it through the FFI.
* The paper's join points (finite products of computations) are not
  supported; `filterP` above duplicates its continuation.  `genJoin`
  (let insertion of a function) would be the next library function.
* Generic sums of products (section 3.5 and the generic `concatMap`) need
  type level computation that MicroHs does not have; write them per type.
* Reflection gives an untyped (but type annotated) tree.  A typed
  representation (`LowTerm a` as a GADT) would make backends safer.
* An n-level generalization (`Code (Low a)`, or more levels) needs the stage
  signature of the quotation types to be indexed by levels; reflection is not
  needed for it, but makes the top level an ordinary meta program.

## Implementation

### Type checker (`src/MicroHs/TypeCheck.hs`)

Stages are tracked by a small unification problem on *levels*
(`Level` in `Expr.hs`: `LMeta`, `LObj`, level variables, and `LPoly` in tables),
kept separately from types.  The design follows the observation that in 2LTT
the stage of a term is a function of its type, and all subterms of a term have
the same stage except under quote/splice, so a single level per term suffices.

* `curLevel` in the type checker state is the stage of the expression being
  checked.  A quotation requires `LMeta` and checks its body at `LObj`; a splice
  requires `LObj` and checks its body at `LMeta`.
* Every local variable records the level at which it was bound
  (`localLevels`); every top level definition has a level in `levelTable`
  (exported through `GlobTables.gLevels`).  Using a variable unifies its level
  with the current level.  A definition whose level is unconstrained after
  checking is generalized to `LPoly` and can be used at any stage.
  Definitions are checked in dependency order (`tcDefsSCC`) so that this is
  known before use.
* Type constructors and classes have *stage signatures* (`typeLevels`,
  `gTypeLevels`): the stage of `T a1 .. an` and the stages of the arguments.
  `Code :: (meta, [object])`, user data types are inferred from their
  constructor fields (`addTypeLevels`) and are polymorphic when unconstrained.
  Foreign imports are stage polymorphic, except `foreign import javascript`,
  which is object level (JavaScript is not there in the compiler).  Written types (signatures, annotations,
  instance heads) are checked against the current level with `tcTypeLevel`.
* `let`, `case` and `if` get `EStaged from to e` markers; after a definition
  is checked, `zonkStage` turns them into `EQuote`/`ESplice` or removes them.
* Dictionaries: the level at which a constraint arises is recorded; a
  constraint solved by a dictionary argument must be at the argument's level,
  and uses of stage restricted instances are checked at the end of the module.

### Staging (`src/MicroHs/Stage.hs`)

After desugaring, quotations and splices are the pseudo primitives `$quote`
and `$splice`.  Staging follows section 4 of the ICFP 2022 paper, which has
two evaluators.  The meta level evaluator is the runtime system; only the
object level one is in the compiler.

* Meta level code is compiled to combinators and loaded into the running
  runtime system with `MicroHs.Translate`, like the interactive system does.
  A quotation is compiled (`quoteExp`) to code that builds a value of the type
  `Code` in `Stage.hs`: applications, global variables, literals, and binders
  as functions (HOAS).  There is no library definition of that type; the
  constructor functions are generated (`codeConstrs`) with the data type
  encoding the compiler itself uses, so the compiler can use the value that
  the runtime computes directly.  `Staged.codeInt` etc. are these constructors.
* The meta level definitions of a module are kept, as combinators, in
  `tMetaDefs`, for the splices of the modules that import it.
* The splices of a module are taken out of its object level definitions
  (`prepExp`): splice number n becomes a meta level function of the object
  level variables it uses, and all of them are loaded together, with the
  imported modules and the splice free definitions of the module itself.
  An object level variable that is `let` bound to an expression that does not
  depend on the object level can also be used inside the splice at the meta
  level; this is what the dictionary bindings of the type checker need.
* `eval0` traverses the object level code, with the binders as HOAS closures.
  At a splice it applies the splice function to the code of its variables.
  The result is read back (`quote0`) with de Bruijn levels, so that generated
  code never captures variables.

Meta level definitions are removed from the generated program.  An exception
in compile time code (`error`, division by zero, ...) is reported as an error
at the definition with the splice.  Since the splices are loaded with all the
code they can reach, the real modules of the `.hs-boot` modules are compiled
before the first module with a splice is staged.

Compile time code runs on the machine of the compiler, so with a cross
compiling target (e.g., emscripten) `Int` has the size of the host, and a
foreign function that is not in the runtime system of the compiler (one from
the user's own C code) cannot be called at compile time.

### Low code

`Low` is a second kind of quotation, not a second stage: a Low quotation is
checked at the object level like a Code quotation.  The kind of a quotation
is a unification variable (kind `Type -> Type`) that its uses unify with
`Code` or `Low`; quotation kinds are never generalized, and an undetermined
kind is `Code` at the end of the definition (`lowFinalizeEqns`).  Inside a
quotation that may be Low the type checker records the checks of the rules
above (`ssLowChecks`), done when the kind is known, and marks the leaves,
lambdas and lets with their types (`$lowty`, `$lowlam`, `$lowlet`); the
marks become expressions that compute the run time representation of the
types (the `lowTyP` method of a `LowRep` dictionary) if the quotation is Low,
and are removed if it is Code.  `LowRep t` is solved by a built in solver
(`solveLowRep`) that builds a `LowTy` from the data table, with goals for the
type arguments; only type variables need a dictionary argument.

The desugarer (`Desugar.hs`) keeps the structure of a Low quotation: cases,
constructors, lets and recursive lets become pseudo primitives (`$lowcase`,
`$lowcon`, `$lowletrec`, ...), join points of the pattern match compiler
become functions, and let bound expressions are not inlined.  `Stage.hs`
compiles a Low quotation to meta level code that builds the HOAS
representation `Staged.Low.Internal.LowExp`, resolving class methods to
primitives through the instance dictionaries.  A `Low` value spliced into
object code is read back (`lowToExp`) as ordinary code with strict
semantics.  `Staged.Low.reflect` reads the HOAS representation back as a
first order tree, computes the types of the let bound variables and case
alternatives, and saturates the calls (section 2.2 of the paper).

### Files touched

`Expr.hs` (`EQuote`, `ESplice`, `EStaged`, `Level`), `Parse.hs`,
`TCMonad.hs`, `TypeCheck.hs`, `Desugar.hs`, `Stage.hs` (new), `Compile.hs`,
`Flags.hs` (`-ddump-stage`), `lib/Primitives.hs` (`Code`), `lib/Staged.hs` (new),
`tests/Staged*.hs`, `tests/stagederr.test`, `tests/istaged.in`.
Low: `Names.hs`, `TCMonad.hs`, `TypeCheck.hs`, `Desugar.hs`, `Stage.hs`,
`lib/Primitives.hs` (`Low`), `lib/Staged/Low.hs`, `lib/Staged/Low/Internal.hs`,
`lib/Staged/Low/C.hs`, `lib/Staged/Low/JS.hs`, `tests/Low*.hs`, `tests/lowerr.test`.
