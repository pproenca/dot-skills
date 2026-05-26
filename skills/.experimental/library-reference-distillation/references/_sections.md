# Sections

This file defines the four orthogonal decision categories that hold across
shipped library-reference distillations in this repo. The prefix in parentheses
is the filename prefix that groups rules. Categories are ordered by the
sequence in which the decisions actually come up when authoring: you cannot pin
a version before you have sources; you cannot shape a category ladder before
you know what kind of rules you are mining; you cannot make a metadata
checksum honest until rules exist.

The four categories are **orthogonal** — getting one right does not help with
the others. Match the decision in front of you to the category, do not walk
them in order:

- "Where do I read to find rules?" → `source`
- "Which version of the library is this skill against?" → `pin`
- "What are the categories and how does each rule land?" → `shape`
- "Is the cite list honest?" → `meta`

This skill is a **methodology distillation about a distillation archetype**.
The reference set behind these rules is empirical: 5 library-ref skills
(`nuqs`, `zod`, `react-hook-form`, `effect-ts`, `emilkowal-animations`) traced
rule-by-rule to their cited sources. Each rule below names the wrong default
the author makes when this convention is absent.

---

## 1. Source Selection (source)

**Description:** Where rules come from and what makes a rule earn its place. The
default failure mode is treating the library's official API reference as the
source of rules — which produces an API-restatement skill that adds no judgment.
Across all 5 traced skills, the most load-bearing rules came from secondary
sources (author blog posts, changelogs, GitHub discussions on edge cases) and
from production-failure stories that contradict or extend what the docs say.
Covers the source-priority ladder (docs → blog/changelog → issues → types →
examples) and the failure-gap exemplar heuristic.

## 2. Versioning (pin)

**Description:** How the skill stays honest as the upstream library moves. The
default failure mode is either pinning too tightly (every minor version
invalidates the skill) or not at all (the skill silently rots). Across all 5
traced skills, pinning **inverts with API velocity**: stable libraries (Zod 4,
RHF v7) record only the skill version in `metadata.json`; fast-moving libraries
(nuqs v2.5–v2.8, Tailwind v4 features) declare an explicit range in the
`SKILL.md` heading itself. Covers initial pinning and the refresh-vs-HEAD move
applied during `/dev-skill:evolve`.

## 3. Rule Shape (shape)

**Description:** How categories and individual rules land on the page. The
default failure mode is inventing a new category structure for each skill and
phrasing "When to Apply" as a vague paragraph. Across all 5 traced skills, a
universal 4-tier category ladder appears (CRITICAL setup → HIGH isolation/perf
→ MEDIUM composition → LOW edge cases) and a 4-slot "When to Apply" template
(import-statement trigger + problem-domain language + frequency signal +
explicit NOT-to-do boundary). Covers both.

## 4. Metadata Discipline (meta)

**Description:** Making the skill auditable from `metadata.json` alone. The
default failure mode is `metadata.references[]` becoming an aspirational
reading list rather than a checksum of cites actually used in rules. The
invariant across all 5 traced skills: `metadata.references[]` is the exact set
of URLs cited in rules — no aspirational entries, no missing cites. If the two
diverge, one of them is lying. Covers this single discipline.
