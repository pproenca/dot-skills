---
title: Match tap Method to the Hook's Async Type
impact: CRITICAL
impactDescription: prevents silently dropped async work
tags: hook, tapable, async, sync, tap-promise
---

## Match tap Method to the Hook's Async Type

`tap()` ignores any return value, so registering a synchronous-tap function that returns a Promise on an `AsyncSeriesHook` causes webpack to advance to the next phase before your work finishes — assets get emitted before your file is written, or the build closes before your worker exits. The compiler-hooks reference table tells you which hooks are `SyncHook` vs `AsyncSeriesHook` vs `AsyncParallelHook`; the `tap` method MUST match.

**Incorrect (synchronous tap on AsyncSeriesHook — promise is fire-and-forget):**

```js
class WriteManifestPlugin {
  apply(compiler) {
    // emit is AsyncSeriesHook — tap() returns immediately, ignores the promise
    compiler.hooks.emit.tap('WriteManifestPlugin', async (compilation) => {
      const manifest = JSON.stringify(buildManifest(compilation));
      await fs.promises.writeFile('dist/manifest.json', manifest);
      // emit completes BEFORE writeFile finishes — manifest may be missing or stale
    });
  }
}
```

**Correct (tapPromise returns the promise to the AsyncSeriesHook):**

```js
class WriteManifestPlugin {
  apply(compiler) {
    compiler.hooks.emit.tapPromise('WriteManifestPlugin', async (compilation) => {
      const manifest = JSON.stringify(buildManifest(compilation));
      await fs.promises.writeFile('dist/manifest.json', manifest);
      // emit waits for this promise to resolve before advancing to afterEmit
    });
  }
}
```

**Hook type → tap method:**

| Hook type | Use | Notes |
|---|---|---|
| `SyncHook`, `SyncBailHook`, `SyncWaterfallHook` | `tap()` | Return value matters for Bail/Waterfall |
| `AsyncSeriesHook`, `AsyncParallelHook` | `tapAsync()` or `tapPromise()` | NEVER `tap()` — async work is dropped |
| `AsyncSeriesBailHook`, `AsyncSeriesWaterfallHook` | `tapPromise()` (preferred) | Return value flows through |

**When NOT to use `tap()` on a synchronous hook:**

- The handler awaits anything (file I/O, network, child process)
- The handler returns a Promise the hook needs to wait for

Reference: [Plugin API — tap, tapAsync, tapPromise](https://webpack.js.org/api/plugins/#tap)
