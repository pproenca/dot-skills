---
title: Bend the design rules only for two reasons, and document it
tags: anti, denormalization, tradeoffs
---

## Bend the design rules only for two reasons, and document it

The wrong default is to denormalize casually — to "add a field for the report" or "flatten a table so the query is faster" — as a routine optimization. Every time you break a design rule you introduce data-integrity problems: inconsistent data, redundant data, weakened table- and relationship-level integrity, and ultimately inaccurate information. The real question is never performance; it is whether the perceived speed-up is worth the loss of integrity.

There are only **two** defensible reasons to depart from proper design:

```text
1. You are building an ANALYTICAL database (historical, time-dependent, calculated
   and aggregated fields by nature). This needs a different methodology entirely —
   use a dedicated method for it, don't improvise on the operational schema.

2. PERFORMANCE — and only as a LAST resort. First exhaust the alternatives:
   upgrade hardware, tune the OS, review the schema for actual design flaws (poorly
   designed databases are themselves slow), review the implementation, review the
   queries and application. Denormalize only after those fail.
```

When you do bend a rule, do it deliberately after designing properly, and document each break: the reason, the design principle violated, the exact structure changed, the specific modification, and its anticipated effects. The record lets you reverse the change if the payoff never materializes.
