---
title: Use replaceWith Callback for Context-Aware Transforms
impact: HIGH
impactDescription: enables dynamic transformations based on original node
tags: transform, replaceWith, callback, dynamic
---

## Use replaceWith Callback for Context-Aware Transforms

The `replaceWith()` method accepts a callback that receives the path, enabling transformations that depend on the original node's properties.

**Incorrect (static replacement ignores context):**

```javascript
// Always replaces with same node, loses original arguments
root.find(j.CallExpression, { callee: { name: 'oldFunc' } })
  .replaceWith(j.callExpression(
    j.identifier('newFunc'),
    [] // Lost the original arguments!
  ));
```

**Correct (callback preserves context):**

```javascript
root.find(j.CallExpression, { callee: { name: 'oldFunc' } })
  .replaceWith(path => {
    // Access original node through path
    return j.callExpression(
      j.identifier('newFunc'),
      path.node.arguments // Preserve original arguments
    );
  });
```

**Alternative (add argument to existing call):**

```javascript
// Add a new first argument while preserving existing ones
root.find(j.CallExpression, { callee: { name: 'translate' } })
  .replaceWith(path => {
    return j.callExpression(
      path.node.callee,
      [
        j.identifier('locale'), // New first argument
        ...path.node.arguments   // Original arguments
      ]
    );
  });
```

**Complex example (wrap in another call):**

```javascript
// Wrap: oldFunc(args) → wrapper(oldFunc(args))
root.find(j.CallExpression, { callee: { name: 'oldFunc' } })
  .replaceWith(path => {
    return j.callExpression(
      j.identifier('wrapper'),
      [path.node] // Original call becomes argument
    );
  });
```

Reference: [jscodeshift API - replaceWith](https://jscodeshift.com/build/api-reference/)
