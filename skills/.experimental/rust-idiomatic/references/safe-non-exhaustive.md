---
title: Use non_exhaustive on Public Enums
impact: HIGH
impactDescription: enables adding variants without breaking downstream crates
tags: safe, non-exhaustive, enum, api-evolution, semver
---

## Use non_exhaustive on Public Enums

Apply `#[non_exhaustive]` to public enums that will grow over time. Without it, adding a new variant is a semver-breaking change because downstream match statements become non-exhaustive.

**Incorrect (adding a variant breaks all downstream matches):**

```rust
pub enum UserInput {
    Text(String),
    Image { path: PathBuf },
}
// Adding Audio variant breaks every consumer's match
```

**Correct (non_exhaustive forces wildcard arms in downstream):**

```rust
#[non_exhaustive]
pub enum UserInput {
    Text(String),
    Image { path: PathBuf },
}
// Downstream must include _ => arm, so adding Audio is non-breaking
```

**When NOT to use this pattern:**

- Internal enums within a single crate where exhaustive matching is desired
- Enums where all variants are known at design time and will not change
