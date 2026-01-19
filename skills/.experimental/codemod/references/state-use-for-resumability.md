---
title: Use State for Resumable Migrations
impact: MEDIUM
impactDescription: enables restart from failure point in long migrations
tags: state, resumability, persistence, migration
---

## Use State for Resumable Migrations

Persist migration progress in workflow state. When migrations fail mid-way, you can resume from the last successful point.

**Incorrect (no state tracking):**

```yaml
# workflow.yaml - no progress tracking
version: "1"
nodes:
  - id: migrate-all
    steps:
      - type: js-ast-grep
        codemod: ./scripts/migrate.ts
        # Processes all 5000 files
        # Fails at file 3000
        # Must restart from beginning
```

**Correct (state-tracked progress):**

```yaml
# workflow.yaml - resumable migration
version: "1"

state:
  processed_files: []
  failed_files: []
  current_batch: 0

nodes:
  - id: list-files
    steps:
      - type: run
        command: find ./src -name "*.tsx" | sort
        output: all_files

  - id: process-batch
    depends_on: [list-files]
    strategy:
      type: matrix
      from_state: all_files
    steps:
      - type: js-ast-grep
        codemod: ./scripts/migrate.ts
        target: ${{ matrix.value }}
        on_success: processed_files@=${{ matrix.value }}
        on_failure: failed_files@=${{ matrix.value }}
```

**Resume after failure:**

```bash
# Check status
npx codemod workflow status -w ./workflow.yaml
# Shows: 3000/5000 files processed

# Resume from last state
npx codemod workflow resume -w ./workflow.yaml
# Continues from file 3001
```

**State operations:**
- `KEY=VALUE` - set value
- `KEY@=VALUE` - append to array
- `KEY.nested=VALUE` - set nested property

Reference: [Codemod Workflow Reference](https://docs.codemod.com/workflows/reference)
