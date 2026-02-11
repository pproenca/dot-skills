---
title: Derive Copy for Simple Enums
impact: MEDIUM
impactDescription: Copy-able enums avoid unnecessary cloning and enable value semantics
tags: type, enum, copy, clone
---

## Derive Copy for Simple Enums

Enums without heap-allocated data should derive `Copy` along with `Clone`. This enables value semantics and avoids unnecessary `.clone()` calls.

**Incorrect (problematic pattern):**

```rust
// Missing Copy - requires .clone() everywhere
#[derive(Clone, Debug, PartialEq)]
pub enum Direction {
    Forward,
    Reverse,
}

fn process(dir: Direction) { ... }

let dir = Direction::Forward;
process(dir.clone());  // Unnecessary clone
process(dir.clone());  // And again
```

**Correct (recommended pattern):**

```rust
// Copy + Clone for simple enums
#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum Direction {
    Forward,
    Reverse,
}

fn process(dir: Direction) { ... }

let dir = Direction::Forward;
process(dir);  // Copied implicitly
process(dir);  // Can use again - it's Copy

// Also add Eq when PartialEq is present and variants have no floats
#[derive(Clone, Copy, Debug, Eq, PartialEq, Hash)]
pub enum ViewMode {
    Live,
    Pause,
    Zoom,
}

// Hash for use in HashMaps/HashSets
let mut modes: HashSet<ViewMode> = HashSet::new();
modes.insert(ViewMode::Live);
```

**When NOT to use:**
- Enums with heap-allocated variants (String, Vec, Box)
- Enums with large data that would be expensive to copy
- When you want move semantics to prevent multiple ownership
