---
title: Traverse compilation.chunks Not compilation.modules When Possible
impact: MEDIUM
impactDescription: O(modules) becomes O(chunks) — often 10-100x fewer iterations
tags: perf, chunks, modules, traversal
---

## Traverse compilation.chunks Not compilation.modules When Possible

`compilation.modules` contains every module reachable from any entry — for a Next.js app, that's 20,000+ entries including every node_modules import. `compilation.chunks` is the much smaller set of OUTPUT bundles (typically 10–100). When the plugin's question is "what gets emitted?" — chunk traversal is the right answer and is 10–1000x faster. Iterating modules to answer a chunk-level question is a common authoring mistake that surfaces only when the plugin runs in a real-sized project.

**Incorrect (iterates every module to find entry chunks — O(modules) per build):**

```js
compiler.hooks.thisCompilation.tap('EntryManifestPlugin', (compilation) => {
  compilation.hooks.afterSeal.tap('EntryManifestPlugin', () => {
    const manifest = {};
    // 20,000+ iterations in a real Next.js build
    for (const mod of compilation.modules) {
      if (mod.type !== 'javascript/auto') continue;
      for (const chunk of compilation.chunkGraph.getModuleChunks(mod)) {
        if (!chunk.canBeInitial()) continue;
        manifest[chunk.name] = manifest[chunk.name] || [];
        manifest[chunk.name].push(mod.userRequest);
      }
    }
    // ...
  });
});
```

**Correct (start from chunks — O(chunks) total):**

```js
compiler.hooks.thisCompilation.tap('EntryManifestPlugin', (compilation) => {
  compilation.hooks.afterSeal.tap('EntryManifestPlugin', () => {
    const manifest = {};
    // ~50 iterations in the same Next.js build
    for (const chunk of compilation.chunks) {
      if (!chunk.canBeInitial()) continue;

      const entryModules = compilation.chunkGraph.getChunkEntryModulesIterable(chunk);
      manifest[chunk.name] = [...entryModules].map((m) => m.userRequest);
    }
    // ...
  });
});
```

**ChunkGraph API for chunk → modules traversal:**

| API | Returns | Use when |
|---|---|---|
| `chunkGraph.getChunkModulesIterable(chunk)` | All modules in the chunk | Listing chunk contents |
| `chunkGraph.getChunkEntryModulesIterable(chunk)` | Just entry modules | Manifest, async-chunk routing |
| `chunkGraph.getChunkRuntimeModulesIterable(chunk)` | Runtime helpers | Runtime patching |
| `chunkGraph.getModuleChunks(module)` | All chunks containing this module | Module-centric questions (rarely needed) |
| `chunkGraph.getNumberOfChunkModules(chunk)` | Count only | Size reporting without materializing the list |

**For asset-level questions, iterate `chunk.files` and `chunk.auxiliaryFiles`:**

```js
for (const chunk of compilation.chunks) {
  for (const file of chunk.files) {        // .js / .mjs
    manifest[chunk.id] = manifest[chunk.id] || { js: [], assets: [] };
    manifest[chunk.id].js.push(file);
  }
  for (const file of chunk.auxiliaryFiles) { // .css / .map / images
    manifest[chunk.id].assets.push(file);
  }
}
```

This is the pattern `webpack-manifest-plugin` and Next.js's BuildManifestPlugin use.

**When you DO need `compilation.modules`:**

- Linting or analyzing source code across the entire dependency graph
- Per-module decisions independent of chunking (e.g., "flag every module with a TODO comment")
- Implementing tree-shaking-style analysis

For these, iterate `compilation.modules` BUT use `Set` lookups for membership tests, not `Array.includes`, which is O(n²) at scale.

Reference: [ChunkGraph API](https://webpack.js.org/api/compilation-object/#chunkgraph) · [vercel/next.js BuildManifestPlugin](https://github.com/vercel/next.js/tree/canary/packages/next/src/build/webpack/plugins)
