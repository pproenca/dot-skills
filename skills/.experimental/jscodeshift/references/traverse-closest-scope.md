---
title: Use closestScope() for Scope-Aware Transforms
impact: CRITICAL
impactDescription: prevents incorrect transforms on shadowed variables
tags: traverse, scope, closestScope, shadowing
---

## Use closestScope() for Scope-Aware Transforms

Variable names can be shadowed in nested scopes. Use `closestScope()` to ensure transforms only affect the correct binding.

**Incorrect (ignores variable shadowing):**

```javascript
// Renames ALL 'data' identifiers, even shadowed ones
root.find(j.Identifier, { name: 'data' })
  .forEach(path => {
    path.node.name = 'payload';
  });

// Input:
// const data = fetch();
// function process(data) { return data; }
//
// Broken output (shadows broken):
// const payload = fetch();
// function process(payload) { return payload; }
```

**Correct (scope-aware transformation):**

```javascript
// Only rename 'data' in module scope, not function parameters
root.find(j.VariableDeclarator, { id: { name: 'data' } })
  .filter(path => {
    // Check if this is at module scope
    const scope = path.scope;
    return scope.isGlobal || scope.path.node.type === 'Program';
  })
  .forEach(path => {
    const binding = path.scope.getBindings()['data'];

    // Rename all references to this specific binding
    binding?.forEach(refPath => {
      refPath.node.name = 'payload';
    });

    path.node.id.name = 'payload';
  });
```

**Alternative (using closestScope):**

```javascript
root.find(j.Identifier, { name: 'oldName' })
  .filter(path => {
    // Only transform if in the target scope
    const scope = path.closestScope();
    return scope.node.type === 'FunctionDeclaration' &&
           scope.node.id?.name === 'targetFunction';
  });
```

**Note:** Always consider scope when renaming identifiers or the codemod will corrupt variable bindings.

Reference: [ast-types - Scope](https://github.com/benjamn/ast-types#scope)
