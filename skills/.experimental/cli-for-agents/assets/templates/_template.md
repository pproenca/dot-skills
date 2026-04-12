---
title: {Action-oriented title starting with an imperative verb}
impact: CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM|LOW
impactDescription: {quantified impact: "prevents X", "reduces Y by N%", "O(a) to O(b)"}
tags: {prefix}, {technique}, {tool-if-any}, {related-concept}
---

## {Rule title matching the frontmatter title}

{1-3 sentences explaining WHY this matters in terms of agent behavior. What goes wrong
without the rule? What cascade effect does the failure have on agent workflows? Name
the specific failure mode, not just "it's bad practice." The reader should be able to
predict what happens in an edge case even though this rule doesn't explicitly cover it.}

**Incorrect ({short label of the problem}):**

```{language}
{Production-realistic code that uses a real CLI framework (commander, click, clap,
cobra, etc.). Not strawman — a developer could write this in good faith. Keep it
under 30 lines. Use comments sparingly to point out the cost.}
```

**Correct ({short label of the solution}):**

```{language}
{Minimal-diff correct version. Same variable names, same structure, only the key
insight changes. The reader should be able to diff incorrect vs correct in their
head. Keep it under 30 lines.}
```

{Optional sections below, use only when genuinely needed:}

**Benefits:**
- {Observable benefit agents or operators will see}
- {Observable benefit agents or operators will see}

**When NOT to use this pattern:**
- {Exception with a concrete scenario, not "it depends"}

**Alternative ({short context label}):**

```{language}
{Another valid approach, e.g. different library or language idiom}
```

Reference: [{Source title}]({https://source-url})
