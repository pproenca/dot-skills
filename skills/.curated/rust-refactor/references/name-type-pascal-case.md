---
title: Use PascalCase for Types
impact: HIGH
impactDescription: Consistent with Rust RFC 430 and visually distinguishes types from values
tags: name, types, pascal-case, structs, enums, traits
---

## Use PascalCase for Types

All type names (structs, enums, traits, type aliases) must use PascalCase. This visually distinguishes types from variables and functions.

**Incorrect (problematic pattern):**

```rust
struct data_frame { ... }           // snake_case - wrong
enum view_mode { ... }              // snake_case - wrong
trait queriable { ... }             // snake_case - wrong
type pid_map = BTreeMap<i32, Pid>;  // snake_case - wrong
```

**Correct (recommended pattern):**

```rust
struct DataFrame { ... }
enum ViewMode { Forward, Reverse }
trait Queriable { ... }
type PidMap = BTreeMap<i32, PidInfo>;

// Compound names
struct CgroupCpuModel { ... }      // Not Cgroup_Cpu_Model
struct BtrfsReader { ... }         // Not BTRFSReader
enum IoDirection { Read, Write }   // Not IODirection
```

```rust
// Type aliases follow same convention
type Result<T> = std::result::Result<T, Error>;
type VecFieldId<Q> = QueriableContainerFieldId<Vec<Q>>;
```

**When NOT to use:**
- FFI types matching C conventions (use type aliases to wrap)
- Primitive type aliases (`type byte = u8;` - though avoid these)
