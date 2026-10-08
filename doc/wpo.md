# Whole program optimization: `mhs -wpo`

`mhs -wpo` compiles a whole program to C with a *staged call by need
interpreter*, instead of to combinators for the runtime system's graph
reducer.  The C has no combinators (unless the program itself evaluates code
at run time, like `mhs`), and it uses the primitives of the runtime system
(`src/runtime/eval.c`).  It is the first Futamura projection: the interpreter
runs on the program at compile time, and what is left is the program.

This is work in progress; see the status at the end.

## Pipeline

```
mhs -wpo M.hs -oM.c
  compile all modules as usual (or take them from the cache and packages)
  allDefs :: [LDef]                       -- the whole program, as combinator code
  MicroHs.Staged.Decode                    -- definitions decoded on demand into lambda calculus
  MicroHs.Staged.Eval                      -- the staged interpreter, from main
  MicroHs.Staged.C                         -- C code, using the runtime system's primitives
```

`MicroHs.Staged.Compile.compileWPO` is called from `mainCompile`
(`MicroHs.Main`) in place of the combinator array.

## Decoding (`MicroHs.Staged.Decode`)

The definitions of every module, including those in packages, are
`[(Ident, Exp)]` in combinator form: `Exp` without lambdas, with the
combinators as primitives (`Lit (LPrim "S")`).  Packages store exactly this
(`pkgExported :: [TModule [LDef]]`, after `compileOpt`), so nothing new needs
to be stored: a definition is looked up by name when the interpreter first
needs it, and its combinators are replaced by their lambda expressions, with
the rules of the runtime system:

```
S x y z = x z (y z)        S' x y z w = x (y w) (z w)    B x y z = x (y z)
B' x y z w = x y (z w)     C x y z = x z y               C' x y z w = x (y w) z
C'B x y z w = x z (y w)    K x y = x    A x y = y         U x y = y x
I x = x                    Z x y z = x y                 J x y z = z x
L x y z = y x              KK x y z = y                  KA x y z = z
P x y z = z x y            R x y z = y z x               O x y z w = w x y
K2 x y z = x               K3 x y z w = x                K4 x y z w v = x
Tk x1 ... xk f = f x1 ... xk            TAGk x y = y k x
```

Arguments are shared variables (as the runtime system shares graph nodes), so
call by need is kept.  `Y` and the other primitives (arithmetic, `IO.>>=`,
foreign calls, ...) stay primitives, implemented by the interpreter.
`-ddump-wpo` prints the decoded definitions reachable from `main`, and the
primitives they use.

`main = print (fib 25)` reaches 408 definitions: `Show`, `putStrLn` through
the `System.IO` handles (a `BFILE` from the runtime system), UTF-8 encoding,
and the exception machinery.

## The interpreter (`MicroHs.Staged.Eval`)

The design of `tests/LowFutamura.hs` and `tests/LowFutamuraLazy.hs`, for
untyped lambda calculus with primitives:

* Closures and thunks are compile time values (a label and an environment
  trimmed to its free variables); only data that must exist at run time is
  run time data.
* Call by need is resolved at compile time where it can be (a thunk is
  evaluated where a path first needs it), and with heap cells (thunk code
  and captures, updated with the value) where it cannot.
* Recursion through run time values becomes recursive C functions, found by
  an analysis mode of the same interpreter, run to a fixed point.
* Data: Scott encoded constructors (up to 6 constructors) and tagged ones are
  recognized by name (constructors are named definitions); a constructor
  application that must exist at run time is a node, and a case on a run time
  node (the scrutinee applied to one continuation per constructor) is a
  switch.  All data types share one node layout (a tag and fields), so
  constructor code is per arity, not per type.
* IO: `IO.>>=` and `IO.return` sequence C code, foreign calls (`LForImp`)
  are C calls, and the IO primitives call the runtime system.

## The runtime system

The C uses the node heap, garbage collector, and primitives of `eval.c`, but
not its graph reducer `evali`, which is only needed by programs that
evaluate combinator code at run time (`mhs` itself, for splices and `-r`).
Most primitives are cases of `evali` today, so using them without `evali`
means moving them out of it; the C calls them directly.  Compiled code must
also tell the garbage collector about the nodes it holds.

## Status

* Done: the `-wpo` flag, `-ddump-wpo`, decoding.
* Next: the interpreter for the pure core, then IO and foreign calls
  (`main = print (fib 25)` with the same output as the combinator
  compilation), then lazy data (`print (fibs !! 40)`), then the rest of the
  primitives.
