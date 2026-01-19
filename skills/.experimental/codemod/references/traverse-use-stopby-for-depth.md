---
title: Use stopBy to Control Traversal Depth
impact: HIGH
impactDescription: prevents unbounded searches in deeply nested code
tags: traverse, stopby, depth, relational
---

## Use stopBy to Control Traversal Depth

Relational patterns (`inside`, `has`) traverse unbounded by default. Use `stopBy` to limit search depth and improve performance.

**Incorrect (unbounded search):**

```typescript
const transform: Transform<TSX> = (root) => {
  // Searches through ALL ancestors up to root
  const awaitInTry = root.findAll({
    rule: {
      kind: "await_expression",
      inside: {
        kind: "try_statement"
      }
      // Without stopBy, climbs entire ancestor chain
      // In deeply nested code, this is expensive
    }
  });

  return null;
};
```

**Correct (bounded search):**

```typescript
const transform: Transform<TSX> = (root) => {
  // Stop at nearest function boundary
  const awaitInTry = root.findAll({
    rule: {
      kind: "await_expression",
      inside: {
        kind: "try_statement",
        stopBy: {
          any: [
            { kind: "function_declaration" },
            { kind: "arrow_function" },
            { kind: "method_definition" }
          ]
        }
      }
    }
  });

  // Or use "neighbor" to check only immediate parent
  const directChild = root.findAll({
    rule: {
      kind: "identifier",
      inside: {
        kind: "variable_declarator",
        stopBy: "neighbor"  // Only checks direct parent
      }
    }
  });

  return null;
};
```

**stopBy options:**
- `"neighbor"` - check only immediate parent/children
- `"end"` - search to tree boundary (default)
- `{ kind: "x" }` - stop at specific node type
- Rule object - stop when rule matches

Reference: [JSSG API Reference](https://docs.codemod.com/jssg/reference)
