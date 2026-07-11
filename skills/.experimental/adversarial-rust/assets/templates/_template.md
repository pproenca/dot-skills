---
title: {Decision-oriented title — "Delete X", "Replace X with Y", "Don't X — Y instead"}
tags: {prefix}, {concept}, {concept}
# This is an architecture/correctness skill — omit impact tiers.
---

## {title}

{WHY — 1-3 sentences. Name the alien pattern (the OO/GC/exception/imperative
habit the code imported) and the concrete cost in Rust — what the compiler can
no longer check, what leaks or panics at runtime, what ceremony every caller
pays. State the refactor: what collapses, what layer gets deleted. The model
generalizes from the reason, so lead with why Rust rejects this, not with a
bare rule.}

```rust
{The canonical, idiomatic Rust the smell refactors to. Production-realistic
domain names — never foo/bar. Must compile (stub externals if needed).
Usually the only example needed.}
```

Reference: [{source title}]({url})

<!-- Add an Incorrect/Correct foil ONLY when the wrong way is a real, common trap
     (never a strawman). Label both blocks — "**Incorrect (...):**" and
     "**Correct (...):**" — and keep the diff minimal so the contrast is the lesson.
     Optional: **When a trait/dyn/clone/collect IS right:** for the real exceptions.
     Compile-test both blocks; an Incorrect example that fails to compile is only
     acceptable when the compile error IS the point, stated in prose. -->
