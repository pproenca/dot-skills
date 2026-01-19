---
title: Return Early When No Transformation Needed
impact: CRITICAL
impactDescription: 10-100× faster on files with no matches
tags: traverse, early-return, performance, optimization
---

## Return Early When No Transformation Needed

Calling `toSource()` is expensive as it regenerates the entire file. Return early when no changes are needed to skip code generation entirely.

**Incorrect (always calls toSource):**

```javascript
module.exports = function transformer(file, api) {
  const j = api.jscodeshift;
  const root = j(file.source);

  root.find(j.CallExpression, { callee: { name: 'oldFunction' } })
    .replaceWith(path => j.callExpression(
      j.identifier('newFunction'),
      path.node.arguments
    ));

  // toSource() called even when no changes made
  return root.toSource();
};
```

**Correct (early return on no changes):**

```javascript
module.exports = function transformer(file, api) {
  const j = api.jscodeshift;
  const root = j(file.source);

  const calls = root.find(j.CallExpression, { callee: { name: 'oldFunction' } });

  // Skip toSource() if nothing to transform
  if (calls.size() === 0) {
    return null; // Signal: no changes
  }

  calls.replaceWith(path => j.callExpression(
    j.identifier('newFunction'),
    path.node.arguments
  ));

  return root.toSource();
};
```

**Alternative (using undefined):**

```javascript
// Both null and undefined signal "no changes"
if (calls.size() === 0) {
  return undefined;
}
```

**Benefits:**
- Unchanged files skip expensive parsing and printing
- jscodeshift reports accurate "unchanged" counts
- Significant speedup on large codebases with sparse changes

Reference: [jscodeshift README](https://github.com/facebook/jscodeshift#transform-module)
