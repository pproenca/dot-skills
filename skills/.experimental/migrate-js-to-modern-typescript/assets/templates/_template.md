---
title: {Imperative Rule Title — starts with a verb, equals the H2 below}
impact: {CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM|LOW}
impactDescription: {Quantified or verb-led, e.g. "prevents undefined-index crashes", "eliminates implicit any"}
tags: {prefix}, {technique}, {related-concepts}
---

## {Imperative Rule Title — identical to the title above}

{1-3 sentences explaining WHY this matters for a JS-to-TS migration: what
untyped or unsafe pattern it removes, and what bug or churn it prevents
downstream. Explain the reasoning so the model generalizes, not just the rule.}

**Incorrect ({specific problem, not "bad"}):**

```typescript
{Production-realistic JavaScript or loosely-typed code being migrated.}
{// Comment naming the concrete cost — the unchecked access, the leaked any.}
```

**Correct ({specific fix, not "good"}):**

```typescript
{Modern, strict TypeScript — minimal diff from the incorrect version.}
{// Comment naming the concrete benefit.}
```

{Optional sections as needed:}

**Alternative ({context}):**

```typescript
{A second valid approach when one exists.}
```

**When NOT to use this pattern:**
- {Exception where the simpler/older form is genuinely better.}

Reference: [{Authoritative Source Title}]({Source URL})
