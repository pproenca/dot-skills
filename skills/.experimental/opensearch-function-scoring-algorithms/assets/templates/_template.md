---
title: Rule Title in Imperative Mood
impact: CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM|LOW
impactDescription: quantified impact (e.g., "5-15% NDCG@10 lift", "prevents X")
tags: prefix, technique, concept, tool
---

## Rule Title in Imperative Mood

Brief explanation (1-3 sentences) of WHY this matters in a marketplace ranking context. Focus on the cascade effect — what goes wrong downstream when this rule is violated, and which property (recall, base relevance, fairness, bias) is being protected. Cite the underlying mechanism or paper at the level of intuition; details go below.

**Incorrect (concrete description of the wrong pattern):**

```json
{
  "query": {
    "bad_example_query": "..."
  }
}
```

Brief one-line annotation about what's wrong above (e.g., "applies popularity boost to all 200k matches").

**Correct (concrete description of the right pattern):**

```json
{
  "query": {
    "good_example_query": "..."
  }
}
```

Brief one-line annotation about why this works (e.g., "rescore phase applies popularity only to top-500").

**Optional sections (include when applicable):**

**Why this matters at marketplace scale:** Deeper explanation tying the rule to two-sided dynamics, scale economics, or training-data hygiene.

**Calibration / Tuning:** Table or recipe for picking parameters.

| Parameter | When | Default |
|-----------|------|---------|
| ... | ... | ... |

**When NOT to use this pattern:** Important exceptions (e.g., "don't apply MMR diversity to specific-intent queries").

**Warning (gotcha):** A subtle failure mode worth calling out.

Reference: [Primary source title](https://primary-source-url) · [Secondary source title](https://secondary-source-url)
