---
title: Attach loc and module to Errors for Source Mapping
impact: MEDIUM-HIGH
impactDescription: enables IDE click-through to the offending line
tags: diag, loc, module, source-link, ide
---

## Attach loc and module to Errors for Source Mapping

A WebpackError with no `loc` or `module` appears in stats output as a bare message. With `loc` and `module` set, webpack-cli renders a clickable source link (file:line:column), the dev-server overlay highlights the source range, and IDE webpack extensions (VS Code's `webpack` plugin, JetBrains' webpack integration) navigate to the exact line. The cost is two property assignments; the benefit is the difference between "search the codebase for this string" and "click here."

**Incorrect (bare message — no source link):**

```js
compilation.hooks.finishModules.tap('NoDefaultExportPlugin', (modules) => {
  for (const mod of modules) {
    const src = mod.originalSource()?.source().toString();
    if (src && /export default/.test(src)) {
      compilation.warnings.push(
        new WebpackError(`${mod.resource}: default exports are forbidden`),
      );
      // Stats: "WARNING in /abs/path/file.ts: default exports are forbidden"
      // No clickable link, no overlay highlight.
    }
  }
});
```

**Correct (loc + module — webpack renders clickable source link):**

```js
compilation.hooks.finishModules.tap('NoDefaultExportPlugin', (modules) => {
  for (const mod of modules) {
    const src = mod.originalSource()?.source().toString();
    if (!src) continue;
    const match = /^export default/m.exec(src);
    if (!match) continue;

    const lineOffset = src.slice(0, match.index).split('\n').length;
    const warn = new WebpackError('Default exports are forbidden — use named exports');
    warn.module = mod;
    warn.loc = {
      start: { line: lineOffset, column: 0 },
      end: { line: lineOffset, column: 'export default'.length },
    };

    compilation.warnings.push(warn);
    // Stats: "WARNING in ./src/foo.ts:7:0-14
    //   Module Warning (from NoDefaultExportPlugin):
    //   Default exports are forbidden — use named exports"
  }
});
```

**Error properties that affect stats rendering:**

| Property | Type | Effect |
|---|---|---|
| `.module` | `Module` | Renders as `WARNING in ./relative/path` (resolved via stats context) |
| `.file` | `string` | Used when no `.module` available — absolute path shown as-is |
| `.loc` | `{ start: { line, column }, end: { line, column } }` | Adds `:line:col-col` and enables source-snippet rendering |
| `.dependencies` | `Dependency[]` | For dependency-related errors, attaches to dependency chain |
| `.hideStack` | `boolean` | Suppresses webpack's auto-appended stack |
| `.details` | `string` | Long-form info shown with `stats.errorDetails: true` |
| `.name` | `string` | Shown as the error category prefix |

**Line numbers are 1-based, columns are 0-based.** This matches the source-map convention and what webpack's stats formatter expects.

**For string-replacement plugins, compute loc from the match index:**

```js
function locFromMatch(source, index) {
  const before = source.slice(0, index);
  const line = before.split('\n').length;
  const lineStart = before.lastIndexOf('\n') + 1;
  return {
    start: { line, column: index - lineStart },
    end: { line, column: index - lineStart },
  };
}
```

**Avoid loc with the wrong source.** If you're inspecting a `Module`'s ORIGINAL source but the user has a loader chain (Babel, TS), `loc` should reference the loader output's line numbers — which is what you have from `mod.originalSource()`. The source map will translate when the overlay renders.

Reference: [WebpackError fields](https://github.com/webpack/webpack/blob/main/lib/WebpackError.js) · [stats configuration](https://webpack.js.org/configuration/stats/)
