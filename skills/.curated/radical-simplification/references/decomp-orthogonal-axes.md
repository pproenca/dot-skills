---
title: Decompose along axes that do not entangle
tags: decomp, orthogonality, design
---

## Decompose along axes that do not entangle

A decomposition is **correct** when changing one part does not force changes in another. By default the agent splits on convenience — file boundaries, team boundaries, the order things came up in the conversation — and the resulting parts share hidden state across the seams. The test: name a likely future change. If it touches more than one part, the axes are wrong.

```text
Feature-flag system.

Wrong axes (convenience):
  flags_for_free_users.ts
  flags_for_paid_users.ts
  flags_for_internal_users.ts

  Future change: "add an 'enterprise' tier" → touches three files,
  and any flag that crosses tiers (most of them) lives in all three.

Right axes (orthogonal):
  rollout.ts        → percentage, ramp, kill switch
  targeting.ts      → user attributes (tier, region, cohort)
  evaluation.ts     → bind(flag, user) → bool

  Future change: "add enterprise tier" → only targeting.ts. Adding
  a new ramp shape → only rollout.ts. The three parts move independently.
```

The axes are usually verbs (rollout, evaluation) and the wrong axes are usually nouns from the current data shape (free, paid, internal). Verbs survive schema changes; today's nouns rarely do.

If renaming the original noun exposes a structurally identical pattern from another domain, the cleaner move is [`transfer-cross-domain-analogue`](transfer-cross-domain-analogue.md); if the original noun itself is the cage, see [`transfer-suspect-vocabulary-lock-in`](transfer-suspect-vocabulary-lock-in.md).

Reference: [Parnas — On the Criteria To Be Used in Decomposing Systems into Modules (CACM, 1972)](https://dl.acm.org/doi/10.1145/361598.361623)
