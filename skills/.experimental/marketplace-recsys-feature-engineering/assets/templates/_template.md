---
title: {Action-Oriented Rule Title}
impact: CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM|LOW
impactDescription: {quantified, e.g. "prevents 30% of requests ending in rejection" or "2-10x improvement"}
tags: {category-prefix}, {technique}, {tool-or-concept}, {related-feature-type}
---

## {Rule Title}

{1-3 sentences explaining WHY this matters in the context of marketplace
recsys feature engineering — what goes wrong without this pattern, what
the cascade effect is on downstream i2i/u2i/u2u systems, and what the
concrete consequence looks like in production. Focus on reasoning the
model can generalise, not rigid dictation.}

**Incorrect ({what is wrong}):**

```python
# production-realistic code showing the problem
# comment explaining the specific cost
def example_bad():
    ...
```

**Correct ({what is right}):**

```python
# production-realistic code showing the fix
# minimal diff from the incorrect example — only the key insight changes
# comment explaining the specific benefit
def example_good():
    ...
```

{Optional sections as needed:}

**Alternative ({context}):**
{Alternative approach when applicable}

**When NOT to use this pattern:**
- {Exception 1}
- {Exception 2}

Reference: [{Title}]({URL})
