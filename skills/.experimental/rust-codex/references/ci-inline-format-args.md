---
title: Inline Format Arguments in format! Macros
impact: LOW-MEDIUM
impactDescription: prevents clippy CI failure and improves readability
tags: ci, clippy, format, inline-args
---

## Inline Format Arguments in format! Macros

When using `format!` and variables can be inlined into `{}`, always do so per the `clippy::uninlined_format_args` lint. This reduces visual noise and makes the formatted string easier to read. The lint is enforced in CI.

**Incorrect (redundant positional arguments):**

```rust
let message = format!(
    "unexpected status {}: {}, url: {}",
    status, body, url
);
let error_msg = format!(
    "failed to connect to {} on port {}",
    host, port
);
```

**Correct (variables inlined into format string):**

```rust
let message = format!(
    "unexpected status {status}: {body}, url: {url}"
);
let error_msg = format!(
    "failed to connect to {host} on port {port}"
);
```
