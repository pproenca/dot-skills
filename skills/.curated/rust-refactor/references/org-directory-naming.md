---
title: Use snake_case for All Directory Names
impact: HIGH
impactDescription: Consistent naming prevents module resolution issues and follows Rust ecosystem conventions
tags: org, naming, directories, snake-case
---

## Use snake_case for All Directory Names

All directories including crate names should use snake_case convention. This matches Rust's module naming rules and prevents import issues.

**Incorrect (problematic pattern):**

```text
my-project/
├── My-Derive/          # Wrong: kebab-case with caps
├── gpuStats/          # Wrong: camelCase
├── CGROUPfs/          # Wrong: mixed case
└── Ethtool/           # Wrong: PascalCase
```text

**Correct (recommended pattern):**

```
my_project/
├── my_derive/         # Correct: snake_case
├── gpu_stats/         # Correct: snake_case
├── cgroupfs/          # Correct: lowercase snake_case
└── ethtool/           # Correct: lowercase
```

```rust
// Module imports then work naturally
use gpu_stats::GpuReader;
use cgroupfs::CgroupReader;
```

**When NOT to use:**
- Directory names that don't correspond to Rust modules (e.g., `.github/`, `docs/`)
