---
title: Enforce Parser Command Interface
impact: CRITICAL
impactDescription: wrong interface breaks 4 downstream tools (generator, runtime, mutator, reporter)
tags: parser, cli, command, exit-codes, interface
---

## Enforce Parser Command Interface

The parser is the pipeline entry point. A predictable command interface ensures that the generator, mutator, and scripts can invoke it without special-casing. If the parser's interface deviates from the spec, every downstream tool must compensate, creating fragile coupling.

### Spec Requirements

The parser command accepts exactly two positional arguments:

```sh
gherkin-parser <feature-file> <json-output>
```

- `<feature-file>` — path to the Gherkin source file to parse.
- `<json-output>` — path where the pretty-printed JSON IR will be written.

### Exit Codes

Exit codes must follow this contract so scripts can branch on failure:

| Code | Meaning |
|------|---------|
| `0` | Parse succeeded and JSON IR was written |
| `1` | Input/output/parsing error (bad Gherkin, file not found, write failure) |
| `2` | Wrong command usage (wrong number of arguments, unknown flags) |

### Why This Matters

The distinction between exit code 1 (content error) and exit code 2 (usage error) lets scripts provide different diagnostics. A usage error means the script itself is misconfigured. A parse error means the feature file needs fixing. Conflating these forces manual investigation of every failure.

The parser writes pretty-printed JSON IR. Pretty-printing costs negligible performance but makes the IR human-readable for debugging and diffing — critical during pipeline development.

### Examples

**Incorrect (single exit code for all errors conflates usage and parse failures):**

```sh
# Non-conforming: exits 1 for both bad arguments and parse errors
gherkin-parser
# exit code 1, message: "Error: missing arguments"

gherkin-parser bad.feature out.json
# exit code 1, message: "Error: parse failed at line 3"
```

**Correct (exit code 2 for usage errors, exit code 1 for parse errors):**

```sh
# Conforming: distinct exit codes enable script-level branching
gherkin-parser
# exit code 2, message: "Usage: gherkin-parser <feature-file> <json-output>"

gherkin-parser bad.feature out.json
# exit code 1, message: "Parse error at line 3: expected Feature: declaration"

gherkin-parser valid.feature out.json
# exit code 0, out.json written with pretty-printed JSON IR
```
