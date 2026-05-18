---
title: {Imperative Title — "Use X for Y", "Avoid Z", "Verb Object in Context"}
impact: {CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM|LOW}
impactDescription: {Quantified: "10-100x throughput", "O(N) memory to O(chunk)", "prevents OOM"}
tags: {category-prefix}, {technique}, {tool-or-library}, {related-concept}
---

## {Title}

{1-3 sentences explaining WHY this matters on a constrained box. What is the cascade — which downstream stage pays the cost? What goes wrong without this pattern (OOM, syscall storm, full table scan, defeated readahead)? Quantify where possible. This is the highest-signal part of the rule — the model generalizes from understood reasoning, not from dictation.}

**Incorrect ({short problem label}):**

```python
{Production-realistic bad code. Not a strawman — show the version someone might actually write.}
{# Comments explaining the cost / where it breaks under scale.}
```

**Correct ({short solution label}):**

```python
{Good code — minimal diff from incorrect.}
{# Comments explaining the benefit / what's now bounded or amortized.}
```

{Optional sections — use only if they add signal:}

**With {library/engine} ({context}):**

```python
{Alternative using Polars / Arrow / DuckDB / asyncio — when the workflow benefits.}
```

**When NOT to use this pattern:**

- {Specific scenario where the pattern is inappropriate}
- {Edge case where the simpler approach is correct}

**Sizing / tuning reference (when relevant):**

| Workload | Setting | Reason |
|---|---|---|
| {workload} | {value} | {why} |

**Verification (how to measure the win):**

```bash
{# Command that demonstrates the improvement — strace, time, py-spy, iostat, etc.}
```

Reference: [{Source Title}]({URL})
