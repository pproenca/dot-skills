---
title: Expose Custom Hooks via getCompilationHooks WeakMap
impact: LOW-MEDIUM
impactDescription: prevents memory leaks from per-compilation hook state
tags: compat, getCompilationHooks, WeakMap, custom-hooks
---

## Expose Custom Hooks via getCompilationHooks WeakMap

Plugins that offer extension points for OTHER plugins to tap into (e.g., `html-webpack-plugin`'s `beforeEmit` hook, `mini-css-extract-plugin`'s `runtimeRequirements` hook) cannot attach the hooks directly to the `Compilation` instance — webpack 5 sealed the hooks surface and direct assignment (`compilation.hooks.myHook = new SyncHook()`) is no longer reliable. The canonical pattern is a static `getCompilationHooks(compilation)` method backed by a module-scope `WeakMap<Compilation, Hooks>`. The WeakMap entry is GC'd when the compilation is — no manual cleanup, no leaks across rebuilds.

**Incorrect (direct assignment — sealed in webpack 5, would leak in 4):**

```js
const { SyncHook } = require('tapable');

class HtmlPlugin {
  apply(compiler) {
    compiler.hooks.thisCompilation.tap('HtmlPlugin', (compilation) => {
      // Webpack 5: TypeError (hooks is sealed)
      // Webpack 4: works, but compilation never GC'd while hook handlers live
      compilation.hooks.beforeEmit = new SyncHook(['data']);
    });
  }
}
```

**Correct (WeakMap + static getter — the webpack-contrib standard):**

```js
const { SyncHook, AsyncSeriesWaterfallHook } = require('tapable');

// Module-scope WeakMap — one entry per Compilation, GC'd with it
const compilationHooksMap = new WeakMap();

class HtmlPlugin {
  static getCompilationHooks(compilation) {
    let hooks = compilationHooksMap.get(compilation);
    if (hooks === undefined) {
      hooks = {
        beforeAssetTagGeneration: new AsyncSeriesWaterfallHook(['data']),
        beforeEmit: new SyncHook(['html']),
        afterEmit: new AsyncSeriesWaterfallHook(['html']),
      };
      compilationHooksMap.set(compilation, hooks);
    }
    return hooks;
  }

  apply(compiler) {
    compiler.hooks.thisCompilation.tap('HtmlPlugin', (compilation) => {
      compilation.hooks.processAssets.tapPromise(/* ... */, async (assets) => {
        const hooks = HtmlPlugin.getCompilationHooks(compilation);
        // Fire your custom hooks at the right moment
        const result = await hooks.beforeAssetTagGeneration.promise(initialData);
        // ...
      });
    });
  }
}

module.exports = HtmlPlugin;
```

**Other plugins tap into your custom hooks:**

```js
const HtmlPlugin = require('html-plugin');

class InlineRuntimePlugin {
  apply(compiler) {
    compiler.hooks.compilation.tap('InlineRuntimePlugin', (compilation) => {
      const hooks = HtmlPlugin.getCompilationHooks(compilation);
      hooks.beforeAssetTagGeneration.tapAsync(
        'InlineRuntimePlugin',
        (data, cb) => { /* mutate data, call cb */ },
      );
    });
  }
}
```

**Why a static method, not an instance method:**

- Other plugins can access hooks without holding a reference to the HtmlPlugin instance
- Multiple HtmlPlugin instances (one per output, in a multi-output build) share the hook surface
- `WeakMap` is keyed by `Compilation`, not by plugin instance — exactly one hook bundle per compilation

**Hook types to choose from:**

| Hook type | When |
|---|---|
| `SyncHook` | Notification, no return value matters |
| `SyncBailHook` | Allow plugins to short-circuit (defined return stops) |
| `SyncWaterfallHook` | Each tap can transform the data passed to the next |
| `AsyncSeriesHook` | Async work, no return |
| `AsyncSeriesWaterfallHook` | Async + transformation chain — most common for "modify this data" extension points |
| `AsyncParallelHook` | Independent async work that can run concurrently |

**Document your hooks in your README** as part of your public API — once published, they're a compatibility surface.

Reference: [Plugin API — Custom hooks pattern](https://webpack.js.org/api/plugins/#custom-hooks) · [html-webpack-plugin getHooks](https://github.com/jantimon/html-webpack-plugin/blob/main/index.js)
