---
title: {Action-Oriented Title}
impact: CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM|LOW
impactDescription: {quantified or "prevents {problem}" impact — e.g. "O(n) to O(1)", "prevents border false negatives"}
tags: {prefix}, {technique-1}, {technique-2}, {concept}
---

## {Title}

{1-3 sentences explaining WHY this matters — what breaks without it, what cascade effect it
has, and what the model should generalise from. Teach the reasoning, not just the rule. For
the map-/nav- application rules, state plainly when the pattern is overkill.}

**Incorrect ({problem label}):**

```typescript
// Production-realistic anti-pattern. Comment explains the cost.
// (Use ```rust for the encoding/neighbour/indexing rules where Rust idioms matter.)
```

**Correct ({solution label}):**

```typescript
// Minimal diff from the incorrect example. Comment explains the benefit.
```

**When NOT to apply:**
- {Realistic exception 1}
- {Realistic exception 2}

Reference: [{Title}]({URL})
