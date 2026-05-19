---
title: Decompose Research Goals into a Claim Inventory Mapped to Evidence Channels
impact: MEDIUM
impactDescription: prevents dropping or relabeling unverifiable claims by forcing per-claim status
tags: research, claim-inventory, decomposition, mapping
---

## Decompose Research Goals into a Claim Inventory Mapped to Evidence Channels

Research Goals fail when treated monolithically. A paper, a spec, or an audit target is not one claim — it's many. Decompose the target into a claim inventory and map each claim to the evidence channels that could support or refute it. Then label which evidence is feasible to produce locally, which requires external resources, and which is blocked. This is what turns "reproduce the paper" from an undefined verb into a per-claim audit. The inventory becomes the structure of the final report — one entry per claim, each with its route to evidence and its status. Without the inventory, claims that can't be verified get quietly dropped or relabeled; with the inventory, every claim has a status, including "blocked".

**Incorrect (treating the paper as a single claim):**

```text
[Inside an active "reproduce Deep Hedging" Goal]
Codex: "Reproduction in progress. Will produce a report when done."
[Final report: a few figures, a numerical match, conclusion "paper
reproduced".]
```

```text
# Which of the paper's claims were checked? Which weren't?
# Single-claim framing hides the gaps. The reader can't separate
# what was actually verified from what was assumed.
```

**Correct (claim inventory with explicit evidence channels):**

```text
[Inside the Goal, during the planning phase]
Codex produces a claim inventory:

| Claim | Headline | Evidence channel | Feasibility |
|-------|----------|-----------------|-------------|
| C1 | Heston complete-market hedge approximation | Reference hedge comparison, trained policy | Approximate (no original seeds) |
| C2 | CVaR hedge under transaction costs | Rebuilt mechanics, trained policy, histogram | Approximate |
| C3 | Black-Scholes transaction-cost slope | Reference formula, simulation | Confirmed (formula-driven) |
| C4 | High-dimensional generalization | Trained checks at sample dimensions | Approximate |
| C5 | Exact reproduction of published figures with original seeds | Original artifacts (seeds, checkpoints) | Blocked — artifacts not in paper |

[Each claim gets an entry in the final report with its evidence
channel and status.]
```

```text
# Five claims, five labeled statuses. The reader knows what was
# confirmed, what was approximated, and what was blocked. The inventory
# is the audit surface.
```

Reference: [Using Goals in Codex — Using Goals for complex research](https://developers.openai.com/cookbook/examples/codex/using_goals_in_codex)
