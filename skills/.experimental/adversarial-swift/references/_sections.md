# Sections

This file defines the categories and their order. The prefix in parentheses is
the filename prefix that groups rules. Order categories by **importance** — the
decisions that come up most often and cost most when wrong go first.

---

## 1. Concurrency & Task Structure (conc)

**Description:** Swift concurrency structure a reviewer can verify path-by-path — continuations with a reachable branch that never resumes (a permanently hung task), cancellable loops that never consult `Task.isCancelled` (with `try? await Task.sleep` swallowing the one built-in cancellation signal), independent awaits run serially instead of via `async let`, runtime-sized fan-out through per-element unstructured `Task {}` spawning with shared-state merges instead of `withTaskGroup`, and CPU-bound async work left implicitly on the main actor under MainActor default isolation. The costliest category because the failures are hangs, leaks, races, and dropped frames with no crash pointing at the cause.

## 2. Property & Resource Invariants (prop)

**Description:** State whose correctness the type itself must enforce — derived values stored as separate properties and re-synchronized by hand at each write site (they drift the first time a site forgets), internally-mutated `var`s left publicly writable so external assignments bypass the preconditions the mutating methods enforce, `init` assignments that rely on `willSet`/`didSet` observers which deliberately do not fire during initialization, and `~Copyable` consuming cleanup that runs a second time in `deinit` for lack of `discard self`. Silent state corruption and double-release — no diagnostic anywhere.

## 3. Error Handling & Diagnostics (err)

**Description:** Error and diagnostic surfaces that destroy information a reviewer can see being discarded — `catch` blocks that wrap the caught error into a payload-free domain case (the URLError code or decoding path is gone forever), `throws` on functions whose only throw source is their closure parameter (`rethrows` territory), hand-rolled `switch` unpacking of `Result` where `try result.get()` is the standard form, diagnostics helpers whose `#file`/`#line` literals expand in the helper body instead of as caller-substituted default arguments, and TODO comments marking shipped-incomplete code that `#warning` would surface in every build.

## 4. Enum Evolution & Exhaustiveness (enum)

**Description:** Hand-maintained surfaces that silently rot when an enum evolves — a bare `default:` over another module's non-frozen enum (future cases are swallowed with no diagnostic where `@unknown default` would warn), hand-written all-cases arrays instead of `CaseIterable`'s synthesized `allCases`, hand-rolled `static func <` ladders that desynchronize from declaration order instead of synthesized `Comparable`, and instantiable `struct`s posing as namespaces where a caseless `enum` makes the no-instances intent compiler-enforced.

## 5. API & Type Surface (api)

**Description:** Type and signature decisions that give away compile-time enforcement — convenience `init`s declared in the struct body (silently suppressing the memberwise initializer), rows of three-plus `Bool` parameters where `OptionSet` composes, fully spelled nested generic return types or `any P` where `some P` hides the composition with static dispatch, `fatalError` stubs not marked `@available(*, unavailable)` (a runtime crash where a compile error is available), trap-only functions without `-> Never`, eagerly evaluated parameters used only inside a gated branch (`@autoclosure` territory), and internal non-final classes nothing subclasses (every call dynamically dispatched for no benefit).

## 6. Collections & Dictionaries (coll)

**Description:** Local patterns with a strictly better standard-library form and a measurable cost — hand-rolled dictionary upserts (`dict[k] = (dict[k] ?? 0) + 1` does two hash lookups where `subscript(_:default:)` does one), copy-out/write-back mutation dances that force a CoW copy where optional chaining mutates in place, whole-dictionary rebuilds via `Dictionary(uniqueKeysWithValues:)` (which traps on duplicate keys) for value-only transforms that `mapValues()` does in place, copying `reduce(_:_:)` accumulation that turns linear work into O(n²) where `reduce(into:)` mutates one accumulator, and `.filter{}.count` allocating a throwaway array that `count(where:)` never builds.

## 7. Control Flow, Strings & Conditional Compilation (flow)

**Description:** Statement-level shapes that trade away a compiler check or corrupt data silently — placeholder-initialized `var`s where an uninitialized branch-assigned `let` gets definite-initialization exhaustiveness checking, `enumerated()` offsets used as subscripts (off-by-N corruption or a crash on any slice), escape-heavy string literals where raw strings make the content visually verifiable, `String(decoding:)` silently repairing untrusted bytes that `String(validating:)` would reject at the boundary, `#if os(...)` chains hand-tracking framework presence that `canImport` tracks automatically, and read-then-nil optional teardown where `Optional.take()` makes single-use consumption explicit.
