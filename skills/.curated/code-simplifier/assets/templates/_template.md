---
title: {Rule Title}
impact: {CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM|LOW}
impactDescription: {Quantified impact, e.g., "reduces nesting by 40%", "prevents 90% of behavior changes"}
tags: {prefix}, {technique}, {related-concepts}
---

## {Rule Title}

{1-3 sentences explaining WHY this matters for code simplification. Focus on maintainability, readability, and behavior preservation.}

**Incorrect ({what's wrong}):**

```{language}
{Bad code example - production-realistic, not strawman}
{// Comments explaining the problem}
```

**Correct ({what's right}):**

```{language}
{Good code example - minimal diff from incorrect}
{// Comments explaining the benefit}
```

{Optional sections as needed:}

**Alternative ({context}):**

```{language}
{Alternative approach when applicable}
```

**When NOT to Apply:**

- {Exception 1 - when this rule doesn't apply}
- {Exception 2 - legitimate reasons to skip this rule}

**Benefits:**

- {Benefit 1 - specific, measurable improvement}
- {Benefit 2 - additional positive outcome}

Reference: [{Reference Title}]({Reference URL})
