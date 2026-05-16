---
title: Clean Up Resources in compiler.hooks.shutdown
impact: HIGH
impactDescription: prevents hanging CI processes and leaked workers
tags: life, shutdown, cleanup, workers, watcher
---

## Clean Up Resources in compiler.hooks.shutdown

Workers, file watchers, child processes, and open file descriptors must be terminated when webpack closes. `compiler.hooks.shutdown` (AsyncSeries) is webpack's signal that the compiler is closing — `compiler.close(cb)` waits for every tap to finish. Without an explicit shutdown tap, CI processes hang waiting for unreferenced workers, `jest` reports "Jest did not exit", and `webpack-cli`'s `--watch` doesn't exit on Ctrl+C until you kill the orphans.

**Incorrect (worker started in beforeRun, never terminated):**

```js
class ParallelMinifierPlugin {
  apply(compiler) {
    let pool = null;

    compiler.hooks.beforeRun.tap('ParallelMinifierPlugin', () => {
      pool = new Worker(require.resolve('./minifier-worker'), { numWorkers: 4 });
    });

    compiler.hooks.thisCompilation.tap('ParallelMinifierPlugin', (compilation) => {
      compilation.hooks.processAssets.tapPromise(/* ... */, async (assets) => {
        await Promise.all(Object.entries(assets).map(([k, v]) => pool.minify(k, v)));
      });
    });
    // pool is never .end()ed — CI hangs after build completes
  }
}
```

**Correct (shutdown hook tears down the pool — tapPromise so close() waits):**

```js
class ParallelMinifierPlugin {
  apply(compiler) {
    let pool = null;

    compiler.hooks.beforeRun.tap('ParallelMinifierPlugin', () => {
      if (!pool) {
        pool = new Worker(require.resolve('./minifier-worker'), { numWorkers: 4 });
      }
    });

    compiler.hooks.thisCompilation.tap('ParallelMinifierPlugin', (compilation) => {
      compilation.hooks.processAssets.tapPromise(/* ... */, async (assets) => {
        await Promise.all(Object.entries(assets).map(([k, v]) => pool.minify(k, v)));
      });
    });

    // AsyncSeriesHook — tapPromise so compiler.close() awaits cleanup
    compiler.hooks.shutdown.tapPromise('ParallelMinifierPlugin', async () => {
      if (pool) {
        await pool.end();
        pool = null;
      }
    });
  }
}
```

**Resources requiring shutdown cleanup:**

| Resource | Cleanup |
|---|---|
| `jest-worker` pool | `await pool.end()` |
| `node:worker_threads` worker | `await worker.terminate()` |
| `child_process.spawn` | `child.kill('SIGTERM')`, then await close |
| `chokidar`/`watchpack` watcher | `await watcher.close()` |
| Open file descriptors | `await fd.close()` |
| Network connections | client-specific `.close()` / `.disconnect()` |
| Timers (setInterval) | `clearInterval(handle)` |

**Beware `watchClose` vs `shutdown`:**

- `compiler.hooks.watchClose` fires when watch mode stops (not when a non-watch build finishes)
- `compiler.hooks.shutdown` fires for both watch close AND the end of a regular build
- For resources that should outlive a single build but die with the compiler, use `shutdown`

**Make cleanup idempotent.** Both `watchClose` and `shutdown` may fire for the same compiler (especially in MultiCompiler). Check `if (pool)` and null out the reference, so the second call is a no-op.

**The "Jest did not exit" test:** `npx jest tests/my-plugin.test.js --detectOpenHandles` will list any unreleased workers, watchers, or sockets your plugin leaks.

Reference: [compiler.hooks.shutdown](https://webpack.js.org/api/compiler-hooks/#shutdown) · [compiler.close](https://webpack.js.org/api/node/#close-watching)
