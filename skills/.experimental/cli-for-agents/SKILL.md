---
name: cli-for-agents
description: Use this skill whenever designing, building, or reviewing a command-line tool that AI agents or automation will invoke — covers non-interactive flags, layered --help with examples, stdin/pipeline composition, actionable errors, idempotency, dry-run, destructive-action safety, and predictable command structure. Trigger even if the user doesn't explicitly say "agent-friendly" — apply whenever they are writing `--help` text, adding a new subcommand, designing error messages, or reviewing a CLI's UX.
---

# Agent-Friendly CLI Design Best Practices

Prescriptive design and review standards for Command-Line Interface Design targeting AI agents and scripts, not just humans typing at a prompt. Human-oriented CLIs often block agents: interactive prompts, huge upfront docs, help text without copy-pasteable examples, error messages without fixes, no dry-run mode. This skill prioritizes rules by blast radius — from "the agent cannot use this CLI at all" (CRITICAL) to "the agent has to read help one extra time" (MEDIUM).

Use this skill both when **building** a new CLI and when **reviewing** an existing one for agent-friendliness.

This skill contains **45 rules across 8 categories**.

## When to Apply

Reference these guidelines when:
- Writing `--help` text for any subcommand
- Designing new flags, arguments, or subcommands
- Crafting error messages or exit codes
- Adding destructive operations that need dry-run or confirmation
- Choosing between interactive prompts and flag-only inputs
- Shaping success output so agents can chain commands
- Reviewing an existing CLI for headless-usability regressions

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Non-interactive Operation | CRITICAL | `interact-` |
| 2 | Help Text Design | HIGH | `help-` |
| 3 | Error Messages | HIGH | `err-` |
| 4 | Destructive Action Safety | HIGH | `safe-` |
| 5 | Input Handling | HIGH | `input-` |
| 6 | Output Format | MEDIUM-HIGH | `output-` |
| 7 | Idempotency & Retries | MEDIUM-HIGH | `idem-` |
| 8 | Command Structure | MEDIUM | `struct-` |

Note: `help-examples-in-help` is rated CRITICAL within the HIGH `help-` category because its specific failure — help text without examples — makes every other help rule moot. The category label reflects the average, not the worst case.

## Quick Reference

### 1. Non-interactive Operation (CRITICAL)

- [`interact-flags-first`](references/interact-flags-first.md) — Express every input as a flag first; prompts are TTY-only fallback
- [`interact-detect-tty`](references/interact-detect-tty.md) — Check `isatty()` before prompting
- [`interact-no-arrow-menus`](references/interact-no-arrow-menus.md) — Replace arrow-key menus with flag-selected choices
- [`interact-no-input-flag`](references/interact-no-input-flag.md) — Support `--no-input` to force non-interactive mode
- [`interact-no-timed-prompts`](references/interact-no-timed-prompts.md) — Never use timed prompts or press-any-key screens
- [`interact-no-hang-on-stdin`](references/interact-no-hang-on-stdin.md) — Don't block on stdin when a TTY is attached

### 2. Help Text Design (HIGH)

- [`help-examples-in-help`](references/help-examples-in-help.md) — Include copy-pasteable examples in every `--help`
- [`help-per-subcommand`](references/help-per-subcommand.md) — Every subcommand owns its own `--help`
- [`help-no-flag-required`](references/help-no-flag-required.md) — Show help when invoked with zero arguments
- [`help-layered-discovery`](references/help-layered-discovery.md) — Top-level help is a navigational index
- [`help-flag-summary`](references/help-flag-summary.md) — List both short and long forms for every flag
- [`help-suggest-next-steps`](references/help-suggest-next-steps.md) — Suggest what to run next in help and success output

### 3. Error Messages (HIGH)

- [`err-exit-fast-on-missing-required`](references/err-exit-fast-on-missing-required.md) — Exit fast on missing required flags
- [`err-actionable-fix`](references/err-actionable-fix.md) — Include a concrete fix in every error message
- [`err-stderr-not-stdout`](references/err-stderr-not-stdout.md) — Send errors to stderr, not stdout
- [`err-non-zero-exit-codes`](references/err-non-zero-exit-codes.md) — Use distinct non-zero exit codes for distinct failures
- [`err-include-example-invocation`](references/err-include-example-invocation.md) — Include a correct example invocation in errors
- [`err-no-stack-traces-by-default`](references/err-no-stack-traces-by-default.md) — Reserve stack traces for `--debug` mode

### 4. Destructive Action Safety (HIGH)

