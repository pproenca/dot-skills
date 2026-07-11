---
title: Delete the dependency-injection trait with one implementation
tags: arch, traits, dependency-injection, generics
---

## Delete the dependency-injection trait with one implementation

Ported from Java/C#, an `IUserService`-style trait defined so the "real" struct can be "injected" taxes the whole call graph: every caller grows a `<S: UserService>` parameter or pays a `Box<dyn UserService>` allocation, and the swappability it pretends to buy — a second implementation — never arrives. Traits exist to share behavior across *multiple* types; a single-impl trait shares nothing and exists only to be mocked, which Rust codebases do better with fakes at the real process boundary (a wiremock HTTP fake, a temp-dir filesystem) than with a hand-rolled mock of their own internals. Use the concrete type directly; introduce the trait on the day a second implementation actually exists.

**Incorrect (a trait whose only reason to exist is injection):**

```rust
trait UserStore {
    fn find(&self, id: u64) -> Option<User>;
}

struct PgUserStore { pool: PgPool }

impl UserStore for PgUserStore {
    fn find(&self, id: u64) -> Option<User> { /* ... */ }
}

// Every consumer now carries the type parameter for one impl.
struct SignupFlow<S: UserStore> { store: S }
```

**Correct (the concrete type is the seam):**

```rust
struct PgUserStore { pool: PgPool }

impl PgUserStore {
    fn find(&self, id: u64) -> Option<User> { /* ... */ }
}

struct SignupFlow { store: PgUserStore }
```

**When a trait IS right:** two or more real implementations exist today (Postgres and in-memory both shipped, not "someday"), or the trait crosses a crate boundary where downstream crates genuinely plug in their own types. For test seams without a trait, see `testing-wiremock-sse-fakes` and `testing-atomic-bool-test-opt-in` in the sibling `openai-codex-rust-patterns` skill.

Reference: [The Rust Book — Traits: Defining Shared Behavior](https://doc.rust-lang.org/book/ch10-02-traits.html)
