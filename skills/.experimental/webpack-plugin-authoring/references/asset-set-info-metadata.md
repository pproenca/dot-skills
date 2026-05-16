---
title: Set asset.info Metadata When Emitting
impact: CRITICAL
impactDescription: prevents wrong cache headers and broken SRI
tags: asset, info, immutable, content-hash, sri
---

## Set asset.info Metadata When Emitting

`asset.info` is webpack's contract with the rest of the toolchain about what an asset is and how downstream tools should treat it. Emitting an asset without `info.immutable` causes Next.js's CDN headers to disable long-term caching; emitting without `info.contenthash` makes `webpack-subresource-integrity` skip the asset; emitting without `info.related` orphans companion files (source maps, gzipped versions). Setting `info` correctly is part of "correctly emitting an asset," not an optional polish step.

**Incorrect (no info — looks fine in dev, breaks production caching and SRI):**

```js
const { sources } = compiler.webpack;
const hash = compilation.outputOptions.hashFunction;
const filename = `licenses.${computeHash(content)}.txt`;

compilation.emitAsset(filename, new sources.RawSource(content));
// No info — CDN won't cache, SRI skips it, source map won't follow
```

**Correct (info documents the contract):**

```js
const { sources } = compiler.webpack;
const contentHash = compilation.outputOptions.hashFunction;
const filename = `licenses.${computeHash(content)}.txt`;

compilation.emitAsset(filename, new sources.RawSource(content), {
  // Filename contains content hash — safe for far-future Cache-Control
  immutable: true,
  // Hashes used by SRI and integrity-checking plugins
  contenthash: [computeHash(content)],
  // Companion files webpack should ship together
  related: { sourceMap: filename + '.map' },
  // Where this asset came from (some loaders use this for HMR)
  sourceFilename: 'LICENSES',
  // Mark generated content so other plugins know not to retransform
  development: false,
  // For text assets, declare encoding so compression plugin can act on it
  minimized: false,
});
```

**Most-used `info` fields:**

| Field | Type | Used by |
|---|---|---|
| `immutable` | `boolean` | CDN cache headers (Next.js, Vercel), browser cache lifetime |
| `contenthash` | `string \| string[]` | `webpack-subresource-integrity`, real-content-hash plugin |
| `minimized` | `boolean` | Skips re-minification; informs bundle analyzer |
| `related` | `{ [key]: string \| string[] }` | Source maps, gzip/brotli companions, license files |
| `sourceFilename` | `string` | HMR module replacement, error originator display |
| `chunkhash` | `string \| string[]` | Long-term caching for code-split chunks |
| `fullhash` | `string \| string[]` | Whole-build hash references |
| `hotModuleReplacement` | `boolean` | HMR runtime — must NOT be re-emitted by other plugins |
| `javascriptModule` | `boolean` | Asset is an ESM module (affects `<script type=module>`) |
| `development` | `boolean` | Marks dev-only assets that should be stripped from prod stats |
| `size` | `number` | Hint for bundle reports without forcing source materialization |

**When updating an asset, merge — don't replace — the info:**

```js
compilation.updateAsset(
  name,
  newSource,
  (oldInfo) => ({ ...oldInfo, minimized: true }), // preserve everything else
);
```

Reference: [Compilation API — assetInfo](https://webpack.js.org/api/compilation-object/#emitasset) · [webpack-subresource-integrity](https://github.com/waysact/webpack-subresource-integrity)
