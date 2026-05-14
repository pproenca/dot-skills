---
title: Create Required Project Directories
impact: MEDIUM
impactDescription: missing directories cause file-not-found errors on first pipeline run, blocking all 4 pipeline stages
tags: layout, paths, directories, project-structure
---

## Required Project Paths

A conforming pipeline setup must create specific directories. These paths establish the convention that all pipeline components follow — the parser knows where to write, the generator knows where to read, and the mutator knows where to create work directories.

### Spec Requirements

A conforming setup should create these paths or their project-specific equivalents:

```text
features/a-feature.feature
build/acceptance/a-feature.json
build/acceptance-mutation/
acceptance/generated/
```

| Path | Purpose |
|------|---------|
| `features/` | Gherkin feature files (pipeline input) |
| `build/acceptance/` | Parsed JSON IR files (parser output, generator input) |
| `build/acceptance-mutation/` | Mutation work directories (mutator workspace) |
| `acceptance/generated/` | Generated test files (generator output, runner input) |

### Why `build/` for Intermediate Files

Parser output (JSON IR) and mutation work files are build artifacts — they are derived from source files and can be regenerated. Placing them under `build/` follows the convention of keeping derived files separate from source files, making `.gitignore` rules simple (`build/`).

### Why `acceptance/generated/` Separate from `build/`

Generated tests are not just intermediate files — they are executable tests that the project's test runner discovers and runs. Some test frameworks require tests to be in specific locations. Keeping them under `acceptance/generated/` puts them near the project's test root while clearly marking them as generated (not hand-written).

### Why This Matters

The normal acceptance script and mutation script both reference these paths. If the directories do not exist, the first `mkdir -p` in the script creates them. But if the convention is not followed, paths in the script will not match paths expected by the pipeline components, causing file-not-found errors.

Consistent paths also make it easy to understand a project's pipeline structure at a glance.

### Examples

**Incorrect (non-standard paths -- pipeline components cannot find each other's output):**

```text
src/gherkin/
  a-feature.feature
out/
  a-feature.json
tmp/mutations/
tests/auto/
```

**Correct (spec-conforming paths -- all pipeline components agree on locations):**

```text
features/
  a-feature.feature
build/acceptance/
  a-feature.json
build/acceptance-mutation/
acceptance/generated/
```
