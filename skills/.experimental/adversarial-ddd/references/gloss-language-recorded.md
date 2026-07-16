---
title: Record the ubiquitous language in a glossary the team can find
tags: gloss, ubiquitous-language, glossary, documentation
---

## Record the ubiquitous language in a glossary the team can find

The wrong default is letting the domain vocabulary live only in identifiers and heads. A language that is not written down cannot be shared with stakeholders, cannot be checked for drift, and forks silently every time a new contributor picks a synonym. DDD's core practice is to cultivate the ubiquitous language deliberately — and a language is only cultivated if there is a canonical place where its terms and meanings are recorded.

**Evidence of violation:** the target contains domain concepts — at least one type with lifecycle states, business operations, or invariants — and no recorded glossary exists at any conventional location: `GLOSSARY.md`, `docs/glossary.md`, `docs/ubiquitous-language.md`, `docs/domain/glossary.md`, or a `## Glossary` / `## Domain language` section in the README or the module's own docs. **Absence is FAIL, not N/A** — the missing artifact is the violation. For a diff target: the diff introduces a new domain noun, lifecycle state, or operation name and no glossary entry is added or updated for it in the same change (when the repo already has a glossary; when it has none, the module-level absence leg applies).

**Carve-outs (must be cited to claim):** targets with no domain concepts at all — pure infrastructure, build tooling, generic libraries — make the whole gate not applicable rather than passing this rule; cite the absence of any type carrying business meaning.

**Incorrect (domain concepts, no recorded language):**

```text
billing/
├── src/
│   ├── invoice.ts          # Invoice with states draft | issued | settled | voided
│   ├── credit-note.ts
│   └── dunning.ts          # escalation levels, grace periods
└── README.md               # build and deploy instructions only
```

**Correct (the language has a home; the gate can now hold code to it):**

```markdown
<!-- docs/ubiquitous-language.md -->
# Ubiquitous Language — Billing

| Term | Meaning |
|------|---------|
| Invoice | A demand for payment for delivered work. Moves draft → issued → settled, or is voided before settlement. |
| Credit Note | A negative correction to an issued Invoice; never issued on its own. |
| Dunning | The escalation process for overdue Invoices; each level tightens the reminder cadence. |
```

A FAIL's "missing for PASS" must name the file to create and the terms it must define — the terms are already visible in the target's types and operations.

Reference: [Eric Evans — Domain-Driven Design Reference: Ubiquitous Language](https://www.domainlanguage.com/ddd/reference/), [Martin Fowler — UbiquitousLanguage](https://martinfowler.com/bliki/UbiquitousLanguage.html)
