---
title: Use kind Constraint for Precision
impact: CRITICAL
impactDescription: reduces false positives by 10x
tags: ast, kind, precision, matching
---

## Use kind Constraint for Precision

Combine pattern matching with `kind` constraints to eliminate false positives. Patterns alone can match unintended code structures with similar text.

**Incorrect (pattern without kind constraint):**

```typescript
const transform: Transform<TSX> = (root) => {
  // Pattern matches too broadly
  const matches = root.findAll({
    rule: { pattern: "console.log($ARG)" }
  });
  // Also matches: const console = { log: fn }; console.log(x)
  // And: "console.log(test)" in strings
  // And: // console.log(debug) in comments
  return null;
};
```

**Correct (pattern with kind constraint):**

```typescript
const transform: Transform<TSX> = (root) => {
  // Constrain to actual call expressions only
  const matches = root.findAll({
    rule: {
      kind: "call_expression",
      pattern: "console.log($ARG)"
    }
  });
  // Only matches real console.log() calls
  // Ignores strings, comments, and shadowed variables
  return null;
};
```

**Common kind values:**
- `call_expression` - function calls
- `member_expression` - property access (a.b)
- `arrow_function` - arrow functions
- `function_declaration` - named functions
- `jsx_element` - JSX tags

Reference: [ast-grep Pattern Syntax](https://ast-grep.github.io/guide/pattern-syntax.html)
