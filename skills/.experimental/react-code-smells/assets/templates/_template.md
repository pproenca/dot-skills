---
title: {Rule Title}
impact: {CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM|LOW}
impactDescription: {Quantified impact, e.g., "eliminates sync bugs", "reduces complexity by 40%"}
tags: {category-prefix}, {technique}, {related-concepts}
---

## {Rule Title}

{1-3 sentences explaining WHY this matters. Focus on maintainability, debugging, and architectural implications.}

**Code Smell Indicators:**
- {Symptom 1 that suggests this refactoring is needed}
- {Symptom 2}
- {Symptom 3}

**Incorrect ({what's wrong}):**

```tsx
{Bad code example - production-realistic, not strawman}
{// Comments explaining the cost/problem}
```

**Correct ({what's right}):**

```tsx
{Good code example - minimal diff from incorrect}
{// Comments explaining the benefit}
```

{Optional sections as needed:}

**Alternative ({context}):**
{Alternative approach when applicable}

**When NOT to refactor:**
- {Exception 1 - when the smell is actually OK}
- {Exception 2}

**Safe transformation steps:**
1. {Step 1}
2. {Step 2}
3. {Step 3}

**Principal engineer judgment:**
{Guidelines for when to apply vs when to skip this refactoring}

Reference: [{Reference Title}]({Reference URL})
