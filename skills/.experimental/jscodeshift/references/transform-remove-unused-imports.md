---
title: Remove Unused Imports After Transformation
impact: HIGH
impactDescription: prevents dead imports causing build warnings or errors
tags: transform, imports, cleanup, dead-code
---

## Remove Unused Imports After Transformation

When transformations remove code, associated imports may become unused. Clean up imports to avoid build warnings and bundle bloat.

**Incorrect (leaves orphaned imports):**

```javascript
// Removes all console.log calls
root.find(j.CallExpression, {
  callee: { object: { name: 'console' }, property: { name: 'log' } }
}).remove();

// But if file had: import { debug } from './logger';
// And: console.log(debug(data));
// Now 'debug' is unused but still imported
```

**Correct (clean up unused imports):**

```javascript
function removeUnusedImports(root, j) {
  root.find(j.ImportDeclaration).forEach(importPath => {
    const specifiers = importPath.node.specifiers;

    // Check each imported binding
    const usedSpecifiers = specifiers.filter(spec => {
      const localName = spec.local.name;

      // Count usages (excluding the import itself)
      const usages = root.find(j.Identifier, { name: localName })
        .filter(idPath => {
          // Not the import specifier itself
          return idPath.parent.node !== spec;
        });

      return usages.size() > 0;
    });

    if (usedSpecifiers.length === 0) {
      // Remove entire import
      importPath.prune();
    } else if (usedSpecifiers.length < specifiers.length) {
      // Remove only unused specifiers
      importPath.node.specifiers = usedSpecifiers;
    }
  });
}

// Usage: call after main transformation
root.find(j.CallExpression, { callee: { name: 'oldFunc' } }).remove();
removeUnusedImports(root, j);
```

**Note:** Run import cleanup as a separate pass after all transformations to catch all unused imports.

Reference: [jscodeshift Recipes - Removing Imports](https://jscodeshift.com/run/recipes/#imports)
