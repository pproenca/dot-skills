---
title: {Action-Oriented Title — imperative verb + object + optional context}
impact: {CRITICAL | HIGH | MEDIUM-HIGH | MEDIUM | LOW-MEDIUM | LOW}
impactDescription: {Quantified: "O(n²) to O(n)", "100× speedup at n=10,000", "prevents stack overflow"}
tags: {prefix}, {technique}, {tool-or-concept}, {related-pattern}
---

## {Title — mirror the frontmatter title}

{1-3 sentences explaining WHY the anti-pattern is bad. Focus on the cascade effect:
what scales wrong, how the cost grows with input, why it's easy to miss at the call site.
The model generalizes from understood reasoning, not from dictation — explain the mechanism,
not just the rule.}

**Incorrect ({short label, e.g., "linear scan per iteration"}):**

```{language}
{Production-realistic bad code — not a strawman}
{// Comments quantify the cost: "10,000 × 50,000 = 500M comparisons"}
```

**Correct ({short label, e.g., "hash lookup"}):**

```{language}
{Minimal-diff fix — should look like a small refactor of the incorrect version}
{// Comments explain why the new version is cheaper}
```

**Alternative ({context}):**

{Optional. Include only when there's a genuinely different valid approach for a different
situation — e.g., "when the data is sorted" or "when keys are non-hashable".}

```{language}
{Alternative implementation}
```

**When NOT to use this pattern:**

- {Specific exception with the input characteristics that make the rule wrong}
- {Another exception, ideally with measurable threshold ("when n < 30")}

Reference: [{Title of cited source}]({URL})

---

## Authoring Notes

When adding a new rule:

1. **Pick a prefix** from [`_sections.md`](../../references/_sections.md). The first tag MUST be the section prefix.
2. **Title in imperative form** — "Use", "Avoid", "Replace", "Cache", "Hoist".
3. **Quantify the impact** in `impactDescription`. Prefer Big-O class change (O(n²) to O(n))
   over vague "much faster". Add a concrete factor (e.g., "100× at n=10,000") when possible.
4. **Incorrect ≠ strawman** — write code that looks plausible, the kind of thing a competent
   engineer would write without thinking about complexity.
5. **Correct = minimal diff** — the goal is for the reader to see exactly which lines change.
6. **Add a "When NOT to use" section** for any rule with non-trivial exceptions. Rules without
   exceptions are rare; explicit exceptions make the model apply the rule with judgment.
7. **Reference an authoritative source** — primary docs (Python TimeComplexity, MDN, cppreference,
   NIST DADS), engineering blogs with benchmarks (V8 blog, web.dev), or canonical textbooks
   (CLRS, Sedgewick). Avoid tutorial sites and undated personal blogs.
