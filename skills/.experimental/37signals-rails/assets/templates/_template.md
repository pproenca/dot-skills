---
title: {Rule Title}
impact: {CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM|LOW}
impactDescription: {Quantified impact, e.g., "eliminates N+1 queries", "reduces controller size by 60%"}
tags: {prefix}, {technique}, {related-concepts}
---

## {Rule Title}

{1-3 sentences explaining WHY this matters. Focus on architectural or maintainability implications.}

**Incorrect ({what's wrong}):**

```ruby
{Bad code example - production-realistic, not strawman}
{# Comments explaining the cost}
```

**Correct ({what's right}):**

```ruby
{Good code example - minimal diff from incorrect}
{# Comments explaining the benefit}
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
