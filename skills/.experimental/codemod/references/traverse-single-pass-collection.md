---
title: Collect Multiple Patterns in Single Traversal
impact: HIGH
impactDescription: reduces N traversals to 1 traversal
tags: traverse, single-pass, optimization, batching
---

## Collect Multiple Patterns in Single Traversal

When you need to find multiple different patterns, combine them into a single query with `any` instead of making separate traversals.

**Incorrect (multiple traversals):**

```typescript
const transform: Transform<TSX> = (root) => {
  // 4 separate traversals of the AST
  const requires = root.findAll({ rule: { pattern: "require($PATH)" } });
  const imports = root.findAll({ rule: { kind: "import_statement" } });
  const exports = root.findAll({ rule: { kind: "export_statement" } });
  const dynamicImports = root.findAll({ rule: { pattern: "import($PATH)" } });

  // Each traversal walks the entire tree
  // 4N time complexity
  return null;
};
```

**Correct (single traversal):**

```typescript
const transform: Transform<TSX> = (root) => {
  // Single traversal collecting all patterns
  const moduleStatements = root.findAll({
    rule: {
      any: [
        { pattern: "require($PATH)" },
        { kind: "import_statement" },
        { kind: "export_statement" },
        { pattern: "import($PATH)" }
      ]
    }
  });

  // Categorize after collection
  const requires = moduleStatements.filter(n => n.text().startsWith("require"));
  const imports = moduleStatements.filter(n => n.kind() === "import_statement");
  const exports = moduleStatements.filter(n => n.kind() === "export_statement");
  const dynamicImports = moduleStatements.filter(n =>
    n.kind() === "call_expression" && n.text().includes("import(")
  );

  // 1N time complexity + fast array filtering
  return null;
};
```

**When to combine:**
- Searching for related patterns (all module syntax)
- Collecting nodes for analysis (all function definitions)
- Building a manifest (all API usages)

Reference: [JSSG API Reference](https://docs.codemod.com/jssg/reference)
