# Documentation Navigation Methodology

**Version 0.1.0**  
dot-skills  
May 2026

---

## Abstract

Methodology distillation of the generic moves that turn 'I need to look this up' into a fast, version-correct answer from a library's official documentation — independent of which library. 7 rules across 4 orthogonal categories — Choose Source, Match Version, Fall Back, Capture for Reuse — each naming a wrong default an agent makes when reaching for docs (treating all questions as 'search docs', ignoring llms.txt, reading latest docs while user is on an older version, re-reading docs when reality contradicts them, preferring prose over examples, redoing lookup work next time). Per-library facts live in a topography registry (registry/<lib>.md) so the methodology is shared once and per-library overlay is thin reference data — collapses the 'one skill per library' trap. Registry is intentionally empty at v0.1.0; first entry should be grounded in a real lookup, not pre-empted.

---

## Table of Contents

1. [Choose Source](references/_sections.md#1-choose-source)
   - 1.1 [Classify the question before searching — changelog, reference, idiom, or known-bug](references/src-decision-tree.md)
   - 1.2 [Probe llms.txt before scraping HTML — AI-canonical format takes priority](references/src-llms-txt-first.md)
2. [Match Version](references/_sections.md#2-match-version)
   - 2.1 [Find the version selector before reading any reference page](references/ver-find-selector.md)
   - 2.2 [Read the changelog before the reference for "did X change" questions](references/ver-changelog-first.md)
3. [Fall Back](references/_sections.md#3-fall-back)
   - 3.1 [For idiom questions, read examples and samples before prose docs](references/fall-samples-over-prose.md)
   - 3.2 [When docs match the code but reality doesn't, check GitHub issues, status, and forum](references/fall-known-issues.md)
4. [Capture for Reuse](references/_sections.md#4-capture-for-reuse)
   - 4.1 [Write the docs section of knowledge/libraries/<library>.md after a successful lookup](references/capture-registry-record.md)

---

## References

1. [https://diataxis.fr/](https://diataxis.fr/)
2. [https://llmstxt.org/](https://llmstxt.org/)
3. [https://stripe.com/docs/upgrades](https://stripe.com/docs/upgrades)
4. [https://keepachangelog.com/](https://keepachangelog.com/)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |