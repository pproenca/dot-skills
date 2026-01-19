---
title: Use Sibling Navigation Efficiently
impact: HIGH
impactDescription: O(1) sibling access vs O(n) re-traversal
tags: traverse, siblings, navigation, next, prev
---

## Use Sibling Navigation Efficiently

Use `next()`, `prev()`, `nextAll()`, and `prevAll()` for sibling navigation instead of re-traversing from parent. Sibling methods are O(1) operations.

**Incorrect (re-traversing from parent):**

```typescript
const transform: Transform<TSX> = (root) => {
  const statements = root.findAll({ rule: { kind: "expression_statement" } });

  const edits = statements.flatMap(stmt => {
    // Re-traverse parent to find siblings
    const parent = stmt.parent();
    if (!parent) return [];

    const siblings = parent.children();
    const index = siblings.findIndex(s => s.id() === stmt.id());
    const nextSibling = siblings[index + 1];

    // O(n) per statement = O(n²) total
    if (nextSibling?.kind() === "comment") {
      return [stmt.replace(stmt.text() + " // has comment")];
    }
    return [];
  });

  return root.commitEdits(edits);
};
```

**Correct (direct sibling access):**

```typescript
const transform: Transform<TSX> = (root) => {
  const statements = root.findAll({ rule: { kind: "expression_statement" } });

  const edits = statements.flatMap(stmt => {
    // O(1) sibling access
    const nextSibling = stmt.next();

    if (nextSibling?.kind() === "comment") {
      return [stmt.replace(stmt.text() + " // has comment")];
    }
    return [];
  });

  return root.commitEdits(edits);
};
```

**Sibling navigation methods:**
- `next()` - immediately following sibling
- `prev()` - immediately preceding sibling
- `nextAll()` - all following siblings
- `prevAll()` - all preceding siblings

Reference: [JSSG API Reference](https://docs.codemod.com/jssg/reference)
