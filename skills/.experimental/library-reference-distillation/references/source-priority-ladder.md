---
title: Mine sources in order — docs, then blog/changelog, then issues, then types, then examples
tags: source, sourcing, priority-ladder
---

## Mine sources in order — docs, then blog/changelog, then issues, then types, then examples

By default the agent treats the library's official API reference as the only source. The resulting skill restates the API in markdown and adds no judgment a `tsc`/JSDoc reader could not get for free. Walk the **5-tier ladder** instead — each tier surfaces a different kind of rule, and the load-bearing ones rarely come from tier 1.

```text
Tier 1 — Official docs                 (e.g. zod.dev/api, nuqs.dev/docs)
  WHAT to write. Defines vocabulary, names the canonical idioms,
  marks deprecations. Rules from here are the table-of-contents.

Tier 2 — Author blog posts & changelogs (e.g. emilkowal.ski/ui/*,
                                         nuqs.dev/blog/nuqs-2.5)
  WHY each idiom exists. Authors explain motivation, the design
  alternatives they rejected, and "if you only learn one thing"
  rules. This tier produces the highest-leverage rules.

Tier 3 — GitHub discussions/issues       (e.g. react-hook-form #10103)
  WHERE docs and code disagree. "isSubmitting doesn't recover when
  submit handler throws" — the kind of rule docs never include
  because they cover the happy path. Failure-gap goldmine.

Tier 4 — TypeScript .d.ts / type files
  GROUND TRUTH. When docs and types contradict, types win. Inferred
  return types reveal generic constraints the docs hide.

Tier 5 — examples/ + playground/ dirs in the repo
  REAL USAGE. Authors test their own API here; idioms they didn't
  bother to document end up here as the "how I'd use it" reference.

Inversion: if the library publishes an llms.txt (Effect), it
collapses tiers 1–2 into a single AI-facing artifact — prefer it
over scraping HTML docs.
```

Trace check before committing: for any rule in your draft skill, you should be able to say which tier its source came from. If every rule cites tier 1 only, the skill is API documentation in disguise and you should drop ~half the rules and re-mine from tiers 2–3.

Reference: [Empirical trace across nuqs, zod, react-hook-form, effect-ts, emilkowal-animations skills in this repo](../../../../skills/.curated/nuqs/SKILL.md)
