---
title: Use Scope Analysis for Safe Variable Transforms
impact: LOW
impactDescription: prevents 100% of scope-related transform bugs
tags: advanced, scope, analysis, closures
---

## Use Scope Analysis for Safe Variable Transforms

ast-types provides scope analysis to track variable bindings. Use it for transforms that need to understand variable usage across scopes.

**Incorrect (ignores scope boundaries):**

```javascript
// Attempts to inline a variable without scope awareness
root.find(j.VariableDeclarator, { id: { name: 'config' } })
  .forEach(path => {
    const initValue = path.node.init;

    // Inlines ALL references, even in wrong scope
    root.find(j.Identifier, { name: 'config' })
      .replaceWith(initValue);
  });

// Breaks when 'config' is shadowed in nested scope
```

**Correct (scope-aware transformation):**

```javascript
root.find(j.VariableDeclarator, { id: { name: 'config' } })
  .forEach(declPath => {
    const initValue = declPath.node.init;
    const scope = declPath.scope;

    // Get all bindings in this scope
    const bindings = scope.getBindings();
    const configBinding = bindings['config'];

    if (!configBinding) return;

    // Only transform references that belong to THIS binding
    configBinding.forEach(refPath => {
      // Skip the declaration itself
      if (refPath === declPath.get('id')) return;

      // Check if reference is in a scope where 'config' is shadowed
      let currentScope = refPath.scope;
      while (currentScope && currentScope !== scope) {
        if (currentScope.getBindings()['config']) {
          // Shadowed - don't transform this reference
          return;
        }
        currentScope = currentScope.parent;
      }

      // Safe to inline
      refPath.replace(initValue);
    });
  });
```

**Using scope.lookup():**

```javascript
root.find(j.Identifier, { name: 'target' })
  .filter(path => {
    // Find which scope owns this binding
    const scope = path.scope.lookup('target');

    // Only transform if binding is at module level
    return scope && scope.isGlobal;
  });
```

**Caveat:** ast-types scope analysis treats `let` and `const` as function-scoped rather than block-scoped. For block-scoped variables, manually check scope boundaries.

Reference: [ast-types Scope](https://github.com/benjamn/ast-types#scope)
