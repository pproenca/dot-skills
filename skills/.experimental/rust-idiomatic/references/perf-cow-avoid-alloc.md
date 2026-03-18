---
title: Use Cow to Avoid Unnecessary Allocations
impact: LOW-MEDIUM
impactDescription: 0 allocations on 90%+ of calls vs 1 allocation per call
tags: perf, cow, allocation, hot-path, display
---

## Use Cow to Avoid Unnecessary Allocations

Use `Cow<'_, str>` in hot-path functions where most inputs pass through unchanged but some require transformation. Unlike the ownership-focused `own-cow-conditional` rule, this applies to throughput-sensitive display and formatting paths where every allocation counts.

**Incorrect (allocates on every call, even when input is unchanged):**

```rust
fn escape_html(input: &str) -> String {
    let mut output = String::with_capacity(input.len());
    for ch in input.chars() {
        match ch {
            '<' => output.push_str("&lt;"),
            '>' => output.push_str("&gt;"),
            '&' => output.push_str("&amp;"),
            _ => output.push(ch),
        }
    }
    output
}
// Allocates even for "hello world" with no special chars
```

**Correct (borrows when no escaping needed, allocates only on special chars):**

```rust
use std::borrow::Cow;

fn escape_html(input: &str) -> Cow<'_, str> {
    if input.contains(['<', '>', '&']) {
        let mut output = String::with_capacity(input.len());
        for ch in input.chars() {
            match ch {
                '<' => output.push_str("&lt;"),
                '>' => output.push_str("&gt;"),
                '&' => output.push_str("&amp;"),
                _ => output.push(ch),
            }
        }
        Cow::Owned(output)
    } else {
        Cow::Borrowed(input)
    }
}
```
