---
title: Combine Property Tests with Edge Case Unit Tests
impact: MEDIUM
impactDescription: covers both random exploration and known boundaries
tags: prop, proptest, unit-testing, edge-cases, complementary
---

## Combine Property Tests with Edge Case Unit Tests

Use property tests for broad coverage and unit tests for known edge cases. Property tests explore randomly but may miss specific values in large spaces.

**Incorrect (only property tests):**

```rust
proptest! {
    #[test]
    fn division_never_panics(a in any::<i64>(), b in any::<i64>()) {
        let _ = safe_divide(a, b);  // Might not hit b=0 or overflow cases
    }
}
// Random testing unlikely to hit i64::MIN / -1 overflow
```

**Correct (complementary testing):**

```rust
// Unit tests for known edge cases
#[test]
fn division_by_zero_returns_none() {
    assert_eq!(safe_divide(42, 0), None);
}

#[test]
fn min_value_divided_by_negative_one_returns_none() {
    // i64::MIN / -1 would overflow
    assert_eq!(safe_divide(i64::MIN, -1), None);
}

#[test]
fn max_values_handled_correctly() {
    assert_eq!(safe_divide(i64::MAX, 1), Some(i64::MAX));
    assert_eq!(safe_divide(i64::MIN, 1), Some(i64::MIN));
}

// Property tests for broad coverage
proptest! {
    #[test]
    fn division_is_reversible_when_no_remainder(
        a in any::<i64>(),
        b in any::<i64>().prop_filter("non-zero", |b| *b != 0)
    ) {
        if let Some(result) = safe_divide(a, b) {
            if a % b == 0 {
                prop_assert_eq!(result * b, a);
            }
        }
    }

    #[test]
    fn division_result_smaller_than_dividend(
        a in 1i64..i64::MAX,
        b in 2i64..1000
    ) {
        if let Some(result) = safe_divide(a, b) {
            prop_assert!(result.abs() <= a.abs());
        }
    }
}
```

**Testing strategy:**

| Test Type | Covers | Examples |
|-----------|--------|----------|
| Unit tests | Boundary values | 0, -1, MAX, MIN |
| Unit tests | Known bugs | Issue #123 edge case |
| Property tests | General invariants | Roundtrips, ordering |
| Property tests | Robustness | Never panics |

Reference: [proptest - Combining with Unit Tests](https://github.com/proptest-rs/proptest#limitations)
