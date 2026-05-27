---
name: cli-review-runner
description: Use this skill whenever reviewing, auditing, or grading a command-line tool for agent-friendliness - it runs a black-box test suite against a target CLI and reports per-rule pass/fail from the cli-for-agents 45-rule catalog. Trigger even if the user doesn't explicitly say "agent-friendly" - apply whenever they ask "is mycli good for agents?", "review this CLI", "grade my cli against the rules", "check if this tool is safe to automate", or "audit command-line design". Companion to the cli-for-agents distillation skill.
---

# cli-review-runner

Automates the 10-item agent-friendliness audit from [cli-for-agents](../cli-for-agents/SKILL.md). Runs black-box probes against a target CLI and emits a structured report mapping each finding to a rule ID (e.g., `help-examples-in-help`, `err-non-zero-exit-codes`, `safe-dry-run-flag`). Default mode is read-only - probes never run destructive verbs with real arguments.

## When to Apply

- User asks to **review** or **audit** a CLI for agent-friendliness, automation readiness, or CI use
- User has just finished **building** a CLI and wants a pre-ship sanity check
- User is **grading** their own or a third-party CLI against the cli-for-agents catalog
- User is asking why a CLI is **hanging** an agent, **blowing up context**, or **failing to compose** in a pipeline
- PR review for a CLI change - quickly regress-test the `--help`, errors, and dry-run flags

## How to Use

The skill is orchestrated by **`scripts/review.sh`**. Point it at the target CLI (absolute path or PATH-resolvable name) and pick an output format.

```bash
# Default: text table on stdout, exit 0 if all passed, 1 if any failed
bash scripts/review.sh --target /usr/local/bin/mycli

# Machine-readable output
bash scripts/review.sh --target gh --format json
bash scripts/review.sh --target kubectl --format ndjson

# Supply subcommand list when auto-discovery misses them
bash scripts/review.sh --target gh --subcommands pr,issue,repo

# Preview what would run without touching the target CLI
bash scripts/review.sh --target mycli --dry-run

# Include risky probes on destructive verbs (off by default)
bash scripts/review.sh --target mycli --include-destructive
```

See `bash scripts/review.sh --help` for the full flag list.

## Workflow Overview

```
--target <cli>
   │
   ▼
[1] Validate target       fail fast if path missing or not executable
   │
   ▼
[2] Load rule catalog     references/rule-catalog.tsv (45 rules)
   │
   ▼
[3] Discover subcommands  parse top-level --help (gh/kubectl/commander shapes)
   │
   ▼
[4] Run probes P1..P10    each probe emits NDJSON findings to a temp file
   │
   ▼
[5] Render report         scripts/render.sh  ->  text | json | ndjson
```

Read [references/workflow.md](references/workflow.md) when you need the full probe-by-probe breakdown, failure modes, and how to extend the catalog.

## Probe Coverage

| Probe | Rules tested | Coverage |
|-------|-------------|----------|
| P1 Non-interactive | `interact-no-hang-on-stdin`, `interact-no-input-flag`, `interact-flags-first`, `interact-detect-tty`, `interact-no-timed-prompts`, `interact-no-arrow-menus`, `input-no-prompt-fallback` | Run under `</dev/null` with timeout; inspect help for interactive language |
| P2 Layered help | `help-per-subcommand`, `help-no-flag-required`, `help-layered-discovery` | Top-level line count; per-subcommand `--help`; zero-arg invocation |
| P3 Help examples | `help-examples-in-help`, `help-flag-summary`, `help-suggest-next-steps` | Grep each subcommand help for `Examples:`, short+long flag pairs, "See also" |
| P4 Actionable errors | `err-actionable-fix`, `err-include-example-invocation`, `err-exit-fast-on-missing-required`, `err-no-stack-traces-by-default` | Invoke with bogus flag; grep stderr for fix + example; check for raw stack traces |
| P5 stderr channeling | `err-stderr-not-stdout` | Error text must land on fd 2 |
| P6 Exit codes | `err-non-zero-exit-codes` | Usage error and runtime error must produce distinct non-zero codes |
| P7 stdin composition | `input-accept-stdin-dash`, `input-flags-over-positional` | Grep help for `-` stdin convention; count positionals vs flags |
| P8 Structured output | `output-json-flag`, `output-respect-no-color` | `--json` produces JSON; `NO_COLOR=1` suppresses ANSI |
| P9 Destructive safety | `safe-dry-run-flag`, `safe-force-bypass-flag`, `safe-no-prompts-with-no-input` | Inspect destructive verbs' `--help` for `--dry-run` / `--yes` / `--force` / `--no-input` |
| P10 Command structure | `struct-resource-verb`, `struct-standard-flag-names`, `struct-no-hidden-subcommand-catchall`, `struct-flag-order-independent` | Uniform shape, `--help`/`--version` present, unknown subcommand errors, flag position independence |

**Coverage:** 30 of the 45 rules in cli-for-agents are black-box testable. The remaining 15 (idempotency, state reconciliation, NDJSON streaming, bounded output, crash-only recovery, env-var fallback, secret-stdin, confirm-by-typing-name) require either real invocation or source-code inspection - the report lists them as "manual review required".

## Configuration

`config.json` stores the verb classifier lists and default timeout. The skill works without any setup - defaults are reasonable. Override per-invocation via flags or edit the file for project-wide changes.

```json
{
  "timeout_seconds": 5,
  "safe_verbs": ["list", "get", "show", "status", "describe", "help", "version", "config", "ls", "inspect"],
  "destructive_verbs": ["delete", "drop", "destroy", "remove", "reset", "purge", "rm", "del"]
}
```

## Safety Model

All probes are **read-only by default**:

- Safe verbs (list, get, show, ...) may be invoked with bogus flags to test error handling
- Destructive verbs (delete, drop, ...) are ONLY inspected via `--help` - never executed with arguments
- Every probe runs with a 5-second wall-clock timeout under `</dev/null`
- The target CLI is sandboxed to its own process; no shell metacharacters in arguments

When `--include-destructive` is passed, probes may invoke destructive verbs with bogus flags too. This exposes the rare case where a CLI does something destructive before validating flags. Only enable this against CLIs you trust, or in a disposable test environment.

## Self-test

Before shipping changes to probes, run the self-test - it generates a mock CLI that deliberately violates specific rules and asserts the probes detect them:

```bash
bash scripts/selftest.sh
```

Expected output: `Results: 8 passed, 0 failed`. Any failure points at a regression in `scripts/lib/probes.sh`.

## Files

| File | Purpose |
|------|---------|
| [scripts/review.sh](scripts/review.sh) | Main entry point - orchestrates probes, renders the report |
| [scripts/render.sh](scripts/render.sh) | Output formatter: text / json / ndjson |
| [scripts/selftest.sh](scripts/selftest.sh) | Sanity check against a deliberately-buggy mock CLI |
| [scripts/lib/common.sh](scripts/lib/common.sh) | Shared helpers: timeout, verb classifier, JSON escape, catalog loader |
| [scripts/lib/probes.sh](scripts/lib/probes.sh) | Probe functions `probe_p1..probe_p10` |
| [references/rule-catalog.tsv](references/rule-catalog.tsv) | 45 rules from cli-for-agents, mapped to probes |
| [references/workflow.md](references/workflow.md) | Detailed probe-by-probe methodology, failure modes, extension guide |
| [gotchas.md](gotchas.md) | Known edge cases discovered during use |
| [config.json](config.json) | Verb classifier lists and default timeout |

## Related Skills

- **[cli-for-agents](../cli-for-agents/SKILL.md)** - the 45-rule design catalog this skill audits against. Read rule files there when the report flags an issue and you need the full explanation.
