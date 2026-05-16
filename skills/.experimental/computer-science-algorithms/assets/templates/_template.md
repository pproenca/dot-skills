---
title: {Imperative Title — "Use X for Y", "Avoid Z", "Verb Object in Context"}
impact: {CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM|LOW}
impactDescription: {Quantified: "O(n²) to O(n log n)", "prevents stack overflow", "10-100x"}
tags: {category-prefix}, {technique}, {data-structure-or-algorithm-name}, {related-concept}
---

## {Title}

{1-3 sentences explaining WHY this matters. What is the cascade — what other code pays the cost? What goes wrong without this pattern? Quantify where possible. This is the highest-signal part of the rule.}

**Incorrect ({short problem label}):**

```python
{Production-realistic bad code. Not a strawman — show the version someone might actually write.}
{# Comments explaining the cost / where the bug bites.}
```

**Correct ({short solution label}):**

```python
{Good code — minimal diff from incorrect.}
{# Comments explaining the benefit.}
```

{Optional sections — use only if they add signal:}

**Alternative ({when relevant}):**

```python
{Different valid approach with its own tradeoffs.}
```

**When NOT to use this pattern:**

- {Specific scenario}
- {Specific scenario}

**Language equivalents:**

- Python: `...`
- C++: `...`
- Java: `...`

Reference: [{Source Title}]({URL})
