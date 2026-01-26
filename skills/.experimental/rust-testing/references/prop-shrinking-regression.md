---
title: Commit proptest Regression Files
impact: MEDIUM
impactDescription: preserves discovered edge cases permanently
tags: prop, proptest, shrinking, regression, git
---

## Commit proptest Regression Files

Commit `proptest-regressions/` files to version control. These files preserve failing cases that proptest discovered and shrunk, preventing regression.

**Incorrect (ignoring regression files):**

```gitignore
# .gitignore
proptest-regressions/
*.proptest-regressions
```

```text
Developer A runs tests, discovers a bug
proptest shrinks input to minimal reproducer
proptest-regressions/my_tests.txt created
Developer A fixes bug but doesn't commit regression file
Developer B later reintroduces bug
CI doesn't catch it because regression file is missing
```

**Correct (committing regression files):**

```bash
# Don't ignore proptest regressions
git add proptest-regressions/

# Commit with context
git commit -m "Add regression test for order validation edge case"
```

```rust
// proptest-regressions/order_tests.txt contents:
// cc 0xe3a42f1c # shrunk from much larger input
// cc 0x00000001
// cc 0x00000000

// Future test runs replay these cases first
proptest! {
    #[test]
    fn order_validation_handles_edge_cases(order in arb_order()) {
        // Regression cases run automatically before random cases
        let result = validate_order(&order);
        prop_assert!(result.is_ok() || result.unwrap_err().is_recoverable());
    }
}
```

**Directory structure:**

```text
project/
├── src/
├── tests/
└── proptest-regressions/
    ├── order_tests.txt
    └── parser_tests.txt
```

**Benefits:**
- Discovered bugs become permanent test cases
- Minimal reproducers are preserved
- CI catches regressions immediately

Reference: [proptest - Failure Persistence](https://docs.rs/proptest/latest/proptest/#failure-persistence)
