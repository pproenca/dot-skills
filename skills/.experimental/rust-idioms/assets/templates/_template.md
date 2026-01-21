---
title: Rule Title Here
impact: CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM|LOW
impactDescription: Quantified impact (e.g., "2-10× improvement", "prevents X bugs")
tags: category-prefix, technique1, technique2, tool-if-mentioned
---

## Rule Title Here

Brief explanation (1-3 sentences) of WHY this matters. Focus on the performance, safety, or maintainability implications.

**Incorrect (what's wrong with this approach):**

```rust
// Production-realistic bad code example
// Include comments on key lines explaining the cost/problem
fn example_bad() {
    // This causes X problem
}
```

**Correct (what's right about this approach):**

```rust
// Production-realistic good code example
// Minimal diff from incorrect - same variable names, structure
fn example_good() {
    // This solves the problem
}
```

**Alternative (when to use this variant):**

```rust
// Optional alternative approach
// Include when there are multiple valid solutions
```

**When NOT to use this pattern:**
- Exception case 1
- Exception case 2

**Benefits:**
- Benefit 1
- Benefit 2

Reference: [Reference Title](https://reference-url.com)
