---
title: Use inline format arguments
impact: MEDIUM
impactDescription: Cleaner, more readable format strings
tags: style, formatting, strings
---

# Use inline format arguments

Inline variable names in format strings instead of positional arguments.

## Why This Matters

- More readable format strings
- Fewer places to make mistakes
- Enforced by clippy::uninlined_format_args
- Rust 1.58+ feature

## Configuration

```toml
[workspace.lints.clippy
uninlined_format_args = "warn"
```

**Incorrect (avoid this pattern):**

```rust
let name = "Alice";
let count = 42;

println!("Hello, {}!", name);
println!("{} items remaining", count);
format!("User {} has {} points", name, count);
tracing::info!("Processing {} items for {}", count, name);
```

**Correct (recommended):**

```rust
let name = "Alice";
let count = 42;

println!("Hello, {name}!");
println!("{count} items remaining");
format!("User {name} has {count} points");
tracing::info!("Processing {count} items for {name}");
```

## With Expressions

For expressions, you still need positional or named arguments:

```rust
// Expression in format - needs positional
println!("Result: {}", compute_value());

// Or use a binding
let result = compute_value();
println!("Result: {result}");

// Named argument for clarity
println!("Sum: {sum}", sum = a + b);
```

## Debug and Display

```rust
let config = Config::new();

// Debug format
println!("Config: {config:?}");
println!("Config: {config:#?}");  // Pretty print

// With width/precision
println!("Value: {value:>10}");
println!("Float: {f:.2}");
```
