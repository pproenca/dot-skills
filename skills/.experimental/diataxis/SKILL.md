---
name: diataxis
description: Use whenever writing, editing, restructuring, or reviewing technical documentation — READMEs, API docs, guides, tutorials, reference, onboarding, or developer docs of any kind — to apply the Diátaxis framework, which splits content into four modes (tutorials, how-to guides, reference, explanation) that each serve a distinct user need. Trigger even when the user just says "write docs", "document this", "improve the README", or "our docs are confusing" without naming Diátaxis or documentation types. Use it to decide WHAT KIND of doc to write (via the compass), to diagnose docs that feel bloated, mix instruction with reference, or leave users unable to get started or find facts, and to improve docs in small safe iterations. Especially when you are unsure whether something belongs in a tutorial vs how-to vs reference vs explanation, or when one page is trying to do all four at once.
metadata:
  internal: true
---
# Diátaxis

A runbook for producing and fixing technical documentation with the **Diátaxis** framework. Diátaxis splits documentation into four modes — **tutorials, how-to guides, reference, explanation** — because they answer four different user needs that pull in opposite directions. The single idea that makes it work:

> Most documentation problems are a single thing: content that tries to serve more than one need at once. Separate the four modes and most confusion dissolves.

Diátaxis is descriptive, not prescriptive — a way to *understand* documentation, not a template to fill in. Don't wait to understand the whole framework before applying it: pick one small thing, classify it, improve it, publish, repeat.

## When to Apply

Use this skill when:

- **Writing or generating new documentation** of any kind (README, API docs, guide, onboarding, developer docs) — decide which mode(s) the content needs *before* writing it.
- A page is **confusing, bloated, or "tries to do everything"** — diagnose the type-mixing and split it.
- **Users can't get started, can't complete a task, can't find a fact, or don't understand *why*** — locate the missing or weak mode.
- **Restructuring or auditing** an existing doc set — apply the small-step workflow instead of a big rewrite.
- You're **unsure whether something is a tutorial, how-to, reference, or explanation** — run the compass.

Do **not** reach for this skill for pure prose/copy-editing *within* an already-correct mode (use a copywriting skill), or for design/spec/proposal documents — those are mostly *explanation* and are better served by `dev-rfc` or `feature-spec`.

## The four modes

Each mode serves a different user, in a different situation, with a different content style. The quickest way to keep them straight:

| Mode | Serves | Oriented to | Analogy | Answers |
|------|--------|-------------|---------|---------|
| **[Tutorial](references/tutorials.md)** | a beginner *learning* | learning, study | teaching a child to cook | "teach me, by doing" |
| **[How-to guide](references/how-to-guides.md)** | a user *working* | a goal, a task | a recipe in a cookbook | "how do I achieve X?" |
| **[Reference](references/reference.md)** | a user *working* | information | an encyclopaedia entry | "what is X exactly?" |
| **[Explanation](references/explanation.md)** | a user *studying* | understanding | an article *about* cooking | "why is X this way?" |

Two of them serve **practical steps** (tutorial, how-to); two serve **theoretical knowledge** (reference, explanation). Two serve someone **acquiring skill / studying** (tutorial, explanation); two serve someone **applying skill / working** (how-to, reference).

## The compass — decide what you are writing

When you are unsure which mode a piece of content belongs to, answer two questions. This is the master decision tool; the full tree is in [compass-tree.md](references/compass-tree.md).

**1. Does it inform _action_ or _cognition_?** — practical steps (doing) vs theoretical knowledge (thinking).
**2. Does it serve _acquisition_ or _application_?** — study (learning) vs work (applying what you know).

|                                    | **Action** (practical steps) | **Cognition** (theoretical knowledge) |
|------------------------------------|------------------------------|---------------------------------------|
| **Acquisition** (study / learning) | **Tutorial**                 | **Explanation**                       |
| **Application** (work / doing)      | **How-to guide**             | **Reference**                         |

Read as a decision: *informs action + serves acquisition → tutorial; informs action + serves application → how-to guide; informs cognition + serves application → reference; informs cognition + serves acquisition → explanation.* Apply the compass at any scale — a whole document, a section, or a single sentence that has drifted into the wrong mode.

## Common Symptoms

Start here. Match the situation, open its tree. Severity reflects how badly the reader is failed right now (see [symptoms.md](references/symptoms.md)).

| Symptom / trigger | Likely problem | Tree |
|-------------------|----------------|------|
| "Write docs for X" / "document this" — and it's unclear what *kind* of doc | No mode chosen yet — classify first | [compass-tree](references/compass-tree.md) |
| A page feels bloated, rambling, or mixes teaching + steps + specs + opinion | Type-mixing — two needs in one document | [wrong-type-tree](references/wrong-type-tree.md) |
| Beginners can't get started · competent users can't finish a task · people can't find a fact · users don't understand *why* | A missing or weak quadrant | [gaps-tree](references/gaps-tree.md) |
| "Our docs are a sprawling mess — where do I even start?" | Needs the iterative workflow, not a rewrite | [restructure-tree](references/restructure-tree.md) |

## How to use

1. **Match the symptom** in the table above and open its tree in `references/`. For a large *existing* corpus, run `bash references/queries/scan-docs.sh <docs_root>` first — it triages which pages show signals of more than one mode, so you know where to point the compass.
2. **Classify with the compass** — decide which of the four modes the content serves. When in doubt, open [compass-tree.md](references/compass-tree.md).
3. **Read the matching type guide** — [tutorials](references/tutorials.md), [how-to-guides](references/how-to-guides.md), [reference](references/reference.md), or [explanation](references/explanation.md) — for how to write *that* mode well, and what to keep out of it.
4. **Work in small steps.** Follow [workflow.md](references/workflow.md): choose something small → assess it → decide one next action → do it and publish. Never tear everything down to restructure top-down.
5. **Assess against quality.** Use [quality.md](references/quality.md) to judge functional quality (accuracy, completeness, consistency) and deep quality (does it feel good to use, anticipate the user's needs).
6. **Record an audit** with [assets/templates/report.md](assets/templates/report.md) when reviewing an existing doc set, so the same gaps don't get re-litigated each time.

## Setup

This skill uses an optional `config.json` to know where your docs live and where to log audits. On first use, if `docs_root` is empty and you are auditing an existing doc set, ask the user (via `AskUserQuestion`) for the documentation directory, then save it. The skill works without config — fall back to asking inline. Never block on missing config.

## Gotchas

The recurring traps of applying Diátaxis — empty structure-first scaffolding, "balancing" the four types instead of separating them, explaining inside a tutorial — are in [gotchas.md](gotchas.md). Read it before your first restructure.

## Related skills

- `skill-authoring` — authoring Agent Skills; their SKILL.md is itself a Diátaxis problem (navigation + reference, not a tutorial).
- `human-copywrite` / `humanize` — once a doc is in the right mode, these tighten the prose so it reads naturally.
- `dev-rfc` / `feature-spec` — design and spec documents are mostly *explanation*; reach for those when the artifact is a proposal, not user documentation.
