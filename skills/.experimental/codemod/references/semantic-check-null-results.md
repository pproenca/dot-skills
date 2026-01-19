---
title: Handle Null Semantic Analysis Results
impact: HIGH
impactDescription: prevents crashes when symbols are unresolvable
tags: semantic, null-safety, defensive, error-handling
---

## Handle Null Semantic Analysis Results

Semantic analysis methods return `null` when symbols cannot be resolved. Always handle null results gracefully - not all code can be statically analyzed.

**Incorrect (assumes resolution succeeds):**

```typescript
const transform: Transform<TSX> = (root) => {
  const identifiers = root.findAll({ rule: { kind: "identifier" } });

  const edits = identifiers.map(id => {
    // Crashes on unresolvable symbols
    const def = id.definition();
    const defNode = def.node;  // TypeError: Cannot read property 'node' of null

    // External imports, globals, and dynamic code return null
    return id.replace(defNode.text().toUpperCase());
  });

  return root.commitEdits(edits);
};
```

**Correct (null-safe semantic access):**

```typescript
const transform: Transform<TSX> = (root) => {
  const identifiers = root.findAll({ rule: { kind: "identifier" } });

  const edits = identifiers.flatMap(id => {
    const def = id.definition();

    // Handle unresolvable symbols
    if (!def) {
      // Could be: external import, global, dynamic, or analysis limitation
      console.log(`Could not resolve: ${id.text()}`);
      return [];
    }

    // Check definition kind for appropriate handling
    if (def.kind === "external") {
      // Symbol defined in node_modules or external file
      return [];
    }

    if (def.kind === "import") {
      // Symbol imported from another file
      const importDef = def.node;
      // Handle import-specific logic
    }

    return [id.replace(def.node.text().toUpperCase())];
  });

  return root.commitEdits(edits);
};
```

**Definition kinds:**
- `"local"` - defined in same file
- `"import"` - imported from another file
- `"external"` - from node_modules or outside project
- `null` - unresolvable (dynamic, global, etc.)

Reference: [JSSG Semantic Analysis](https://docs.codemod.com/jssg/semantic-analysis)
