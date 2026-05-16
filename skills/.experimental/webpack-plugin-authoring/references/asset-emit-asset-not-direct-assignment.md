---
title: Use emitAsset / updateAsset, Not Direct compilation.assets Mutation
impact: CRITICAL
impactDescription: prevents desynced asset.info, hashes, and cache state
tags: asset, emitAsset, updateAsset, source-objects
---

## Use emitAsset / updateAsset, Not Direct compilation.assets Mutation

Webpack 5 stores assets behind methods that maintain three parallel structures: the `Source` object itself, the `info` metadata (immutable, hash, related, contenthash), and the persistent-cache entry. Direct assignment via `compilation.assets[name] = source` updates only the first, leaving `info` empty and the cache stale. Tools downstream (`html-webpack-plugin`, `webpack-subresource-integrity`, `compression-webpack-plugin`) read `getAsset(name).info` and silently produce wrong output.

**Incorrect (direct assignment — info metadata lost, real-content hash bypassed):**

```js
compilation.hooks.processAssets.tap(
  { name: 'StripBomPlugin', stage: Compilation.PROCESS_ASSETS_STAGE_PRE_PROCESS },
  (assets) => {
    for (const name of Object.keys(assets)) {
      const original = assets[name];
      const cleaned = original.source().toString().replace(/^﻿/, '');
      // Lost: original info (immutable, sourceFilename, related sourcemap)
      compilation.assets[name] = new sources.RawSource(cleaned);
    }
  },
);
```

**Correct (updateAsset preserves info, integrates with cache):**

```js
compilation.hooks.processAssets.tap(
  { name: 'StripBomPlugin', stage: Compilation.PROCESS_ASSETS_STAGE_PRE_PROCESS },
  (assets) => {
    for (const name of Object.keys(assets)) {
      compilation.updateAsset(
        name,
        (old) => new sources.RawSource(old.source().toString().replace(/^﻿/, '')),
        // Optional second arg: info updater function
        (oldInfo) => ({ ...oldInfo, javascriptModule: undefined }),
      );
    }
  },
);
```

**API summary:**

| Operation | Method | Notes |
|---|---|---|
| Add a new asset | `compilation.emitAsset(name, source, info?)` | Throws if name exists; pair with `compilation.fileDependencies.add(...)` if derived from a source file |
| Replace existing | `compilation.updateAsset(name, source \| (old) => new, info? \| (oldInfo) => newInfo)` | Preserves info unless second arg provided |
| Remove asset | `compilation.deleteAsset(name)` | Removes from assets and from related child references |
| Read | `compilation.getAsset(name)` | Returns `{ name, source, info }` — preferred over `compilation.assets[name]` |

**`info` fields downstream plugins rely on:**

- `immutable: true` — long-term cacheable (filename has content hash)
- `contenthash: string[]` — list of content hashes, used by SRI
- `related: { sourceMap: 'foo.js.map' }` — sibling assets that should follow this one
- `sourceFilename` — the originating source path
- `hotModuleReplacement: true` — HMR runtime asset, do not modify

Reference: [Compilation API — emitAsset / updateAsset / deleteAsset](https://webpack.js.org/api/compilation-object/#emitasset)
