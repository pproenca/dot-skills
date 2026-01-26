---
title: Use Shrinking to Find Minimal Failing Cases
impact: MEDIUM
impactDescription: reduces 500-char failures to single problematic character
tags: prop, proptest, shrinking, debugging, minimal-case
---

## Use Shrinking to Find Minimal Failing Cases

Proptest automatically shrinks failing inputs to find the simplest case that still fails. Understand shrinking to debug property test failures effectively.

**Incorrect (manually debugging complex failing input):**

```rust
proptest! {
    #[test]
    fn parse_roundtrips(s in ".*") {
        let parsed = parse(&s)?;
        let serialized = serialize(&parsed);
        prop_assert_eq!(s, serialized);
    }
}

// Failure output: 500-character random string
// Developer: "What part of this causes the failure?"
// Must manually bisect the input to find the issue
```

**Correct (let proptest shrink to minimal case):**

```rust
proptest! {
    #[test]
    fn parse_roundtrips(s in ".*") {
        let parsed = parse(&s)?;
        let serialized = serialize(&parsed);
        prop_assert_eq!(s, serialized);
    }
}

// Proptest output after shrinking:
// minimal failing input: s = "\t"
// Now it's clear: tab character handling is broken!
```

**Customize shrinking for domain types:**

```rust
use proptest::prelude::*;

fn valid_order() -> impl Strategy<Value = Order> {
    (1u32..1000, valid_price(), valid_email())
        .prop_map(|(qty, price, email)| Order::new(qty, price, &email).unwrap())
        .prop_filter("order total > 0", |o| o.total() > Decimal::ZERO)
}
```

**Persist failing cases for regression testing:**

```toml
# proptest.toml in crate root
[cases]
count = 1000

[failure_persistence]
file = "proptest-regressions/.regressions"
```

**Debug verbose shrinking:**

```rust
proptest! {
    #![proptest_config(ProptestConfig {
        verbose: 1,
        max_shrink_iters: 100,
        ..Default::default()
    })]

    #[test]
    fn complex_property(input in complex_strategy()) {
        prop_assert!(check(&input));
    }
}
```

**Benefits of shrinking:**
- 500-char failing string → single problematic character
- Complex nested struct → minimal fields needed to reproduce
- Large array → smallest array that fails

Reference: [proptest - Shrinking](https://proptest-rs.github.io/proptest/proptest/tutorial/shrinking.html)
