---
title: Rule Title Here
impact: MEDIUM
impactDescription: Quantified impact (e.g., "2-10× improvement", "O(n) to O(1)")
tags: prefix, technique, related-concepts
---

## Rule Title Here

Brief explanation (1-3 sentences) of why this pattern matters for performance. Focus on the performance implications, not just what the code does.

**Incorrect (description of what's wrong):**

```rust
// Code example showing the anti-pattern
// Comments should explain the cost, not describe the syntax
fn example() {
    // This causes N allocations
}
```

**Correct (description of what's right):**

```rust
// Code example showing the correct pattern
// Comments should explain the benefit
fn example() {
    // Single allocation
}
```

**When NOT to use this pattern:**
- Exception 1
- Exception 2

Reference: [Source Title](https://example.com)
