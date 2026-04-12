# Transcript — shipit deploy scaffold

## Skill files consulted (4, as instructed)

1. `cli-for-agents/SKILL.md` — rule index and priority categories
2. `references/idem-stable-identifiers.md` — idempotency-key pattern for deploys
3. `references/err-non-zero-exit-codes.md` — sysexits.h taxonomy (0/1/2/75)
4. `references/output-respect-no-color.md` — NO_COLOR env var and TTY gating

## Rules applied

- **idem-stable-identifiers** — accept `--idempotency-key` and alias `--deployment-id`; when omitted, derive a deterministic key from `sha256(service:env:tag)` so timed-out retries hit the same deploy instead of creating ghost resources.
- **err-non-zero-exit-codes** — named constants `EX_OK=0`, `EX_FAILURE=1`, `EX_USAGE=2`, `EX_TEMPFAIL=75`. `TransientError` maps to 75 so agents retry with backoff; commander's usage errors are overridden to exit 2 via `exitOverride`.
- **output-respect-no-color** — `useColor()` checks `--no-color` flag first, then `NO_COLOR` env var (non-empty per no-color.org spec), then `stream.isTTY`. Called once per stream (stdout for success, stderr for errors).
- **help-examples-in-help** — `addHelpText('after', ...)` includes four copy-pasteable examples: minimal human, CI/agent with idempotency key + JSON, dry-run preview, and chaining into `verify` via `jq`.
- **help-no-flag-required** — `process.argv.length <= 2` falls through to `outputHelp()` instead of hanging.
- **err-actionable-fix** / **err-include-example-invocation** — `emitError()` always appends a `Try: …` line with a concrete invocation; cross-flag conflicts and prod-deploy-without-yes both emit fixes.
- **err-stderr-not-stdout** — `emitError()` writes to `process.stderr`; `emitSuccess()` writes to `process.stdout`; verbose progress goes to stderr so `--json` stdout stays parseable.
- **output-json-flag** — `--json` emits a single `JSON.stringify(result)` line on stdout with `deploy_id`, `idempotency_key`, `changed`, `status`, `url`.
- **output-machine-ids-on-success** + **help-suggest-next-steps** — non-JSON success block prints `deploy_id` and ends with `Next: shipit deploy verify --id <id>`.
- **safe-dry-run-flag** / **safe-force-bypass-flag** — `--dry-run` and `--yes` present; prod deploys in non-TTY refuse without `--yes`.
- **struct-standard-flag-names** — `--verbose`, short forms for every common flag (`-s`, `-e`, `-t`, `-k`, `-n`, `-y`, `-v`).
- **interact-detect-tty** — `process.stdin.isTTY` used for the prod-without-yes guard.

## Required flags added

`--service`, `--env`, `--tag` (all via `requiredOption`).

## Optional flags added

`--idempotency-key` / `-k`, `--deployment-id` (alias), `--dry-run` / `-n`, `--yes` / `-y`, `--json`, `--no-color`, `--verbose` / `-v`.

## Stubs

`runDeploy()` carries a TODO for wiring to the real API plus a fake `DeployResult` whose `deploy_id` is derived from the idempotency key so unit tests can assert retry stability.
