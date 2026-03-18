---
title: Use Builder Pattern for Complex Object Construction
impact: HIGH
impactDescription: eliminates constructor parameter confusion, self-documenting callsites
tags: safe, builder, construction, api-design, type-safety
---

## Use Builder Pattern for Complex Object Construction

Use the builder pattern when a struct has more than 3-4 configuration fields, especially when most have defaults. Builders make each field assignment explicit and self-documenting at the callsite.

**Incorrect (positional constructor with ambiguous parameters):**

```rust
let policy = SandboxPolicy::new(
    true,
    false,
    "/tmp",
    vec!["*.rs"],
    None,
    30,
);
// What does `true, false` mean?
```

**Correct (builder with named methods):**

```rust
let policy = SandboxPolicy::builder()
    .network_enabled(true)
    .filesystem_writable(false)
    .working_directory("/tmp")
    .allowed_extensions(vec!["*.rs"])
    .timeout_seconds(30)
    .build()?;
```
