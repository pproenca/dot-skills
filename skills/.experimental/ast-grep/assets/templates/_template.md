---
title: Rule Title in Imperative Form
impact: CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM|LOW
impactDescription: quantified impact (e.g., "prevents silent failures")
tags: category-prefix, technique, related-concepts
---

## Rule Title in Imperative Form

Brief explanation (1-3 sentences) of WHY this matters. Focus on the problem being solved and its impact.

**Incorrect (description of the problem):**

```yaml
id: example-rule
language: javascript
rule:
  pattern: bad_pattern($ARG)
# Comment explaining the cost/problem
```

**Correct (description of the solution):**

```yaml
id: example-rule
language: javascript
rule:
  pattern: good_pattern($ARG)
# Comment explaining the benefit
```

**When NOT to use this pattern:**
- Exception 1
- Exception 2

**Benefits:**
- Benefit 1
- Benefit 2

Reference: [Reference Title](https://ast-grep.github.io/relevant-page.html)
