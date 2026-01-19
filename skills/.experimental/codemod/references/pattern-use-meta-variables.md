---
title: Use Meta Variables for Flexible Matching
impact: CRITICAL
impactDescription: enables pattern reuse across variations
tags: pattern, meta-variables, wildcards, captures
---

## Use Meta Variables for Flexible Matching

Meta variables (`$NAME`, `$$$ARGS`) capture arbitrary AST nodes, enabling flexible patterns that match code variations. Use single `$` for one node, triple `$$$` for multiple.

**Incorrect (hardcoded literals):**

```typescript
const transform: Transform<TSX> = (root) => {
  // Only matches exact string "error"
  const matches = root.findAll({
    rule: { pattern: 'console.error("error")' }
  });
  // Misses: console.error(message), console.error(err.message)
  // Misses: console.error("Error:", details)
  return null;
};
```

**Correct (meta variables for flexibility):**

```typescript
const transform: Transform<TSX> = (root) => {
  // $ARG captures any single argument
  const singleArg = root.findAll({
    rule: { pattern: "console.error($ARG)" }
  });

  // $$$ARGS captures zero or more arguments
  const anyArgs = root.findAll({
    rule: { pattern: "console.error($$$ARGS)" }
  });

  // Access captured values
  for (const match of anyArgs) {
    const args = match.getMultipleMatches("ARGS");
    console.log(`Found ${args.length} arguments`);
  }

  return null;
};
```

**Meta variable syntax:**
- `$NAME` - captures exactly one node
- `$$$NAME` - captures zero or more nodes
- `$_` - anonymous single capture (don't need value)
- `$$$` - anonymous multiple capture

Reference: [ast-grep Pattern Syntax](https://ast-grep.github.io/guide/pattern-syntax.html)
