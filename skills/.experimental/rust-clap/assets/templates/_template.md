---
title: Rule Title Here
impact: CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM|LOW
impactDescription: quantified impact, e.g., "2-10× improvement", "prevents runtime errors"
tags: category-prefix, technique, related-concepts
---

## Rule Title Here

Brief explanation (1-3 sentences) of WHY this pattern matters. Focus on the problem it solves and the impact of getting it wrong.

**Incorrect (what's wrong):**

```rust
// Bad example with comments explaining the cost
fn example() {
    // This causes [problem]
}
```

**Correct (what's right):**

```rust
// Good example with minimal diff from incorrect
fn example() {
    // This achieves [benefit]
}
```

**When NOT to use this pattern:**
- Exception 1
- Exception 2

**Benefits:**
- Benefit 1
- Benefit 2

Reference: [Reference Title](https://example.com)
