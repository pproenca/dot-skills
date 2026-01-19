---
title: Set Appropriate Print Width for Long Lines
impact: MEDIUM
impactDescription: prevents overly long lines that break linting rules
tags: codegen, print-width, formatting, line-length
---

## Set Appropriate Print Width for Long Lines

New nodes created with builders use recast's default formatting. Set `wrapColumn` to match your project's line length limit.

**Incorrect (default width causes long lines):**

```javascript
// Default wrapColumn is 74, but project uses 100
return root.toSource();

// Creates:
// import {
//   ComponentA,
//   ComponentB,
//   ComponentC
// } from './components';
// When it could fit on one line
```

**Correct (match project line length):**

```javascript
// Match your prettier/eslint max-line-length
return root.toSource({
  wrapColumn: 100  // Or 80, 120 depending on project
});

// Creates:
// import { ComponentA, ComponentB, ComponentC } from './components';
```

**Alternative (disable wrapping for specific nodes):**

```javascript
// For nodes that should stay on one line regardless
const importNode = j.importDeclaration(specifiers, source);

// Mark as single-line (recast-specific)
importNode.loc = null; // Forces reprint without original location

return root.toSource({ wrapColumn: Infinity }); // No wrapping
```

**Matching common tools:**

| Tool | Default | Option |
|------|---------|--------|
| Prettier | 80 | `printWidth` |
| ESLint | varies | `max-len` |
| jscodeshift | 74 | `wrapColumn` |

**Note:** Consider running prettier/eslint after jscodeshift as a post-processing step rather than trying to match formatting exactly.

Reference: [recast - Print Options](https://github.com/benjamn/recast)
