---
title: Calibrate Action Thresholds to Ground Truth, Not Round Numbers
impact: MEDIUM
impactDescription: prevents arbitrary round-number thresholds
tags: valid, threshold, calibration, roc
---

## Calibrate Action Thresholds to Ground Truth, Not Round Numbers

The action threshold the metric drives ("flag if cyclomatic > 10") is part of the metric, and a round number inherited from a 1976 paper is not a calibration. Derive the cutoff from data: pick the operating point that optimizes the decision's real cost trade-off (false flags vs. missed risks) on a labelled set, or from the distribution of a healthy benchmark corpus. Report precision and recall at the chosen point so consumers know what the threshold buys.

**Incorrect (arbitrary inherited cutoff):**

```python
THRESHOLD = 10        # the historical cyclomatic default — never calibrated to THIS codebase or decision
flagged = cyclomatic(module) > THRESHOLD
```

**Correct (threshold chosen from labelled outcomes):**

```python
# Choose the cutoff that maximises F-beta for the decision's cost (beta>1 if misses cost more).
prec, rec, thresholds = precision_recall_curve(y_true, [cyclomatic(m) for m in sample])
THRESHOLD = thresholds[argmax(fbeta(prec, rec, beta=2))]
report(threshold=THRESHOLD, precision=prec_at(THRESHOLD), recall=rec_at(THRESHOLD))
```

Reference: [Alves, Ypma & Visser, "Deriving metric thresholds from benchmark data" (ICSM 2010)](https://doi.org/10.1109/ICSM.2010.5609747)
