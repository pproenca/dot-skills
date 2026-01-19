---
title: Add Nullish Checks Before Property Access
impact: HIGH
impactDescription: prevents runtime crashes on optional AST properties
tags: filter, null-safety, defensive, properties
---

## Add Nullish Checks Before Property Access

AST nodes have optional properties that may be null or undefined. Accessing nested properties without checks crashes the transform.

**Incorrect (assumes properties exist):**

```javascript
root.find(j.CallExpression)
  .filter(path => {
    // Crashes if callee is not MemberExpression
    return path.node.callee.object.name === 'console';
  });

// Throws: Cannot read property 'object' of undefined
// when callee is Identifier, not MemberExpression
```

**Correct (defensive property access):**

```javascript
root.find(j.CallExpression)
  .filter(path => {
    const callee = path.node.callee;

    // Check type before accessing type-specific properties
    if (callee.type !== 'MemberExpression') {
      return false;
    }

    // Now safe to access MemberExpression properties
    return callee.object?.name === 'console';
  });
```

**Alternative (using optional chaining):**

```javascript
root.find(j.CallExpression)
  .filter(path => {
    // Optional chaining handles missing properties
    return path.node.callee?.object?.name === 'console' &&
           path.node.callee?.property?.name === 'log';
  });
```

**Common optional properties:**

| Node Type | Optional Property | When Missing |
|-----------|-------------------|--------------|
| FunctionDeclaration | `id` | Anonymous function |
| ExportDefaultDeclaration | `declaration.id` | Inline expression |
| MemberExpression | `object.name` | Computed member |
| Property | `key.name` | Computed key `[expr]` |
| ArrowFunctionExpression | `id` | Always missing |

Reference: [ast-types Node Definitions](https://github.com/benjamn/ast-types/blob/master/def/core.ts)
