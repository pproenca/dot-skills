# Sections

This file defines the categories and their order. The prefix in parentheses is
the filename prefix that groups rules. Order categories by **importance** — the
architectural mistakes with the widest blast radius (and the biggest refactor
payoff) go first.

This is an adversarial review/refactor skill for correctness and architecture,
not a performance skill, so there are no impact tiers. Each rule names an alien
mental model — imported from OO/enterprise, garbage-collected, or
exception-based ecosystems — and the refactor that collapses it back to
idiomatic Rust, up to and including deleting a whole layer.

---

## 1. Enterprise Ceremony & Fake OO (arch)

**Description:** Whole structures ported from Java/C# codebases that have no reason to exist in Rust. Dependency-injection traits defined for a single implementation, `Deref` abuse to simulate inheritance, stateless `*Manager`/`*Service` structs wrapping what should be free functions, and getter/setter boilerplate on plain data. Rust's module system is already the namespace, ownership is already the lifecycle manager, and monomorphized generics are already the seam — so the ceremony is pure indirection. Delete the layer.

## 2. Ownership Fought, Not Used (own)

**Description:** Code that treats the borrow checker as an adversary instead of a design tool. `.clone()` sprinkled until it compiles, `Rc<RefCell<T>>`/`Arc<Mutex<T>>` reproducing a garbage-collected object graph, and doomed self-referential structs. Each is a signal that ownership was never designed — the data has no single owner, so the code buys shared mutability at runtime and loses the aliasing guarantees the language exists to give. The refactor redesigns who owns what: a tree of owned data with borrows flowing down, or a single owning collection with ID handles for genuine graphs.

## 3. Anemic & Stringly Data (type)

**Description:** Data modeled as if `enum` and `match` did not exist. Booleans and strings encoding a state machine, parallel `Option` fields that are really a `Result`, raw `String`/`u64` primitives carrying domain meaning, and god-structs where half the fields are `None` at any given time. This throws away exhaustive matching — the compiler's ability to prove every state is handled — and pushes validation to every call site. The refactor makes invalid states unrepresentable: enums with data, validated newtypes, and parse-don't-validate at the boundary.

## 4. Exception-Style Control Flow (flow)

**Description:** Error handling transliterated from exception-based languages. `.unwrap()`/`panic!` on expected failures, sentinel values (`-1`, empty string, `bool` success flags) instead of `Option`/`Result`, `catch_unwind` used as try/catch, and `anyhow`'s opaque errors leaking out of library APIs. Panics are for bugs, not for outcomes the caller must handle; sentinels erase the compiler's exhaustiveness checking. The refactor routes every expected failure through `Result` + `?` and gives libraries structured error enums callers can match on.

## 5. Dynamic Dispatch by Habit (dyn)

**Description:** `Box<dyn Trait>` reached for reflexively — the Java-interface habit of "program to an interface" — where the set of implementors is closed and known at compile time, or where a generic parameter would do. Trait objects erase the type, forcing vtable calls, blocking inlining, and giving up exhaustive matching over the variants. The refactor uses an enum for a closed set and generics (`impl Trait`) for open-but-static polymorphism, reserving `dyn` for genuinely heterogeneous collections and runtime-loaded behavior.

## 6. Imperative Iteration (iter)

**Description:** Loops transliterated from C or Python. Index-based `for i in 0..v.len()` access, `let mut acc` + push loops re-implementing named combinators, and `.collect()` called between every step of what should be one lazy chain. Iterator chains state intent, skip bounds checks, and compile to the same or better code. The refactor names the transformation with the right combinator and stays lazy until one final `collect`.

## 7. Concurrency From Another Runtime (conc)

**Description:** Concurrency habits imported from Go, JavaScript, or thread-per-request servers. Blocking calls (`std::thread::sleep`, synchronous I/O, heavy CPU work) inside `async fn`, a `std::sync::MutexGuard` held across an `.await`, and async task fan-out used for CPU-bound parallelism. An async runtime multiplexes many tasks onto few threads — one blocked task stalls every task on that worker. The refactor moves blocking and CPU-bound work to `spawn_blocking` and narrows lock scopes to synchronous sections.
