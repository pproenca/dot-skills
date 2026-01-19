---
title: Compose Multiple Transforms into Pipelines
impact: LOW
impactDescription: enables reusable, testable transform building blocks
tags: advanced, composition, pipeline, modularity
---

## Compose Multiple Transforms into Pipelines

Complex codemods can be built from smaller, independently testable transforms. Composition enables reuse and easier maintenance.

**Incorrect (monolithic transform):**

```javascript
// Single 200+ line transform that does everything
module.exports = function transformer(file, api) {
  const j = api.jscodeshift;
  const root = j(file.source);

  // Rename imports... 50 lines
  // Update function calls... 50 lines
  // Remove deprecated code... 50 lines
  // Clean up unused imports... 50 lines

  return root.toSource();
};
// Hard to test, maintain, or reuse parts
```

**Correct (composed small transforms):**

```javascript
// transforms/renameImports.js
function renameImports(root, j, config) {
  root.find(j.ImportDeclaration, { source: { value: config.oldModule } })
    .forEach(path => {
      path.node.source.value = config.newModule;
    });
  return root;
}

// transforms/updateCalls.js
function updateCalls(root, j, config) {
  root.find(j.CallExpression, { callee: { name: config.oldName } })
    .replaceWith(path => j.callExpression(
      j.identifier(config.newName),
      path.node.arguments
    ));
  return root;
}

// transforms/removeUnusedImports.js
function removeUnusedImports(root, j) { /* ... */ }

// Main transform composes all pieces
module.exports = function transformer(file, api, options) {
  const j = api.jscodeshift;
  let root = j(file.source);

  // Pipeline of transforms
  root = renameImports(root, j, options);
  root = updateCalls(root, j, options);
  root = removeUnusedImports(root, j);

  return root.toSource();
};
```

**Factory pattern for configurable transforms:**

```javascript
function createMigrationTransform(migrations) {
  return function transformer(file, api) {
    const j = api.jscodeshift;
    let root = j(file.source);

    migrations.forEach(migration => {
      root = migration(root, j);
    });

    return root.toSource();
  };
}

module.exports = createMigrationTransform([
  renameImports,
  updateCalls,
  removeUnusedImports
]);
```

Reference: [Refactoring with Codemods to Automate API Changes](https://martinfowler.com/articles/codemods-api-refactoring.html)
