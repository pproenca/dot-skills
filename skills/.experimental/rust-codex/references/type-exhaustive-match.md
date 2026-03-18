---
title: Use Exhaustive Match Without Wildcards
impact: CRITICAL
impactDescription: catches 100% of unhandled enum variants at compile time
tags: type, match, exhaustive, enums
---

## Use Exhaustive Match Without Wildcards

When matching on enums, list every variant explicitly instead of using a wildcard `_` arm. When a new variant is added to the enum, the compiler flags every match site that needs updating. Wildcards silently swallow new variants and lead to incorrect behavior.

**Incorrect (new variants silently fall through to false):**

```rust
impl Feature {
    pub fn is_stable(&self) -> bool {
        match self.stage() {
            Stage::Stable => true,
            _ => false,
        }
    }
}
```

**Correct (compiler error when Stage gains a new variant):**

```rust
impl Feature {
    pub fn is_stable(&self) -> bool {
        match self.stage() {
            Stage::Stable => true,
            Stage::UnderDevelopment
            | Stage::Experimental { .. }
            | Stage::Deprecated
            | Stage::Removed => false,
        }
    }
}
```
