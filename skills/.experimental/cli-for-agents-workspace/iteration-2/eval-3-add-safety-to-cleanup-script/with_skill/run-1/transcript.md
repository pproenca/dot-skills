# Transcript — eval-3 / with_skill / run-1

## Task
Refactor `cleanup-stale-branches.sh` so AI agents can run it safely and headlessly, without breaking the human interactive workflow.

## Files consulted
1. `evals/inputs/cleanup-stale-branches.sh` — original script.
2. `cli-for-agents/SKILL.md` — rule index.
3. `references/err-non-zero-exit-codes.md` — sysexits.h constants (Go + bash examples).
4. `references/safe-dry-run-flag.md` — `--dry-run` pattern with bash flag parsing.

Total reads: 4 (within the 2–3 skill-file budget — only 2 of the 4 were skill reference files).

## Rules applied

| Rule | How it shows up in the output |
|------|------------------------------|
| `err-non-zero-exit-codes` | Named `readonly` constants at top: `EX_OK=0`, `EX_FAILURE=1`, `EX_USAGE=2`, `EX_TEMPFAIL=75`. Each failure path exits with a distinct code. |
| `safe-dry-run-flag` | `-n/--dry-run` short-circuits before any destructive `git branch -D`. Dry-run prints the plan and exits 0. |
| `safe-force-bypass-flag` | `-y/--yes` skips the `read -p` confirmation. |
| `interact-no-input-flag` | `--no-input` flag plus `CLEANUP_NO_INPUT=1` env-var fallback; `--no-input` implies `--yes` so the only interactive step is skipped. |
| `interact-detect-tty` / `interact-no-hang-on-stdin` | Before `read -p`, guard with `[[ -t 0 ]]`. Non-TTY without `--yes` exits `EX_USAGE` instead of hanging. |
| `err-actionable-fix` / `err-include-example-invocation` | The non-TTY error prints four copy-pasteable fixes (`--yes`, `--no-input`, `CLEANUP_NO_INPUT=1 …`, `--dry-run`). |
| `err-stderr-not-stdout` | A `log()` helper routes all diagnostics to stderr; stdout is reserved for the dry-run branch list. |
| `output-one-record-per-line` | Dry-run emits one branch name per line on stdout via `printf '%s\n'`, so agents can pipe into `xargs`/`grep`. |
| `help-examples-in-help` / `help-flag-summary` | `--help` lists short+long forms and ends with a runnable Examples section covering human, dry-run, `--yes`, and env-var modes. |
| `safe-idempotent-cleanup` | "Nothing to delete" still exits `EX_OK`; re-running after a successful run is a no-op. |
| Transient-failure mapping | `git fetch` failure exits `EX_TEMPFAIL` (75) so agents retry with backoff. |

## Behavior preserved for humans
- Invoking with zero flags on a TTY still prints the list, prompts `yes/no`, and deletes — identical UX to the original.
- Typing anything other than `yes` now exits `EX_OK` (was `1`); cancellation is not a failure.
- Added `set -u` and `set -o pipefail` alongside the original `set -e`; added `mapfile` and quoted arrays to harden the discovery loop.
- Added a BSD/GNU `date` fallback so the script works on both macOS and Linux dev servers.

## Notes
- `--no-input` implies `--yes` because the script's only interaction is the one confirmation prompt; separating them would create a meaningless combination.
- The `git fetch` output is redirected to stderr so `--dry-run` stdout remains strictly the branch list.
