---
title: Use buffer() Not source() for Binary Assets
impact: CRITICAL
impactDescription: prevents UTF-8 corruption of images and wasm
tags: asset, buffer, source, binary, encoding
---

## Use buffer() Not source() for Binary Assets

`Source.source()` returns either a string or a Buffer, depending on what was originally passed in — but webpack code that handles unknown assets generally calls `.toString()` on the result for convenience, which UTF-8-encodes binary content and silently corrupts PNGs, fonts, wasm modules, and source maps. `Source.buffer()` is the contract for "give me bytes regardless of how I was constructed." Use `buffer()` whenever the asset might be binary; use `source()` only when you've already established it's text.

**Incorrect (source() coerces to string — corrupts binary content):**

```js
compilation.hooks.processAssets.tap(
  { name: 'PngOptimizerPlugin', stage: Compilation.PROCESS_ASSETS_STAGE_OPTIMIZE_SIZE },
  async (assets) => {
    for (const name of Object.keys(assets)) {
      if (!name.endsWith('.png')) continue;
      const original = compilation.getAsset(name).source;
      // .source() may return string OR buffer — code below assumes buffer
      const bytes = original.source(); // <-- if string, UTF-8-encoded → corrupt PNG
      const compressed = await pngquant(bytes);
      compilation.updateAsset(name, new sources.RawSource(compressed));
    }
  },
);
```

**Correct (buffer() always returns a Buffer):**

```js
compilation.hooks.processAssets.tapPromise(
  { name: 'PngOptimizerPlugin', stage: Compilation.PROCESS_ASSETS_STAGE_OPTIMIZE_SIZE },
  async (assets) => {
    for (const name of Object.keys(assets)) {
      if (!name.endsWith('.png')) continue;
      const original = compilation.getAsset(name).source;
      const bytes = original.buffer(); // always a Buffer, even for OriginalSource
      const compressed = await pngquant(bytes);
      compilation.updateAsset(name, new sources.RawSource(compressed));
    }
  },
);
```

**Source method contract:**

| Method | Returns | Use for |
|---|---|---|
| `source()` | `string \| Buffer` | Text content where you know the source is text |
| `buffer()` | `Buffer` | ANY content where bytes matter (binary OR text) |
| `size()` | `number` (bytes) | Reporting, ordering — does NOT materialize content |
| `map(opts?)` | `RawSourceMap \| null` | Source map (only meaningful for SourceMapSource etc.) |
| `sourceAndMap(opts?)` | `{ source, map }` | Single materialization for both |

**Performance note:** `size()` returns a cached value when available; calling it doesn't decompress or read the underlying buffer. Prefer `size()` over `buffer().length` when you only need the size.

**RawSource accepts both:**

```js
new sources.RawSource(stringContent);          // text
new sources.RawSource(Buffer.from(bytes));     // binary — preserved as-is
new sources.RawSource(stringContent, /* convertToString */ false); // skip conversion in toString()
```

The third argument is webpack 5.79+ — pass `false` for binary content stored as a string to prevent webpack from trying to re-encode it.

Reference: [webpack-sources — Source API](https://github.com/webpack/webpack-sources#source) · [webpack 5.79 release notes](https://github.com/webpack/webpack/releases/tag/v5.79.0)
