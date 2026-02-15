---
title: {Rule Title}
impact: {CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM|LOW}
impactDescription: {Quantified impact, e.g., "2-10x improvement", "200ms savings"}
tags: {category-prefix}, {technique}, {related-concepts}
---

## {Rule Title}

{1-3 sentences explaining WHY this matters. Focus on build time, image size, security, or robustness implications.}

**Incorrect ({what's wrong}):**

```dockerfile
{Bad Dockerfile example - production-realistic, not strawman}
# Comments explaining the cost
```

**Correct ({what's right}):**

```dockerfile
{Good Dockerfile example - minimal diff from incorrect}
# Comments explaining the benefit
```

{Optional sections as needed:}

**Alternative ({context}):**

```dockerfile
{Alternative approach when applicable}
```

**When NOT to use this pattern:**
- {Exception 1}
- {Exception 2}

**Benefits:**
- {Benefit 1}
- {Benefit 2}

Reference: [{Reference Title}]({Reference URL})
