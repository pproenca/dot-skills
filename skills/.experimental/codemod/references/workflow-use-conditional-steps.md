---
title: Use Conditional Steps for Dynamic Workflows
impact: MEDIUM-HIGH
impactDescription: reduces execution time by 30-70% for partial migrations
tags: workflow, conditional, if, dynamic
---

## Use Conditional Steps for Dynamic Workflows

Use `if` expressions to conditionally execute steps based on state, parameters, or previous results.

**Incorrect (always running all steps):**

```yaml
# workflow.yaml - runs everything regardless
version: "1"
nodes:
  - id: migrate
    steps:
      - type: js-ast-grep
        codemod: ./scripts/react-18.ts

      - type: js-ast-grep
        codemod: ./scripts/react-19.ts
        # Runs even if not needed

      - type: run
        command: npm run typecheck
        # Runs even if no changes were made
```

**Correct (conditional execution):**

```yaml
# workflow.yaml - smart step execution
version: "1"

params:
  react_version:
    type: string
    default: "19"
  skip_typecheck:
    type: boolean
    default: false

nodes:
  - id: migrate
    steps:
      - type: js-ast-grep
        codemod: ./scripts/react-18.ts
        if: ${{ params.react_version == "18" }}

      - type: js-ast-grep
        codemod: ./scripts/react-19.ts
        if: ${{ params.react_version == "19" }}

      - type: run
        command: npm run typecheck
        if: ${{ !params.skip_typecheck }}
```

**Conditional based on state:**

```yaml
version: "1"

state:
  has_typescript: false

nodes:
  - id: detect-typescript
    steps:
      - type: run
        command: test -f tsconfig.json && echo "true" || echo "false"
        output: has_typescript

  - id: type-migration
    depends_on: [detect-typescript]
    steps:
      - type: js-ast-grep
        codemod: ./scripts/add-types.ts
        if: ${{ state.has_typescript == "true" }}
```

**Conditional expressions:**
- `${{ params.x == "value" }}`
- `${{ state.flag == true }}`
- `${{ !params.skip }}`
- `${{ matrix.value == "special" }}`

Reference: [Codemod Workflow Reference](https://docs.codemod.com/workflows/reference)
