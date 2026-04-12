# Workflow

Detailed methodology for each probe in cli-review-runner, including failure modes and how to extend the catalog when cli-for-agents grows.

## End-to-End Flow

```
review.sh --target <cli> [options]
  │
  ├─ [1] Flag parsing                      validate --target, --format, --timeout
  │
  ├─ [2] Resolve target                    absolute path or `command -v` lookup
  │                                        fail fast if missing / not executable
  │
  ├─ [3] Load config                       config.json → safe/destructive verb lists
  │                                        flag overrides win over file values
  │
  ├─ [4] Load rule catalog                 references/rule-catalog.tsv (45 rules)
  │                                        into CRR_RULE_* associative arrays
  │
  ├─ [5] Discover subcommands              crr_discover_subcommands parses --help
  │                                        OR use --subcommands override
  │
  ├─ [6] Initialize findings file          mktemp NDJSON file; trap cleanup on EXIT
  │
  ├─ [7] Run probes P1..P10                each probe appends NDJSON findings
  │                                        probes never abort the pipeline
  │
  └─ [8] Render report                     render.sh reads findings, emits text/json/ndjson
                                           exit 1 if any finding failed, 0 otherwise
```

## Probe Reference

### P1 - Non-interactive Operation

**Rules tested:** `interact-no-hang-on-stdin`, `interact-no-input-flag`, `interact-flags-first`, `interact-detect-tty`, `interact-no-timed-prompts`, `interact-no-arrow-menus`, `input-no-prompt-fallback`.

**Method:**
1. Run `target --help` under `</dev/null` with timeout. A hang implies stdin blocking.
2. Grep top-level `--help` for `--no-input` / `--non-interactive` / `--batch` / `--yes` flags.
3. Grep `--help` for timed-prompt language (`press any key`, `abort in N seconds`).
4. Grep `--help` for arrow-key hints (`use arrow keys`, `j/k to move`, arrow glyphs).
5. Pick the first safe verb from discovery; run it with no arguments under `</dev/null`. Hang implies prompting.

**Failure modes:**
- CLI hangs on top-level `--help`: rare, but reported as FAIL for `interact-no-hang-on-stdin`.
- CLI prompts for input on the first safe verb: FAIL for `interact-flags-first` and `interact-detect-tty` and `input-no-prompt-fallback`.
- CLI help mentions timed prompts even without running them: FAIL for `interact-no-timed-prompts` (cautious).

**Extension:** To catch arrow-key TUI detection for more frameworks, add patterns to the grep in `probe_p1_noninteractive`.

### P2 - Layered Help

**Rules tested:** `help-per-subcommand`, `help-no-flag-required`, `help-layered-discovery`.

**Method:**
1. Count lines in top-level `--help`. Over 200 lines = flat dump; under 10 = probably missing subcommand list.
2. Invoke the target with zero args. Should print usage-shaped output (not start work, not hang).
3. For each classified subcommand, invoke `target <verb> --help`. Count how many produce non-empty output with exit 0.

**Failure modes:**
- Top-level `--help` prints 500 lines of flag details across all subcommands: FAIL for `help-layered-discovery`.
- Running the target with no arguments starts an interactive REPL: probe P1 catches the hang; P2 reports `help-no-flag-required` FAIL.
- Some subcommands have `--help`, others don't: partial failure for `help-per-subcommand` with the count as evidence.

### P3 - Help Examples, Flag Summary, Next Steps

**Rules tested:** `help-examples-in-help`, `help-flag-summary`, `help-suggest-next-steps`.

**Method:** For each subcommand's `--help`:
1. Grep for a line matching `^[[:space:]]*example` (case-insensitive) - marks an Examples section.
2. Grep for `see also`, `next`, `then run`, `related` - hints at navigation guidance.
3. Grep for `-x, --long-form` pattern - marks short+long form flag listings.

Report per-rule as `X of Y subcommands have ...`.

**Failure modes:** Zero subcommands surfaced by discovery → probe defaults all P3 rules to PASS with "skipped" evidence. Explicit `--subcommands` fixes this.

### P4 - Actionable Errors

**Rules tested:** `err-actionable-fix`, `err-include-example-invocation`, `err-exit-fast-on-missing-required`, `err-no-stack-traces-by-default`.

**Method:**
1. Pick the first safe verb. Invoke it with a guaranteed-invalid flag: `--definitely-not-a-real-flag-xyz123`.
2. Capture stderr + stdout within the probe timeout.
3. Check exit code is non-zero (for `err-exit-fast-on-missing-required`).
4. Grep combined output for usage hints (`usage:`, `try:`, `example:`, `valid values`, `did you mean`).
5. Grep for indented/prefixed example invocations.
6. Grep for raw stack traces (`Traceback`, `File "...", line N`, `panic:`, `at path.js:123`).

