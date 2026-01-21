---
title: Use Sealed Traits to Prevent External Implementation
impact: HIGH
impactDescription: enables future API evolution without breaking changes
tags: api, sealed, traits, private, extension
---

## Use Sealed Traits to Prevent External Implementation

Seal public traits when you need to add methods later without breaking downstream code. External crates cannot implement sealed traits.

**Incorrect (open trait, can't add methods):**

```rust
// In library v1.0
pub trait Encoder {
    fn encode(&self, data: &[u8]) -> Vec<u8>;
}

// In library v2.0 - adding this breaks downstream implementors!
// pub trait Encoder {
//     fn encode(&self, data: &[u8]) -> Vec<u8>;
//     fn encode_with_options(&self, data: &[u8], opts: Options) -> Vec<u8>;
// }
```

**Correct (sealed trait, safe to extend):**

```rust
mod private {
    pub trait Sealed {}
}

pub trait Encoder: private::Sealed {
    fn encode(&self, data: &[u8]) -> Vec<u8>;
}

// Only types in this crate can implement Sealed
impl private::Sealed for JsonEncoder {}
impl private::Sealed for XmlEncoder {}

impl Encoder for JsonEncoder {
    fn encode(&self, data: &[u8]) -> Vec<u8> {
        // JSON encoding
        vec![]
    }
}

// Adding methods is now safe - no external implementors exist
// impl Encoder for JsonEncoder {
//     fn encode_with_options(...) { ... }
// }
```

**When to seal:**
- Traits that may gain methods in future versions
- Traits where you need exhaustive knowledge of all implementors
- Extension traits that shouldn't be implemented externally

**When NOT to seal:**
- Traits meant for user extension (like `Iterator` adapters)
- Marker traits

Reference: [Sealed Traits - Rust API Guidelines](https://rust-lang.github.io/api-guidelines/future-proofing.html#sealed-traits-protect-against-downstream-implementations-c-sealed)
