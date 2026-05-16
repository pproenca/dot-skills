---
title: Use renameAsset to Move Assets, Not Delete + Emit
impact: CRITICAL
impactDescription: prevents losing related-asset graph and chunk linkage
tags: asset, renameAsset, related, chunk-graph
---

## Use renameAsset to Move Assets, Not Delete + Emit

When an asset is part of a chunk, webpack tracks the relationship in the chunk graph (`chunk.files`, `chunk.auxiliaryFiles`) and in the related-asset graph (`info.related.sourceMap`, `info.related.gz`). `compilation.deleteAsset(old)` followed by `compilation.emitAsset(new, source)` severs all of these references — chunks point to a missing file, source maps detach, and the manifest plugin emits a stale entry. `compilation.renameAsset(old, new)` updates every cross-reference atomically.

**Incorrect (delete + emit — chunk graph still references the old name):**

```js
compilation.hooks.processAssets.tap(
  { name: 'PrefixAssetsPlugin', stage: Compilation.PROCESS_ASSETS_STAGE_OPTIMIZE_HASH },
  (assets) => {
    for (const oldName of Object.keys(assets)) {
      const newName = `cdn/${oldName}`;
      const asset = compilation.getAsset(oldName);
      compilation.deleteAsset(oldName);
      compilation.emitAsset(newName, asset.source, asset.info);
      // chunk.files still contains oldName; sourcemap.related still points at oldName.map
    }
  },
);
```

**Correct (renameAsset rewrites every reference):**

```js
compilation.hooks.processAssets.tap(
  { name: 'PrefixAssetsPlugin', stage: Compilation.PROCESS_ASSETS_STAGE_OPTIMIZE_HASH },
  (assets) => {
    for (const oldName of Object.keys(assets)) {
      const newName = `cdn/${oldName}`;
      compilation.renameAsset(oldName, newName);
      // chunk.files updated; related sourcemap reference rebased
    }
  },
);
```

**What `renameAsset` updates that delete+emit doesn't:**

| Reference | delete + emit | renameAsset |
|---|---|---|
| `compilation.assets` map key | ✓ (manually) | ✓ |
| `compilation.assetsInfo` map | ✗ (info passed but not the original entry) | ✓ |
| `chunk.files` Set | ✗ — points at deleted asset | ✓ |
| `chunk.auxiliaryFiles` Set | ✗ | ✓ |
| `info.related.sourceMap` references | ✗ | ✓ |
| Persistent cache key | ✗ — cache write is for new key, old key orphaned | ✓ |

**`deleteAsset` IS the right call when:**

- The asset is genuinely going away (e.g., stripping a dev-only `.LICENSE.txt` companion in production)
- You explicitly want to break the chunk reference (e.g., replacing a chunk with multiple new ones)
- You're cleaning up an asset emitted by a different plugin you're explicitly replacing

In all those cases, follow the delete with cleanup of the chunk reference yourself: `chunk.files.delete(oldName)` for every chunk in `compilation.chunks`.

Reference: [Compilation API — renameAsset](https://webpack.js.org/api/compilation-object/#renameasset)
