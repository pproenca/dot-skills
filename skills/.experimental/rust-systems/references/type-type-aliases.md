---
title: Use Type Aliases for Complex Generics
impact: LOW
impactDescription: Type aliases simplify signatures and improve readability
tags: type, alias, generics, readability
---

## Use Type Aliases for Complex Generics

Create type aliases to simplify complex generic instantiations. This improves readability and reduces repetition.

**Incorrect (problematic pattern):**

```rust
// Verbose and hard to read
fn process(
    container: QueriableContainerFieldId<Vec<SingleCgroupModel>>
) -> QueriableContainerFieldId<Vec<SingleCgroupModel>> {
    // ...
}

// Repetitive in structs
struct Collector {
    pids: BTreeMap<i32, PidInfo>,
    networks: BTreeMap<String, NetworkStats>,
    disks: BTreeMap<String, DiskStats>,
}
```

**Correct (recommended pattern):**

```rust
// Clear type aliases
pub type VecFieldId<Q> = QueriableContainerFieldId<Vec<Q>>;
pub type BTreeMapFieldId<K, Q> = QueriableContainerFieldId<BTreeMap<K, Q>>;

fn process(container: VecFieldId<SingleCgroupModel>) -> VecFieldId<SingleCgroupModel> {
    // Much cleaner
}

// Domain-specific aliases
pub type PidMap = BTreeMap<i32, PidInfo>;
pub type NetMap = BTreeMap<String, NetworkStats>;
pub type DiskMap = BTreeMap<String, DiskStats>;

struct Collector {
    pids: PidMap,
    networks: NetMap,
    disks: DiskMap,
}

// Result alias (covered in err-result-alias)
pub type Result<T> = std::result::Result<T, Error>;

// Complex type alias
pub type Advance = advance::Advance<DataFrame, Model>;
pub type ViewType = StatsView<SystemView>;
```

```rust
// Type alias with associated type bounds
pub type CgroupField = <SingleCgroupModel as Queriable>::FieldId;
pub type ProcessField = <ProcessModel as Queriable>::FieldId;
```

**When NOT to use:**
- Simple generic types that are already readable
- When the alias would be used only once
- When it hides important type information from readers
