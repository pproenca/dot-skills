# flagctl refactor — transcript

## Goal
Refactor the legacy `flagctl.py` click CLI to be agent-friendly (usable
headlessly by AI agents and CI) without breaking human ergonomics.

## Files read
- `evals/inputs/flagctl.py` (input)
- `cli-for-agents/SKILL.md`
- `references/help-examples-in-help.md`
- `references/output-bounded-by-default.md`
- `references/output-one-record-per-line.md`

## Rules applied

### Non-interactive operation
- `interact-flags-first`: every `create` input is now `--name`,
  `--description`, `--owner`. Old `input()` calls removed.
- `interact-detect-tty`: `_can_prompt()` requires `sys.stdin.isatty()
  and sys.stderr.isatty()` before any prompt fires.
- `interact-no-input-flag`: global `--no-input` disables prompting.
- `interact-no-hang-on-stdin`: when a flag is missing in non-TTY mode,
  we exit code 2 with an actionable message — never read stdin.
- `safe-no-prompts-with-no-input`: `--no-input` hard-disables prompts
  even in delete/toggle.

### Help text
- `help-examples-in-help`: every subcommand docstring ends with
  `\b\nExamples:\n` containing 2–3 copy-pasteable invocations; the top-level
  group also has examples.
- `help-per-subcommand`: each command owns its own `--help`.
- `help-no-flag-required`: `cli` uses `invoke_without_command=True` and
  prints help on bare invocation.
- `help-flag-summary`: `-h/--help` enabled via `context_settings`.

### Error messages
- `err-stderr-not-stdout`: `_eprint` routes all errors/hints to stderr.
- `err-actionable-fix` + `err-include-example-invocation`: `_die` accepts an
  `example=` and prints a `try: ...` line with a correct invocation.
- `err-non-zero-exit-codes`: distinct codes — `0` OK, `1` runtime,
  `2` usage, `69` service unavailable (500/502/URLError), `75` transient
  (429/503/504/timeout). Documented in module docstring.
- `err-exit-fast-on-missing-required`: missing flags fail with code 2
  before any network call.
- `err-no-stack-traces-by-default`: all `urllib`/JSON errors are caught
  and turned into short messages.

### Destructive action safety
- `safe-force-bypass-flag`: `--yes` on both `delete` and `toggle`.
- `safe-idempotent-cleanup` / `idem-retry-safe`: `toggle` is a no-op
  success when the flag is already in the requested `--state`.
- Non-TTY + no `--yes` = exit 2 with the exact `--yes` example,
  instead of hanging on `input()`.

### Output format
- `output-json-flag`: global `--json` plus per-command `--json` flag.
- `output-ndjson-streaming`: `list --json` emits one JSON object per line.
- `output-bounded-by-default`: `list` defaults to `--limit 50`; `--all`
  opts into everything; truncation hint goes to stderr.
- `output-one-record-per-line`: human `list` output is a header line
  plus `NAME\tSTATE\tUPDATED\tOWNER` — no `+---+` borders.
- `output-machine-ids-on-success`: `create`/`delete`/`toggle` echo the
  flag name to stdout so it can be piped into the next command;
  human-readable status messages go to stderr.

### Idempotency & env
- `input-env-var-fallback`: `FLAGCTL_API_BASE` overrides the API base.

## Result
One file, `outputs/flagctl.py`, human- and agent-friendly, with
prompt-safety, bounded output, structured errors, and copy-pasteable
examples in every `--help`.
