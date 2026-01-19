---
title: Early Return for Non-Applicable Files
impact: CRITICAL
impactDescription: 10-100x speedup by skipping irrelevant files
tags: parse, optimization, early-return, performance
---

## Early Return for Non-Applicable Files

Check file applicability before performing expensive traversals. Return early when files cannot possibly contain relevant patterns.

**Incorrect (full traversal for all files):**

```typescript
const transform: Transform<TSX> = (root) => {
  // Full AST traversal on every file
  const matches = root.findAll({
    rule: { pattern: "React.Component" }
  });

  if (matches.length === 0) {
    return null; // Wasted traversal time
  }

  // Transform logic...
  return root.commitEdits([]);
};
// 1000 files × full traversal = slow
```

**Correct (early return with quick check):**

```typescript
const transform: Transform<TSX> = (root) => {
  const source = root.root().text();

  // Quick string checks before expensive traversal
  if (!source.includes("React.Component") &&
      !source.includes("extends Component")) {
    return null; // Skip file entirely
  }

  // Only traverse files that might match
  const matches = root.findAll({
    rule: { pattern: "React.Component" }
  });

  // Transform logic...
  return root.commitEdits([]);
};
// 50 relevant files × full traversal = fast
```

**Better: use getSelector export:**

```typescript
// Pre-filter files at the engine level
export const getSelector = {
  rule: {
    any: [
      { pattern: "React.Component" },
      { pattern: "extends Component" }
    ]
  }
};

const transform: Transform<TSX> = (root, options) => {
  // Only called for files that match selector
  // options.matches contains pre-matched nodes
  const matches = options.matches || [];
  // Transform logic...
  return root.commitEdits([]);
};
```

**Early return strategies:**
- String `includes()` for keywords
- `getSelector` export for engine-level filtering
- Filename checks for path-specific transforms

Reference: [JSSG Advanced Patterns](https://docs.codemod.com/jssg/advanced)
