---
title: Use Newtype Pattern for Unit Safety
impact: CRITICAL
impactDescription: prevents unit confusion bugs at compile time
tags: type, newtype, units, safety, wrapper
---

## Use Newtype Pattern for Unit Safety

Wrap primitive types in newtype structs to prevent mixing logically distinct values. The compiler catches unit confusion errors that would otherwise cause runtime bugs.

**Incorrect (unit confusion possible):**

```rust
fn calculate_velocity(distance: f64, time: f64) -> f64 {
    distance / time
}

fn main() {
    let distance_km = 100.0;
    let time_hours = 2.0;
    // Accidentally swapped arguments - compiles fine, wrong result
    let velocity = calculate_velocity(time_hours, distance_km);
}
```

**Correct (compile-time unit safety):**

```rust
struct Kilometers(f64);
struct Hours(f64);
struct KilometersPerHour(f64);

fn calculate_velocity(distance: Kilometers, time: Hours) -> KilometersPerHour {
    KilometersPerHour(distance.0 / time.0)
}

fn main() {
    let distance = Kilometers(100.0);
    let time = Hours(2.0);
    // Swapped arguments won't compile
    let velocity = calculate_velocity(distance, time);
}
```

**Note:** Newtypes have zero runtime cost - the compiler optimizes away the wrapper.

Reference: [Newtype Pattern - Rust Design Patterns](https://rust-unofficial.github.io/patterns/patterns/behavioural/newtype.html)
