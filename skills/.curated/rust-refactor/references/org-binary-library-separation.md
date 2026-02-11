---
title: Separate Binary and Library Crates
impact: HIGH
impactDescription: Enables code reuse, cleaner dependencies, and testable library code
tags: org, binary, library, crate-structure
---

## Separate Binary and Library Crates

Keep main.rs and binary-specific code in a dedicated binary crate. All reusable logic should live in library crates that the binary depends on.

**Incorrect (problematic pattern):**

```rust
// Single crate mixing binary and library concerns
// src/main.rs
fn main() {
    let model = build_model();
    render_view(&model);
}

// All logic in same crate - can't be reused as library
fn build_model() -> Model { ... }
fn render_view(model: &Model) { ... }
fn collect_data() -> Data { ... }
```text

**Correct (recommended pattern):**

```
workspace/
├── app/                # Binary crate - entry point only
│   ├── Cargo.toml
│   └── src/
│       ├── main.rs     # Just orchestration
│       └── exitstat.rs # Binary-specific logic
├── model/              # Library crate - reusable
│   └── src/lib.rs
└── view/               # Library crate - reusable
    └── src/lib.rs
```

```rust
// app/src/main.rs - thin binary
use model::Model;
use view::render;

fn main() -> anyhow::Result<()> {
    let model = Model::collect()?;
    render(&model)?;
    Ok(())
}
```

```toml
# app/Cargo.toml
[dependencies]
model = { path = "../model" }
view = { path = "../view" }
```

**When NOT to use:**
- Trivial single-file CLI tools
- Examples or test binaries
