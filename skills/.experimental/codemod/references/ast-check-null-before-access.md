---
title: Check Null Before Property Access
impact: CRITICAL
impactDescription: prevents runtime crashes in transforms
tags: ast, null-safety, defensive-programming, typescript
---

## Check Null Before Property Access

AST navigation methods return `null` when nodes don't exist. Always check for null before accessing properties to prevent runtime crashes.

**Incorrect (assumes nodes exist):**

```typescript
const transform: Transform<TSX> = (root) => {
  const calls = root.findAll({ rule: { kind: "call_expression" } });

  const edits = calls.map(call => {
    // Crashes if callee is computed: obj[method]()
    const methodName = call.field("function").field("property").text();
    // Crashes if no arguments
    const firstArg = call.field("arguments").children()[0].text();

    return call.replace(`newMethod(${firstArg})`);
  });

  return root.commitEdits(edits);
};
```

**Correct (null-safe access):**

```typescript
const transform: Transform<TSX> = (root) => {
  const calls = root.findAll({ rule: { kind: "call_expression" } });

  const edits = calls.flatMap(call => {
    const callee = call.field("function");
    if (!callee) return [];

    const property = callee.field("property");
    if (!property) return [];

    const args = call.field("arguments");
    const firstArg = args?.children()[0];
    if (!firstArg) return [];

    const methodName = property.text();
    return [call.replace(`newMethod(${firstArg.text()})`)];
  });

  return root.commitEdits(edits);
};
```

**Best practices:**
- Use optional chaining (`?.`) for exploratory access
- Use explicit null checks before transformations
- Return empty arrays from `flatMap` for invalid nodes
- Use TypeScript's narrowing with `if` statements

Reference: [JSSG API Reference](https://docs.codemod.com/jssg/reference)
