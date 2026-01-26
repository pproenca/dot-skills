---
title: Use Approximate Comparison for Floating Point
impact: MEDIUM
impactDescription: prevents false failures from floating point precision
tags: assert, floating-point, approximate, precision, numerics
---

## Use Approximate Comparison for Floating Point

Use approximate equality for floating point comparisons. Exact equality fails due to precision errors even for mathematically equal values.

**Incorrect (exact equality fails):**

```rust
#[test]
fn test_average() {
    let values = vec![0.1, 0.2, 0.3];
    let avg = average(&values);

    assert_eq!(avg, 0.2);  // Fails! 0.1 + 0.2 + 0.3 != 0.6 exactly
}

#[test]
fn test_trigonometry() {
    let result = (std::f64::consts::PI).sin();
    assert_eq!(result, 0.0);  // Fails! Result is ~1.2e-16, not exactly 0
}
```

**Correct (approximate equality):**

```rust
#[test]
fn test_average() {
    let values = vec![0.1, 0.2, 0.3];
    let avg = average(&values);

    assert!((avg - 0.2).abs() < 1e-10, "Expected ~0.2, got {}", avg);
}

#[test]
fn test_trigonometry() {
    let result = (std::f64::consts::PI).sin();
    assert!((result - 0.0).abs() < 1e-10, "Expected ~0, got {}", result);
}
```

**Using approx crate:**

```rust
use approx::assert_relative_eq;

#[test]
fn test_with_approx() {
    let result = calculate_percentage(33.333);

    // Relative epsilon - good for values of varying magnitude
    assert_relative_eq!(result, 33.333, epsilon = 1e-6);

    // Absolute epsilon - good for values near zero
    assert_abs_diff_eq!(result, 33.333, epsilon = 0.001);
}

#[test]
fn test_vectors() {
    let computed = compute_vector();
    let expected = [1.0, 2.0, 3.0];

    for (c, e) in computed.iter().zip(expected.iter()) {
        assert_relative_eq!(c, e, epsilon = 1e-10);
    }
}
```

**Custom epsilon based on context:**

```rust
const PHYSICS_EPSILON: f64 = 1e-9;
const GRAPHICS_EPSILON: f64 = 1e-4;  // Pixels don't need high precision

fn assert_near(actual: f64, expected: f64, epsilon: f64, context: &str) {
    assert!(
        (actual - expected).abs() < epsilon,
        "{}: expected {} ± {}, got {} (diff: {})",
        context,
        expected,
        epsilon,
        actual,
        (actual - expected).abs()
    );
}

#[test]
fn test_physics_simulation() {
    let position = simulate_trajectory();
    assert_near(position.x, 100.0, PHYSICS_EPSILON, "x position");
    assert_near(position.y, 50.0, PHYSICS_EPSILON, "y position");
}
```

**Cargo.toml:**

```toml
[dev-dependencies]
approx = "0.5"
```

**Choosing epsilon:**

| Context | Typical Epsilon |
|---------|-----------------|
| Graphics/UI | 1e-4 to 1e-2 |
| Scientific | 1e-9 to 1e-6 |
| Financial | Use Decimal, not float |
| Machine learning | 1e-6 to 1e-4 |

Reference: [approx crate documentation](https://docs.rs/approx)
