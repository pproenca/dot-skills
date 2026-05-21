# Decision Tree: Conflict Resolution (the Evaporating Cloud)

**Symptom:** You know the constraint, but the obvious fix is blocked by a tradeoff that feels unresolvable — "we must move faster but we must stay safe", "shrink the agent's context but keep full coverage", "deploy continuously but protect stability." The team is stuck choosing between two bad options or splitting the difference.

**Core principle:** ToC's Evaporating Cloud (Conflict Resolution Diagram) holds that a persistent conflict is never a real tradeoff — it survives only because of a hidden, false **assumption**. You don't *compromise* the cloud; you *evaporate* it by breaking one assumption, producing a win-win "injection." Compromise leaves both needs partly unmet; evaporation meets both.

```
State the conflict as a cloud, then attack the assumptions.
│
├── Step 1 — Build the cloud (5 boxes):
│   A  (Objective)      ← the shared goal both sides actually want
│   B  (Need)           ← what side 1 must protect   → requires D
│   C  (Need)           ← what side 2 must protect   → requires D'
│   D  vs D' (Wants)    ← the two conflicting actions
│
│   Read it as logic:
│   "To achieve A we need B; to have B we want D."
│   "To achieve A we need C; to have C we want D'."
│   "But D and D' conflict."
│
├── Step 2 — Surface the assumption behind EACH arrow. Ask "why must this be
│   true?" for all five:
│     A→B : "to reach the goal we really need B because…"
│     A→C : "…we really need C because…"
│     B→D : "to get B we must do D because…"   ← most assumptions hide here
│     C→D': "to get C we must do D' because…"  ← and here
│     D↔D': "D and D' can't coexist because…"  ← and here
│
├── Step 3 — Find the WEAKEST assumption (the one that isn't actually a law of
│   nature) and break it with an INJECTION — a change that makes the assumption
│   false, so both needs are met without choosing.
│   │
│   ├── Found a breakable assumption
│   │   └── State the injection. Verify it doesn't create new negative effects
│   │       (a mini Future Reality Tree: "if we do this, then… does anything
│   │       bad follow?"). 
│   │       ├── No new negatives → adopt the injection; the conflict evaporates.
│   │       │   Return to the constraint fix you were blocked on →
│   │       │   find-the-constraint-tree.md.
│   │       └── New negative effect appears → it's a different assumption or a
│   │           real necessary condition; pick the next-weakest assumption and
│   │           repeat Step 3.
│   │
│   └── Every assumption seems ironclad (it's a genuine physical tradeoff)
│       └── This is rare. If truly no assumption breaks, it is a real
│           constraint, not a false conflict → make the tradeoff explicit,
│           pick the side that maximizes the GOAL METRIC, and elevate later →
│           find-the-constraint-tree.md.
│
└── Step 4 — Record the cloud, the broken assumption, and the injection so the
    same dilemma isn't re-litigated next time → ../assets/templates/report.md
```

## Worked examples (the injection is the payoff)

**"Move faster" vs "stay safe" (CI gate):**
- A = ship value reliably; B = catch regressions → D = run full suite on every change; C = fast feedback → D' = skip/shorten the suite.
- Weak assumption (B→D): "the only way to catch regressions is to run *everything*." 
- **Injection:** run the diff-affected tests on every change + the full suite nightly. Both needs met; no compromise.

**"Shrink agent context" vs "keep full coverage" (Agent Skill):**
- A = correct task completion; B = enough knowledge → D = load all references; C = fit the context budget → D' = drop references.
- Weak assumption (B→D): "the agent needs all references *loaded up front* to be correct."
- **Injection:** progressive disclosure — a lean SKILL.md that points to on-demand references. Full coverage, small always-loaded budget.

**"Deploy continuously" vs "protect stability" (release policy):**
- Weak assumption: "more frequent deploys mean more risk."
- **Injection:** small, automated, reversible deploys with canary + auto-rollback. Smaller batches are *lower* risk per deploy, not higher.

## When to use this tree vs the others

Reach for the Evaporating Cloud when the *constraint is known* but a dilemma blocks the intervention — most often after [policy-constraint-tree.md](policy-constraint-tree.md) (a policy persists because of a "we have to" assumption) or when an exploit/elevate move is resisted as "too risky." For finding the constraint itself, use the measurement-driven trees.

## Decision criteria

| Signal | Reading |
|--------|---------|
| Is there a shared objective (A)? | If the two sides don't share a goal, it's a priorities conflict, not a cloud — escalate to the goal owner |
| Does an assumption break cleanly? | Yes = injection evaporates the conflict; no new negatives = adopt |
| Does breaking it create new problems? | Yes = real necessary condition; try the next assumption |
| All assumptions ironclad? | Genuine tradeoff (rare) — choose by goal metric, make it explicit |

## Terminal actions

- **Adopt the injection** — assumption broken, no new negatives; conflict evaporated → resume the blocked constraint fix.
- **Try the next assumption** — the injection created a new negative effect.
- **Make the tradeoff explicit** — genuinely no breakable assumption; decide by the goal metric and revisit after elevating.
- **Escalate** — no shared objective exists; this is a goal/priority disagreement for the owner, not a ToC cloud.

Record the cloud and chosen injection in [../assets/templates/report.md](../assets/templates/report.md).
