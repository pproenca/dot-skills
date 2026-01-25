---
title: Use num_args for Value Count Constraints
impact: MEDIUM
impactDescription: enforces exact or bounded number of values per argument
tags: valid, num-args, count, constraints, multiple
---

## Use num_args for Value Count Constraints

Use `num_args` to specify exactly how many values an argument should accept. This provides better validation and clearer help text.

**Incorrect (unbounded values):**

```rust
#[derive(Parser)]
struct Cli {
    #[arg(long)]
    points: Vec<i32>,  // Accepts any number of values
}
// --points 1 2 3 4 5 6 7 8 9 10  // All accepted, but we need pairs
```

**Correct (constrained value count):**

```rust
#[derive(Parser)]
struct Cli {
    /// X and Y coordinates
    #[arg(long, num_args = 2)]
    point: Vec<i32>,  // Exactly 2 values required per --point
}
// --point 10 20          # Valid
// --point 10             # Error: requires 2 values
// --point 10 20 --point 30 40  # Multiple pairs allowed
```

**Range of values:**

```rust
#[derive(Parser)]
struct Cli {
    /// Input files (1 to 5)
    #[arg(long, num_args = 1..=5)]
    files: Vec<PathBuf>,

    /// Optional tags
    #[arg(long, num_args = 0..)]
    tags: Vec<String>,
}
```

**Benefits:**
- Clear expectations in help text
- Early validation of value counts
- Works with repeated arguments

Reference: [Clap Arg num_args](https://docs.rs/clap/latest/clap/struct.Arg.html#method.num_args)
