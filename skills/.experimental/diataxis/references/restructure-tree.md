# Decision Tree: Restructure a Messy Doc Set

**Symptom:** "our docs are a sprawling mess — where do I even start?" This tree is the Diátaxis **workflow** applied to a whole corpus. The core rule: **do not restructure top-down.** Use Diátaxis as a guide, not a plan.

```
A large, messy doc set
│
├── DON'T (the two failure modes):
│   ├── Create the four empty buckets (tutorials/, how-to/, reference/, explanation/)
│   │   and try to file everything at once. Empty structure with no content is worse
│   │   than no structure — "it's horrible," and the migration stalls half-done.
│   └── Tear it all down to "start fresh." You'll lose working content and ship nothing
│       for months.
│
├── Step 1. CHOOSE something small. One page, one section, even one paragraph —
│   preferably something you're already touching for another reason. Scope = tiny.
│   On a large corpus, triage first: run queries/scan-docs.sh <docs_root> to list
│   pages showing signals of two+ modes (candidate type-mixes) — pick from those.
│
├── Step 2. ASSESS it. Ask the two diagnostic questions:
│   "What user need does this represent? How well does it serve that need?"
│   Run the compass (compass-tree.md) and check quality (quality.md).
│   ├── Serves one need, serves it well → leave it. Return to Step 1 with the next thing.
│   ├── Serves the wrong mode, or mixes modes → go to wrong-type-tree.md.
│   └── A user need has no content at all → go to gaps-tree.md.
│
├── Step 3. DECIDE one next action that produces an immediate improvement — the
│   smallest useful change, not the ideal end-state.
│
├── Step 4. DO it, and PUBLISH immediately — even though the whole is still unfinished.
│   A small published improvement beats a big unpublished plan.
│
└── Step 5. REPEAT. Let overall structure EMERGE from the improving parts (organic
    growth that adapts to real conditions, not an imposed blueprint).
    Terminal each loop: ONE published improvement.
```

## The standard you're holding to

The corpus is **never "finished"** — but at every moment it should be **"complete"**: every part that exists is useful and structurally sound *for its current stage of growth*. Complete-not-finished is what lets you ship continuously without an empty-scaffold phase. See [workflow.md](workflow.md) for the full rationale.

## Terminal actions

- **Each loop** ends in one published change. There is no "done" — there is only *complete at this stage*.
- Periodically run a full pass with [../assets/templates/report.md](../assets/templates/report.md) to see the shape that's emerging and pick the next worst gap.
- When a single piece needs classifying → [compass-tree.md](compass-tree.md); mixing → [wrong-type-tree.md](wrong-type-tree.md); missing → [gaps-tree.md](gaps-tree.md).
