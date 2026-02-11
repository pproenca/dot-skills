---
title: Implement From Instead of Into
impact: MEDIUM
impactDescription: 50% less code, automatic Into via blanket implementation
tags: conv, from, into, conversion, traits
---

## Implement From Instead of Into

Implement `From<T>` rather than `Into<U>`. The standard library provides a blanket `Into` implementation for any type implementing `From`.

**Incorrect (implements Into directly):**

```rust
struct Celsius(f64);
struct Fahrenheit(f64);

impl Into<Fahrenheit> for Celsius {
    fn into(self) -> Fahrenheit {
        Fahrenheit(self.0 * 9.0 / 5.0 + 32.0)
    }
}

// No automatic From implementation
```

**Correct (implements From, gets Into free):**

```rust
struct Celsius(f64);
struct Fahrenheit(f64);

impl From<Celsius> for Fahrenheit {
    fn from(c: Celsius) -> Self {
        Fahrenheit(c.0 * 9.0 / 5.0 + 32.0)
    }
}

// Both work now
let f1: Fahrenheit = Fahrenheit::from(Celsius(100.0));
let f2: Fahrenheit = Celsius(100.0).into();
```

**Benefits:**
- `From<T>` for `U` automatically provides `Into<U>` for `T`
- `From` is more explicit about the target type
- Follows Rust convention

**When to implement Into directly:**
- Converting to a type in an external crate (orphan rule prevents implementing `From`)

Reference: [From and Into - Rust by Example](https://doc.rust-lang.org/rust-by-example/conversion/from_into.html)
