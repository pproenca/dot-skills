---
title: Use Public Fields for Data Structs
impact: MEDIUM
impactDescription: Public fields reduce boilerplate for pure data containers
tags: type, fields, visibility, data-structs
---

## Use Public Fields for Data Structs

Data structs (DTOs, models, stats) should have public fields for direct access. Reserve private fields with getters for invariant-maintaining types.

**Incorrect (problematic pattern):**

```rust
// Unnecessary encapsulation for pure data
pub struct CpuStat {
    user_usec: Option<u64>,    // Private
    system_usec: Option<u64>,  // Private
    idle_usec: Option<u64>,    // Private
}

impl CpuStat {
    pub fn user_usec(&self) -> Option<u64> { self.user_usec }
    pub fn system_usec(&self) -> Option<u64> { self.system_usec }
    pub fn idle_usec(&self) -> Option<u64> { self.idle_usec }

    pub fn set_user_usec(&mut self, v: Option<u64>) { self.user_usec = v; }
    // ... 20 more getters/setters
}
```

**Correct (recommended pattern):**

```rust
// Data struct - public fields
#[derive(Default, Clone, Debug, Serialize, Deserialize)]
pub struct CpuStat {
    pub user_usec: Option<u64>,
    pub system_usec: Option<u64>,
    pub idle_usec: Option<u64>,
}

// Direct access - clean and simple
let stat = CpuStat::default();
let user = stat.user_usec.unwrap_or(0);

// Struct update syntax works
let updated = CpuStat {
    user_usec: Some(100),
    ..stat
};
```

```rust
// Private fields only when maintaining invariants
pub struct ValidatedConfig {
    path: PathBuf,      // Private - validated on construction
    max_size: usize,    // Private - must be > 0
}

impl ValidatedConfig {
    pub fn new(path: PathBuf, max_size: usize) -> Result<Self, Error> {
        if max_size == 0 {
            return Err(Error::InvalidMaxSize);
        }
        Ok(Self { path, max_size })
    }

    // Getters needed because invariants must be maintained
    pub fn path(&self) -> &Path { &self.path }
    pub fn max_size(&self) -> usize { self.max_size }
}
```

**When NOT to use:**
- Types with invariants that must be validated
- Types where fields should only change together
- Public API types where future changes might break compatibility
