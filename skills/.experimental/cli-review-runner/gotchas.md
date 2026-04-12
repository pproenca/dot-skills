# Gotchas

Failure points and surprises discovered while using cli-review-runner. Add new entries with a date so future readers can judge freshness.

## Subcommand discovery is heuristic

The catalog parser recognizes three common `--help` shapes:
1. `Commands:` / `Available Commands:` header (commander.js, click, cobra)
2. `CORE COMMANDS` / `ACTIONS COMMANDS` uppercase-no-colon (gh)
3. `Basic Commands (Beginner):` with tag-aligned verbs (kubectl)

CLIs that invent a fourth shape will yield zero discovered subcommands, and probes that depend on subcommand enumeration (P2 per-subcommand help, P3 examples, P7 stdin, P9 destructive safety) will skip-pass with a note instead of running. **Workaround**: pass `--subcommands verb1,verb2,...` explicitly.

Added: 2026-04-12

## `timeout` is not built-in on macOS

macOS ships without GNU `timeout(1)`. `common.sh::crr_with_timeout` tries `timeout`, then `gtimeout` (from `brew install coreutils`), then falls back to a Perl one-liner. The Perl fallback uses `alarm` which fires SIGALRM and shows as exit 142 - we normalize it to 75 (`EX_TEMPFAIL`). If the target CLI traps SIGALRM, the Perl path will misreport. **Fix**: install coreutils or GNU timeout.

Added: 2026-04-12

## `set -e` and `(( var++ ))`

Bash arithmetic `(( x++ ))` returns exit code 1 when the PRE-increment value is 0 (which happens on every counter's first call). Under `set -e`, this aborts the script with no error message. This skill uses `(( var+=1 ))` instead, which returns exit code 0 unless the new value is 0 (which never happens when counting up). Noted here because it's an easy regression to reintroduce.

Added: 2026-04-12

## Safe-verbs vs destructive-verbs precedence

If `config.json` accidentally lists the same verb in both `safe_verbs` and `destructive_verbs`, the destructive list wins. `crr_is_safe_verb` calls `crr_is_destructive_verb` first and returns false on any match, so P1 (flag-first), P4 (bogus-flag), and P8 (`--json`) will NOT invoke the verb with real arguments - only P9 will inspect its `--help`. If you want a verb treated as safe, remove it from `destructive_verbs` first. A warning is printed to stderr when a verb appears in both lists so the misconfiguration surfaces on the first run.

Added: 2026-04-12

## P8 `--json` probe runs the target

Probe P8 invokes `target <safe_verb> --json` to see if JSON comes back. If the safe verb is classified wrong (it actually mutates state with `--json` somehow, or talks to a remote API without confirmation), the probe will cause a side effect. **Mitigation**: the probe only runs against ONE verb and only if that verb is in the `safe_verbs` allowlist. Audit the allowlist in `config.json` if you're probing against a CLI that uses unusual verb names.

Added: 2026-04-12
