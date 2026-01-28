---
title: Order derive macros consistently
impact: MEDIUM
impactDescription: Consistent derive ordering improves code readability and diff quality
tags: mod, derive, formatting
---

# Order derive macros consistently

Order derive macros in a consistent sequence: Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize, then others alphabetically.

## Why This Matters

- Predictable code structure
- Easier to scan for specific traits
- Cleaner diffs when adding derives
- Team consistency

## Standard Order

1. `Debug` - always first (essential for development)
2. `Clone` / `Copy` - value semantics
3. `PartialEq` / `Eq` - equality
4. `PartialOrd` / `Ord` - ordering
5. `Hash` - hashing
6. `Default` - default construction
7. `Serialize` / `Deserialize` - serde
8. Others alphabetically

**Incorrect (avoid this pattern):**

```rust
#[derive(Serialize, Debug, Clone)
pub struct Config { }

#[derive(PartialEq, Debug, Deserialize, Clone, Serialize)
pub struct Message { }
```

**Correct (recommended):**

```rust
#[derive(Debug, Clone, Serialize)
pub struct Config { }

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)
pub struct Message { }

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)
pub struct Id(u64);

#[derive(Debug, Clone, PartialEq, Eq, Default, Serialize, Deserialize)
pub struct Options {
    pub timeout: Option<Duration>,
    pub retry: bool,
}
```

## With Additional Macros

```rust
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize, JsonSchema)
#[serde(rename_all = "camelCase")
pub struct ApiRequest {
    pub request_id: String,
    pub payload: Value,
}
```