**Failure modes:**
- CLI silently accepts bogus flags and exits 0: FAIL for `err-exit-fast-on-missing-required`.
- CLI errors generically ("invalid argument") with no fix: FAIL for `err-actionable-fix`.
- CLI dumps a Python Traceback in production path: FAIL for `err-no-stack-traces-by-default`.

### P5 - stderr Channeling

**Rule tested:** `err-stderr-not-stdout`.

**Method:** Invoke target with bogus top-level flag. Compare where error text landed:
- Only on fd 2 → PASS
- Only on fd 1 → FAIL (redirection breaks pipes)
- On both → FAIL (still dirties stdout)
- Exit 0 (no error) → skip-pass

### P6 - Exit Codes

**Rule tested:** `err-non-zero-exit-codes`.

**Method:**
1. Record exit of `target --help` (must be 0).
2. Record exit of `target --definitely-not-a-real-flag`. Distinct non-zero code expected.
3. Code 0 for the bogus path → FAIL (silent accept).
4. Code 1 → partial FAIL (1 is too generic; 2/64 is the convention for usage).
5. Code 2+ → PASS.

### P7 - stdin and Positional Composition

**Rules tested:** `input-accept-stdin-dash`, `input-flags-over-positional`.

**Method:**
1. For each subcommand's `--help`, grep for `stdin`, `STDIN`, `"-"`, or ` - ` patterns indicating `-` filename support.
2. Count positional placeholders `<NAME>` vs flags `--name` in top-level `--help`. Flags-heavy = PASS.

### P8 - Structured Output

**Rules tested:** `output-json-flag`, `output-respect-no-color`.

**Method:**
1. Grep top-level `--help` for `--json` or `--format json` advertising.
2. Pick first safe verb, invoke `target <verb> --json`, check first byte is `{` or `[`.
3. Run `target --help` with `NO_COLOR=1`, check output has no ANSI escape sequences.

### P9 - Destructive Safety

**Rules tested:** `safe-dry-run-flag`, `safe-force-bypass-flag`, `safe-no-prompts-with-no-input`.

**Method:** For each destructive verb discovered:
1. Invoke `target <verb> --help` (READ-ONLY - never with real arguments).
2. Grep for `--dry-run` / `-n` / `dry.run`.
3. Grep for `--force` / `--yes` / `-f` / `-y`.
4. Grep for `--no-input` / `--non-interactive` / `--batch`.

If no destructive verbs are discovered, the probe skip-passes all three rules.

### P10 - Command Structure

**Rules tested:** `struct-resource-verb`, `struct-standard-flag-names`, `struct-no-hidden-subcommand-catchall`, `struct-flag-order-independent`.

**Method:**
1. Grep top-level `--help` for `--help` and `--version`. Both required.
2. Invoke `target __crr_not_a_subcommand_zz`. Should exit non-zero (no silent catchall).
3. Invoke `target --help <verb>` AND `target <verb> --help`. Both should work.
4. Count subcommands matching `<resource>:<verb>` or `<resource> <verb>` shape.

## Extending the Catalog

When cli-for-agents adds a rule:
1. Append a row to `references/rule-catalog.tsv`: `rule_id<TAB>title<TAB>impact<TAB>probe_id<TAB>testable`.
2. Use `P1..P10` if an existing probe tests it; `manual` if it is not black-box testable.
3. If the new rule needs a new probe, add `probe_p11_...` to `scripts/lib/probes.sh` and call it from `review.sh`.
4. Update `SKILL.md` "Probe Coverage" table.
5. Add a selftest assertion in `scripts/selftest.sh` that exercises the new rule.
6. Run `bash scripts/selftest.sh` to confirm no regressions.

## Error Handling and Resumability

- Every probe catches its own errors and emits findings instead of aborting. `review.sh::run_probe` logs a warning if a probe function returns non-zero but keeps the pipeline moving.
- The findings file is `mktemp`'d and cleaned up via `trap EXIT` - there is nothing to resume; a re-run is the recovery path.
- Exit codes from `review.sh`:
  - `0` all findings passed
  - `1` at least one finding failed (normal when a CLI has issues)
  - `2` usage error from `review.sh` itself
  - `66` target CLI not found or not executable
  - `75` a probe timed out; partial findings may still be rendered

## Troubleshooting

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| `subcommands: <none discovered>` | Non-standard help shape | Pass `--subcommands verb1,verb2,...` |
| Every probe times out | macOS without GNU `timeout` and Perl behaving oddly | `brew install coreutils` |
| `line N: service: command not found` | Regression in a probe's evidence message using backticks | Replace backticks with single quotes in the probe emit call |
| `0 findings` in output | Regression in `(( counter++ ))` under `set -e` | Replace with `(( counter+=1 ))` |
| Probe reports PASS on obviously broken CLI | Heuristic gap | Add more specific grep patterns in the probe function |
