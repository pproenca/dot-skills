---
title: Check Parent Path Before Transformation
impact: HIGH
impactDescription: prevents false positives on nested structures
tags: filter, parent, context, validation
---

## Check Parent Path Before Transformation

Nodes can appear in multiple contexts. Check the parent path to ensure you're transforming the correct usage.

**Incorrect (transforms all matching identifiers):**

```javascript
// Renames 'config' everywhere, including object keys and destructuring
root.find(j.Identifier, { name: 'config' })
  .forEach(path => {
    path.node.name = 'settings';
  });

// Breaks: { config: value } becomes { settings: value }
// Breaks: const { config } = obj; pattern matching fails
```

**Correct (checks parent context):**

```javascript
root.find(j.Identifier, { name: 'config' })
  .filter(path => {
    const parent = path.parent.node;

    // Skip object property keys: { config: ... }
    if (parent.type === 'Property' && parent.key === path.node) {
      return false;
    }

    // Skip object property shorthand: { config }
    if (parent.type === 'Property' && parent.shorthand) {
      return false;
    }

    // Skip member expression properties: obj.config
    if (parent.type === 'MemberExpression' && parent.property === path.node) {
      return false;
    }

    return true;
  })
  .forEach(path => {
    path.node.name = 'settings';
  });
```

**Alternative (using path.name for position):**

```javascript
root.find(j.Identifier, { name: 'config' })
  .filter(path => {
    // path.name tells you which property of parent this node is
    // 'object' = left side of member expression
    // 'property' = right side of member expression
    return path.name !== 'property' && path.name !== 'key';
  });
```

Reference: [ast-types - NodePath](https://github.com/benjamn/ast-types#nodepath)
