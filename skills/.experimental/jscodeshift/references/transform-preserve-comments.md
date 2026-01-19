---
title: Preserve Comments When Replacing Nodes
impact: HIGH
impactDescription: prevents loss of documentation and directives
tags: transform, comments, preservation, documentation
---

## Preserve Comments When Replacing Nodes

Comments are attached to AST nodes. Replacing a node loses its comments unless explicitly preserved.

**Incorrect (loses comments):**

```javascript
// Original: /* Important */ const config = getConfig();
root.find(j.VariableDeclaration)
  .replaceWith(path => {
    return j.variableDeclaration('let', path.node.declarations);
  });
// Result: let config = getConfig();
// Comment /* Important */ is lost!
```

**Correct (preserves comments):**

```javascript
root.find(j.VariableDeclaration)
  .replaceWith(path => {
    const newNode = j.variableDeclaration('let', path.node.declarations);

    // Copy leading and trailing comments
    newNode.comments = path.node.comments;

    return newNode;
  });
// Result: /* Important */ let config = getConfig();
```

**Alternative (preserve all attached comments):**

```javascript
function preserveComments(oldNode, newNode) {
  if (oldNode.comments) {
    newNode.comments = oldNode.comments;
  }
  if (oldNode.leadingComments) {
    newNode.leadingComments = oldNode.leadingComments;
  }
  if (oldNode.trailingComments) {
    newNode.trailingComments = oldNode.trailingComments;
  }
  return newNode;
}

root.find(j.VariableDeclaration)
  .replaceWith(path => {
    const newNode = j.variableDeclaration('let', path.node.declarations);
    return preserveComments(path.node, newNode);
  });
```

**When NOT to preserve comments:**

```javascript
// When deleting code, comments should be removed too
root.find(j.CallExpression, { callee: { name: 'deprecatedFunc' } })
  .remove(); // Comments on removed nodes are intentionally lost
```

Reference: [recast - Preserving Original Formatting](https://github.com/benjamn/recast)
