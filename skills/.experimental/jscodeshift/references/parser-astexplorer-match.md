---
title: Match AST Explorer Parser to jscodeshift Parser
impact: CRITICAL
impactDescription: prevents AST structure mismatches during development
tags: parser, astexplorer, debugging, development
---

## Match AST Explorer Parser to jscodeshift Parser

AST Explorer uses different default parsers than jscodeshift. Mismatched parsers produce different AST structures, causing transforms developed in AST Explorer to fail in production.

**Incorrect (mismatched parsers):**

```javascript
// Developed in AST Explorer with @babel/parser
// Node type: OptionalMemberExpression
root.find(j.OptionalMemberExpression);

// But jscodeshift with 'tsx' parser produces:
// Node type: TSOptionalMemberExpression
// Transform finds nothing!
```

**Correct (matched parsers):**

```javascript
// For jscodeshift parser='tsx', use @typescript-eslint/parser in AST Explorer
// Both produce consistent node types

// For jscodeshift parser='babel', use @babel/parser in AST Explorer
// Both produce consistent node types

// AST Explorer settings → Transform: jscodeshift
// Parser: Match your module.exports.parser value
```

**Parser Mapping:**

| jscodeshift parser | AST Explorer parser |
|--------------------|---------------------|
| `tsx` | `@typescript-eslint/parser` |
| `ts` | `@typescript-eslint/parser` |
| `babel` | `@babel/parser` |
| `babylon` | `babylon7` |
| `flow` | `flow` |

**Note:** Always verify node types by inspecting the actual AST in AST Explorer with the matching parser before writing traversal code.

Reference: [AST Explorer](https://astexplorer.net/)
