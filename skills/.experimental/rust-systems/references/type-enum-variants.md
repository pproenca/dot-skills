---
title: Use Enums for Type-Safe Variants
impact: HIGH
impactDescription: Enum variants with data enable exhaustive matching and prevent invalid states
tags: type, enum, variants, sum-types
---

## Use Enums for Type-Safe Variants

Use enums to wrap different data types for type-safe dispatch. The compiler ensures all variants are handled.

**Incorrect (problematic pattern):**

```rust
// Stringly-typed - no compile-time safety
struct Field {
    type_name: String,  // "u32", "u64", "string"...
    value: Vec<u8>,     // Serialized data - type lost
}

// Must check type at runtime
fn display(field: &Field) {
    match field.type_name.as_str() {
        "u32" => { /* deserialize as u32 */ }
        "u64" => { /* deserialize as u64 */ }
        _ => panic!("unknown type"),  // Runtime error
    }
}
```

**Correct (recommended pattern):**

```rust
#[derive(Clone, Debug)]
pub enum Field {
    U32(u32),
    U64(u64),
    I32(i32),
    I64(i64),
    F32(f32),
    F64(f64),
    Str(String),
    StrVec(Vec<String>),
}

// Compiler ensures all variants handled
fn display(field: &Field) {
    match field {
        Field::U32(v) => println!("{}", v),
        Field::U64(v) => println!("{}", v),
        Field::I32(v) => println!("{}", v),
        Field::I64(v) => println!("{}", v),
        Field::F32(v) => println!("{:.2}", v),
        Field::F64(v) => println!("{:.2}", v),
        Field::Str(s) => println!("{}", s),
        Field::StrVec(v) => println!("{:?}", v),
    }
}

// Implement From for ergonomic construction
impl From<u32> for Field {
    fn from(value: u32) -> Self {
        Field::U32(value)
    }
}

impl From<String> for Field {
    fn from(value: String) -> Self {
        Field::Str(value)
    }
}

// Usage
let field: Field = 42u32.into();
```

**When NOT to use:**
- When variants share no common interface (consider separate types)
- When the number of variants is unbounded (use trait objects)
