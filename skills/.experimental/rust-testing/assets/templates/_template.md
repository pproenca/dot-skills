---
title: Rule Title Here
impact: MEDIUM
impactDescription: quantified impact (e.g., "2-10× improvement", "prevents flaky tests")
tags: prefix, technique, tool, related-concept
---

## Rule Title Here

Brief explanation (1-3 sentences) of WHY this matters for testing. Focus on the testing implications and what problems it prevents.

**Incorrect (description of what's wrong):**

```rust
// Bad code example - production-realistic, not strawman
fn problematic_test() {
    // Comment explaining the cost/problem
}
```

**Correct (description of what's right):**

```rust
// Good code example - minimal diff from incorrect
fn improved_test() {
    // Comment explaining the benefit
}
```

**When NOT to use this pattern:**
- Exception 1
- Exception 2

**Benefits:**
- Benefit 1
- Benefit 2

Reference: [Reference Title](https://example.com)
