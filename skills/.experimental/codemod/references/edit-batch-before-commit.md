---
title: Batch Edits Before Committing
impact: MEDIUM-HIGH
impactDescription: prevents edit conflicts and improves performance
tags: edit, batching, commitEdits, performance
---

## Batch Edits Before Committing

Collect all edits into an array and call `commitEdits()` once at the end. Multiple commits can cause conflicts and performance degradation.

**Incorrect (committing inside loop):**

```typescript
const transform: Transform<TSX> = (root) => {
  const consoleCalls = root.findAll({
    rule: { pattern: "console.log($$$ARGS)" }
  });

  let result = root.root().text();

  for (const call of consoleCalls) {
    // Each commit regenerates the entire source string
    result = root.commitEdits([call.replace("logger.info()")]);
    // Edits applied sequentially - O(n²) string operations
    // Later edits may use stale positions
  }

  return result;
};
```

**Correct (batched commits):**

```typescript
const transform: Transform<TSX> = (root) => {
  const consoleCalls = root.findAll({
    rule: { pattern: "console.log($$$ARGS)" }
  });

  // Collect all edits first
  const edits = consoleCalls.map(call => {
    const args = call.getMultipleMatches("ARGS");
    const argsText = args.map(a => a.text()).join(", ");
    return call.replace(`logger.info(${argsText})`);
  });

  // Single commit with all edits
  return root.commitEdits(edits);
  // Edits applied atomically - O(n) string operations
  // Position calculations are accurate
};
```

**Why batching matters:**
- Single string reconstruction pass
- Correct position calculations for overlapping ranges
- Atomic application (all or nothing)
- Better performance for large edit sets

Reference: [JSSG API Reference](https://docs.codemod.com/jssg/reference)
