---
title: Preserve Source Maps When Transforming Assets
impact: CRITICAL
impactDescription: prevents detached source maps and broken debugging
tags: asset, source-map, source-map-source, replace-source
---

## Preserve Source Maps When Transforming Assets

Wrapping a transformed asset in `RawSource` discards its source map — debuggers, error trackers (Sentry), and the dev-server overlay then point at minified output. The correct primitives are `SourceMapSource` (when you have a fresh map for the new content) and `ReplaceSource` (when you make text-replacement edits and want webpack to compute the rebased map). Both preserve the source-map graph so downstream consumers still get useful stack traces.

**Incorrect (RawSource drops the map — production stack traces become useless):**

```js
const { sources } = compiler.webpack;

compilation.updateAsset(name, (old) => {
  const code = old.source().toString();
  const transformed = transformAst(code); // syntax transform, no map produced
  return new sources.RawSource(transformed); // map gone
});
```

**Correct (when you produce a fresh map alongside the new code):**

```js
const { sources } = compiler.webpack;

compilation.updateAsset(name, (old) => {
  const code = old.source().toString();
  const oldMap = old.map(); // may be null if no map
  const { code: newCode, map: newMap } = transformAstWithMap(code, oldMap);
  return new sources.SourceMapSource(
    newCode,
    name,
    newMap,
    code,        // original source for `original` link
    oldMap,      // input map to chain through
    /* removeOriginalSource */ true,
  );
});
```

**Alternative (pure text replacement — let ReplaceSource compute the map):**

```js
const { sources } = compiler.webpack;

compilation.updateAsset(name, (old) => {
  const replacer = new sources.ReplaceSource(old, name);
  // Each replace records position; final map is computed against the input map
  for (const match of findEnvVarReferences(old.source().toString())) {
    replacer.replace(match.start, match.end - 1, JSON.stringify(process.env[match.name]));
  }
  return replacer;
});
```

**Decision matrix:**

| Transform shape | Use |
|---|---|
| AST/codegen produces own source map | `SourceMapSource(code, name, newMap, origSrc, inputMap, true)` |
| String find/replace, splicing, prepend/append | `ReplaceSource` (computes map automatically) |
| Concatenating multiple sources (banners, headers) | `ConcatSource(...)` (preserves each child's map) |
| Caching an expensive transformation | wrap result in `CachedSource(inner)` |
| Truly no source mapping (e.g., a binary asset) | `RawSource` is fine |

**Don't strip the original source map asset.** When you produce a new map, webpack will emit it as a related asset (`name + '.map'`) automatically through the `SourceMapDevToolPlugin` pipeline if `devtool` is configured. Do not `compilation.deleteAsset(name + '.map')` manually.

Reference: [webpack-sources README](https://github.com/webpack/webpack-sources#readme) · [SourceMapDevToolPlugin](https://webpack.js.org/plugins/source-map-dev-tool-plugin/)
