---
title: Parse with Lang.Tsx when scripting ast-grep over components
tags: napi, javascript-api, lang-tsx, findall
---

## Parse with Lang.Tsx when scripting ast-grep over components

`@ast-grep/napi` exposes the same two grammars as the CLI, and the same trap: `Lang.TypeScript` cannot parse JSX. A codemod script that calls `parse(Lang.TypeScript, source)` on a `.tsx` file gets an AST full of `ERROR` nodes and `findAll` returns `[]` — no exception, just silence. Select `Lang.Tsx` for any source that may contain JSX.

```typescript
import { parse, Lang } from '@ast-grep/napi';

const source = await readFile('src/components/Card.tsx', 'utf8');
const root = parse(Lang.Tsx, source).root();

// findAll takes a NapiConfig: { rule, constraints?, transform? } — not a bare rule object.
const buttons = root.findAll({
  rule: { pattern: '<Button $$$PROPS />' },
});
for (const node of buttons) {
  console.log(node.text());
}
```

A common mistake is passing the rule fields at the top level (`findAll({ pattern: … })`); they must be nested under `rule`. For scanning many files, `parseFiles` streams parsed roots so you avoid reading each file into memory yourself.

Reference: [ast-grep JavaScript API](https://ast-grep.github.io/guide/api-usage/js-api.html)
