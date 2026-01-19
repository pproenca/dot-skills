---
title: Use renameTo for Variable Renaming
impact: HIGH
impactDescription: prevents 100% of scope-related rename bugs
tags: transform, rename, scope, variables
---

## Use renameTo for Variable Renaming

The `renameTo()` method handles all references to a variable within its scope. Manual renaming misses references or incorrectly renames shadowed variables.

**Incorrect (manual identifier replacement):**

```javascript
// Renames ALL 'data' identifiers, even unrelated ones
root.find(j.Identifier, { name: 'data' })
  .forEach(path => {
    path.node.name = 'payload';
  });

// Breaks: function process(data) { return data; }
// Becomes: function process(payload) { return payload; }
// But these are different variables!
```

**Correct (renameTo handles scope):**

```javascript
// Only rename the specific variable declaration and its references
root.find(j.VariableDeclarator, { id: { name: 'data' } })
  .renameTo('payload');

// Input:
// const data = fetch(); console.log(data);
// function process(data) { return data; }
//
// Output:
// const payload = fetch(); console.log(payload);
// function process(data) { return data; }  // Unchanged - different scope
```

**Alternative (for function parameters):**

```javascript
// Rename a function parameter
root.find(j.FunctionDeclaration, { id: { name: 'processUser' } })
  .find(j.Identifier, { name: 'callback' })
  .filter(path => path.parent.node.type === 'FunctionDeclaration')
  .renameTo('onComplete');
```

**Limitation:** `renameTo()` works on variable declarators. For other identifiers, use scope-aware manual transformation.

Reference: [jscodeshift API - renameTo](https://jscodeshift.com/build/api-reference/)
