---
title: Test Invariants Instead of Specific Values
impact: HIGH
impactDescription: catches entire classes of bugs instead of single cases
tags: prop, proptest, invariants, properties, correctness
---

## Test Invariants Instead of Specific Values

Test that properties hold for all inputs, not just specific examples. This catches entire classes of bugs rather than individual cases.

**Incorrect (testing specific values):**

```rust
#[test]
fn test_add_to_set() {
    let mut set = HashSet::new();
    set.insert(5);
    assert!(set.contains(&5));
    assert_eq!(set.len(), 1);

    set.insert(5);  // Duplicate
    assert_eq!(set.len(), 1);
}
// Only tests one specific value!
```

**Correct (testing invariants):**

```rust
use proptest::prelude::*;

proptest! {
    // Invariant: insert then contains
    #[test]
    fn set_contains_inserted_element(value: i32) {
        let mut set = HashSet::new();
        set.insert(value);
        prop_assert!(set.contains(&value));
    }

    // Invariant: duplicate inserts don't change size
    #[test]
    fn set_ignores_duplicates(value: i32) {
        let mut set = HashSet::new();
        set.insert(value);
        let size_after_first = set.len();

        set.insert(value);  // Same value again
        prop_assert_eq!(set.len(), size_after_first);
    }

    // Invariant: remove then not contains
    #[test]
    fn set_does_not_contain_removed(value: i32) {
        let mut set = HashSet::new();
        set.insert(value);
        set.remove(&value);
        prop_assert!(!set.contains(&value));
    }
}
```

**Common invariant patterns:**

```rust
proptest! {
    // Roundtrip: encode → decode = identity
    #[test]
    fn json_roundtrips(user in valid_user()) {
        let json = serde_json::to_string(&user).unwrap();
        let decoded: User = serde_json::from_str(&json).unwrap();
        prop_assert_eq!(user, decoded);
    }

    // Commutativity: f(a, b) = f(b, a)
    #[test]
    fn addition_is_commutative(a: i32, b: i32) {
        prop_assert_eq!(a.wrapping_add(b), b.wrapping_add(a));
    }

    // Monotonicity: a < b implies f(a) <= f(b)
    #[test]
    fn sqrt_is_monotonic(a in 0.0f64..1e10, b in 0.0f64..1e10) {
        prop_assume!(a < b);
        prop_assert!(a.sqrt() <= b.sqrt());
    }

    // Idempotency: f(f(x)) = f(x)
    #[test]
    fn normalize_is_idempotent(path in ".*") {
        let normalized = normalize_path(&path);
        let double_normalized = normalize_path(&normalized);
        prop_assert_eq!(normalized, double_normalized);
    }

    // Preservation: operation preserves some property
    #[test]
    fn sort_preserves_length(v in prop::collection::vec(any::<i32>(), 0..100)) {
        let original_len = v.len();
        let mut sorted = v;
        sorted.sort();
        prop_assert_eq!(sorted.len(), original_len);
    }
}
```

**Benefits:**
- Tests cover infinite input space via sampling
- Catches edge cases you wouldn't think to test
- Documents the actual contract, not just examples

Reference: [proptest - Properties](https://proptest-rs.github.io/proptest/proptest/tutorial/first-steps.html)
