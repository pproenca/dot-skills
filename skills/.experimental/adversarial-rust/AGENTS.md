# Rust

**Version 0.2.0**  
dot-skills  
July 2026

---

## Abstract

Adversarial, architecture-level review and refactoring of Rust code that imported an alien mental model (OO/enterprise ceremony, GC object graphs, exception-style control flow, imperative iteration, borrowed concurrency habits) — names the paradigm the code betrays and prescribes the deep, ceremony-flattening refactor back to idiomatic Rust. The diagnostic counterpart to the greenfield openai-codex-rust-patterns skill. All examples compile-tested on Rust 1.86.

---

## Table of Contents

1. [Enterprise Ceremony & Fake OO](references/_sections.md#1-enterprise-ceremony-&-fake-oo)
   - 1.1 [Avoid simulating inheritance with Deref — delegate or use a trait](references/arch-no-deref-inheritance.md)
   - 1.2 [Collapse stateless Manager/Service structs into module functions](references/arch-free-functions-over-manager-struct.md)
   - 1.3 [Delete the dependency-injection trait with one implementation](references/arch-drop-di-trait-single-impl.md)
   - 1.4 [Expose plain data as public fields, not getter/setter pairs](references/arch-public-fields-over-getter-ceremony.md)
2. [Ownership Fought, Not Used](references/_sections.md#2-ownership-fought,-not-used)
   - 2.1 [Avoid rebuilding a GC object graph with Rc<RefCell<T>>](references/own-no-rc-refcell-object-graph.md)
   - 2.2 [Model graphs with an owning map and ID handles, not references](references/own-id-map-over-self-referential.md)
   - 2.3 [Redesign ownership instead of cloning to satisfy the borrow checker](references/own-restructure-over-clone.md)
3. [Anemic & Stringly Data](references/_sections.md#3-anemic-&-stringly-data)
   - 3.1 [Collapse parallel Option fields into the enum they encode](references/type-result-over-parallel-options.md)
   - 3.2 [Parse into validated newtypes at the boundary — don't re-validate Strings](references/type-newtype-parse-dont-validate.md)
   - 3.3 [Replace boolean and string state flags with one enum](references/type-enum-over-bool-string-state.md)
   - 3.4 [Split the god-struct of Options by lifecycle stage](references/type-split-option-god-struct.md)
4. [Exception-Style Control Flow](references/_sections.md#4-exception-style-control-flow)
   - 4.1 [Avoid catch_unwind as try/catch](references/flow-no-catch-unwind-try-catch.md)
   - 4.2 [Give libraries structured error enums — anyhow stays at the application edge](references/flow-thiserror-library-anyhow-application.md)
   - 4.3 [Return Option or Result instead of sentinel values](references/flow-option-over-sentinel-values.md)
   - 4.4 [Return Result for expected failures — unwrap only where Err proves a bug](references/flow-result-over-unwrap-expected.md)
5. [Dynamic Dispatch by Habit](references/_sections.md#5-dynamic-dispatch-by-habit)
   - 5.1 [Take impl Trait parameters instead of boxing by habit](references/dyn-generics-over-boxed-callbacks.md)
   - 5.2 [Use an enum, not Box<dyn Trait>, for a closed set of variants](references/dyn-enum-over-box-dyn-closed-set.md)
6. [Imperative Iteration](references/_sections.md#6-imperative-iteration)
   - 6.1 [Replace index loops and mut accumulators with iterator chains](references/iter-combinator-over-index-loop.md)
   - 6.2 [Stay lazy — collect once at the end of the chain](references/iter-stay-lazy-single-collect.md)
7. [Concurrency From Another Runtime](references/_sections.md#7-concurrency-from-another-runtime)
   - 7.1 [Avoid holding a std MutexGuard across an .await](references/conc-narrow-locks-before-await.md)
   - 7.2 [Move blocking work out of async fns — spawn_blocking or async primitives](references/conc-spawn-blocking-over-blocking-async.md)
   - 7.3 [Offload CPU-bound work to the blocking pool, not a fleet of async tasks](references/conc-blocking-pool-over-async-cpu-fanout.md)

---

## References

1. [https://rust-unofficial.github.io/patterns/anti_patterns/deref.html](https://rust-unofficial.github.io/patterns/anti_patterns/deref.html)
2. [https://rust-unofficial.github.io/patterns/anti_patterns/borrow_clone.html](https://rust-unofficial.github.io/patterns/anti_patterns/borrow_clone.html)
3. [https://doc.rust-lang.org/book/ch09-03-to-panic-or-not-to-panic.html](https://doc.rust-lang.org/book/ch09-03-to-panic-or-not-to-panic.html)
4. [https://doc.rust-lang.org/book/ch15-06-reference-cycles.html](https://doc.rust-lang.org/book/ch15-06-reference-cycles.html)
5. [https://doc.rust-lang.org/book/ch18-02-trait-objects.html](https://doc.rust-lang.org/book/ch18-02-trait-objects.html)
6. [https://doc.rust-lang.org/book/ch13-04-performance.html](https://doc.rust-lang.org/book/ch13-04-performance.html)
7. [https://rust-lang.github.io/api-guidelines/naming.html](https://rust-lang.github.io/api-guidelines/naming.html)
8. [https://rust-lang.github.io/api-guidelines/type-safety.html](https://rust-lang.github.io/api-guidelines/type-safety.html)
9. [https://doc.rust-lang.org/std/panic/fn.catch_unwind.html](https://doc.rust-lang.org/std/panic/fn.catch_unwind.html)
10. [https://doc.rust-lang.org/std/iter/index.html](https://doc.rust-lang.org/std/iter/index.html)
11. [https://lexi-lambda.github.io/blog/2019/11/05/parse-don-t-validate/](https://lexi-lambda.github.io/blog/2019/11/05/parse-don-t-validate/)
12. [https://corrode.dev/blog/illegal-state/](https://corrode.dev/blog/illegal-state/)
13. [https://cliffle.com/blog/rust-typestate/](https://cliffle.com/blog/rust-typestate/)
14. [https://github.com/nrc/r4cppp/blob/master/graphs/README.md](https://github.com/nrc/r4cppp/blob/master/graphs/README.md)
15. [https://ryhl.io/blog/async-what-is-blocking/](https://ryhl.io/blog/async-what-is-blocking/)
16. [https://tokio.rs/tokio/tutorial/shared-state](https://tokio.rs/tokio/tutorial/shared-state)
17. [https://docs.rs/anyhow/latest/anyhow/](https://docs.rs/anyhow/latest/anyhow/)
18. [https://docs.rs/rayon/latest/rayon/](https://docs.rs/rayon/latest/rayon/)
19. [https://docs.rs/tokio/latest/tokio/task/fn.spawn_blocking.html](https://docs.rs/tokio/latest/tokio/task/fn.spawn_blocking.html)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |