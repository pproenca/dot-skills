---
title: Use Dry Run Mode for Codebase Exploration
impact: MEDIUM
impactDescription: enables safe exploration without modifying files
tags: test, dry-run, exploration, stats
---

## Use Dry Run Mode for Codebase Exploration

Before writing the transform, use dry run mode with `api.stats()` to understand the codebase patterns you'll encounter.

**Incorrect (writing transform without exploration):**

```javascript
// Guessing at patterns without data
module.exports = function transformer(file, api) {
  const j = api.jscodeshift;
  const root = j(file.source);

  // Assuming all calls look like: oldFunc(arg1, arg2)
  root.find(j.CallExpression, { callee: { name: 'oldFunc' } })
    .replaceWith(/* ... */);

  return root.toSource();
};
// Misses: oldFunc.bind(this), obj.oldFunc(), etc.
```

**Correct (explore first with stats):**

```javascript
// exploration-codemod.js
module.exports = function transformer(file, api) {
  const j = api.jscodeshift;
  const root = j(file.source);

  // Count different call patterns
  root.find(j.CallExpression).forEach(path => {
    const callee = path.node.callee;

    if (callee.type === 'Identifier' && callee.name === 'oldFunc') {
      api.stats('Direct call: oldFunc()');
    } else if (callee.type === 'MemberExpression') {
      if (callee.property.name === 'oldFunc') {
        api.stats(`Member call: ${callee.object.name || '?'}.oldFunc()`);
      }
    }
  });

  return undefined; // No changes
};
```

**Running exploration:**

```bash
# --dry runs transform without writing files
# Stats are printed at the end
jscodeshift --dry --print -t exploration-codemod.js src/

# Output:
# Results:
# 0 errors
# 47 unmodified
# Stats:
#   Direct call: oldFunc(): 23
#   Member call: utils.oldFunc(): 12
#   Member call: this.oldFunc(): 3
```

**Note:** Understanding the actual patterns in your codebase prevents incomplete transforms.

Reference: [jscodeshift README - Stats](https://github.com/facebook/jscodeshift#stats)
