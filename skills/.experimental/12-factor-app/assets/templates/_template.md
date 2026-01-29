---
title: {Rule Title}
impact: {CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM|LOW}
impactDescription: {Quantified impact, e.g., "enables horizontal scaling", "prevents config drift"}
tags: {category-prefix}, {technique}, {related-concepts}
---

## {Rule Title}

{1-3 sentences explaining WHY this matters for cloud-native applications. Focus on scalability, portability, or operational implications.}

**Incorrect ({what's wrong}):**

```{language}
{Bad code example - production-realistic, not strawman}
{# Comments explaining the cost or problem}
```

**Correct ({what's right}):**

```{language}
{Good code example - minimal diff from incorrect}
{# Comments explaining the benefit}
```

{Optional sections as needed:}

**Alternative ({context}):**

```{language}
{Alternative approach when applicable}
```

**When NOT to use this pattern:**
- {Exception 1}
- {Exception 2}

**Benefits:**
- {Benefit 1}
- {Benefit 2}

Reference: [The Twelve-Factor App](https://12factor.net/)
