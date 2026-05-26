---
title: For idiom questions, read examples and samples before prose docs
tags: fall, samples, idioms
---

## For idiom questions, read examples and samples before prose docs

By default for "how should I structure this?" the agent reads the prose guides and assembles an answer from English sentences. This produces structurally plausible answers that don't match how the library is actually used. Idioms are encoded in **code**, not prose — the authors' own examples and samples are the highest-fidelity source for "what does idiomatic usage look like." Read the code first; use prose only for context.

```text
The idiom-source ladder (for "how should I do X?" questions):

  Tier 1 — Examples dir inside the main repo
    github.com/<owner>/<library>/tree/main/examples/
    github.com/<owner>/<library>/tree/main/e2e/
    These are the maintainers' own canonical usage. They were
    written to validate the API and exhibit how the author
    actually intends the library to be used.

  Tier 2 — Dedicated samples / templates repo
    github.com/<owner>/<library>-samples
    github.com/<owner>/<library>-examples
    Often per-framework or per-use-case. Useful when the main
    repo doesn't include examples, or includes only minimal ones.

  Tier 3 — Playground / sandbox the library publishes
    e.g. tailwindplay.com, codesandbox templates linked from docs,
    stackblitz starters
    Reveals interactive idioms that a static repo doesn't.

  Tier 4 — Test files in the main repo
    github.com/<owner>/<library>/tree/main/test
    Tests are the "what the library guarantees" surface — they
    exhibit edge-case idioms (error handling, concurrent use,
    initialization order) that the examples don't bother with.

  Tier 5 — Real OSS projects that use the library
    GitHub code search for `<distinctive-import>` filtered to
    repos with >100 stars. Shows how *consumers* use the library,
    which sometimes diverges from author intent.

  Tier 6 — Prose docs / cookbook
    Only NOW does the prose come in — and only for "why" context
    around the patterns you already saw in code.

The discriminator (per question):
  - Question contains "structure", "organize", "set up", "pattern"
    → idiom question → samples ladder
  - Question contains "what does X return", "what are X's params"
    → reference question → /docs/api page
  - Question contains "best practice" → samples + prose together
    (the prose tells you what the author thinks is best;
     the samples show what they actually do)

Anti-pattern:
  Citing a snippet from prose docs as "the idiomatic way" when
  the samples directory shows a different pattern. The samples
  are how the library is used; the prose is how it's marketed.
```

The mechanical trigger: when the question is about structure or pattern, the first WebFetch should be a samples URL, not a prose page. If the registry record for this library doesn't list a samples URL, find one and capture it before answering.

Reference: [The library-reference-distillation skill's `source-priority-ladder` rule — same observation applied to skill authoring](../../library-reference-distillation/references/source-priority-ladder.md)
