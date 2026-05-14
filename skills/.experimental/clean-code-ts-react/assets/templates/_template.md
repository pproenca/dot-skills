---
title: Rule Title Here
impact: MEDIUM
impactDescription: description of impact (e.g., "eliminates confusion on every read")
tags: category-prefix, keyword1, keyword2
---

## Rule Title Here

Brief explanation (1-3 sentences) of WHY this matters. Focus on the principle and its impact on cognitive cost, change locality, or invariant preservation — not on rote rules. The model should be able to apply the principle in novel situations.

**Incorrect (description of what's wrong):**

```tsx
// Modern TS+React example showing the anti-pattern.
// Comment explaining the cost (what the reader/modifier has to do extra).
```

**Correct (description of what's right):**

```tsx
// Same code, minimal diff, showing the principle applied.
// Comment explaining the benefit (what the reader/modifier saves).
```

**When NOT to apply this pattern:**
- Concrete scenario where the principle is rightly bent (not a generic disclaimer).
- Second concrete scenario, ideally one that highlights a known tension with another principle.

**Why this matters:** One line tying the rule back to the underlying principle (cognitive load, change locality, invariant preservation, etc.) — what the rule is *really* about.

Reference: [Clean Code, Chapter N: Topic](https://www.oreilly.com/library/view/clean-code-a/9780136083238/) — and a modern counter-source where the original advice is contested (e.g., [Ousterhout, *A Philosophy of Software Design*](https://web.stanford.edu/~ouster/cgi-bin/aposd.php)).
