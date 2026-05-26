# Skill Authoring Methodology

**Version 0.1.0**  
dot-skills  
May 2026

---

## Abstract

Methodology distillation of the conventions that hold across shipped library-reference distillation skills (nuqs, zod, react-hook-form, effect-ts, emilkowal-animations) — the archetype that turns one external library into an idiomatic-usage rule pack. 7 rules across 4 orthogonal categories — Source Selection, Versioning, Rule Shape, Metadata Discipline — each naming a wrong default the author makes when starting a new library-reference skill, the convention that corrects it, and a concrete trace from an existing skill showing the convention in use. The skill is the meta-archetype playbook above /dev-skill:new and /dev-skill:ingest — it does not generate skills, it constrains the editorial decisions that the generator cannot make. Sibling playbooks for code-atlas, methodology, scaffolder, and runbook archetypes are still to be extracted.

---

## Table of Contents

1. [Source Selection](references/_sections.md#1-source-selection)
   - 1.1 [Mine sources in order — docs, then blog/changelog, then issues, then types, then examples](references/source-priority-ladder.md)
   - 1.2 [Privilege rules that capture the failure gap, not the API surface](references/source-failure-gap.md)
2. [Versioning](references/_sections.md#2-versioning)
   - 2.1 [On evolve, diff the skill against upstream HEAD and codify the drift](references/pin-refresh-vs-head.md)
   - 2.2 [Pin version by API velocity — metadata only for stable, explicit range in SKILL.md for moving](references/pin-by-velocity.md)
3. [Rule Shape](references/_sections.md#3-rule-shape)
   - 3.1 [Fill four When-to-Apply slots — import trigger, problem domain, frequency, not-to-do boundary](references/shape-when-to-apply-template.md)
   - 3.2 [Ladder categories CRITICAL setup, HIGH isolation, MEDIUM composition, LOW edge cases](references/shape-category-ladder.md)
4. [Metadata Discipline](references/_sections.md#4-metadata-discipline)
   - 4.1 [Treat metadata.references[] as a cite-set checksum — exact match with rule cites](references/meta-references-checksum.md)

---

## References

1. [https://nuqs.dev/docs](https://nuqs.dev/docs)
2. [https://zod.dev/api](https://zod.dev/api)
3. [https://react-hook-form.com/docs](https://react-hook-form.com/docs)
4. [https://effect.website/docs](https://effect.website/docs)
5. [https://emilkowal.ski/ui](https://emilkowal.ski/ui)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |