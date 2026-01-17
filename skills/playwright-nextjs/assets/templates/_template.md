---
title: {Rule Title}
impact: {CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM|LOW}
impactDescription: {Quantified impact, e.g., "2-10× improvement", "80% reduction in flakiness"}
tags: {prefix}, {technique}, {tool-if-mentioned}, {related-concepts}
---

## {Rule Title}

{1-3 sentences explaining WHY this matters. Focus on testing implications and reliability.}

**Incorrect ({what's wrong}):**

```typescript
// tests/example.spec.ts
test('example test', async ({ page }) => {
  // Bad code example - production-realistic, not strawman
  // Comments explaining the problem
});
```

**Correct ({what's right}):**

```typescript
// tests/example.spec.ts
test('example test', async ({ page }) => {
  // Good code example - minimal diff from incorrect
  // Comments explaining the benefit
});
```

{Optional sections as needed:}

**Alternative ({context}):**
{Alternative approach when applicable}

**When NOT to use this pattern:**
- {Exception 1}
- {Exception 2}

**Benefits:**
- {Benefit 1}
- {Benefit 2}

Reference: [{Reference Title}]({Reference URL})
