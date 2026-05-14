---
title: Provide Standard Command Entry Points
impact: MEDIUM
impactDescription: inconsistent command names break convenience scripts, CI pipelines, and developer muscle memory across all projects
tags: layout, commands, entry-points, cli
---

## Command Entry Points

The spec recommends three command entry points. These are the stable names that scripts, CI systems, and developers invoke. The actual implementation behind each command is project-specific.

### Spec Requirements

Recommended command entry points:

```sh
gherkin-parser <feature-file> <json-output>
acceptance-generator <json-ir> <generated-test-output>
gherkin-mutator [options]
```

| Command | Purpose | Arguments |
|---------|---------|-----------|
| `gherkin-parser` | Parse Gherkin to JSON IR | 2 positional |
| `acceptance-generator` | Generate tests from JSON IR | 2 positional |
| `gherkin-mutator` | Run mutation testing | Options (--feature, --work-dir, etc.) |

### Why Named Commands, Not Direct Script Invocation

Named commands abstract the implementation. A project might implement the parser as:
- A compiled Go binary
- A Python script
- A Node.js CLI tool
- A shell script wrapping a library

The scripts and the mutator invoke `gherkin-parser` regardless of what is behind it. This means changing the implementation language does not require updating scripts.

### How to Provide Named Commands

Common approaches:
- Add the project's `bin/` directory to `PATH` and place executables there.
- Use the language's package manager (e.g., `go install`, `npm link`, `pip install -e .`).
- Define shell aliases or Makefile targets.
- Use `package.json` scripts or similar project-level command definitions.

### Examples

**Incorrect (ad-hoc script names -- scripts must hard-code implementation paths):**

```sh
#!/bin/sh
set -eu
python3 scripts/parse_gherkin.py features/a-feature.feature build/acceptance/a-feature.json
node tools/gen_tests.js build/acceptance/a-feature.json acceptance/generated/a-feature_test.js
```

**Correct (named commands -- scripts are implementation-agnostic):**

```sh
#!/bin/sh
set -eu
gherkin-parser features/a-feature.feature build/acceptance/a-feature.json
acceptance-generator build/acceptance/a-feature.json acceptance/generated/a-feature_test.js
```

### Why This Matters

Consistent command names make the pipeline self-documenting. A new developer looking at the acceptance script sees `gherkin-parser` and `acceptance-generator` — the names communicate what each step does. Custom names like `parse.sh` or `gen_tests.py` are less discoverable and harder to reference in documentation.
