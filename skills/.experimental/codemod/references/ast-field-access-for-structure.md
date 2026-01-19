---
title: Use Field Access for Structural Queries
impact: CRITICAL
impactDescription: enables precise child selection in complex nodes
tags: ast, fields, structure, navigation
---

## Use Field Access for Structural Queries

Tree-sitter nodes have named fields that provide semantic access to children. Use `field()` and field constraints instead of index-based child access.

**Incorrect (index-based access):**

```typescript
const transform: Transform<TSX> = (root) => {
  const functions = root.findAll({ rule: { kind: "function_declaration" } });

  for (const fn of functions) {
    // Index-based access is fragile
    const name = fn.children()[0];  // Might be 'async' keyword
    const params = fn.children()[1]; // Might be name if no async
    // Breaks with async functions, generators, type annotations
  }
  return null;
};
```

**Correct (field-based access):**

```typescript
const transform: Transform<TSX> = (root) => {
  const functions = root.findAll({ rule: { kind: "function_declaration" } });

  for (const fn of functions) {
    // Field access is semantic and stable
    const name = fn.field("name");      // Always the function name
    const params = fn.field("parameters"); // Always the params list
    const body = fn.field("body");      // Always the function body

    if (name && params) {
      console.log(`Function ${name.text()} has ${params.children().length} params`);
    }
  }
  return null;
};
```

**Common field names:**
- Functions: `name`, `parameters`, `body`, `return_type`
- Variables: `name`, `value`, `type`
- Calls: `function`, `arguments`
- Classes: `name`, `body`, `superclass`

Reference: [JSSG API Reference](https://docs.codemod.com/jssg/reference)
