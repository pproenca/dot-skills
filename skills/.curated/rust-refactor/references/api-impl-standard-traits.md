---
title: Implement Standard Traits for Ergonomic APIs
impact: HIGH
impactDescription: enables idiomatic usage patterns, integrates with ecosystem
tags: api, traits, display, default, iterator, standard
---

## Implement Standard Traits for Ergonomic APIs

Implement standard library traits like `Display`, `Default`, `Iterator`, and `IntoIterator` to make types feel native to Rust.

**Incorrect (custom methods instead of traits):**

```rust
pub struct Temperature(f64);

impl Temperature {
    pub fn to_string(&self) -> String {
        format!("{}°C", self.0)
    }

    pub fn new_default() -> Self {
        Temperature(20.0)
    }
}

pub struct SensorReadings {
    readings: Vec<f64>,
}

impl SensorReadings {
    pub fn get_readings(&self) -> &[f64] {
        &self.readings
    }
}
```

**Correct (implement standard traits):**

```rust
use std::fmt;

pub struct Temperature(f64);

impl fmt::Display for Temperature {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}°C", self.0)
    }
}

impl Default for Temperature {
    fn default() -> Self {
        Temperature(20.0)
    }
}

pub struct SensorReadings {
    readings: Vec<f64>,
}

impl IntoIterator for SensorReadings {
    type Item = f64;
    type IntoIter = std::vec::IntoIter<f64>;

    fn into_iter(self) -> Self::IntoIter {
        self.readings.into_iter()
    }
}

// Now works naturally
fn main() {
    let current_temp = Temperature::default();
    println!("Temperature: {}", current_temp);  // Uses Display

    let readings = SensorReadings { readings: vec![1.0, 2.0, 3.0] };
    for reading in readings {  // Uses IntoIterator
        println!("{}", reading);
    }
}
```

Reference: [Standard Traits - Rust API Guidelines](https://rust-lang.github.io/api-guidelines/interoperability.html)
