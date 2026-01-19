---
title: Order Nodes by Dependency
impact: MEDIUM-HIGH
impactDescription: prevents failed transforms due to missing prerequisites
tags: workflow, dependencies, ordering, dag
---

## Order Nodes by Dependency

Define explicit `depends_on` relationships between workflow nodes. The engine executes nodes in topological order based on dependencies.

**Incorrect (implicit ordering):**

```yaml
# workflow.yaml - assumes sequential execution
version: "1"
nodes:
  - id: add-types
    steps:
      - type: js-ast-grep
        codemod: ./scripts/add-types.ts

  - id: update-imports
    # No depends_on - might run before add-types!
    steps:
      - type: js-ast-grep
        codemod: ./scripts/update-imports.ts
        # Fails if types aren't added yet

  - id: run-tests
    steps:
      - type: run
        command: npm test
        # Might run before transforms complete
```

**Correct (explicit dependencies):**

```yaml
# workflow.yaml - explicit DAG
version: "1"
nodes:
  - id: add-types
    steps:
      - type: js-ast-grep
        codemod: ./scripts/add-types.ts

  - id: update-imports
    depends_on: [add-types]  # Explicit dependency
    steps:
      - type: js-ast-grep
        codemod: ./scripts/update-imports.ts

  - id: fix-lint
    depends_on: [update-imports]
    steps:
      - type: run
        command: npx eslint --fix .

  - id: run-tests
    depends_on: [fix-lint]  # Waits for all transforms
    steps:
      - type: run
        command: npm test
```

**Dependency patterns:**
- Transform order: `[parse] → [transform] → [format] → [test]`
- Parallel-safe nodes can omit mutual dependencies
- Use arrays for multiple dependencies: `depends_on: [a, b]`
- Cyclic dependencies are detected and rejected

Reference: [Codemod Workflow Reference](https://docs.codemod.com/workflows/reference)
