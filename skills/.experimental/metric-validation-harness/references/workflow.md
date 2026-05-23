# Workflow — metric-validation-harness

The harness empirically tests one candidate metric against a corpus. This document covers the
adapter contract, each check in detail, how to wire up your own metric, and troubleshooting.

## The metric adapter

A metric is a command that takes a path as its **last** argument and prints **one number** to
stdout:

```
$METRIC_CMD <path>   →   <number>\n
```

- stdout is the number only; send any logging to stderr.
- The bash checks invoke `$METRIC_CMD "$path"` with word-splitting (no spaces in the command/path);
  the Python checks use `shlex.split` (quoting tolerated).
- Wrap richer tools in a one-line launcher if needed, e.g.:
  ```bash
  #!/usr/bin/env bash
  exec my-metric-tool --quiet --score-only "$1"
  ```

## End-to-end flow

```
config.json / env  →  load-config.sh (resolve METRIC_CMD, corpus, thresholds)
        │
        ▼
   verify.sh  ──►  check-determinism.sh   (det-)
            ├──►  check-invariance.sh     (prop- / game-)
            ├──►  check-monotonicity.sh   (prop-)
            ├──►  check-robustness.sh     (prop-)
            ├──►  check-tractability.py   (comp-)
            └──►  check-validity.py       (valid-)
        │
        ▼
   aggregate PASS/FAIL → exit 0 (all pass) or 1 (any group failed)
```

Setting precedence everywhere: **environment variable > config.json > bundled default**.

## Checks in detail

### 1. Determinism (`det-`)
Runs the metric twice on each fixture, then again under `PYTHONHASHSEED=0` and `=1`. **PASS** if all
four agree exactly. A FAIL means hidden non-determinism (hash-set iteration order, wall-clock,
unpinned tool). Fix: pin iteration/tie-break order, pass any reference time as an explicit input
(`det-make-the-metric-a-pure-function`, `det-pin-iteration-and-tie-break-order`).

### 2. Invariance & anti-gaming (`prop-` / `game-`)
Applies a behavior-neutral cosmetic transform (added comments, blank lines, trailing whitespace)
and re-measures. **PASS** if the score is unchanged. A FAIL means the metric reads surface text, so
an optimizer can move it for free — this is simultaneously an invariance failure
(`prop-prove-invariance-under-irrelevant-transforms`) and a gaming vulnerability
(`game-make-cheapest-improvement-the-right-one`). The bundled LOC baseline FAILS this on purpose.

### 3. Monotonicity & discrimination (`prop-`)
Appends a function with 50 statements (strictly more construct) and re-measures. **PASS** if the
score does not decrease (`prop-prove-monotonicity`). Then checks that the fixtures produce at least
two distinct values — a metric that saturates to one value cannot discriminate
(`prop-ensure-sensitivity-to-relevant-change`).

### 4. Robustness & range (`prop-`)
Runs the metric on an empty file and a single-statement file. **PASS** if each returns a finite
number with no crash, and (when `declared_min`/`declared_max` are set) within the claimed range
(`prop-prove-boundedness-and-handle-empty`).

### 5. Tractability (`comp-`)
Generates inputs of 50–800 functions, times the metric (best of 3), and checks the largest finishes
within budget and the log-log growth exponent is sub-quadratic. This is a **blowup smoke test** —
tiny inputs are dominated by process-spawn overhead — not a microbenchmark
(`comp-keep-the-metric-tractable`). Tune with `TRACTABILITY_BUDGET`, `TRACTABILITY_MAX_SLOPE`.

### 6. Construct validity (`valid-`)
Evaluates the metric over the labeled corpus and computes, with pure-stdlib statistics:

| Sub-check | Statistic | Default threshold | Rule |
|-----------|-----------|-------------------|------|
| convergent | Spearman(metric, `accepted`) | `CONVERGENT_MIN` = 0.5 | `valid-converge-with-accepted-measure` |
| discriminant | \|Spearman(metric, LOC)\| | `DISCRIMINANT_MAX` = 0.97 | `valid-discriminant-not-just-loc` |
| predictive | AUC(metric, `outcome`) | `PREDICTIVE_MIN` = 0.65 | `valid-predictive-validity-against-outcome` |
| beats baseline | AUC(metric) − AUC(LOC) | ≥ 0 | `valid-beat-the-trivial-baseline` |

Missing columns are skipped, not failed. Defaults are lenient by design; the design skill argues for
a stricter discriminant bar — lower `DISCRIMINANT_MAX` for a real run.

## Validating your own metric

1. Point the harness at your metric and corpus (edit `config.json` or export env vars):
   ```bash
   export METRIC_CMD="python3 /abs/path/mymetric.py"
   export CORPUS_DIR="/abs/path/corpus"          # *.py (or your language) files
   export LABELS_CSV="/abs/path/labels.csv"      # path[,outcome][,accepted]
   ```
2. Confirm the adapter: `bash scripts/run-metric.sh /abs/path/corpus/some_file`
3. Run the harness: `bash scripts/verify.sh`
4. For a stricter validity bar: `DISCRIMINANT_MAX=0.8 PREDICTIVE_MIN=0.7 bash scripts/verify.sh`

The corpus CSV's `path` column is resolved relative to the CSV's own directory.

## Building a labeled corpus

- `path` — relative path to each artifact (required)
- `outcome` — 0/1 label of the real outcome you want the metric to predict (defects, churn, incidents)
- `accepted` — an existing trusted measure of the same construct, for convergent validity

20–50 rows give more stable statistics than the 6-row demo. Prefer a temporal split (label with a
later outcome than the snapshot you measure) to avoid leakage — see `valid-validate-out-of-sample`.

## Non-code metrics

The bundled fixtures and transforms are Python, but the contract is generic. To validate a metric
over other artifacts, supply your own `corpus_dir`, `labels_csv`, and a `metric_cmd` that reads them.
The cosmetic/grow transforms used by the invariance and monotonicity checks are Python-specific; for
other domains, point those checks at domain-appropriate transformed fixtures or skip them and rely on
determinism, robustness, tractability, and validity.

## Troubleshooting

| Symptom | Cause / fix |
|---------|-------------|
| "metric did not print one number" | The command printed extra text. Send logs to stderr; print only the number. |
| "metric command failed" | The command exited non-zero on a fixture. Run `scripts/run-metric.sh <file>` to see stderr. |
| determinism FAIL only across seeds | Set/dict ordering leaks into the result; sort before reducing. |
| validity SKIP everywhere | The CSV is missing `accepted`/`outcome` columns, or `labels_csv` is unset. |
| spaces-in-path errors (bash checks) | Move the skill/metric to a space-free path or wrap the metric in a launcher script. |
