---
title: Assert Collection Contents Not Just Length
impact: MEDIUM
impactDescription: catches wrong element bugs
tags: assert, collections, contents, ordering, completeness
---

## Assert Collection Contents Not Just Length

Assert specific collection contents, not just length. Length-only checks pass when collections contain wrong elements.

**Incorrect (only checking length):**

```rust
#[test]
fn test_fetch_users() {
    let users = fetch_active_users();

    assert_eq!(users.len(), 3);  // Passes even if wrong users!
}

#[test]
fn test_filter_orders() {
    let orders = filter_pending_orders(all_orders);

    assert!(!orders.is_empty());  // What orders are included?
}
```

**Correct (verify actual contents):**

```rust
#[test]
fn test_fetch_users() {
    let users = fetch_active_users();

    assert_eq!(users.len(), 3);
    assert!(users.iter().any(|u| u.email == "alice@example.com"));
    assert!(users.iter().any(|u| u.email == "bob@example.com"));
    assert!(users.iter().any(|u| u.email == "carol@example.com"));
}

#[test]
fn test_filter_orders_contents() {
    let orders = filter_pending_orders(all_orders);

    let order_ids: Vec<_> = orders.iter().map(|o| o.id).collect();
    assert_eq!(order_ids, vec![101, 102, 103]);
}
```

**Order-independent comparison:**

```rust
use std::collections::HashSet;

#[test]
fn test_unique_tags() {
    let tags = extract_tags(document);

    let expected: HashSet<_> = ["rust", "testing", "tutorial"].into_iter().collect();
    let actual: HashSet<_> = tags.iter().map(|s| s.as_str()).collect();

    assert_eq!(actual, expected, "Tags don't match");
}

// Or sort both for comparison
#[test]
fn test_sorted_comparison() {
    let mut result = get_names();
    let mut expected = vec!["Alice", "Bob", "Carol"];

    result.sort();
    expected.sort();

    assert_eq!(result, expected);
}
```

**Asserting partial contents:**

```rust
#[test]
fn test_results_contain_expected() {
    let results = search("rust testing");

    // Must contain these (order doesn't matter)
    let required = ["unit tests", "integration tests"];
    for term in required {
        assert!(
            results.iter().any(|r| r.title.contains(term)),
            "Results should contain '{}': {:?}",
            term,
            results.iter().map(|r| &r.title).collect::<Vec<_>>()
        );
    }

    // Must not contain these
    assert!(
        results.iter().all(|r| !r.title.contains("deprecated")),
        "Results should not contain deprecated items"
    );
}
```

**Asserting collection properties:**

```rust
#[test]
fn test_sorted_output() {
    let result = sort_users_by_name(users);

    // Verify sorted property
    for window in result.windows(2) {
        assert!(
            window[0].name <= window[1].name,
            "Not sorted: {:?} should come before {:?}",
            window[0],
            window[1]
        );
    }
}

#[test]
fn test_unique_ids() {
    let items = generate_items(100);
    let ids: HashSet<_> = items.iter().map(|i| i.id).collect();

    assert_eq!(ids.len(), items.len(), "IDs should be unique");
}
```

Reference: [Rust Collections](https://doc.rust-lang.org/std/collections/)
