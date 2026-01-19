---
title: Use find() for Single Match, findAll() for Multiple
impact: HIGH
impactDescription: find() short-circuits, reducing traversal by up to 99%
tags: traverse, find, findall, performance, short-circuit
---

## Use find() for Single Match, findAll() for Multiple

Use `find()` when you only need the first match - it stops traversal immediately. Use `findAll()` only when you need all occurrences.

**Incorrect (findAll when only first needed):**

```typescript
const transform: Transform<TSX> = (root) => {
  // Finds ALL imports, then takes first
  const imports = root.findAll({
    rule: { kind: "import_statement" }
  });

  // Only needed the first import location for insertion
  const firstImport = imports[0];
  if (!firstImport) return null;

  // findAll traversed entire file unnecessarily
  return null;
};
```

**Correct (find for single match):**

```typescript
const transform: Transform<TSX> = (root) => {
  // Stops at first match
  const firstImport = root.find({
    rule: { kind: "import_statement" }
  });

  if (!firstImport) return null;

  // Short-circuited traversal - much faster for large files
  return null;
};
```

**Use find() when:**
- Checking if any match exists
- Finding insertion point (first/last import)
- Validating presence of a pattern
- Getting a single representative node

**Use findAll() when:**
- Transforming all occurrences
- Counting matches
- Collecting nodes for batch operations

Reference: [JSSG API Reference](https://docs.codemod.com/jssg/reference)
