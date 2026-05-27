# Source-Code Pattern Extraction Methodology

**Version 0.1.0**  
dot-skills  
May 2026

---

## Abstract

Methodology distillation of the generic moves an agent makes when distilling code patterns on demand from a specific GitHub codebase, given a focused query (e.g. 'how does shadcn/ui implement the design system', 'how does opencode use effect-ts', 'how does base-ui handle composition'). 7 rules across 4 orthogonal categories — Find, Trace, Filter, Capture — each naming a wrong default an agent makes when reaching for unfamiliar code (reading whole files before grepping, ignoring tests as canonical intent, conflating boilerplate with load-bearing pattern, treating each lookup as one-shot). Per-library code topography (repo URL, default branch, last-verified SHA, folder map, naming conventions, AGENTS.md flags) lives in registry/<lib>.md as ~30-line frontmatter — the dynamic light sibling of static code-atlas distillations (opencode-ts, openai-codex-rust-patterns, nextjs-ppr-patterns). Registry is intentionally empty at v0.1.0; first entry should be grounded in a real session.

---

## Table of Contents

1. [Find](references/_sections.md#1-find)
   - 1.1 [Classify the query before grepping — component, composition, state, effect, error, build, routing](references/find-classify-query.md)
   - 1.2 [Grep narrowly before reading whole files](references/find-grep-before-read.md)
   - 1.3 [Read only the named knowledge entry; never scan knowledge/libraries/](references/find-bounded-knowledge-read.md)
   - 1.4 [Read tests, examples/, and e2e/ dirs as the authors' canonical demonstration of intent](references/find-tests-show-intent.md)
2. [Trace](references/_sections.md#2-trace)
   - 2.1 [Follow imports outward from the implementation file to map the public surface](references/trace-imports-outward.md)
   - 2.2 [From the public surface, follow usages inward to see variants and evolution](references/trace-usages-inward.md)
3. [Filter](references/_sections.md#3-filter)
   - 3.1 [Cut boilerplate, legacy paths, and test scaffolding to surface the load-bearing pattern](references/filter-load-bearing.md)
4. [Capture](references/_sections.md#4-capture)
   - 4.1 [Write the code section of knowledge/libraries/<library>.md after a successful session](references/capture-registry-record.md)

---

## References

1. [https://github.com/BurntSushi/ripgrep](https://github.com/BurntSushi/ripgrep)
2. [https://diataxis.fr/](https://diataxis.fr/)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |