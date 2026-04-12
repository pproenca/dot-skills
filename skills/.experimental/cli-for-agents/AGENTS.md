# CLI Design

**Version 0.1.0**  
Agent-Friendly  
April 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Prescriptive design and review standards for command-line tools that AI agents and automation will invoke. Contains 45 rules across 8 categories, prioritized by blast radius from CRITICAL (non-interactive operation) through HIGH (help text design, error messages, destructive action safety, input handling) and MEDIUM-HIGH (output format, idempotency) to MEDIUM (command structure). Each rule explains the failure mode in concrete terms, provides production-realistic incorrect and correct examples in multiple languages (TypeScript, Python, Go, Rust, Bash), and links to authoritative sources including clig.dev, the Heroku CLI Style Guide, GNU Coding Standards, POSIX utility conventions, no-color.org, and the JSON Lines spec. Used both when building new CLIs and when reviewing existing ones for agent-friendliness regressions.

---

## Table of Contents

1. [Non-interactive Operation](references/_sections.md) — **CRITICAL**
   - 1.1 [Avoid Blocking on stdin When a TTY Is Attached](references/interact-no-hang-on-stdin.md) — HIGH (prevents indefinite hangs when no pipe is provided)
   - 1.2 [Check for a TTY Before Prompting](references/interact-detect-tty.md) — CRITICAL (prevents indefinite hangs under agents and CI)
   - 1.3 [Express Every Input as a Flag First](references/interact-flags-first.md) — CRITICAL (prevents indefinite hangs in headless environments)
   - 1.4 [Never Use Timed Prompts or Press-Any-Key Screens](references/interact-no-timed-prompts.md) — HIGH (prevents wall-clock waste on every retry)
   - 1.5 [Replace Arrow-Key Menus with Flag-Selected Choices](references/interact-no-arrow-menus.md) — CRITICAL (prevents blocking on inputs agents cannot produce)
   - 1.6 [Support a --no-input Flag to Force Non-Interactive Mode](references/interact-no-input-flag.md) — HIGH (prevents prompts inside harnesses that falsely report TTY)
2. [Help Text Design](references/_sections.md) — **HIGH**
   - 2.1 [Every Subcommand Owns Its Own --help](references/help-per-subcommand.md) — HIGH (reduces loaded help context by 80-95%)
   - 2.2 [Include Copy-Pasteable Examples in Every --help](references/help-examples-in-help.md) — CRITICAL (reduces invocation guessing to O(1) lookup)
   - 2.3 [List Both Short and Long Forms for Every Flag](references/help-flag-summary.md) — HIGH (prevents brittle single-letter scripts and collision bugs)
   - 2.4 [Show Help When Invoked With Zero Arguments](references/help-no-flag-required.md) — HIGH (prevents silent side effects from discovery attempts)
   - 2.5 [Structure Top-Level Help as a Navigational Index](references/help-layered-discovery.md) — HIGH (reduces top-level discovery context from ~200 lines to ~15)
   - 2.6 [Suggest What to Run Next in Help and Success Output](references/help-suggest-next-steps.md) — HIGH (prevents round-trips to top-level help for related commands)
3. [Error Messages](references/_sections.md) — **HIGH**
   - 3.1 [Exit Fast on Missing Required Flags](references/err-exit-fast-on-missing-required.md) — HIGH (prevents wasted wall-clock on every retry)
   - 3.2 [Include a Concrete Fix in Every Error Message](references/err-actionable-fix.md) — HIGH (reduces retry loops by collapsing guess-and-check to one round)
   - 3.3 [Include a Correct Example Invocation in Error Messages](references/err-include-example-invocation.md) — HIGH (reduces re-reads of --help after a failed command)
   - 3.4 [Reserve Stack Traces for --debug Mode](references/err-no-stack-traces-by-default.md) — MEDIUM-HIGH (reduces default error output by 10-50x)
   - 3.5 [Send Errors and Warnings to stderr, Not stdout](references/err-stderr-not-stdout.md) — HIGH (prevents error text from corrupting piped data)
   - 3.6 [Use Distinct Non-Zero Exit Codes for Distinct Failures](references/err-non-zero-exit-codes.md) — HIGH (prevents silent failures and unnecessary retries)
4. [Destructive Action Safety](references/_sections.md) — **HIGH**
   - 4.1 [Design Multi-Step Commands for Crash-Only Recovery](references/safe-crash-only-recovery.md) — MEDIUM-HIGH (prevents stuck-state requiring manual intervention)
   - 4.2 [Exit Successfully When Delete Targets Are Already Gone](references/safe-idempotent-cleanup.md) — MEDIUM-HIGH (prevents retry-loop errors on already-clean state)
   - 4.3 [Never Prompt When --no-input Is Set](references/safe-no-prompts-with-no-input.md) — HIGH (prevents silent fallback to prompts in scripted mode)
   - 4.4 [Provide --dry-run for Every Destructive Command](references/safe-dry-run-flag.md) — HIGH (prevents irreversible mistakes during agent exploration)
   - 4.5 [Provide --yes or --force to Skip Confirmation Prompts](references/safe-force-bypass-flag.md) — HIGH (prevents confirmation prompts from blocking scripted runs)
   - 4.6 [Require Typing the Resource Name for Irreversible Actions](references/safe-confirm-by-typing-name.md) — HIGH (prevents muscle-memory past safe-by-default y/N prompts)
5. [Input Handling](references/_sections.md) — **HIGH**
   - 5.1 [Accept `-` as Filename for stdin and stdout](references/input-accept-stdin-dash.md) — HIGH (prevents pipeline composition workarounds and temp files)
   - 5.2 [Accept Common Flags Through Environment Variables](references/input-env-var-fallback.md) — MEDIUM-HIGH (prevents repetition of the same flag on every invocation)
   - 5.3 [Accept Secrets Through stdin or File, Never as Flag Values](references/input-stdin-for-secrets.md) — HIGH (prevents secret leakage into ps output, shell history, and logs)
   - 5.4 [Never Fall Back to a Prompt When a Flag Is Missing](references/input-no-prompt-fallback.md) — MEDIUM-HIGH (prevents silent hangs when TTY detection misfires)
   - 5.5 [Prefer Named Flags Over Positional Arguments](references/input-flags-over-positional.md) — HIGH (prevents argument-order guessing and future breakage)
6. [Output Format](references/_sections.md) — **MEDIUM-HIGH**
   - 6.1 [Avoid Relying on Decorative Output to Convey State](references/output-no-decorative-only.md) — MEDIUM (prevents state from being lost when agents read raw bytes)
   - 6.2 [Bound Default Output Size with --limit and --all](references/output-bounded-by-default.md) — MEDIUM-HIGH (prevents agent context blowup on default list invocations)
   - 6.3 [Disable ANSI Color When NO_COLOR or Non-TTY](references/output-respect-no-color.md) — MEDIUM (prevents escape sequences from breaking regex matches)
   - 6.4 [Emit One Record Per Line for Grep-Able Human Output](references/output-one-record-per-line.md) — MEDIUM (prevents grep/awk/cut breakage on borders and wrapped cells)
   - 6.5 [Provide --json for Stable Machine-Readable Output](references/output-json-flag.md) — MEDIUM-HIGH (prevents brittle regex parsing of human-readable tables)
   - 6.6 [Return Chainable Values on Success, Not Just "Done"](references/output-machine-ids-on-success.md) — MEDIUM-HIGH (prevents round-trip lookups for IDs/URLs of just-created resources)
   - 6.7 [Stream Large Result Sets as NDJSON](references/output-ndjson-streaming.md) — MEDIUM-HIGH (prevents agent context blowup on large list commands)
7. [Idempotency & Retries](references/_sections.md) — **MEDIUM-HIGH**
   - 7.1 [Accept User-Provided Names Instead of Auto-Generating IDs](references/idem-stable-identifiers.md) — MEDIUM (prevents orphaned duplicates from timed-out retries)
   - 7.2 [Make Create Commands Skip When Target Already Exists](references/idem-create-or-skip.md) — MEDIUM-HIGH (prevents race conditions and wrapper if-exists checks)
   - 7.3 [Make Running the Same Command Twice Safe](references/idem-retry-safe.md) — MEDIUM-HIGH (prevents duplicate side effects on retry)
   - 7.4 [Prefer "Ensure State" Semantics Over Delta Application](references/idem-state-reconciliation.md) — MEDIUM (prevents errors when partial state is already applied)
   - 7.5 [Return the Same Output Shape Whether Acting or Skipping](references/idem-stable-output-on-skip.md) — MEDIUM (prevents downstream parser branching on did-anything-happen)
8. [Command Structure](references/_sections.md) — **MEDIUM**
   - 8.1 [Avoid Catch-All Handlers for Unknown Subcommands](references/struct-no-hidden-subcommand-catchall.md) — MEDIUM (prevents locking in support for every typo forever)
   - 8.2 [Parse Flags in Any Position Relative to Subcommands](references/struct-flag-order-independent.md) — MEDIUM (prevents confusing errors when agents append flags)
   - 8.3 [Use a Consistent Resource-Verb Command Shape](references/struct-resource-verb.md) — MEDIUM (prevents re-reading help for every new subcommand)
   - 8.4 [Use Standard Flag Names — --help, --version, --verbose, --quiet](references/struct-standard-flag-names.md) — MEDIUM (prevents agents from guessing wrong flags)

---

## References

1. [https://clig.dev/](https://clig.dev/)
2. [https://devcenter.heroku.com/articles/cli-style-guide](https://devcenter.heroku.com/articles/cli-style-guide)
3. [https://jdx.dev/posts/2018-10-08-12-factor-cli-apps/](https://jdx.dev/posts/2018-10-08-12-factor-cli-apps/)
4. [https://www.gnu.org/prep/standards/html_node/Command_002dLine-Interfaces.html](https://www.gnu.org/prep/standards/html_node/Command_002dLine-Interfaces.html)
5. [https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap12.html](https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap12.html)
6. [https://no-color.org/](https://no-color.org/)
7. [https://rust-cli.github.io/book/index.html](https://rust-cli.github.io/book/index.html)
8. [https://jsonlines.org/](https://jsonlines.org/)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |