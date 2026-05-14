---
title: Enforce Generator Command Interface
impact: CRITICAL
impactDescription: wrong interface breaks the normal acceptance script and mutation workflow, failing 2 pipeline modes (normal run + mutation run)
tags: gen, cli, command, exit-codes, interface
---

## Enforce Generator Command Interface

The generator transforms JSON IR into executable acceptance tests. Like the parser, its command interface must be predictable so that scripts and the mutator can invoke it reliably.

### Spec Requirements

The generator command accepts exactly two positional arguments:

```sh
acceptance-generator <json-ir> <generated-test-output>
```

- `<json-ir>` — path to the JSON IR file (produced by the parser).
- `<generated-test-output>` — path where the generated executable test file will be written.

### Exit Codes

| Code | Meaning |
|------|---------|
| `0` | Generation succeeded |
| `1` | Input/output/generation error (invalid IR, write failure, unsupported IR content) |
| `2` | Wrong command usage (wrong number of arguments, unknown flags) |

### Why This Matters

The generator sits between the IR and the test runner. In the normal acceptance script, a generation failure must stop the pipeline (the script uses `set -eu`). In the mutation workflow, the mutator calls the generator once per mutation — a generation failure for a specific mutation classifies that mutation as `error`, not `killed` or `survived`.

The two-positional-arg interface mirrors the parser's interface, making the pipeline commands consistent and composable in scripts:

```sh
gherkin-parser features/a.feature build/acceptance/a.json
acceptance-generator build/acceptance/a.json acceptance/generated/a_test.ext
```

### Examples

**Incorrect (generator accepts flags instead of positional args, non-standard exit codes):**

```sh
acceptance-generator --input build/a.json --output acceptance/a_test.py
# exit code 255 on generation failure
```

**Correct (two positional args, exit codes 0/1/2 matching parser convention):**

```sh
acceptance-generator build/acceptance/a.json acceptance/generated/a_test.py
# exit code 0: generation succeeded
# exit code 1: invalid IR or write failure
# exit code 2: wrong number of arguments
```
