---
title: Ladder categories CRITICAL setup, HIGH isolation, MEDIUM composition, LOW edge cases
tags: shape, categories, ladder
---

## Ladder categories CRITICAL setup, HIGH isolation, MEDIUM composition, LOW edge cases

By default the agent invents a fresh category taxonomy for every library-ref skill, picking names that mirror the library's own module structure (parser/schema/middleware/plugin). The resulting skills are unreadable as a group — a reader who knows one cannot navigate another. Across shipped library-ref skills in this repo the same **4-tier ladder appears under different names**. Pick category names that map onto the ladder; do not invent a new shape.

```text
The universal ladder, observed across nuqs, zod, react-hook-form,
effect-ts, and emilkowal-animations:

  Tier 1 — CRITICAL setup / correctness
    "What you must get right or nothing works."
    Examples by skill:
      nuqs              → parser-*, setup-*
      zod               → schema-*, parse-*
      react-hook-form   → formcfg-*, sub-*
      effect-ts         → getting-*, error-*, schema-*
      emilkowal         → ease-*, timing-*

  Tier 2 — HIGH isolation / performance
    "How to keep this from making your app slow or re-rendery."
    Examples:
      nuqs              → perf-*
      react-hook-form   → ctrl-*
      effect-ts         → conc-*, resource-*
      emilkowal         → props-*, interact-*

  Tier 3 — MEDIUM composition / integration
    "How this fits with other libraries and your stack."
    Examples:
      react-hook-form   → integ-*
      effect-ts         → req-*, plat-*
      zod               → compose-*, refine-*
      emilkowal         → tw-*

  Tier 4 — LOW edge cases / polish
    "Things you only need when you hit a sharp corner."
    Examples:
      nuqs              → debug-*, history-*
      effect-ts         → test-*, migration-*
      emilkowal         → polish-*, strategy-*
      zod               → error-*, object-*

The discriminator when picking a category name:
  Ask "which tier does this rule belong in?" before "what should I
  call this category?" If a rule does not fit any of the 4 tiers,
  treat the rule as mis-scoped (not the ladder) and re-scope it
  to one tier, or split it into two rules each fitting one tier.
```

The test: print the categories from your draft skill alongside the table above. If a reader who has used one of your other skills can immediately tell which category to read first, the ladder is honest. If they can't, you invented a shape — go back and re-name to the tiers.

Reference: [Empirical cross-skill table in the explore-agent trace of 5 library-ref skills](../_sections.md)
