---
title: Use AST Explorer Before Writing Patterns
impact: CRITICAL
impactDescription: prevents hours of debugging invalid patterns
tags: ast, debugging, development, ast-explorer
---

## Use AST Explorer Before Writing Patterns

Always visualize the AST structure using AST Explorer before writing patterns. The tree structure often differs from what you expect based on source code appearance.

**Incorrect (guessing AST structure):**

```typescript
const transform: Transform<TSX> = (root) => {
  // Assumes 'const x = 1' has a direct 'identifier' child
  const matches = root.findAll({
    rule: { pattern: "const $NAME = $VALUE" }
  });
  // Pattern fails because 'const' creates a lexical_declaration
  // with variable_declarator children, not direct identifiers
  return null;
};
```

**Correct (verified in AST Explorer):**

```typescript
const transform: Transform<TSX> = (root) => {
  // Verified: lexical_declaration > variable_declarator > name, value
  const matches = root.findAll({
    rule: {
      kind: "variable_declarator",
      has: { field: "name", pattern: "$NAME" }
    }
  });
  // Pattern matches actual tree structure
  return null;
};
```

**Workflow:**
1. Paste target code in [astexplorer.net](https://astexplorer.net)
2. Select the correct parser (tree-sitter for ast-grep)
3. Click nodes to see their `kind` and field names
4. Write patterns matching the actual structure

Reference: [ast-grep Pattern Syntax](https://ast-grep.github.io/guide/pattern-syntax.html)
