---
name: metric-validation-harness
description: Use this skill to empirically validate a software metric before trusting or optimizing it — point it at any candidate metric (a command that takes a path and prints one number) plus a corpus, and it runs experiments that try to falsify each property a good metric must have. Checks determinism (same input, same number across runs and hash seeds), invariance to cosmetic edits (also an anti-gaming probe), monotonicity under construct-increasing edits, discrimination, robustness on edge inputs, near-linear tractability, and construct validity (convergent, discriminant vs LOC, predictive AUC, lift over a baseline). Trigger whenever someone proposes, reviews, tunes, or ships a metric, score, or index, asks "is this metric any good", suspects a score tracks LOC or jumps between runs, or builds a deterministic optimization target. It is the empirical companion to the deterministic-metric-design skill and is read-only.
---

# Metric Validation Harness

Point this harness at a candidate metric and a corpus, and it runs experiments that try to **falsify** each property a trustworthy, optimizable metric must have. It is the empirical companion to `deterministic-metric-design`: that skill tells you to *prove* monotonicity, invariance, determinism, and construct validity; this skill *runs the experiment* and reports PASS/FAIL, each result mapped to the design-skill category it checks.

**Read-only.** It computes and reports; it never modifies your metric, the corpus, or any external state. Safe to run unsupervised.

## When to Apply

- Someone proposes, reviews, tunes, or ships a metric / score / index and you need evidence it is sound
- A score "feels off" — you suspect it tracks LOC, jumps between runs, or saturates
- You are about to let an agent **optimize** a metric and need to know it can't be gamed by cosmetic edits
- You built a candidate per `deterministic-metric-design` and want to empirically confirm the properties you argued for
- You are choosing between two metrics and need to know which actually predicts the outcome (and beats a trivial baseline)

## Workflow Overview

```
config.json / env  →  resolve metric_cmd, corpus, thresholds (env > config > bundled default)
        │
        ▼
   verify.sh ──► determinism ─ invariance ─ monotonicity ─ robustness ─ tractability ─ validity
        │            (each property check maps to a deterministic-metric-design category)
        ▼
   PASS / FAIL per property  →  exit 0 (all pass) or 1 (any group failed)
```

## The Adapter Contract

Your metric is **any command that takes a path as its last argument and prints exactly one number to stdout**:

```bash
$ python3 mymetric.py path/to/file.py
42
```

Language-agnostic — Python, a shell one-liner, a compiled binary, anything. Diagnostics go to stderr; stdout is the number only. A bundled example metric (`scripts/examples/metric_ast_nodes.py`, AST-node count) ships so the harness runs out of the box.

## How to Run

```bash
# 1. Validate the bundled example metric (works with zero setup):
bash scripts/verify.sh

# 2. Validate YOUR metric — set metric_cmd in config.json, or override per-run:
METRIC_CMD="python3 /abs/path/mymetric.py" bash scripts/verify.sh

# 3. Prove the harness itself works (positive + negative cases):
bash scripts/selftest.sh

# 4. Sanity-check your adapter prints one number:
bash scripts/run-metric.sh path/to/file.py
```

`verify.sh` runs every check and prints a final PASS/FAIL. Each check is also runnable on its own (e.g. `bash scripts/check-determinism.sh`).

## What It Checks

| Check | Maps to (design skill) | What it does | PASS condition |
|-------|------------------------|--------------|----------------|
| `check-determinism.sh` | `det-` | Runs the metric twice + under `PYTHONHASHSEED` 0/1 | identical number every time |
| `check-invariance.sh` | `prop-` / `game-` | Adds comments/blank lines/whitespace (cosmetic) | score unchanged (else it's gameable) |
| `check-monotonicity.sh` | `prop-` | Appends a code block (construct-increasing) + checks spread | score non-decreasing; not saturated |
| `check-robustness.sh` | `prop-` | Empty + single-statement edge inputs | finite, in declared range, no crash |
| `check-tractability.py` | `comp-` | Times the metric on growing inputs | within budget, sub-quadratic growth |
| `check-validity.py` | `valid-` | Spearman vs accepted, vs LOC; AUC vs outcome | convergent high, discriminant not ~LOC, predictive beats baseline |

Statistics (Spearman, AUC/Mann–Whitney) are pure Python stdlib — no numpy/scipy.

## Setup & Configuration

The harness runs with **zero config** against the bundled example. To validate your own metric, set fields in [`config.json`](config.json) (or override any of them with the matching `UPPER_CASE` environment variable per run):

| config.json | Env override | Meaning |
|-------------|--------------|---------|
| `metric_cmd` | `METRIC_CMD` | your metric command (path-printing → number) |
| `baseline_cmd` | `BASELINE_CMD` | trivial baseline (default: bundled LOC) |
| `corpus_dir` | `CORPUS_DIR` | artifacts the property checks iterate over |
| `labels_csv` | `LABELS_CSV` | `path[,outcome][,accepted]` for validity |
| `declared_min` / `declared_max` | `DECLARED_MIN` / `DECLARED_MAX` | range the robustness check enforces |

Validity thresholds are env-tunable: `CONVERGENT_MIN`, `DISCRIMINANT_MAX`, `PREDICTIVE_MIN` (defaults are lenient — tighten for a real run; see `gotchas.md`).

Empty config fields fall back to the bundled demo, so the skill never crashes on missing setup — it runs the example instead.

## Tool Requirements

- `python3` (3.8+) — runs the metric, the transforms, and the stats
- `bash` and `awk` — the orchestrator and numeric comparisons (scripts are macOS bash 3.2-safe)

No network, no external packages.

## Interpreting Results

A FAIL names the property and the design-skill rule to consult. Examples:
- *cosmetic noise moved the score* → the metric reads surface text; see `prop-prove-invariance-under-irrelevant-transforms` and `game-make-cheapest-improvement-the-right-one`.
- *score DROPPED after adding code* → non-monotonic; optimizing it can reward worse code (`prop-prove-monotonicity`).
- *|Spearman(metric, LOC)| too high* → it's LOC relabeled (`valid-discriminant-not-just-loc`).

## Related Skills

- `deterministic-metric-design` — the design half. Use it to *construct* the metric (define the construct, choose a computable proxy, pick the scale, argue the properties); use this harness to *empirically verify* what you argued.
- `same-results-less-code`, `complexity-optimizer`, `knip-deadcode` — prescriptive code-reduction skills; validate any reduction metric you build to drive them with this harness before letting an agent optimize against it.

See [`references/workflow.md`](references/workflow.md) for per-check details, how to wire up your own metric and corpus, and troubleshooting.
