---
title: Use find() with Filter Object Over filter() Chain
impact: CRITICAL
impactDescription: 2-5× faster than separate filter() calls
tags: traverse, find, filter, performance
---

## Use find() with Filter Object Over filter() Chain

The `find()` method accepts a filter object as its second argument, filtering during traversal. This is faster than traversing first and filtering after.

**Incorrect (find then filter chain):**

```javascript
// Traverses entire AST, then iterates result twice
root.find(j.CallExpression)
  .filter(path => path.node.callee.type === 'MemberExpression')
  .filter(path => path.node.callee.object.name === 'console')
  .filter(path => path.node.callee.property.name === 'log');
```

**Correct (filter object in find):**

```javascript
// Single traversal with inline filtering
root.find(j.CallExpression, {
  callee: {
    type: 'MemberExpression',
    object: { name: 'console' },
    property: { name: 'log' }
  }
});
```

**When to use filter() after find():**

```javascript
// Use filter() for complex conditions that can't be expressed as object matchers
root.find(j.CallExpression, {
  callee: { object: { name: 'console' } }
})
.filter(path => {
  // Complex logic: method must be log, warn, or error
  const method = path.node.callee.property.name;
  return ['log', 'warn', 'error'].includes(method);
});
```

**Benefits:**
- Filter object uses direct property comparison (fast)
- filter() callback invokes function for each node (slower)
- Combine both: filter object for structure, filter() for complex logic

Reference: [jscodeshift API Reference](https://jscodeshift.com/build/api-reference/)
