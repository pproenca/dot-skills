# Sections

This file defines the categories and their order. The prefix in parentheses is
the filename prefix that groups rules. Categories are ordered by **importance** —
the architectural mistakes with the widest blast radius go first; the verdict
report's fix list follows this order.

This is a pass/fail review gate, not a performance skill, so there are no impact
tiers. Each rule names an alien mental model — imported from OO/enterprise or
imperative ecosystems — and carries an **Evidence of violation** paragraph: the
artifact evidence that decides PASS/FAIL/N/A, with carve-outs that must be
claimed with citable evidence (fail closed otherwise).

---

## 1. Enterprise Ceremony & Layering (arch)

**Description:** Whole layers ported from OO/enterprise codebases that have no reason to exist on the BEAM. Repository/DAO wrappers over Ecto, stateless "service"/"manager" object modules, dependency-injection behaviours defined for a single implementation, and DTO/mapper tiers. The refactor is flattening: Ecto is already the data-mapper, Phoenix contexts are already the service boundary, and immutable data needs no mapper — so the indirection is pure overhead. Delete the layer.

## 2. Processes as Objects (proc)

**Description:** The signature paradigm betrayal: treating a process as an object or a variable instead of as a unit of concurrency and failure isolation. One GenServer per entity, an Agent used as a mutable field, a global singleton "Manager" everything calls through, or a per-process interface scattered across the codebase. The refactor moves state to the database/ETS and behavior to pure functions, keeping processes only where you genuinely need concurrency, isolation, or a long-lived resource owner.

## 3. Anemic Data Modeling (type)

**Description:** Data modeled as if the type system and pattern matching did not exist. Free-form maps passed as domain objects, several boolean flags encoding one state, string values used for dispatch, and 30-field god-structs. This defeats the language's core mechanism — matching on the shape of well-typed data — and pushes validation to every call site. The refactor introduces structs, tagged unions/atoms, protocols, and struct decomposition.

## 4. Defensive Control Flow (flow)

**Description:** Control flow that fights let-it-crash and hides the contract. `try/rescue` and `raise` used for expected outcomes, nil-guard pyramids, non-assertive `Map.get`/truthiness checks, and catch-all `with ... else` clauses that erase which step failed. The refactor asserts the happy path with pattern matching (letting genuinely broken input crash), returns tagged tuples for expected failures, and keeps error terms intact.

## 5. Imperative Iteration (iter)

**Description:** For-loops transliterated into Elixir. `Enum.reduce` re-implementing a named `Enum` function, hand-rolled recursion where the standard library already has the traversal, and index-based access into lists. The refactor expresses the transformation declaratively with the right `Enum`/`Stream` function, which states intent and inherits the stdlib's guarantees.

## 6. Needless Metaprogramming & Coupling (meta)

**Description:** Reaching for macros and `use` where plain functions and data would do. Macro DSLs for what a function plus a data structure expresses, `use SomeModule` to obtain functions that should be `import`ed, and compile-time dependencies that force whole-app recompiles. Macros run at compile time and couple modules; the refactor replaces them with functions, protocols/behaviours only at real polymorphism, and runtime configuration.
