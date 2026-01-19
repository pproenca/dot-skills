---
title: Track Import Bindings for Accurate Usage Detection
impact: HIGH
impactDescription: prevents missed transforms due to import aliases
tags: filter, imports, bindings, aliases
---

## Track Import Bindings for Accurate Usage Detection

Import aliases mean the local name differs from the imported name. Track the actual binding name, not the imported module name.

**Incorrect (assumes import name matches usage):**

```javascript
// Looking for 'useState' but import is aliased
root.find(j.CallExpression, {
  callee: { name: 'useState' }
});

// Misses: import { useState as useReactState } from 'react';
// useReactState(0) is not found
```

**Correct (tracks actual binding name):**

```javascript
// First, find the actual local binding name
const localNames = new Set();

root.find(j.ImportDeclaration, { source: { value: 'react' } })
  .find(j.ImportSpecifier, { imported: { name: 'useState' } })
  .forEach(path => {
    // local.name is the actual name used in code
    localNames.add(path.node.local.name);
  });

// Now find usages by actual local name
root.find(j.CallExpression)
  .filter(path => {
    const callee = path.node.callee;
    return callee.type === 'Identifier' && localNames.has(callee.name);
  })
  .forEach(path => {
    // Transform usage
  });
```

**Alternative (handle all specifier types):**

```javascript
function getImportBindings(root, j, source, importedName) {
  const bindings = new Set();

  root.find(j.ImportDeclaration, { source: { value: source } })
    .forEach(importPath => {
      importPath.node.specifiers.forEach(spec => {
        if (spec.type === 'ImportDefaultSpecifier' && importedName === 'default') {
          bindings.add(spec.local.name);
        } else if (spec.type === 'ImportSpecifier' && spec.imported.name === importedName) {
          bindings.add(spec.local.name);
        } else if (spec.type === 'ImportNamespaceSpecifier') {
          bindings.add(`${spec.local.name}.${importedName}`);
        }
      });
    });

  return bindings;
}
```

Reference: [Refactoring with Codemods to Automate API Changes](https://martinfowler.com/articles/codemods-api-refactoring.html)