- [`safe-dry-run-flag`](references/safe-dry-run-flag.md) — Provide `--dry-run` for every destructive command
- [`safe-force-bypass-flag`](references/safe-force-bypass-flag.md) — Provide `--yes` / `--force` to skip confirmations
- [`safe-confirm-by-typing-name`](references/safe-confirm-by-typing-name.md) — Require typing the resource name for irreversible actions
- [`safe-no-prompts-with-no-input`](references/safe-no-prompts-with-no-input.md) — Never prompt when `--no-input` is set
- [`safe-idempotent-cleanup`](references/safe-idempotent-cleanup.md) — Exit successfully when delete targets are already gone
- [`safe-crash-only-recovery`](references/safe-crash-only-recovery.md) — Design multi-step commands for crash-only recovery

### 5. Input Handling (HIGH)

- [`input-accept-stdin-dash`](references/input-accept-stdin-dash.md) — Accept `-` as filename for stdin and stdout
- [`input-flags-over-positional`](references/input-flags-over-positional.md) — Prefer named flags over positional arguments
- [`input-stdin-for-secrets`](references/input-stdin-for-secrets.md) — Accept secrets through stdin or file, never as flag values
- [`input-env-var-fallback`](references/input-env-var-fallback.md) — Accept common flags through environment variables
- [`input-no-prompt-fallback`](references/input-no-prompt-fallback.md) — Never fall back to a prompt when a flag is missing

### 6. Output Format (MEDIUM-HIGH)

- [`output-json-flag`](references/output-json-flag.md) — Provide `--json` for stable machine-readable output
- [`output-ndjson-streaming`](references/output-ndjson-streaming.md) — Stream large result sets as NDJSON
- [`output-bounded-by-default`](references/output-bounded-by-default.md) — Bound default output size with `--limit` and `--all`
- [`output-machine-ids-on-success`](references/output-machine-ids-on-success.md) — Return chainable values on success, not just "Done"
- [`output-respect-no-color`](references/output-respect-no-color.md) — Disable ANSI color when `NO_COLOR` or non-TTY
- [`output-no-decorative-only`](references/output-no-decorative-only.md) — Avoid relying on decorative output to convey state
- [`output-one-record-per-line`](references/output-one-record-per-line.md) — One record per line for grep-able human output

### 7. Idempotency & Retries (MEDIUM-HIGH)

- [`idem-retry-safe`](references/idem-retry-safe.md) — Make running the same command twice safe
- [`idem-create-or-skip`](references/idem-create-or-skip.md) — Make create commands skip when target already exists
- [`idem-stable-output-on-skip`](references/idem-stable-output-on-skip.md) — Return the same output shape whether acting or skipping
- [`idem-state-reconciliation`](references/idem-state-reconciliation.md) — Prefer "ensure state" semantics over delta application
- [`idem-stable-identifiers`](references/idem-stable-identifiers.md) — Accept user-provided names instead of auto-generating IDs

### 8. Command Structure (MEDIUM)

- [`struct-resource-verb`](references/struct-resource-verb.md) — Use a consistent resource-verb command shape
- [`struct-flag-order-independent`](references/struct-flag-order-independent.md) — Parse flags in any position relative to subcommands
- [`struct-no-hidden-subcommand-catchall`](references/struct-no-hidden-subcommand-catchall.md) — Avoid catch-all handlers for unknown subcommands
- [`struct-standard-flag-names`](references/struct-standard-flag-names.md) — Use standard flag names (`--help`, `--version`, `--verbose`, `--quiet`)

## How to Use

### When building a new CLI

Start at CRITICAL and walk down. The first two categories (`interact-` and `help-`) are non-negotiable — if any rule in these is violated, the CLI is unusable by agents regardless of how good the rest is. After those, work through `err-`, `safe-`, and `input-` — these are where most real-world friction lives. `output-`, `idem-`, and `struct-` are polish that compounds across many invocations.

### When reviewing an existing CLI

Run through this checklist in priority order:

1. **Non-interactive path** — invoke every subcommand with `--no-input` or under `</dev/null` and see which hang
2. **Layered help** — does `mycli --help` list subcommands only, or dump everything?
3. **Examples on `--help`** — every subcommand's help should end with a runnable Examples section
4. **Error messages with invocations** — does every error tell the caller exactly which flag to add?
5. **stdin/pipeline story** — can you pipe output into input? Does `-` mean stdin?
6. **Exit codes** — are usage errors (2), runtime failures (1), and transient failures (69) distinct?
7. **Dry-run** — every destructive command has `--dry-run` (or equivalent)
8. **Confirmation bypass** — every destructive command has `--yes`/`--force`
9. **Consistent command structure** — do `service list`, `deploy list`, `config list` all exist and work the same way?
10. **Structured success output** — does `deploy` return a `deploy_id` the agent can use next?

### Individual rules

Read individual reference files for detailed explanations and code examples:

- [Section definitions](references/_sections.md) — Category structure and impact levels
- [Rule template](assets/templates/_template.md) — Template for adding new rules

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for new rules |
| [metadata.json](metadata.json) | Version and reference information |
