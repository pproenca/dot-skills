---
title: Use to_ and from_ for Conversions
impact: MEDIUM
impactDescription: Conversion prefixes indicate data flow direction and transformation semantics
tags: name, conversion, to, from, transform
---

## Use to_ and from_ for Conversions

Conversion functions use `to_*` for converting from self to target, `from_*` for creating from a source. This matches Rust standard library conventions.

**Incorrect (problematic pattern):**

```rust
fn camelcase(snake: &Ident) -> Ident { ... }
fn string(bytes: &[u8]) -> String { ... }
fn parse_config(s: &str) -> Config { ... }

impl Field {
    fn as_u64(&self) -> u64 { ... }  // as_ implies borrowing
}
```

**Correct (recommended pattern):**

```rust
// to_* - convert self to another type
fn to_camelcase(snake: &Ident) -> Ident { ... }
fn to_snakecase(camel: &Ident) -> Ident { ... }

impl Field {
    // to_* when converting and possibly allocating
    fn to_string(&self) -> String { ... }
    fn to_u64(&self) -> Option<u64> { ... }
}

// from_* - create Self from another type
impl Config {
    fn from_str(s: &str) -> Result<Self, ParseError> { ... }
    fn from_bytes(bytes: &[u8]) -> Result<Self, ParseError> { ... }
    fn from_file(path: &Path) -> Result<Self, Error> { ... }
}

// Implement From trait for automatic Into
impl From<u64> for Field {
    fn from(value: u64) -> Self {
        Field::U64(value)
    }
}
```

```rust
// as_* for cheap reference conversions (borrowing)
impl Wrapper {
    fn as_str(&self) -> &str { &self.inner }
    fn as_bytes(&self) -> &[u8] { self.inner.as_bytes() }
}

// into_* for consuming conversions
impl Wrapper {
    fn into_inner(self) -> String { self.inner }
}
```

**When NOT to use:**
- When implementing standard From/Into traits (use impl blocks)
