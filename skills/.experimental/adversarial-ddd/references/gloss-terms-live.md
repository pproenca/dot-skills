---
title: Keep every glossary term live in the code, tests, or docs
tags: gloss, ubiquitous-language, glossary, drift
---

## Keep every glossary term live in the code, tests, or docs

The wrong default is a glossary that only grows. Entries accumulate for concepts that were renamed, cut, or never built, and the vocabulary bloats past what anyone actually speaks. A well-sized language is one where the recorded terms and the working terms are the same set — a zombie entry is drift in the opposite direction from a missing one, and it erodes trust in the glossary just as fast.

**Evidence of violation:** a glossary entry whose term appears nowhere in the target outside the glossary itself — not in code identifiers, not in test names or descriptions, not in other docs or user-facing strings. Search the term and its stated inflections (plural, verb form) before concluding; cite the zero-hit search scope. For a module-scoped review, judge only entries the glossary itself scopes to that module or context.

**Carve-outs (must be cited to claim):** entries explicitly marked as planned or deprecated in the glossary itself ("planned for the Q3 settlement work", "deprecated — replaced by Credit Note, remove after migration"). An unmarked dead term is a violation regardless of anyone's intentions for it.

**Incorrect (the glossary describes a system that no longer exists):**

```markdown
| Term | Meaning |
|------|---------|
| Invoice | A demand for payment for delivered work. |
| Payment Plan | A schedule splitting an Invoice into installments. |   <!-- no identifier,
     test, or doc in the module mentions installments or a plan — the feature was cut -->
```

**Correct (dead entry either removed or explicitly marked):**

```markdown
| Term | Meaning |
|------|---------|
| Invoice | A demand for payment for delivered work. |
| Payment Plan | *Deprecated 2026-06 — installments were cut from Billing; remove after the settlement rework.* |
```

The "missing for PASS" for this rule is always one of two edits: delete the entry, or mark it with its status and reason.

Reference: [Eric Evans — Domain-Driven Design Reference: Continuous Integration of the model](https://www.domainlanguage.com/ddd/reference/), [Martin Fowler — UbiquitousLanguage](https://martinfowler.com/bliki/UbiquitousLanguage.html)
