---
title: Use Argument Comments Before Opaque Literals
impact: CRITICAL
impactDescription: prevents wrong-argument-order bugs at callsites
tags: type, argument-comment, lint, readability
---

## Use Argument Comments Before Opaque Literals

When calling functions with positional literal arguments (booleans, `None`, numeric literals), place an exact `/*param_name*/` comment before each opaque argument. The parameter name must match the callee's signature exactly. String and char literals are exempt unless the comment adds clarity.

**Incorrect (caller cannot distinguish arguments without reading the signature):**

```rust
session_telemetry.counter("codex.shell_snapshot", 1, &counter_tags);
let shell = get_shell(shell_type.clone(), None);
start_snapshot(false, true);
```

**Correct (argument intent is clear at every callsite):**

```rust
session_telemetry.counter("codex.shell_snapshot", /*inc*/ 1, &counter_tags);
let shell = get_shell(shell_type.clone(), /*path*/ None);
start_snapshot(/*use_login_shell*/ false, /*include_disabled*/ true);
```
