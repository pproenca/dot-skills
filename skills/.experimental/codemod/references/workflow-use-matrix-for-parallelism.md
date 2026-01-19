---
title: Use Matrix Strategy for Parallelism
impact: MEDIUM-HIGH
impactDescription: 3-10x speedup for independent transformations
tags: workflow, matrix, parallelism, sharding
---

## Use Matrix Strategy for Parallelism

Use matrix strategies to parallelize transforms across teams, directories, or configurations. Independent work items run concurrently.

**Incorrect (sequential processing):**

```yaml
# workflow.yaml - processes teams one by one
version: "1"
nodes:
  - id: migrate-team-a
    steps:
      - type: js-ast-grep
        codemod: ./scripts/migrate.ts
        target: ./packages/team-a

  - id: migrate-team-b
    depends_on: [migrate-team-a]  # Unnecessary wait
    steps:
      - type: js-ast-grep
        codemod: ./scripts/migrate.ts
        target: ./packages/team-b

  - id: migrate-team-c
    depends_on: [migrate-team-b]
    steps:
      - type: js-ast-grep
        codemod: ./scripts/migrate.ts
        target: ./packages/team-c
# Total time: A + B + C
```

**Correct (parallel matrix execution):**

```yaml
# workflow.yaml - parallel team processing
version: "1"

state:
  teams:
    - team-a
    - team-b
    - team-c

nodes:
  - id: migrate-teams
    strategy:
      type: matrix
      from_state: teams
    steps:
      - type: js-ast-grep
        codemod: ./scripts/migrate.ts
        target: ./packages/${{ matrix.value }}
# Total time: max(A, B, C)

  - id: run-tests
    depends_on: [migrate-teams]
    steps:
      - type: run
        command: npm test
```

**Access matrix values in transforms:**

```typescript
const transform: Transform<TSX> = (root, options) => {
  const team = options.matrixValues?.value;

  // Apply team-specific rules
  if (team === "team-a") {
    // Special handling for team-a
  }

  return null;
};
```

**Matrix use cases:**
- Team/directory sharding
- Multi-variant transforms (different configs)
- Language-specific processing
- Repository-parallel execution

Reference: [Codemod Workflow Reference](https://docs.codemod.com/workflows/reference)
