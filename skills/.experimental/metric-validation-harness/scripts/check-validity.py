#!/usr/bin/env python3
"""check-validity — empirical construct validity against a labeled corpus (valid-* rules).

Using whatever columns the corpus CSV provides (path, [accepted], [outcome]):
  convergent   Spearman(metric, accepted)        should be >= CONVERGENT_MIN
  discriminant |Spearman(metric, baseline LOC)|  FAIL only if > DISCRIMINANT_MAX (it's just size)
  predictive   AUC(metric, outcome)              should be >= PREDICTIVE_MIN
  lift         AUC(metric) - AUC(baseline)       should be >= 0 (beats the trivial baseline)

Thresholds are env-configurable; defaults are deliberately lenient — tighten them for your use
(the design skill argues for a strict discriminant bar, e.g. flag cyclomatic ~0.9 with LOC).
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "lib"))
import harness  # noqa: E402

CONVERGENT_MIN = float(os.environ.get("CONVERGENT_MIN", "0.5"))
DISCRIMINANT_MAX = float(os.environ.get("DISCRIMINANT_MAX", "0.97"))
PREDICTIVE_MIN = float(os.environ.get("PREDICTIVE_MIN", "0.65"))


def main():
    labels = harness.setting("labels_csv", "LABELS_CSV", "{SKILL}/scripts/fixtures/corpus.csv")
    if not os.path.exists(labels):
        print(f"FAIL: labels CSV not found at {labels}. Set 'labels_csv' in config.json.")
        print("check-validity: 1 failed")
        return 1

    rows = list(harness.read_corpus(labels))
    if len(rows) < 3:
        print(f"FAIL: need >= 3 labeled rows for meaningful statistics, found {len(rows)}.")
        print("check-validity: 1 failed")
        return 1

    mcmd, bcmd = harness.metric_cmd(), harness.baseline_cmd()
    try:
        metric = [harness.run_metric(mcmd, r["_path"]) for r in rows]
        baseline = [harness.run_metric(bcmd, r["_path"]) for r in rows]
    except (RuntimeError, FileNotFoundError) as exc:
        print(f"FAIL: could not evaluate metric/baseline over the corpus — {exc}")
        print("check-validity: 1 failed")
        return 1

    fails = 0

    if rows[0].get("accepted"):
        accepted = [float(r["accepted"]) for r in rows]
        rho = harness.spearman(metric, accepted)
        if rho is not None and rho >= CONVERGENT_MIN:
            print(f"PASS: convergent — Spearman(metric, accepted) = {rho:.2f} (>= {CONVERGENT_MIN})")
        else:
            print(f"FAIL: convergent — Spearman(metric, accepted) = {rho} (< {CONVERGENT_MIN}); little agreement with the accepted measure")
            fails += 1
    else:
        print("SKIP: convergent — no 'accepted' column in corpus")

    rho_b = harness.spearman(metric, baseline)
    if rho_b is None:
        print("SKIP: discriminant — baseline has zero variance")
    elif abs(rho_b) <= DISCRIMINANT_MAX:
        print(f"PASS: discriminant — |Spearman(metric, LOC)| = {abs(rho_b):.2f} (<= {DISCRIMINANT_MAX}); adds signal beyond size")
    else:
        print(f"FAIL: discriminant — |Spearman(metric, LOC)| = {abs(rho_b):.2f} (> {DISCRIMINANT_MAX}); the metric is ~LOC relabeled")
        fails += 1

    if rows[0].get("outcome"):
        outcome = [int(float(r["outcome"])) for r in rows]
        a_m = harness.auc(metric, outcome)
        a_b = harness.auc(baseline, outcome)
        if a_m is None:
            print("SKIP: predictive — 'outcome' has only one class")
        else:
            if a_m >= PREDICTIVE_MIN:
                print(f"PASS: predictive — AUC(metric, outcome) = {a_m:.2f} (>= {PREDICTIVE_MIN})")
            else:
                print(f"FAIL: predictive — AUC(metric, outcome) = {a_m:.2f} (< {PREDICTIVE_MIN}); weak forecast of the outcome")
                fails += 1
            if a_b is not None:
                lift = a_m - a_b
                if lift >= 0:
                    print(f"PASS: beats baseline — AUC lift = {lift:+.2f} (metric {a_m:.2f} vs LOC {a_b:.2f})")
                else:
                    print(f"FAIL: beats baseline — metric AUC {a_m:.2f} < LOC AUC {a_b:.2f} ({lift:+.2f}); the cheaper baseline wins")
                    fails += 1
    else:
        print("SKIP: predictive — no 'outcome' column in corpus")

    print(f"check-validity: {'0 failed' if fails == 0 else f'{fails} failed'}")
    return 1 if fails else 0


if __name__ == "__main__":
    sys.exit(main())
