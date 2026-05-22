---
title: {Imperative title — must equal the H2 below, e.g. "Cache Visible Tiles Between Frames"}
impact: {CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM|LOW}
impactDescription: {Quantified or verb-led, e.g. "O(n) to O(1)", "prevents per-frame recompute", "reduces GC pauses"}
tags: {prefix}, {technique}, {concept}, {tool-if-any}
---

## {Imperative title — identical to the title above}

{1-3 sentences on WHY this matters: what goes wrong without the pattern and how the cost
cascades across cells, viewers, or frames. The model generalizes from the reasoning, so
explain the failure mode in concrete terms — do not just say "use X".}

**Incorrect ({non-vague label of the problem}):**

```typescript
// Production-realistic anti-pattern, not a strawman.
// Comment the cost (per-cell allocation, per-frame recompute, cache miss, etc.).
```

**Correct ({non-vague label of the fix}):**

```typescript
// Minimal diff from the incorrect version.
// Comment the benefit.
```

{Optional sections, include only what helps:}

**When NOT to use this pattern:**
- {Exception with the reason}

**Benefits:**
- {Concrete advantage}

**Warning ({context}):**
- {Gotcha to avoid}

Reference: [{Source title}]({https URL})

<!--
Authoring notes (delete before saving):
- The first tag MUST equal the file/category prefix (fov, update, state, render, mem, scale, geo, correct).
- Title must start with a capitalized imperative verb followed by a space (no acronym or hyphenated first word).
- Use a non-vague parenthetical after Incorrect/Correct (avoid bad/good/wrong/right/better/worse).
- Code fences must declare a letter-only language (typescript, tsx, json) at column 0.
- Keep examples type-correct under `tsc --strict`. Reuse the shared model: a flat Uint8Array
  fog buffer with VISIBLE/EXPLORED/OPAQUE bit flags, indexed by y*width+x.
-->
