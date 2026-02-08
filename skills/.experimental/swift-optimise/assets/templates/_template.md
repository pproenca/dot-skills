---
title: Rule Title Here
impact: MEDIUM
impactDescription: Quantified impact (e.g., "2-10× improvement", "prevents memory leaks")
tags: prefix, keyword1, keyword2
---

## Rule Title Here

Brief explanation of WHY this matters and the performance/quality implications. Keep to 1-3 sentences.

**Incorrect (description of the problem/cost):**

```swift
// Production-realistic bad code example
// Include comment explaining the consequence
struct ExampleView: View {
    var body: some View {
        Text("Example")
    }
}
```

**Correct (description of the benefit/solution):**

```swift
// Production-realistic good code example
// Minimal diff from incorrect version
struct ExampleView: View {
    var body: some View {
        Text("Example")
    }
}
```

**Alternative (when to use this approach):**

```swift
// Optional: alternative approach for different contexts
```

**When NOT to use this pattern:**
- Exception case 1
- Exception case 2

Reference: [Documentation Title](https://example.com)
