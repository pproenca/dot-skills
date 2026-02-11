---
title: Use Consistent Derive Order for Data Structs
impact: MEDIUM
impactDescription: Consistent derive ordering improves code review and grep-ability
tags: type, derive, traits, consistency
---

## Use Consistent Derive Order for Data Structs

Data structs should derive traits in a consistent order: Default, Clone, PartialEq, Debug, Serialize, Deserialize. This makes derives predictable and reviewable.

**Incorrect (problematic pattern):**

```rust
// Inconsistent ordering
#[derive(Serialize, Clone, Debug, Deserialize, Default)]
pub struct CpuStat { ... }

#[derive(Debug, Default, Serialize, Clone, Deserialize)]
pub struct MemInfo { ... }

#[derive(Clone, Serialize, Deserialize, Debug)]  // Missing Default
pub struct PidStat { ... }
```

**Correct (recommended pattern):**

```rust
// Consistent ordering throughout codebase
#[derive(Default, Clone, PartialEq, Debug, Serialize, Deserialize)]
pub struct CpuStat {
    pub user_usec: Option<u64>,
    pub system_usec: Option<u64>,
}

#[derive(Default, Clone, PartialEq, Debug, Serialize, Deserialize)]
pub struct MemInfo {
    pub total_bytes: Option<u64>,
    pub free_bytes: Option<u64>,
}

#[derive(Default, Clone, PartialEq, Debug, Serialize, Deserialize)]
pub struct PidStat {
    pub pid: i32,
    pub state: Option<PidState>,
}
```

**Derive order rationale:**
1. `Default` - Construction (most fundamental)
2. `Clone` - Copying (common operation)
3. `PartialEq` - Comparison
4. `Debug` - Debugging
5. `Serialize, Deserialize` - Persistence (external concern)

**When NOT to use:**
- When specific derive order is required by a macro
- When only a subset of derives is needed
