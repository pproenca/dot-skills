---
title: {Rule Title}
impact: {CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM|LOW}
impactDescription: {Quantified impact, e.g., "prevents per-render allocation", "2-10x improvement", "maintains 60fps"}
tags: {category-prefix}, {technique}, {related-concepts}
---

## {Rule Title}

{1-3 sentences explaining WHY this matters for the Expo / React Native design system — what
drift, re-render, or native-feel problem occurs without this pattern. Explain the reasoning so
the model can generalize, rather than dictating a rule.}

**Incorrect ({specific problem}):**

```typescript
{Bad code — production-realistic, clinic-domain names (Patient, Appointment, TreatmentNote)}
{// Comments explaining the cost}
```

**Correct ({specific benefit}):**

```typescript
{Good code — minimal diff from incorrect, using Unistyles StyleSheet and theme tokens}
{// Comments explaining the benefit}
```

{Optional sections as needed:}

**When NOT to use this pattern:**
- {Exception 1}
- {Exception 2}

**Benefits:**
- {Benefit 1}
- {Benefit 2}

Reference: [{Reference Title}]({Reference URL})
