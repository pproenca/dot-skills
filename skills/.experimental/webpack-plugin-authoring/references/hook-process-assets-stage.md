---
title: Pick the Right processAssets Stage
impact: CRITICAL
impactDescription: prevents minification undoing your transform
tags: hook, processAssets, stages, asset-pipeline
---

## Pick the Right processAssets Stage

`processAssets` runs in 15 ordered stages — earlier stages run first, and a stage's name describes what it expects to be in the asset graph at that point. If you inject a banner in `STAGE_OPTIMIZE_SIZE`, the minifier (which runs at `STAGE_OPTIMIZE_SIZE` too) may strip it. If you compute a hash in `STAGE_OPTIMIZE_TRANSFER`, the real-content hash plugin has already run and your hash is wrong. Picking the right stage is the single most consequential decision in modern webpack 5 plugin authoring.

**Incorrect (banner injected during size optimization — terser strips it):**

```js
const { Compilation, sources } = compiler.webpack;

compilation.hooks.processAssets.tap(
  {
    name: 'BannerPlugin',
    // Wrong stage — terser also runs at OPTIMIZE_SIZE and may remove the comment
    stage: Compilation.PROCESS_ASSETS_STAGE_OPTIMIZE_SIZE,
  },
  (assets) => {
    for (const name of Object.keys(assets)) {
      compilation.updateAsset(
        name,
        (old) => new sources.ConcatSource('/* my banner */\n', old),
      );
    }
  },
);
```

**Correct (banner injected at ADDITIONS — runs before any size optimization):**

```js
const { Compilation, sources } = compiler.webpack;

compilation.hooks.processAssets.tap(
  {
    name: 'BannerPlugin',
    stage: Compilation.PROCESS_ASSETS_STAGE_ADDITIONS,
  },
  (assets) => {
    for (const name of Object.keys(assets)) {
      compilation.updateAsset(
        name,
        (old) => new sources.ConcatSource('/* my banner */\n', old),
      );
    }
  },
);
```

**Stage cheatsheet (in execution order):**

| Stage | Use for |
|---|---|
| `PROCESS_ASSETS_STAGE_ADDITIONAL` | Adding entirely new assets (manifests, license files) |
| `PROCESS_ASSETS_STAGE_PRE_PROCESS` | Stripping comments, normalizing line endings |
| `PROCESS_ASSETS_STAGE_DERIVED` | Generating from existing (split chunks, dynamic imports) |
| `PROCESS_ASSETS_STAGE_ADDITIONS` | Banners, prepended init code, polyfills |
| `PROCESS_ASSETS_STAGE_OPTIMIZE` | General optimizations |
| `PROCESS_ASSETS_STAGE_OPTIMIZE_SIZE` | Minification (terser, css-minimizer) |
| `PROCESS_ASSETS_STAGE_DEV_TOOLING` | Source-map extraction |
| `PROCESS_ASSETS_STAGE_OPTIMIZE_INLINE` | Inlining small assets |
| `PROCESS_ASSETS_STAGE_SUMMARIZE` | Reading the final asset list (read-only) |
| `PROCESS_ASSETS_STAGE_OPTIMIZE_HASH` | Computing real content hashes |
| `PROCESS_ASSETS_STAGE_OPTIMIZE_TRANSFER` | gzip/brotli pre-compression |
| `PROCESS_ASSETS_STAGE_ANALYSE` | Bundle analysis (read-only after hashes settled) |
| `PROCESS_ASSETS_STAGE_REPORT` | Report files (stats.json, bundle reports) |

Reference: [Compilation Hooks — processAssets stages](https://webpack.js.org/api/compilation-hooks/#processassets)
