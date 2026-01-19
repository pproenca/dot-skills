---
title: Preserve Original Code Style with Recast
impact: MEDIUM
impactDescription: minimizes diff size by keeping unchanged code intact
tags: codegen, recast, style-preservation, minimal-diff
---

## Preserve Original Code Style with Recast

Recast preserves original formatting for unchanged code. Avoid operations that force full reprinting of the file.

**Incorrect (forces full reprint):**

```javascript
// Modifying the program body array forces full reprint
const body = root.get().node.body;
body.push(newStatement);
body.shift(); // Removing first element

// OR: Converting to source and back
const source = root.toSource();
const newRoot = j(source); // Loses original formatting info
```

**Correct (modify through paths for minimal diff):**

```javascript
// Use insertAfter/insertBefore for additions
root.find(j.ImportDeclaration).at(-1)
  .insertAfter(newImportDeclaration);

// Use path.prune() or remove() for deletions
root.find(j.ExpressionStatement)
  .filter(path => isDebugStatement(path))
  .remove();

// Use replaceWith for modifications
root.find(j.Identifier, { name: 'oldName' })
  .replaceWith(j.identifier('newName'));
```

**Why recast preserves style:**

```javascript
// Recast tracks which nodes are modified
// Unmodified nodes print exactly as original source
// Only modified nodes go through the printer

// Original: const   x   =   1;  // Weird spacing
// After rename:
root.find(j.Identifier, { name: 'x' })
  .replaceWith(j.identifier('y'));
// Output: const   y   =   1;  // Spacing preserved!
```

**Note:** Building new nodes with `j.identifier()` etc. always uses default formatting since they have no original source.

Reference: [recast - Why Recast?](https://github.com/benjamn/recast#motivation)
