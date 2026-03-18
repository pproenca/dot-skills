---
title: Use Sealed Traits for Extension Prevention
impact: MEDIUM
impactDescription: prevents downstream crates from implementing internal traits
tags: api, sealed-trait, encapsulation, semver, private
---

## Use Sealed Traits for Extension Prevention

Use the sealed trait pattern to expose a trait's methods publicly while preventing external crates from implementing it. This preserves the ability to add new methods without breaking semver.

**Incorrect (any external crate can implement the trait):**

```rust
pub trait TaskRunner {
    fn kind(&self) -> TaskKind;
    fn run(&self, ctx: &Context) -> Result<()>;
    // Adding a new required method breaks all external impls
}
```

**Correct (sealed with a private supertrait):**

```rust
mod private {
    pub trait Sealed {}
}

pub trait TaskRunner: private::Sealed {
    fn kind(&self) -> TaskKind;
    fn run(&self, ctx: &Context) -> Result<()>;
}

// Only types in this crate can impl Sealed, so only
// this crate can impl TaskRunner
impl private::Sealed for RegularTask {}
impl TaskRunner for RegularTask {
    fn kind(&self) -> TaskKind { TaskKind::Regular }
    fn run(&self, ctx: &Context) -> Result<()> { todo!() }
}
```
