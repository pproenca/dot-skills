# Decision Tree: The Compass (master)

**Symptom:** "Write docs for X" / "document this", or simple uncertainty about which mode a piece of content belongs to. **Start here whenever the mode is unknown** — every other tree assumes you already know which of the four modes you're in.

**Precondition — name the unit and the reader.** The compass works at any scale: a whole document, a section, or a single sentence that has drifted. Before classifying, fix (a) the *unit* of content you're judging and (b) *who* reads it and *what situation they are in*. The same fact can belong to different modes depending on the reader's need, so the reader is part of the question.

```
Pick the unit of content + the reader's situation
│
├── Q1. Does this content inform ACTION (practical steps — doing)
│        or COGNITION (theoretical knowledge — thinking)?
│
├── ACTION ─► Q2. Acquisition or application?
│   │         (Is the reader STUDYING/learning, or WORKING with a known goal?)
│   │
│   ├── ACQUISITION (study) → TUTORIAL
│   │   Action: write it as a guided lesson — open tutorials.md. Take responsibility for
│   │   the beginner, make it work every time, and keep explanation out.
│   │
│   └── APPLICATION (work) → HOW-TO GUIDE
│       Action: write it as goal-oriented directions — open how-to-guides.md. Name the real
│       problem, sequence the steps, link out for concepts and full specs.
│
└── COGNITION ─► Q2. Acquisition or application?
    │
    ├── APPLICATION (work) → REFERENCE
    │   Action: write it as neutral description led by the product's structure — open
    │   reference.md. Describe and only describe, be consistent, link out for how-to and why.
    │
    └── ACQUISITION (study) → EXPLANATION
        Action: write it as a discursive piece *about* the topic — open explanation.md.
        Make connections, give context and the "why", and bound the scope.
```

## If you're stuck on the two questions

Phrase them whichever way unsticks you — they're the same axes:

- "Am I writing for **study** or for **work**?" (acquisition vs application)
- "Is this content engaged in **doing** or in **thinking**?" (action vs cognition)
- "Does the user need **practical steps** or **knowledge** right now?"

## Decision criteria

| Axis | One end | Other end |
|------|---------|-----------|
| Action ↔ Cognition | Tells the reader **what to do** (steps, commands, a procedure) | Tells the reader **what is true** (facts, concepts, reasons) |
| Acquisition ↔ Application | Reader is **learning**, doesn't yet know what they need (study) | Reader **knows their goal**, is getting a job done (work) |

## Terminal actions

- **One clear mode** → open that mode's guide and write/route the content there.
- **The unit answers "both"** (it serves two needs at once) → it is really *two* pieces of content. Go to [wrong-type-tree.md](wrong-type-tree.md) and split it.
- **The unit doesn't exist yet** and you're deciding what to *create* for a failing user need → go to [gaps-tree.md](gaps-tree.md).

Record any classification or split in [../assets/templates/report.md](../assets/templates/report.md).
