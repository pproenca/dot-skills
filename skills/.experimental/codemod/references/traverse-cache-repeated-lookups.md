---
title: Cache Repeated Node Lookups
impact: HIGH
impactDescription: eliminates redundant traversals in transform loops
tags: traverse, caching, optimization, lookup
---

## Cache Repeated Node Lookups

When transforming multiple nodes that share context, cache common lookups to avoid repeated traversals.

**Incorrect (repeated lookups):**

```typescript
const transform: Transform<TSX> = (root) => {
  const apiCalls = root.findAll({
    rule: { pattern: "api.$METHOD($$$ARGS)" }
  });

  const edits = apiCalls.map(call => {
    // Each iteration re-traverses to find imports
    const hasErrorImport = root.find({
      rule: { pattern: 'import { ApiError } from "api"' }
    });

    // Each iteration re-traverses to find config
    const config = root.find({
      rule: { pattern: "const config = $VALUE" }
    });

    // N calls × 2 traversals = 2N unnecessary traversals
    return call.replace(`wrappedApi.${call.getMatch("METHOD")?.text()}()`);
  });

  return root.commitEdits(edits);
};
```

**Correct (cached lookups):**

```typescript
const transform: Transform<TSX> = (root) => {
  // Cache lookups before the loop
  const hasErrorImport = root.find({
    rule: { pattern: 'import { ApiError } from "api"' }
  });

  const config = root.find({
    rule: { pattern: "const config = $VALUE" }
  });

  const apiCalls = root.findAll({
    rule: { pattern: "api.$METHOD($$$ARGS)" }
  });

  // Reuse cached values
  const edits = apiCalls.map(call => {
    if (!hasErrorImport) {
      // Use cached result
    }
    return call.replace(`wrappedApi.${call.getMatch("METHOD")?.text()}()`);
  });

  return root.commitEdits(edits);
};
```

**What to cache:**
- Import statements (checked for many nodes)
- Configuration declarations
- Type definitions
- Any context used across multiple transformations

Reference: [JSSG API Reference](https://docs.codemod.com/jssg/reference)
