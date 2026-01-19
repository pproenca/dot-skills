---
title: Understand Named vs Anonymous Nodes
impact: CRITICAL
impactDescription: eliminates 80% of pattern matching failures
tags: ast, tree-sitter, named-nodes, anonymous-nodes
---

## Understand Named vs Anonymous Nodes

Tree-sitter distinguishes between named nodes (semantic) and anonymous nodes (punctuation, keywords). ast-grep patterns skip anonymous nodes by default, which affects pattern matching behavior.

**Incorrect (matching anonymous nodes explicitly):**

```typescript
const transform: Transform<TSX> = (root) => {
  // Tries to match punctuation literally
  const matches = root.findAll({
    rule: { pattern: "{ $KEY: $VALUE }" }
  });
  // Fails because '{', ':', '}' are anonymous nodes
  // ast-grep skips them by default
  return null;
};
```

**Correct (matching named nodes only):**

```typescript
const transform: Transform<TSX> = (root) => {
  // Match the named 'object' node with pair children
  const matches = root.findAll({
    rule: {
      kind: "object",
      has: {
        kind: "pair",
        has: [
          { field: "key", pattern: "$KEY" },
          { field: "value", pattern: "$VALUE" }
        ]
      }
    }
  });
  return null;
};
```

**Named vs Anonymous:**
- **Named**: `function_declaration`, `identifier`, `string` (semantic meaning)
- **Anonymous**: `{`, `}`, `:`, `;`, `const` (syntax punctuation)

Use `node.isNamed()` to check node type programmatically.

Reference: [ast-grep Core Concepts](https://ast-grep.github.io/advanced/core-concepts.html)
