---
title: Avoid Repeated find() Calls for Same Node Type
impact: CRITICAL
impactDescription: reduces traversal from N passes to 1 pass
tags: traverse, find, caching, performance
---

## Avoid Repeated find() Calls for Same Node Type

Each `find()` call traverses the AST. Cache the collection when accessing the same node type multiple times.

**Incorrect (traverses AST 3 times):**

```javascript
// First traversal
const hasRequireCalls = root.find(j.CallExpression, { callee: { name: 'require' } }).size() > 0;

// Second traversal - same nodes
const requirePaths = root.find(j.CallExpression, { callee: { name: 'require' } }).paths();

// Third traversal - same nodes again
root.find(j.CallExpression, { callee: { name: 'require' } })
  .replaceWith(path => /* transform */);
```

**Correct (single traversal, cached):**

```javascript
// Single traversal, reuse collection
const requireCalls = root.find(j.CallExpression, { callee: { name: 'require' } });

const hasRequireCalls = requireCalls.size() > 0;
const requirePaths = requireCalls.paths();

requireCalls.replaceWith(path => /* transform */);
```

**Alternative (for conditional transforms):**

```javascript
const requireCalls = root.find(j.CallExpression, { callee: { name: 'require' } });

if (requireCalls.size() === 0) {
  return null; // Early return, no changes
}

// Now safe to transform
requireCalls.replaceWith(/* ... */);
```

**Benefits:**
- Each `find()` is O(n) where n = AST nodes
- Caching reduces 3×O(n) to 1×O(n)
- Collections are lazy - operations chain without intermediate traversals

Reference: [jscodeshift - Collections](https://jscodeshift.com/build/api-reference/)
