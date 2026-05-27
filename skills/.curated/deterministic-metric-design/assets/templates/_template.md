---
title: {Action-Oriented Rule Title}
impact: {CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM|LOW}
impactDescription: {what the rule prevents or guarantees, stated concretely}
tags: {prefix}, {concept-1}, {concept-2}, {concept-3}
---

## {Action-Oriented Rule Title}

{1-3 sentences explaining WHY this matters for metric design — what goes wrong without it
and how that failure poisons the rest of the metric. This is the highest-signal part: the
model generalizes from understood reasoning, not from dictation. For this discipline, the
"failure" is usually that the metric becomes uncomputable, non-deterministic, invalid, or
gameable — say which, and why.}

**Incorrect ({the design flaw}):**

```python
# A realistic, badly-designed metric DEFINITION or computation (not a strawman).
# Annotate the exact flaw: uncomputable ideal, wrong scale, non-determinism, confound, etc.
```

**Correct ({the fix}):**

```python
# The fixed metric — minimal diff from the incorrect version, the key insight only.
# Annotate the property it now has: computable, sound-bounded, invariant, validated, gated.
```

{Optional sections, used when they add value:}

**When NOT to apply:**
- {Exception with its reasoning}

**Alternative ({context}):**
{A second valid approach and when to prefer it}

Reference: [{Authoritative source — primary literature, standards body, or maintainer docs}]({url})

<!--
Authoring notes (delete before committing):
- First tag MUST be the category prefix (def, comp, meas, prop, det, valid, game, agg).
- Examples are metric DEFINITIONS/procedures, not application code: the contrast is a
  badly-designed measure vs. the fixed one.
- Prefer primary sources (papers, standards, language docs). No tutorial sites or SO answers.
- Thread the running example (behavior-preserving codebase-size reduction) where it fits.
- Keep the incorrect→correct diff minimal so the key insight is unmistakable.
-->
