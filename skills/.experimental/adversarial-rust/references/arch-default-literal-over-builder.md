---
title: Struct literal with Default over a builder for every struct
tags: arch, builder, default, struct-literal
---

## Struct literal with Default over a builder for every struct

The Java builder habit — a `Builder` class per type because constructors can't name arguments — ports into Rust as reflexive `XBuilder` structs with chained setters and a fallible `build()`. Rust already has named construction: the struct literal, with `..Default::default()` filling the rest. codex-rs uses the literal form 1,787 times against 16 builder structs total (about seven of those test-only harnesses), because the literal is checked at compile time — a forgotten required field is a compile error, while a forgotten builder setter is a runtime `build()` error or a silent default.

```rust
#[derive(Default)]
struct FileSearchOptions {
    limit: usize,
    threads: usize,
    compute_indices: bool,
    exclude_hidden: bool,
}

// How codex-rs constructs options structs at call sites:
let options = FileSearchOptions {
    limit: 100,
    threads: 4,
    compute_indices: true,
    ..Default::default()
};
```

**When a builder IS right:** construction is genuinely staged — many optional inputs combined with work a literal can't express. codex-rs's one substantial production builder, `ConfigBuilder`, exists because config assembly layers CLI overrides, harness overrides, and async loading from disk; even there the builder's fields are plain `Option<T>` setters, not hidden invariants. If your type constructs in one expression from values you already have, the builder is ceremony.

Reference: [codex-rs core/src/config/mod.rs](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/core/src/config/mod.rs#L1231), [codex-rs app-server/src/fuzzy_file_search.rs](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/app-server/src/fuzzy_file_search.rs#L41)
