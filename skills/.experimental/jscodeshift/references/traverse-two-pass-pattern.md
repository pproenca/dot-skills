---
title: Use Two-Pass Pattern for Complex Transforms
impact: CRITICAL
impactDescription: reduces O(n²) to O(n) on complex transformations
tags: traverse, two-pass, performance, pattern
---

## Use Two-Pass Pattern for Complex Transforms

Nested find() calls inside forEach() create O(n²) complexity. Use a two-pass pattern: collect data first, then transform.

**Incorrect (O(n²) nested traversal):**

```javascript
// For each import, searches entire AST again
root.find(j.ImportDeclaration)
  .forEach(importPath => {
    const importedNames = importPath.node.specifiers.map(s => s.local.name);

    // O(n) traversal for EACH import = O(n²) total
    root.find(j.Identifier)
      .filter(idPath => importedNames.includes(idPath.node.name))
      .forEach(idPath => {
        // transform usage
      });
  });
```

**Correct (O(n) two-pass approach):**

```javascript
// Pass 1: Collect all data in single traversal
const importedBindings = new Map();

root.find(j.ImportDeclaration)
  .forEach(importPath => {
    importPath.node.specifiers.forEach(specifier => {
      importedBindings.set(specifier.local.name, {
        source: importPath.node.source.value,
        imported: specifier.imported?.name || 'default'
      });
    });
  });

// Pass 2: Transform using collected data
root.find(j.Identifier)
  .filter(idPath => importedBindings.has(idPath.node.name))
  .forEach(idPath => {
    const binding = importedBindings.get(idPath.node.name);
    // Transform using pre-collected data
  });
```

**Benefits:**
- Single traversal for collection, single traversal for transformation
- Map lookups are O(1) vs array includes() O(n)
- Scales linearly with file size

Reference: [Martin Fowler - Refactoring with Codemods](https://martinfowler.com/articles/codemods-api-refactoring.html)
