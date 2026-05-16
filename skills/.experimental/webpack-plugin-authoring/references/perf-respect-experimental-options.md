---
title: Honor compiler.options.experiments.cacheUnaffected and incremental
impact: MEDIUM
impactDescription: 5x faster incremental rebuilds (limits work to changed inputs)
tags: perf, experiments, incremental, cacheUnaffected
---

## Honor compiler.options.experiments.cacheUnaffected and incremental

Webpack 5.95+ ships incremental compilation experiments (`experiments.cacheUnaffected`, `experiments.incremental`) that let webpack skip phases for unchanged modules. Plugins that re-process every asset on every rebuild defeat this — the user enables the experiment expecting 5x faster rebuilds and gets the same 30s rebuild because your plugin's `processAssets` tap touches everything. Check the experiment flag, and on incremental rebuilds use `compilation.modifiedFiles` / `compilation.removedFiles` to limit work to the changed inputs.

**Incorrect (re-processes everything on every rebuild — defeats incremental mode):**

```js
compilation.hooks.processAssets.tap(/* ... */, (assets) => {
  for (const name of Object.keys(assets)) {
    if (!name.endsWith('.js')) continue;
    transformAsset(compilation, name); // runs for all 200 assets even if 1 changed
  }
});
```

**Correct (limit work to changed assets on incremental rebuilds):**

```js
compilation.hooks.processAssets.tapPromise(/* ... */, async (assets) => {
  const isIncremental = compiler.options.experiments?.cacheUnaffected
    && compilation.modifiedFiles
    && compilation.modifiedFiles.size > 0;

  const affectedAssets = isIncremental
    ? computeAffectedAssets(compilation, assets) // walk dep graph from modifiedFiles
    : Object.keys(assets);

  for (const name of affectedAssets) {
    if (!name.endsWith('.js')) continue;
    transformAsset(compilation, name);
  }
});

function computeAffectedAssets(compilation, assets) {
  const affected = new Set();
  for (const chunk of compilation.chunks) {
    const modules = compilation.chunkGraph.getChunkModulesIterable(chunk);
    for (const mod of modules) {
      if (mod.resource && compilation.modifiedFiles.has(mod.resource)) {
        for (const file of chunk.files) affected.add(file);
        break;
      }
    }
  }
  return [...affected];
}
```

**Compilation properties exposed for incremental work:**

| Property | What |
|---|---|
| `compilation.modifiedFiles` | `Set<string>` of files changed since last build (watch mode only) |
| `compilation.removedFiles` | `Set<string>` of files deleted since last build |
| `compilation.compiler.modifiedFiles` | Compiler-level aggregate |
| `compilation.fileSystemInfo` | Snapshot interface for fine-grained "what changed?" queries |

On a cold build (first run, no watch state), `modifiedFiles` is `undefined` — the fallback path processes everything, which is correct.

**Even simpler: cache via `getCache` (see perf-cache-results-with-compilation-cache)** — for many plugins, etag-keyed caching is enough to skip 95%+ of work without needing to know which files changed.

**When NOT to optimize:**

- Plugin's work is global and depends on the full asset set (e.g., generating a manifest that lists every asset). Even one new asset means re-emitting the manifest.
- The work is already < 50ms total — the bookkeeping costs more than the savings.
- The plugin is a one-shot like `clean-webpack-plugin` that doesn't run per-rebuild meaningfully.

**Future-proofing:** The flag names have been moving in webpack 5.95–5.106 (`cacheUnaffected`, `incremental`, `incrementalBuild`). Reading the flag opportunistically (`?.`) and falling back to full processing is safer than depending on a specific flag.

Reference: [experiments configuration](https://webpack.js.org/configuration/experiments/) · [Webpack 5.106 release notes](https://webpack.js.org/blog/2026-04-08-webpack-5-106/)
