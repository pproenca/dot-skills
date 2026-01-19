---
title: Use flatMap for Conditional Edits
impact: MEDIUM-HIGH
impactDescription: eliminates null filtering, reduces code by 30%
tags: edit, flatmap, conditional, filtering
---

## Use flatMap for Conditional Edits

Use `flatMap` instead of `map` + `filter` when some nodes don't produce edits. Return empty arrays for skipped nodes.

**Incorrect (map with nulls):**

```typescript
const transform: Transform<TSX> = (root) => {
  const calls = root.findAll({
    rule: { pattern: "api.$METHOD($$$ARGS)" }
  });

  const edits = calls.map(call => {
    const method = call.getMatch("METHOD");
    if (!method) return null;

    const methodName = method.text();
    // Only transform deprecated methods
    if (!deprecatedMethods.includes(methodName)) {
      return null;
    }

    return call.replace(`newApi.${methodName}()`);
  });

  // Must filter out nulls
  return root.commitEdits(edits.filter(Boolean) as Edit[]);
  // Type assertion needed, filter doesn't narrow
};
```

**Correct (flatMap with empty arrays):**

```typescript
const transform: Transform<TSX> = (root) => {
  const calls = root.findAll({
    rule: { pattern: "api.$METHOD($$$ARGS)" }
  });

  const edits = calls.flatMap(call => {
    const method = call.getMatch("METHOD");
    if (!method) return [];  // Skip gracefully

    const methodName = method.text();
    if (!deprecatedMethods.includes(methodName)) {
      return [];  // Not deprecated, skip
    }

    // Return array with single edit
    return [call.replace(`newApi.${methodName}()`)];
  });

  // No filtering needed, proper types
  return root.commitEdits(edits);
};
```

**Benefits of flatMap:**
- No null/undefined handling
- Proper TypeScript types without assertions
- Can return multiple edits per node if needed
- Cleaner functional style

**Pattern:**
```typescript
nodes.flatMap(node => {
  if (shouldSkip(node)) return [];
  if (needsMultipleEdits(node)) return [edit1, edit2];
  return [singleEdit];
});
```

Reference: [JSSG API Reference](https://docs.codemod.com/jssg/reference)
