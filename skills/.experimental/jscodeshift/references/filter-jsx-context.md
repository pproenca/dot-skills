---
title: Distinguish JSX Context from Regular JavaScript
impact: HIGH
impactDescription: prevents incorrect transforms in JSX attributes vs expressions
tags: filter, jsx, context, attributes
---

## Distinguish JSX Context from Regular JavaScript

JSX uses different node types than regular JavaScript. Transforms must handle both contexts or risk missing matches.

**Incorrect (ignores JSX context):**

```javascript
// Only finds JavaScript function calls, misses JSX
root.find(j.CallExpression, {
  callee: { name: 'formatDate' }
});

// Misses: <Component date={formatDate(value)} />
// The formatDate call IS found, but...

// This misses JSX attribute handling entirely:
root.find(j.Identifier, { name: 'onClick' });
// Does NOT find: <button onClick={handler}>
```

**Correct (handles both contexts):**

```javascript
// For function calls in JSX expressions - this works fine
root.find(j.CallExpression, {
  callee: { name: 'formatDate' }
});

// For prop/attribute names - use JSX-specific types
root.find(j.JSXAttribute, {
  name: { name: 'onClick' }
});

// For JSX element names
root.find(j.JSXIdentifier, { name: 'Button' })
  .filter(path => {
    // Only opening/closing element names, not attribute names
    return path.parent.node.type === 'JSXOpeningElement' ||
           path.parent.node.type === 'JSXClosingElement';
  });
```

**JSX node type mapping:**

| JavaScript | JSX Equivalent |
|------------|----------------|
| `Identifier` | `JSXIdentifier` |
| `MemberExpression` | `JSXMemberExpression` |
| N/A | `JSXAttribute` |
| N/A | `JSXSpreadAttribute` |
| N/A | `JSXExpressionContainer` |

**Note:** CallExpressions inside JSX are regular CallExpressions - only the JSX-specific syntax uses JSX node types.

Reference: [JSX AST Specification](https://github.com/facebook/jsx/blob/main/AST.md)
