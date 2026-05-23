# Gotchas

### The metric must print exactly ONE number to stdout
The adapter contract is strict: `$METRIC_CMD <path>` prints a single number and nothing else. Extra log lines, a trailing label, or a JSON blob make the harness reject the metric with "did not print one number." Send diagnostics to stderr.
Added: 2026-05-23

### No spaces in the skill path or in `metric_cmd`
The bash checks invoke `$METRIC_CMD "$path"` with word-splitting, so a command or path containing spaces breaks. Keep the skill under a space-free path and use a space-free `metric_cmd` (wrap your metric in a small launcher script if needed). The Python checks use `shlex.split`, so they tolerate quoting — but the bash checks do not.
Added: 2026-05-23

### macOS ships bash 3.2 — scripts are written for it
Empty-array expansion under `set -u` errors on bash 3.2, so `check-monotonicity.sh` guards `${values[@]}` behind a length check. If you add scripts, keep them 3.2-safe (no associative arrays, guard empty-array expansion).
Added: 2026-05-23

### Tractability is a blowup smoke test, not a microbenchmark
On the tiny ramp inputs, Python process-spawn (~40 ms) dominates the metric's own work, so the measured exponent is near 0 (sub-linear). That is expected — the check only catches egregious super-quadratic/exponential metrics. For real tractability numbers, profile your metric directly on production-sized inputs.
Added: 2026-05-23

### The discriminant threshold is intentionally lenient by default
`DISCRIMINANT_MAX` defaults to 0.97 (flag only a metric that is essentially LOC relabeled). The deterministic-metric-design skill argues for a stricter bar (cyclomatic correlating ~0.9 with LOC is already a failure). Lower `DISCRIMINANT_MAX` in the environment for a real validation run.
Added: 2026-05-23
