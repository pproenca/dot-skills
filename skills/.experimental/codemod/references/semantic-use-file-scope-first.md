---
title: Use File Scope Semantic Analysis First
impact: HIGH
impactDescription: 10-100x faster than workspace scope for local transforms
tags: semantic, file-scope, performance, analysis
---

## Use File Scope Semantic Analysis First

Start with file-scope semantic analysis, which is fast and requires no configuration. Only upgrade to workspace scope when cross-file resolution is necessary.

**Incorrect (workspace scope for local variables):**

```yaml
# workflow.yaml - unnecessary workspace scope
nodes:
  - id: rename-locals
    steps:
      - type: js-ast-grep
        codemod: ./scripts/rename.ts
        semantic_analysis: workspace  # Overkill for file-local transforms
        # Indexes entire project even for local renames
```

```typescript
const transform: Transform<TSX> = (root) => {
  const localVars = root.findAll({
    rule: { pattern: "const $NAME = $VALUE" }
  });
  // Only renaming within this file
  // Workspace indexing was wasted work
  return null;
};
```

**Correct (file scope for local, workspace for cross-file):**

```yaml
# workflow.yaml - appropriate scoping
nodes:
  - id: rename-locals
    steps:
      - type: js-ast-grep
        codemod: ./scripts/rename-locals.ts
        semantic_analysis: file  # Fast, local-only

  - id: rename-exports
    depends_on: [rename-locals]
    steps:
      - type: js-ast-grep
        codemod: ./scripts/rename-exports.ts
        semantic_analysis: workspace  # Needed for cross-file refs
```

```typescript
// rename-exports.ts - needs workspace scope
const transform: Transform<TSX> = async (root) => {
  const exportedFn = root.find({
    rule: { pattern: "export function $NAME($$$PARAMS) { $$$BODY }" }
  });

  if (!exportedFn) return null;

  // Cross-file reference finding requires workspace scope
  const refs = exportedFn.field("name")?.references();
  // refs contains references from other files
  return null;
};
```

**When to use workspace scope:**
- Renaming exported symbols
- Finding all usages across project
- Analyzing import/export relationships
- Refactoring public APIs

Reference: [JSSG Semantic Analysis](https://docs.codemod.com/jssg/semantic-analysis)
