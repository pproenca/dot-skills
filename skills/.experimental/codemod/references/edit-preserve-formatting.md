---
title: Preserve Surrounding Formatting in Edits
impact: MEDIUM-HIGH
impactDescription: maintains code style consistency
tags: edit, formatting, whitespace, style
---

## Preserve Surrounding Formatting in Edits

When replacing nodes, preserve the surrounding whitespace and formatting to maintain code style consistency.

**Incorrect (ignoring formatting context):**

```typescript
const transform: Transform<TSX> = (root) => {
  const functions = root.findAll({
    rule: { pattern: "function $NAME() { $$$BODY }" }
  });

  const edits = functions.map(fn => {
    const name = fn.getMatch("NAME")?.text();
    // Hardcoded formatting ignores original style
    return fn.replace(`const ${name} = () => {}`);
    // Original: function   foo()  { ... }
    // Result:   const foo = () => {}
    // Lost: extra spacing, newlines, etc.
  });

  return root.commitEdits(edits);
};
```

**Correct (preserving formatting):**

```typescript
const transform: Transform<TSX> = (root) => {
  const functions = root.findAll({
    rule: { pattern: "function $NAME() { $$$BODY }" }
  });

  const edits = functions.map(fn => {
    const name = fn.getMatch("NAME");
    const body = fn.getMultipleMatches("BODY");

    if (!name) return fn.replace(fn.text());

    // Preserve body formatting exactly
    const bodyText = body.map(b => b.text()).join("");

    // Match the original node's formatting
    const original = fn.text();
    const leadingSpace = original.match(/^(\s*)/)?.[1] || "";

    return fn.replace(`${leadingSpace}const ${name.text()} = () => {${bodyText}}`);
  });

  return root.commitEdits(edits);
};
```

**Better: Use getTransformed for captured nodes:**

```typescript
const transform: Transform<TSX> = (root) => {
  const functions = root.findAll({
    rule: { pattern: "function $NAME() { $$$BODY }" }
  });

  const edits = functions.map(fn => {
    // getTransformed preserves original text exactly
    const nameText = fn.getTransformed("NAME") || "anonymous";
    const bodyText = fn.getTransformed("BODY") || "";

    return fn.replace(`const ${nameText} = () => {${bodyText}}`);
  });

  return root.commitEdits(edits);
};
```

Reference: [JSSG API Reference](https://docs.codemod.com/jssg/reference)
