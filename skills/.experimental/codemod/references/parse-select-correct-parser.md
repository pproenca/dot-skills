---
title: Select the Correct Parser for File Type
impact: CRITICAL
impactDescription: prevents 100% transform failures from AST mismatch
tags: parse, parser, language, configuration
---

## Select the Correct Parser for File Type

Parser selection determines AST structure. Using the wrong parser produces an invalid or incomplete AST that causes all downstream pattern matching to fail silently.

**Incorrect (wrong parser for file type):**

```bash
# Using 'javascript' parser for TypeScript files
npx codemod jssg run ./transform.ts ./src --language javascript

# TypeScript-specific syntax is parsed incorrectly:
# - Type annotations become syntax errors
# - Generic parameters are misinterpreted
# - Interface declarations are skipped
```

```typescript
// Transform fails to match typed code
const matches = root.findAll({
  rule: { pattern: "const $NAME: string = $VALUE" }
});
// Returns empty - 'javascript' parser doesn't understand ': string'
```

**Correct (matching parser to file type):**

```bash
# Use 'tsx' for .tsx files (includes .ts and .js support)
npx codemod jssg run ./transform.ts ./src --language tsx

# Use 'typescript' for .ts files without JSX
npx codemod jssg run ./transform.ts ./src --language typescript
```

```typescript
import type { Transform } from "codemod:ast-grep";
import type TSX from "codemod:ast-grep/langs/tsx";

// Explicitly type the transform for proper autocomplete
const transform: Transform<TSX> = (root) => {
  const matches = root.findAll({
    rule: { pattern: "const $NAME: string = $VALUE" }
  });
  // Correctly matches TypeScript code
  return null;
};
```

**Parser selection guide:**
- `.tsx` files → `tsx` (TypeScript + JSX)
- `.ts` files → `typescript` or `tsx`
- `.jsx` files → `jsx` (JavaScript + JSX)
- `.js` files → `javascript` or `jsx`

Reference: [JSSG Quickstart](https://docs.codemod.com/jssg/quickstart)
