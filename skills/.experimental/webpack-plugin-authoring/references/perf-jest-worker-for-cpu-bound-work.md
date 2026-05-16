---
title: Offload CPU-Bound Work to jest-worker
impact: MEDIUM
impactDescription: 2-4x build speedup on multi-core machines
tags: perf, jest-worker, parallelism, terser
---

## Offload CPU-Bound Work to jest-worker

Node's event loop is single-threaded — synchronous CPU work in a `processAssets` tap blocks every other plugin's async work and saturates exactly one core regardless of how many cores the build machine has. `jest-worker` (used by `terser-webpack-plugin`, `css-minimizer-webpack-plugin`, `image-minimizer-webpack-plugin`) spawns a pool of worker processes and farms work across cores; for minification, compression, image processing, and AST transforms, this is the difference between a 60s build and a 15s build.

**Incorrect (sync minification on the main thread — single-core ceiling):**

```js
const { minify } = require('terser');

compilation.hooks.processAssets.tapPromise(/* ... */, async (assets) => {
  // Each minify blocks the event loop entirely while running
  for (const name of Object.keys(assets).filter((n) => n.endsWith('.js'))) {
    const result = await minify(assets[name].source().toString());
    compilation.updateAsset(name, new sources.RawSource(result.code));
  }
});
```

**Correct (jest-worker pool — work fanned out across cores):**

```js
// minify-worker.js — module worker exposes
const { minify } = require('terser');
module.exports = async function minifyOne(code) {
  const result = await minify(code);
  return result.code;
};
```

```js
// plugin.js
const { Worker } = require('jest-worker');
const os = require('node:os');

class MinifyPlugin {
  apply(compiler) {
    let worker = null;

    compiler.hooks.thisCompilation.tap('MinifyPlugin', (compilation) => {
      compilation.hooks.processAssets.tapPromise(
        { name: 'MinifyPlugin', stage: Compilation.PROCESS_ASSETS_STAGE_OPTIMIZE_SIZE },
        async (assets) => {
          if (!worker) {
            worker = new Worker(require.resolve('./minify-worker'), {
              numWorkers: Math.max(1, os.cpus().length - 1), // leave 1 for main
              maxRetries: 2,
            });
          }
          const tasks = Object.keys(assets)
            .filter((n) => n.endsWith('.js'))
            .map(async (name) => {
              const code = assets[name].source().toString();
              const minified = await worker.default(code);
              compilation.updateAsset(name, new sources.RawSource(minified));
            });
          await Promise.all(tasks);
        },
      );
    });

    // Required — see life-cleanup-in-shutdown-hook
    compiler.hooks.shutdown.tapPromise('MinifyPlugin', async () => {
      if (worker) { await worker.end(); worker = null; }
    });
  }
}
```

**When jest-worker pays off:**

- Per-asset work > ~20ms (the IPC overhead is non-trivial)
- Work is independent across assets (no shared mutable state)
- Total work × cores > pool spin-up cost (~50ms cold start)

**When it doesn't:**

- Builds with <10 assets total (overhead dominates)
- Tiny per-asset work (e.g., banner injection) — main thread is faster
- Watch-mode incremental rebuilds with a single changed file
- `webpack.config.js` has `parallelism: 1` (user wants serial — respect it)

**Respect user's parallelism config:**

```js
const numWorkers = this.options.parallel === false
  ? 1
  : Math.min(
      typeof this.options.parallel === 'number' ? this.options.parallel : os.cpus().length - 1,
      compilation.compiler.parallelism || Infinity,
    );
```

This is the pattern `terser-webpack-plugin` uses — users can pass `parallel: 2` for CI, `parallel: false` for debugging, or `parallel: true` for auto-detect.

**Don't use Node's `worker_threads` directly** unless you can serialize all your inputs through `postMessage` cheaply. `jest-worker` handles the boilerplate (pool management, retry-on-crash, transferring large strings) and survives worker crashes — pure `worker_threads` does not.

Reference: [jest-worker README](https://github.com/jestjs/jest/tree/main/packages/jest-worker) · [terser-webpack-plugin source](https://github.com/webpack-contrib/terser-webpack-plugin/blob/master/src/index.js)
