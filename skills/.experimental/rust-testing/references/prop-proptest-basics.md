---
title: Use Proptest for Property-Based Testing
impact: HIGH
impactDescription: finds edge cases that manual tests miss
tags: prop, proptest, property-based, fuzzing, edge-cases
---

## Use Proptest for Property-Based Testing

Use proptest to generate random inputs that verify properties hold for all values. This finds edge cases that hand-written tests consistently miss.

**Incorrect (manual test cases miss edge cases):**

```rust
#[test]
fn test_reverse_string() {
    assert_eq!(reverse("hello"), "olleh");
    assert_eq!(reverse(""), "");
    assert_eq!(reverse("a"), "a");
    // What about Unicode? Multi-byte chars? Very long strings?
}

#[test]
fn test_sort() {
    let mut v = vec![3, 1, 2];
    sort(&mut v);
    assert_eq!(v, vec![1, 2, 3]);
    // What about empty? Single element? Duplicates? Large arrays?
}
```

**Correct (property-based tests):**

```rust
use proptest::prelude::*;

proptest! {
    #[test]
    fn reversing_twice_returns_original(s in ".*") {
        let reversed = reverse(&s);
        let double_reversed = reverse(&reversed);
        prop_assert_eq!(s, double_reversed);
    }

    #[test]
    fn reverse_preserves_length(s in "\\PC*") {
        prop_assert_eq!(s.len(), reverse(&s).len());
    }

    #[test]
    fn sorted_array_is_ordered(mut v in prop::collection::vec(any::<i32>(), 0..100)) {
        sort(&mut v);
        for window in v.windows(2) {
            prop_assert!(window[0] <= window[1]);
        }
    }

    #[test]
    fn sorted_array_contains_same_elements(v in prop::collection::vec(any::<i32>(), 0..100)) {
        let mut sorted = v.clone();
        sort(&mut sorted);

        // Same length
        prop_assert_eq!(v.len(), sorted.len());

        // Same elements (as multiset)
        let mut v_sorted = v.clone();
        v_sorted.sort();
        prop_assert_eq!(v_sorted, sorted);
    }
}
```

**Common strategies:**

```rust
proptest! {
    // Strings matching regex
    #[test]
    fn email_validation(email in "[a-z]+@[a-z]+\\.[a-z]{2,4}") {
        prop_assert!(is_valid_email(&email));
    }

    // Numbers in range
    #[test]
    fn percentage_in_bounds(p in 0.0..=100.0f64) {
        prop_assert!(calculate_discount(p) <= p);
    }

    // Collections with constraints
    #[test]
    fn non_empty_vec(v in prop::collection::vec(any::<u8>(), 1..50)) {
        prop_assert!(!v.is_empty());
    }
}
```

**Cargo.toml:**

```toml
[dev-dependencies]
proptest = "1.4"
```

Reference: [proptest crate documentation](https://docs.rs/proptest/latest/proptest/)
