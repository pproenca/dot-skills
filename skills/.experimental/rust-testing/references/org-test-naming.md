---
title: Name Tests After Behavior Not Implementation
impact: HIGH
impactDescription: improves test discoverability and maintenance
tags: org, naming, readability, maintenance
---

## Name Tests After Behavior Not Implementation

Name tests to describe what behavior is being verified, not implementation details. Use descriptive names that explain the scenario and expected outcome.

**Incorrect (implementation-focused names):**

```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_parse() {
        // What does "parse" mean? Parse what?
    }

    #[test]
    fn test_issue_1234() {
        // What behavior does this verify?
    }

    #[test]
    fn test_user_struct() {
        // Testing a struct doesn't describe behavior
    }

    #[test]
    fn test_validate_email_regex() {
        // Describes implementation (regex), not behavior
    }
}
```

**Correct (behavior-focused names):**

```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parse_returns_none_for_empty_input() {
        let result = parse("");
        assert!(result.is_none());
    }

    #[test]
    fn parse_extracts_title_from_header() {
        let result = parse("Title: Hello World").unwrap();
        assert_eq!(result.title, "Hello World");
    }

    #[test]
    fn user_email_rejects_missing_at_symbol() {
        let result = User::new("invalid-email", "Test");
        assert!(result.is_err());
    }

    #[test]
    fn user_email_accepts_valid_format() {
        let result = User::new("valid@example.com", "Test");
        assert!(result.is_ok());
    }

    #[test]
    fn discount_applies_to_orders_over_100() {
        // Regression test for issue #1234
        let order = Order::new(150.0);
        assert_eq!(order.discount(), 15.0);
    }
}
```

**Naming patterns:**

| Pattern | Example |
|---------|---------|
| `{action}_returns_{result}_for_{condition}` | `parse_returns_none_for_empty_input` |
| `{subject}_{verb}_{expected_behavior}` | `user_email_rejects_missing_at_symbol` |
| `{scenario}_when_{condition}` | `checkout_fails_when_cart_is_empty` |

**Benefits:**
- Test failures immediately describe what broke
- Tests serve as documentation for behavior
- Easy to find tests for specific functionality

Reference: [Rust Compiler Dev Guide - Test Best Practices](https://rustc-dev-guide.rust-lang.org/tests/best-practices.html)
