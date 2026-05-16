---
title: Use a Stable, Unique Name for Every tap
impact: CRITICAL
impactDescription: prevents stats/profiling collisions and HMR breakage
tags: hook, naming, stats, identification
---

## Use a Stable, Unique Name for Every tap

The string passed as the first argument to `tap()`/`tapAsync()`/`tapPromise()` is the plugin's identity in webpack's stats output, the profiler trace, the dev-server overlay, and several `HookMap` lookups (notably HMR's `JavascriptModulesPlugin.getCompilationHooks(...).renderModuleContent`). Anonymous, dynamic, or duplicated tap names break stats grouping, prevent the profiler from attributing time to your plugin, and can cause HMR to silently skip module updates that depend on tap-name comparison.

**Incorrect (template literal name changes per compilation — stats and profiler can't aggregate):**

```js
class WatermarkPlugin {
  constructor(options) {
    this.options = options;
    this.runId = 0;
  }
  apply(compiler) {
    compiler.hooks.thisCompilation.tap('WatermarkPlugin', (compilation) => {
      this.runId++;
      // Different name every compilation — webpack stats shows N entries instead of 1
      compilation.hooks.processAssets.tap(
        `WatermarkPlugin-${this.runId}`,
        (assets) => { /* ... */ },
      );
    });
  }
}
```

**Correct (stable string equal to the class name):**

```js
const PLUGIN_NAME = 'WatermarkPlugin';

class WatermarkPlugin {
  apply(compiler) {
    compiler.hooks.thisCompilation.tap(PLUGIN_NAME, (compilation) => {
      compilation.hooks.processAssets.tap(
        { name: PLUGIN_NAME, stage: /* ... */ },
        (assets) => { /* ... */ },
      );
    });
  }
}
```

**Naming conventions used by `webpack-contrib`:**

- Tap name === class name (e.g., `'MiniCssExtractPlugin'`, `'TerserPlugin'`)
- Define once as a top-of-file `const PLUGIN_NAME = 'X'` and reuse
- Never include compilation IDs, timestamps, hashes, or option values in the tap name

**Why this matters even when not using HMR:**

- `webpack --profile` groups timing by tap name — dynamic names produce thousands of single-entry rows
- Several plugins (notably `webpack-bundle-analyzer`) attribute asset emissions to the plugin via tap name
- `compilation.errors` and `.warnings` may carry the tap name in their displayed module identifier

Reference: [Writing a Plugin — Naming](https://webpack.js.org/contribute/writing-a-plugin/) · [webpack-contrib/mini-css-extract-plugin](https://github.com/webpack-contrib/mini-css-extract-plugin/blob/master/src/index.js)
