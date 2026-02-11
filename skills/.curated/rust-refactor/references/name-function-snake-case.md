---
title: Use snake_case for Functions and Methods
impact: HIGH
impactDescription: Consistent with Rust RFC 430 and enables automatic lint warnings for violations
tags: name, functions, snake-case, convention
---

## Use snake_case for Functions and Methods

All function and method names must use snake_case. This follows Rust RFC 430 and the compiler will warn on violations.

**Incorrect (problematic pattern):**

```rust
fn GetHostname() -> Result<String> { ... }      // PascalCase - wrong
fn readNextSample() -> Sample { ... }           // camelCase - wrong
fn PROCESS_DATA(data: &[u8]) { ... }           // SCREAMING - wrong
fn Read_Config_File() -> Config { ... }         // Mixed - wrong
```

**Correct (recommended pattern):**

```rust
fn get_hostname() -> Result<String> { ... }
fn read_next_sample() -> Sample { ... }
fn process_data(data: &[u8]) { ... }
fn read_config_file() -> Config { ... }

impl DataCollector {
    fn new() -> Self { ... }
    fn collect_stats(&mut self) -> Stats { ... }
    fn get_last_sample(&self) -> Option<&Sample> { ... }
}
```

**When NOT to use:**
- FFI functions that must match C naming conventions (use `#[allow(non_snake_case)]`)
- Generated code where naming is controlled externally
