---
title: Use Specific Node Types in find() Calls
impact: CRITICAL
impactDescription: 10-100× faster traversal on large files
tags: traverse, find, performance, node-types
---

## Use Specific Node Types in find() Calls

Using generic node types in `find()` traverses the entire AST. Specify the exact node type to reduce search space dramatically.

**Incorrect (overly generic traversal):**

```javascript
// Finds ALL expressions, then filters - O(n) full AST walk
root.find(j.Expression)
  .filter(path => path.node.type === 'CallExpression')
  .filter(path => path.node.callee.name === 'require');
```

**Correct (specific type reduces search space):**

```javascript
// Finds only CallExpressions - skips irrelevant nodes
root.find(j.CallExpression, {
  callee: { name: 'require' }
});
```

**Alternative (for member expressions):**

```javascript
// Instead of finding all Identifiers and filtering
// Incorrect:
root.find(j.Identifier).filter(path => path.parent.node.type === 'MemberExpression');

// Correct:
root.find(j.MemberExpression, {
  object: { name: 'console' }
});
```

**Benefits:**
- Reduces nodes visited by 90%+ on typical files
- Second argument to `find()` filters during traversal, not after
- jscodeshift short-circuits non-matching branches

Reference: [jscodeshift API Reference - find()](https://jscodeshift.com/build/api-reference/)
