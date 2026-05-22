# Decision Tree: Gaps / Missing Quadrant

**Symptom:** users can't get started, can't accomplish a task, can't find a fact, or don't understand *why*. Each failing need points to a specific missing or weak mode. Diagnose by the **user need that is failing**, not by the topic.

```
Which user need is failing?
│
├── "I can't get started / I don't know where to begin" — a NEWCOMER, learning
│   └── Missing or weak TUTORIAL. The acquisition path is closed.
│       Action: create a learning-oriented tutorial that takes a beginner to a first,
│       guaranteed success → tutorials.md.  Severity P1.
│
├── "How do I accomplish <specific goal>?" goes unanswered — a COMPETENT user, working
│   └── Missing HOW-TO GUIDE for a real task.
│       Action: write goal-oriented directions named after the real problem →
│       how-to-guides.md.  Severity P1.
│
├── "What exactly is X? what options/params exist?" — facts missing, scattered,
│   inconsistent, or not trusted
│   └── Missing or weak REFERENCE.
│       Action: create reference led by the product's structure — describe and only
│       describe, make it consistent → reference.md.  Severity P2.
│
├── "Why is it like this? I have no mental model; I keep misusing it"
│   └── Missing EXPLANATION.
│       Action: write an "About X" piece — context, the why, connections, trade-offs →
│       explanation.md.  Severity P2.
│
└── Several / all of the above are failing
    └── The corpus is thin across modes. DON'T build all four at once.
        Terminal: go to restructure-tree.md and grow them one small step at a time,
        worst-failing need first.
```

## Confirm it's a real gap, not findability

A "missing" mode is sometimes content that *exists but can't be found or trusted*. Check before writing:

| Symptom | Real gap (create) | Actually different (don't create) |
|---------|-------------------|-----------------------------------|
| "Can't get started" | No tutorial exists | A tutorial exists but is buried/misnamed → navigation problem; fix titling & links |
| "How do I X?" unanswered | No how-to for that goal | A how-to exists but is named for a tool, not the goal → rename it (how-to-guides.md) |
| "Can't find the spec" | No reference | Reference exists but is inconsistent / not product-structured → fix it (reference.md) |
| "I don't get why" | No explanation | The "why" is buried inside a how-to/reference → extract it (wrong-type-tree.md) |

## Terminal actions

- Each leaf → **create the missing mode** by opening its type guide and writing it.
- Breadth problem (several gaps) → **restructure-tree.md**, worst-failing need first.
- Content exists but is mislocated/misnamed → **wrong-type-tree.md** (extract/split) or fix navigation — don't write a duplicate.

Record the gap and the mode created in [../assets/templates/report.md](../assets/templates/report.md).
