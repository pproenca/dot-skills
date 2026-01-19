---
title: Insert Imports at Correct Position
impact: HIGH
impactDescription: maintains valid module structure and import ordering
tags: transform, imports, insertion, module-structure
---

## Insert Imports at Correct Position

New imports must be inserted at the top of the file, after existing imports, and before any code. Incorrect positioning breaks module loading.

**Incorrect (inserts at wrong position):**

```javascript
// Inserts at very top, before 'use strict' or existing imports
root.get().node.body.unshift(
  j.importDeclaration(
    [j.importDefaultSpecifier(j.identifier('newModule'))],
    j.literal('new-module')
  )
);
// May produce: import newModule from 'new-module'; 'use strict';
```

**Correct (insert after existing imports):**

```javascript
function addImport(root, j, source, specifiers) {
  const imports = root.find(j.ImportDeclaration);
  const newImport = j.importDeclaration(specifiers, j.literal(source));

  if (imports.size() > 0) {
    // Insert after last import
    imports.at(-1).insertAfter(newImport);
  } else {
    // No imports exist - find first non-directive statement
    const body = root.get().node.body;
    let insertIndex = 0;

    // Skip 'use strict' and other directives
    while (insertIndex < body.length &&
           body[insertIndex].type === 'ExpressionStatement' &&
           body[insertIndex].directive) {
      insertIndex++;
    }

    body.splice(insertIndex, 0, newImport);
  }
}

// Usage
addImport(root, j, 'lodash', [
  j.importSpecifier(j.identifier('debounce'))
]);
```

**Alternative (check if import exists first):**

```javascript
function ensureImport(root, j, source, importedName, localName = importedName) {
  const existingImport = root.find(j.ImportDeclaration, {
    source: { value: source }
  });

  if (existingImport.size() > 0) {
    // Check if specifier already exists
    const hasSpecifier = existingImport
      .find(j.ImportSpecifier, { imported: { name: importedName } })
      .size() > 0;

    if (!hasSpecifier) {
      // Add specifier to existing import
      existingImport.forEach(path => {
        path.node.specifiers.push(
          j.importSpecifier(j.identifier(importedName), j.identifier(localName))
        );
      });
    }
  } else {
    // Add new import declaration
    addImport(root, j, source, [
      j.importSpecifier(j.identifier(importedName), j.identifier(localName))
    ]);
  }
}
```

Reference: [jscodeshift - Working with Imports](https://jscodeshift.com/run/recipes/#imports)
