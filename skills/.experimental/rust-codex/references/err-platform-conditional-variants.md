---
title: Use Platform-Conditional Error Variants
impact: CRITICAL
impactDescription: avoids compilation errors on non-target platforms
tags: err, cfg, platform, conditional-compilation
---

## Use Platform-Conditional Error Variants

Error variants that reference platform-specific types (e.g., `landlock::RulesetError` on Linux) must be gated with `#[cfg(target_os = "...")]`. The same gate must appear in `match` arms that handle these variants. Without the gate, the code fails to compile on other platforms.

**Incorrect (fails to compile on macOS and Windows):**

```rust
#[derive(Error, Debug)]
pub enum CodexErr {
    #[error(transparent)]
    LandlockRuleset(#[from] landlock::RulesetError),

    #[error(transparent)]
    LandlockPathFd(#[from] landlock::PathFdError),
}
```

**Correct (compiles on all platforms):**

```rust
#[derive(Error, Debug)]
pub enum CodexErr {
    #[cfg(target_os = "linux")]
    #[error(transparent)]
    LandlockRuleset(#[from] landlock::RulesetError),

    #[cfg(target_os = "linux")]
    #[error(transparent)]
    LandlockPathFd(#[from] landlock::PathFdError),
}

impl CodexErr {
    pub fn is_retryable(&self) -> bool {
        match self {
            // ... other arms ...
            #[cfg(target_os = "linux")]
            CodexErr::LandlockRuleset(_)
            | CodexErr::LandlockPathFd(_) => false,
        }
    }
}
```
