---
title: Use new for Constructors
impact: HIGH
impactDescription: Consistent constructor naming follows Rust conventions and IDE expectations
tags: name, constructors, new, creation
---

## Use new for Constructors

Constructor functions use `new` or `new_*` pattern. This is the established Rust convention that IDEs and documentation tools recognize.

**Incorrect (problematic pattern):**

```rust
impl Collector {
    fn create() -> Self { ... }
    fn make() -> Self { ... }
    fn build() -> Self { ... }       // Unless using builder pattern
    fn initialize() -> Self { ... }
}

fn create_advance_local() -> Advance { ... }
fn make_reader() -> Reader { ... }
```

**Correct (recommended pattern):**

```rust
impl Collector {
    pub fn new() -> Self { ... }
}

impl Advance {
    pub fn new(store: Box<dyn Store>) -> Self { ... }

    // Variants with descriptive suffixes
    pub fn new_local(path: PathBuf) -> Self { ... }
    pub fn new_remote(host: &str, port: u16) -> Self { ... }
    pub fn new_with_options(options: Options) -> Self { ... }
}

// Standalone constructors
pub fn new_advance_local(
    logger: slog::Logger,
    dir: PathBuf,
    timestamp: SystemTime,
) -> Advance { ... }
```

```rust
// Default trait for parameterless construction
impl Default for CollectorOptions {
    fn default() -> Self {
        Self {
            cgroup_root: PathBuf::from("/sys/fs/cgroup"),
            collect_io_stat: true,
        }
    }
}
```

**When NOT to use:**
- Conversion constructors (use `from_*` instead)
- Deserializers (use `from_bytes`, `from_str`, etc.)
