# Documentation Quality — what "good" means

When the [workflow](workflow.md) says **assess it** — "how well does this serve the need?" — these are the criteria. Diátaxis distinguishes two kinds of quality, and you check both.

## Functional quality — measurable, objective

The constraints a document must meet to do its job at all. They are largely **independent of each other**, so each can be checked on its own:

- **Accuracy** — it is correct.
- **Completeness** — nothing the user needs is missing. (Remember: how-to guides and tutorials are *deliberately not exhaustive* — "complete" means complete *for the need*, not comprehensive. Exhaustiveness is reference's job.)
- **Consistency** — internally, and with sibling docs: same patterns, terms, and structure.
- **Usefulness** — it actually helps the user with the need it serves.
- **Precision** — exact and unambiguous.

Diátaxis **cannot guarantee** functional quality — that takes technical skill and domain knowledge. But it **exposes lapses**: when each page has exactly one job, missing or wrong content has nowhere to hide.

## Deep quality — subjective, interdependent

The qualities that make documentation feel good to use. They can't be measured numerically, but they're unmistakable when present, and they're **interdependent** — they reinforce one another:

- It **feels good to use**; it has **flow**.
- It **anticipates the user's needs** — answers the next question before it's asked.
- It **fits the human** — there's a rightness, even a beauty, to it.

Deep quality is **assessed against the human**, not against an external spec — "your body knows it," the way you recognise a well-fitting garment without taking measurements. It rests *on top of* functional quality: you can't feel-good your way past inaccuracy.

## What Diátaxis can and can't do for quality

- **Exposes** functional lapses, through structural clarity.
- **Supports** deep quality by organising content around user needs and sustaining narrative flow.
- **Does not replace** UX, interaction, or visual design — and does not, by itself, make content accurate.

## Using this in an assessment

A two-pass check for any page:

1. **Functional pass (objective):** accurate? complete *for its need*? consistent? precise? useful? — any "no" is a defect to fix in place.
2. **Deep pass (felt):** does it flow? does it anticipate the next question? does using it feel good? — a "no" here usually traces back to a *mode confusion* or a functional gap. Run [compass-tree.md](compass-tree.md); the fix is often a split ([wrong-type-tree.md](wrong-type-tree.md)), not more polish.

Record both passes in [../assets/templates/report.md](../assets/templates/report.md).

Reference: https://diataxis.fr/quality/
