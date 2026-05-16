---
title: Prefer processAssets Over the emit Hook for Asset Mutation
impact: CRITICAL
impactDescription: prevents bypassing real-content hashing and SRI
tags: hook, processAssets, emit, deprecation, real-content-hash
---

## Prefer processAssets Over the emit Hook for Asset Mutation

The `emit` hook runs AFTER the entire `processAssets` pipeline, which means real-content hashing (`PROCESS_ASSETS_STAGE_OPTIMIZE_HASH`), Subresource Integrity, and the cache-write step have already executed. Mutating assets in `emit` produces filenames that don't match their content, breaks long-term caching for downstream consumers, and silently bypasses webpack 5's persistent cache. The replacement is a `processAssets` tap with the appropriate stage.

**Incorrect (mutating in emit — content hash and SRI are wrong):**

```js
class StripSourceMapCommentsPlugin {
  apply(compiler) {
    // emit runs after OPTIMIZE_HASH — hashes already baked into filenames
    compiler.hooks.emit.tapAsync('StripSourceMapCommentsPlugin', (compilation, cb) => {
      for (const name of Object.keys(compilation.assets)) {
        if (!name.endsWith('.js')) continue;
        const src = compilation.assets[name].source().toString();
        const cleaned = src.replace(/\/\/# sourceMappingURL=.*$/m, '');
        // Direct assignment bypasses updateAsset — hash, info, and cache out of sync
        compilation.assets[name] = new RawSource(cleaned);
      }
      cb();
    });
  }
}
```

**Correct (processAssets at the right stage, via updateAsset):**

```js
class StripSourceMapCommentsPlugin {
  apply(compiler) {
    compiler.hooks.thisCompilation.tap('StripSourceMapCommentsPlugin', (compilation) => {
      const { Compilation, sources } = compiler.webpack;
      compilation.hooks.processAssets.tap(
        {
          name: 'StripSourceMapCommentsPlugin',
          // Strip BEFORE size optimization and before real-content hashing
          stage: Compilation.PROCESS_ASSETS_STAGE_OPTIMIZE,
        },
        (assets) => {
          for (const name of Object.keys(assets)) {
            if (!name.endsWith('.js')) continue;
            const src = assets[name].source().toString();
            const cleaned = src.replace(/\/\/# sourceMappingURL=.*$/m, '');
            compilation.updateAsset(name, new sources.RawSource(cleaned));
          }
        },
      );
    });
  }
}
```

**Why `processAssets` won:**

- Runs inside the compilation phase, BEFORE filenames and hashes are finalized
- Stage system makes ordering between plugins explicit (no fragile emit-tap ordering)
- Persistent cache participates correctly
- `additionalAssets` is now deprecated in favor of `processAssets` with `STAGE_ADDITIONAL`

**`emit` is still correct for:**

- Side-effects that should happen exactly once after all assets are finalized (e.g., sending a notification, writing a build manifest to a path OUTSIDE webpack's output)
- Plugins that explicitly want to run AFTER all `processAssets` work (rare)

Reference: [Compilation Hooks — processAssets](https://webpack.js.org/api/compilation-hooks/#processassets) · [Webpack 5 release — processAssets](https://webpack.js.org/blog/2020-10-10-webpack-5-release/#new-asset-processing-pipeline)
