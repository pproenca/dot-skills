---
title: Use cfg Attributes for Conditional Modules
impact: MEDIUM
impactDescription: Conditional compilation enables platform-specific code and optional features cleanly
tags: mod, cfg, conditional, platform
---

## Use cfg Attributes for Conditional Modules

Use `#[cfg(...)]` attributes to conditionally compile modules for tests, platforms, or features. Keep conditional code in dedicated subdirectories.

**Incorrect (problematic pattern):**

```rust
// Mixing conditional and unconditional code
// lib.rs
pub fn read_stats() -> Stats {
    #[cfg(target_os = "linux")]
    {
        // 100 lines of Linux code
    }
    #[cfg(target_os = "macos")]
    {
        // 100 lines of macOS code
    }
    #[cfg(not(any(target_os = "linux", target_os = "macos")))]
    {
        // 50 lines of fallback
    }
}
```text

**Correct (recommended pattern):**

```
src/
├── lib.rs
├── reader.rs           # Common interface
├── linux/              # Platform-specific
│   └── mod.rs
├── macos/
│   └── mod.rs
└── open_source/        # Build-variant specific
    └── mod.rs
```

```rust
// lib.rs
mod reader;

#[cfg(target_os = "linux")]
mod linux;
#[cfg(target_os = "linux")]
pub use linux::PlatformReader;

#[cfg(target_os = "macos")]
mod macos;
#[cfg(target_os = "macos")]
pub use macos::PlatformReader;

// For tests
#[cfg(test)]
mod test;

// For features
#[cfg(feature = "advanced")]
mod advanced;
```

```rust
// Macro for build-variant switching
macro_rules! build_variant_shim {
    ($($item:item)*) => {
        #[cfg(not(feature = "enterprise"))]
        mod community;
        #[cfg(not(feature = "enterprise"))]
        pub use community::*;

        #[cfg(feature = "enterprise")]
        mod enterprise;
        #[cfg(feature = "enterprise")]
        pub use enterprise::*;
    }
}
```

**When NOT to use:**
- Trivial differences (use runtime checks instead)
- When cfg complexity exceeds actual platform differences
