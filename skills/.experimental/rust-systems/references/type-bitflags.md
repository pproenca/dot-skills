---
title: Use bitflags! for Type-Safe Bit Flags
impact: MEDIUM
impactDescription: bitflags! prevents integer flag mixing and enables set operations
tags: type, bitflags, flags, safety
---

## Use bitflags! for Type-Safe Bit Flags

Use the `bitflags!` macro to create type-safe bit flag types instead of raw integer constants.

**Incorrect (problematic pattern):**

```rust
// Raw constants - easy to mix up with other integers
const COMPRESSED: u32 = 0x1;
const CBOR: u32 = 0x2;
const ENCRYPTED: u32 = 0x4;

fn process(flags: u32) {
    if flags & COMPRESSED != 0 { ... }
}

// Oops - passed wrong integer
let some_other_value: u32 = 42;
process(some_other_value);  // Compiles, but wrong semantically
```

**Correct (recommended pattern):**

```rust
use bitflags::bitflags;

bitflags! {
    #[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
    pub struct IndexEntryFlags: u32 {
        const COMPRESSED = 0x1;
        const CBOR = 0x2;
        const ENCRYPTED = 0x4;
    }
}

fn process(flags: IndexEntryFlags) {
    if flags.contains(IndexEntryFlags::COMPRESSED) {
        // Handle compressed data
    }
}

// Usage - type safe
let flags = IndexEntryFlags::COMPRESSED | IndexEntryFlags::CBOR;
process(flags);

// Won't compile - type mismatch
let some_value: u32 = 42;
process(some_value);  // Error!

// Set operations
let all_flags = IndexEntryFlags::all();
let is_compressed = flags.contains(IndexEntryFlags::COMPRESSED);
let combined = flags | IndexEntryFlags::ENCRYPTED;
let toggled = flags ^ IndexEntryFlags::CBOR;
```

```toml
# Cargo.toml
[dependencies]
bitflags = "2"
```

**When NOT to use:**
- Single boolean options (use `bool`)
- When flags need to be extended at runtime (use `HashSet`)
