---
title: Use rstest case for Parameterized Tests
impact: MEDIUM
impactDescription: tests multiple inputs without code duplication
tags: fix, rstest, parameterized, case, table-driven
---

## Use rstest case for Parameterized Tests

Use `#[case]` to run the same test with different inputs. This creates separate test functions for each case, with clear names in test output.

**Incorrect (duplicated test functions):**

```rust
#[test]
fn test_parse_positive() {
    assert_eq!(parse_int("42"), Ok(42));
}

#[test]
fn test_parse_negative() {
    assert_eq!(parse_int("-17"), Ok(-17));
}

#[test]
fn test_parse_zero() {
    assert_eq!(parse_int("0"), Ok(0));
}

#[test]
fn test_parse_with_whitespace() {
    assert_eq!(parse_int("  123  "), Ok(123));
}
// Lots of repetition!
```

**Correct (parameterized with rstest):**

```rust
use rstest::rstest;

#[rstest]
#[case("42", 42)]
#[case("-17", -17)]
#[case("0", 0)]
#[case("  123  ", 123)]
#[case("+99", 99)]
fn test_parse_valid_integers(#[case] input: &str, #[case] expected: i32) {
    assert_eq!(parse_int(input), Ok(expected));
}

#[rstest]
#[case("")]
#[case("abc")]
#[case("12.34")]
#[case("99999999999999999999")]
fn test_parse_invalid_integers(#[case] input: &str) {
    assert!(parse_int(input).is_err());
}
```

**Output shows individual test names:**

```text
test test_parse_valid_integers::case_1_42 ... ok
test test_parse_valid_integers::case_2_-17 ... ok
test test_parse_valid_integers::case_3_0 ... ok
```

**Complex cases with tuples:**

```rust
#[rstest]
#[case(Order::new(1, 10.0), 10.0)]
#[case(Order::new(5, 10.0), 50.0)]
#[case(Order::new(10, 10.0), 95.0)]  // 5% discount for 10+ items
fn test_order_total(#[case] order: Order, #[case] expected_total: f64) {
    assert_eq!(order.total(), expected_total);
}
```

**Combining fixtures and cases:**

```rust
#[fixture]
fn calculator() -> Calculator {
    Calculator::new()
}

#[rstest]
#[case(2, 3, 5)]
#[case(0, 0, 0)]
#[case(-1, 1, 0)]
fn test_add(calculator: Calculator, #[case] a: i32, #[case] b: i32, #[case] expected: i32) {
    assert_eq!(calculator.add(a, b), expected);
}
```

Reference: [rstest - Parameterized Tests](https://docs.rs/rstest/latest/rstest/attr.rstest.html#test-parametrized-cases)
