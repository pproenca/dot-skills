---
title: Install Convenience Pipeline Scripts
impact: MEDIUM
impactDescription: missing or incorrect scripts force manual multi-step invocation, risking stale tests and skipped steps in every run
tags: layout, scripts, acceptance, mutation, automation
---

## Convenience Scripts

The spec defines two convenience scripts: one for the normal acceptance run and one for mutation testing. These scripts provide stable, one-command entry points for the pipeline.

### Normal Acceptance Script

```sh
#!/bin/sh
set -eu

mkdir -p build/acceptance acceptance/generated

gherkin-parser \
  features/a-feature.feature \
  build/acceptance/a-feature.json

acceptance-generator \
  build/acceptance/a-feature.json \
  acceptance/generated/a-feature_acceptance_test.<test-extension>

<project-test-command> acceptance/generated
```

**Script requirements:**

1. **Stop on the first failed command** (`set -eu`). A parse failure must not lead to running stale tests.
2. **Create required output directories** before writing files. The script must not assume directories exist.
3. **Treat parser, generator, and test failures as script failures.** The script exit code must reflect any failure.
4. **Never run generated tests against the source feature file directly.** Generated tests must be created from the JSON IR every time. This ensures mutations (when applied to the IR) are reflected in the tests.

### Mutation Script

```sh
#!/bin/sh
set -eu

gherkin-mutator --feature features/a-feature.feature "$@"
```

The mutator command owns parsing, mutation, generation, test execution, and reporting. The mutation script is a thin wrapper that passes through additional arguments (like `--workers`, `--timeout`, `--json`).

### Why `set -eu`

- `set -e` — Exit on the first command that fails. Without this, the script continues after a parser failure and runs stale generated tests, producing misleading results.
- `set -u` — Treat unset variables as errors. Prevents silent failures from typos in variable names.

### Why Regenerate Every Time

Requirement 4 is critical for the mutation workflow. The mutator modifies the IR and asks the generator to produce tests from the modified IR. If the normal script cached generated tests and reused them, the mutation workflow would test the base IR instead of the mutated IR. Always regenerating from IR keeps the pipeline correct.

### Examples

**Incorrect (no set -eu, missing mkdir -- continues after parser failure and may fail on missing dirs):**

```sh
#!/bin/sh

gherkin-parser features/a-feature.feature build/acceptance/a-feature.json
# If parser fails, script continues and runs stale generated tests
acceptance-generator build/acceptance/a-feature.json \
  acceptance/generated/a-feature_acceptance_test.ext
run-tests acceptance/generated
```

**Correct (set -eu, mkdir -p, all failures propagated):**

```sh
#!/bin/sh
set -eu

mkdir -p build/acceptance acceptance/generated

gherkin-parser \
  features/a-feature.feature \
  build/acceptance/a-feature.json

acceptance-generator \
  build/acceptance/a-feature.json \
  acceptance/generated/a-feature_acceptance_test.ext

run-tests acceptance/generated
```

### Why This Matters

Without scripts, running the pipeline requires remembering and typing multiple commands in the correct order. Scripts encode this knowledge and make the pipeline runnable with a single command — essential for CI integration and for developers who did not write the pipeline.
