---
title: Avoid source().toString() on Assets You Won't Modify
impact: MEDIUM
impactDescription: skip O(asset-bytes) materialization for read-only checks
tags: perf, source, materialization, lazy
---

## Avoid source().toString() on Assets You Won't Modify

`Source.source()` materializes the underlying bytes — for a `CachedSource` wrapping a `ConcatSource` of 200 chunk children, it concatenates all of them, allocates the result, and (for `toString()`) decodes UTF-8. Doing this for every asset just to check `name.endsWith('.js')` or `info.size > N` is wasted work. Use `compilation.getAsset(name).info.size` for size, `source.size()` for byte-count, and filter by name/extension BEFORE calling `source()`.

**Incorrect (materializes every asset just to count large ones):**

```js
compiler.hooks.thisCompilation.tap('SizeReportPlugin', (compilation) => {
  compilation.hooks.afterProcessAssets.tap('SizeReportPlugin', (assets) => {
    let largeCount = 0;
    for (const name of Object.keys(assets)) {
      // Forces every asset's underlying source to materialize — wastes ~100MB for a big build
      const size = assets[name].source().length;
      if (size > 250_000) largeCount++;
    }
    console.log(`Large assets: ${largeCount}`);
  });
});
```

**Correct (size() / info.size never materialize content):**

```js
compiler.hooks.thisCompilation.tap('SizeReportPlugin', (compilation) => {
  compilation.hooks.afterProcessAssets.tap('SizeReportPlugin', () => {
    let largeCount = 0;
    for (const chunk of compilation.chunks) {
      for (const file of chunk.files) {
        const info = compilation.getAsset(file)?.info;
        const size = info?.size ?? compilation.getAsset(file)?.source.size() ?? 0;
        if (size > 250_000) largeCount++;
      }
    }
    compilation.getLogger('SizeReportPlugin').info(`Large assets: ${largeCount}`);
  });
});
```

**Cheap operations (don't materialize):**

| Operation | Cost |
|---|---|
| `source.size()` | O(1) — cached |
| `compilation.getAsset(name).info.size` | O(1) |
| `Object.keys(assets)` | O(assets) keys, doesn't touch source |
| Name/extension filters | O(1) per asset |
| `Object.keys(assets).length` | O(1) |

**Expensive operations (force materialization):**

| Operation | Cost |
|---|---|
| `source.source()` | O(content bytes) + allocation |
| `source.source().toString()` | Above + UTF-8 decode |
| `source.buffer()` | O(content bytes) + allocation (returns Buffer) |
| `source.sourceAndMap()` | Source materialization + map serialization |
| `source.map()` | Map serialization (expensive for SourceMapSource) |

**Filter first, materialize second:**

```js
// Good: filter before reading content
for (const name of Object.keys(assets)) {
  if (!name.endsWith('.js')) continue;       // O(1) per asset
  if (assets[name].size() < 1024) continue;  // O(1)
  const code = assets[name].source().toString(); // materialize only candidates
  if (needsTransform(code)) transform(name, code);
}
```

**Cache materialization within a single tap:**

If you need to read the same asset twice within a tap, cache it locally:

```js
const code = source.source().toString();    // materialize once
const hasFoo = code.includes('foo');
const hasBar = code.includes('bar');
// Don't call source.source() again
```

**`CachedSource` is your friend.** Wrapping the result of an expensive transform in `new sources.CachedSource(inner)` makes subsequent `.source()` calls within the same compilation O(1). Webpack already wraps assets internally — your plugin should pass through `CachedSource` references rather than unwrapping them.

Reference: [webpack-sources — Source API](https://github.com/webpack/webpack-sources#source) · [Compilation API — getAsset](https://webpack.js.org/api/compilation-object/#getasset)
