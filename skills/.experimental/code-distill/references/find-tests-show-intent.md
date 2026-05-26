---
title: Read tests, examples/, and e2e/ dirs as the authors' canonical demonstration of intent
tags: find, tests, intent, examples
---

## Read tests, examples/, and e2e/ dirs as the authors' canonical demonstration of intent

By default the agent forms a hypothesis about how a pattern works by reading the prose docs, the README, or a randomly-encountered implementation file. This misses the authors' own canonical demonstration of intent — which lives in `test/`, `examples/`, and `e2e/` directories, **written and maintained by the same authors as the library**. These dirs are how the maintainers exhibit the API they intend you to use. Read them before forming a hypothesis, not after.

```text
The intent-source ladder (consult in this order, for "how does X work" queries):

  Tier 1 — examples/ in the main repo
    github.com/<org>/<lib>/tree/main/examples/
    Each example is a self-contained, runnable demonstration of one
    feature. The author chose what to demo here; that choice is
    a strong signal of canonical usage.

  Tier 2 — e2e/ or integration test dirs
    github.com/<org>/<lib>/tree/main/e2e/
    Wider scope than unit tests; uses the library "as a consumer
    would." Reveals how subsystems are meant to compose.

  Tier 3 — Unit test files next to the implementation
    foo.ts → foo.test.ts (or foo.spec.ts) in the same dir
    Reveals the EDGE CASES the author cares about, error paths,
    and the public contract surface they pinned with assertions.

  Tier 4 — Story files (.stories.tsx) for component libraries
    Each <Component>.stories.tsx lists the canonical variants &
    states the author wants to demo. Strong intent signal for
    component libraries (shadcn, base-ui, MUI, etc.).

  Tier 5 — Demo apps in monorepo (apps/www/, docs/, playground/)
    The library's own marketing/docs site is usually built USING
    the library — the dogfood is the canonical recipe.

  Tier 6 — README + prose docs (LAST, for context only)
    Prose is how the library is MARKETED; tests/examples are how
    it is USED. Prose comes after the code-canonical sources, never
    before — and only to add WHY context.

Anti-pattern:
  Reading the README first and forming a mental model of the
  pattern. The README has marketing-flavored simplifications and
  may show a deprecated idiom because it's easier to explain.
  The tests and examples never lie.

When the repo has no tests / examples (small library, early stage):
  Drop to: GitHub code search for `<distinctive-import>` filtered
  to repos with >100 stars. Real consumer usage in the wild.
```

The mechanical trigger: when the query is "how should I use X?" or "how does X work?" the FIRST `Read` should be a test file, an example file, or a story file — never a README, never an implementation file, never a guide. The test/example shows you the intended call shape; the implementation file shows you how the library does it internally (a different question).

Reference: [The library-reference-distillation skill's `source-priority-ladder` rule — same observation applied to skill-authoring source selection](../../library-reference-distillation/references/source-priority-ladder.md)
