---
title: Move Tests and Docs When Extracting Modules
impact: HIGH
impactDescription: prevents 2-5x documentation staleness after module extraction
tags: mod, extraction, documentation, tests
---

## Move Tests and Docs When Extracting Modules

When extracting code from a large module into a new one, move the related tests and module/type documentation alongside the implementation. Invariant docs left in the old module become stale quickly and mislead future contributors. Tests left behind lose proximity to the code they verify.

**Incorrect (docs and tests left behind after extraction):**

```rust
// codex-rs/core/src/session.rs (original, now thinner)
/// Manages network proxy resolution for sandbox processes.
/// Uses the config table to determine allowed hosts.
// ^ Doc describes code that was moved to network_proxy_loader.rs

#[cfg(test)]
mod tests {
    #[test]
    fn test_proxy_constraints() { /* tests moved code */ }
}
```

**Correct (docs and tests travel with the extracted code):**

```rust
// codex-rs/core/src/network_proxy_loader.rs (new module)
/// Manages network proxy resolution for sandbox processes.
/// Uses the config table to determine allowed hosts.
pub fn load_proxy_constraints(/* ... */) { /* ... */ }

#[cfg(test)]
#[path = "network_proxy_loader_tests.rs"]
mod tests;

// codex-rs/core/src/network_proxy_loader_tests.rs
#[test]
fn test_proxy_constraints() { /* tests live next to the code */ }
```
