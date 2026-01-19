---
title: Handle Embedded Languages with parseAsync
impact: CRITICAL
impactDescription: enables transformations in template literals and CSS-in-JS
tags: parse, embedded, css-in-js, template-literals
---

## Handle Embedded Languages with parseAsync

Code often contains embedded languages (CSS in styled-components, SQL in template literals, GraphQL queries). Use `parseAsync` to create sub-parsers for these contexts.

**Incorrect (treating embedded code as strings):**

```typescript
const transform: Transform<TSX> = (root) => {
  const styledComponents = root.findAll({
    rule: { pattern: "styled.$TAG`$$$CSS`" }
  });

  const edits = styledComponents.map(match => {
    const css = match.getMatch("CSS")?.text() || "";
    // Regex-based CSS transformation - fragile, misses edge cases
    const newCss = css.replace(/color:\s*red/g, "color: blue");
    return match.replace(`styled.${match.getMatch("TAG")?.text()}\`${newCss}\``);
  });

  return root.commitEdits(edits);
};
```

**Correct (parsing embedded CSS):**

```typescript
import { parseAsync } from "codemod:ast-grep";

const transform: Transform<TSX> = async (root) => {
  const styledComponents = root.findAll({
    rule: { pattern: "styled.$TAG`$$$CSS`" }
  });

  const edits = await Promise.all(styledComponents.map(async match => {
    const cssText = match.getMatch("CSS")?.text() || "";

    // Parse CSS content as actual CSS
    const cssRoot = await parseAsync("css", cssText);
    const colorDecls = cssRoot.root().findAll({
      rule: { pattern: "color: red" }
    });

    if (colorDecls.length === 0) return null;

    // Transform CSS using AST
    const cssEdits = colorDecls.map(decl => decl.replace("color: blue"));
    const newCss = cssRoot.commitEdits(cssEdits);

    const tag = match.getMatch("TAG")?.text();
    return match.replace(`styled.${tag}\`${newCss}\``);
  }));

  return root.commitEdits(edits.filter(Boolean) as Edit[]);
};
```

**Embedded language scenarios:**
- `styled-components` / `emotion` → CSS parser
- Template literal SQL → SQL parser (if supported)
- GraphQL tagged templates → GraphQL parser
- HTML in template strings → HTML parser

Reference: [JSSG Advanced Patterns](https://docs.codemod.com/jssg/advanced)
