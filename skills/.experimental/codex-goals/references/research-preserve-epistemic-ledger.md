---
title: Final Report Must Preserve Epistemic Levels Per Claim — Use a Structured Ledger Entry
impact: MEDIUM
impactDescription: prevents flattening confirmed/approximate/blocked into a single "done" claim
tags: research, ledger, report, epistemic-levels
---

## Final Report Must Preserve Epistemic Levels Per Claim — Use a Structured Ledger Entry

The final output of a research Goal should preserve the different levels of evidentiary support instead of flattening them into a single success claim. Use a structured per-claim ledger entry with five fields: Claim (what was asserted), Route (what was done to test it), Evidence surface (what concrete evidence was produced), Status (confirmed / approximate reconstruction / proxy support / blocked), and Remaining uncertainty (what is still unverified). The structure forces the report to be honest — you cannot complete the entry without facing the gap. A trained replacement can support a claim, a close numerical match can raise confidence, and a rebuilt figure can validate part of the result — but none should be reported as recovering the original experiment exactly unless that's the actual status.

**Incorrect (flattened summary):**

```text
Summary: Deep Hedging paper reproduced.
- Heston hedge: ✓
- CVaR hedge: ✓
- Transaction-cost slope: ✓
- High-dim generalization: ✓
```

```text
# Every claim looks confirmed. No reader can tell which results came
# from exact original artifacts (none) versus retrained models with
# new seeds (most of them). The report is plausible and wrong about
# the level of support.
```

**Correct (per-claim ledger preserving epistemic level):**

```text
## Claim: Deep hedging approximates complete-market Heston hedge
            without transaction costs.

- Route: Rebuilt model mechanics from paper description; trained a
  new neural policy with new seeds; compared against the analytic
  reference hedge.
- Evidence surface: Price checks at five strikes; histogram of
  hedging errors; hedge-surface visualization.
- Status: Close approximate reproduction.
- Remaining uncertainty: Original training paths, seeds, and
  checkpoints are unavailable. The published figures could not be
  exactly replayed; only re-derived with new training.

## Claim: Black-Scholes transaction-cost slope matches published
            asymptotic.

- Route: Implemented the analytic formula directly; ran the
  simulation across the published cost range.
- Evidence surface: Slope reproduced to within 0.4% across the full
  cost range.
- Status: Confirmed.
- Remaining uncertainty: None.

[... one entry per claim ...]
```

```text
# Each claim has its actual status. A reader who only cares about
# confirmed results can filter by status. A reader who cares about
# what's blocked can see exactly which artifacts would unblock it.
```

Reference: [Using Goals in Codex — Using Goals for complex research](https://developers.openai.com/cookbook/examples/codex/using_goals_in_codex)
