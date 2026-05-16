---
title: Return Undefined From Bail Hooks Unless You Mean to Stop
impact: CRITICAL
impactDescription: prevents short-circuiting other plugins
tags: hook, bail, sync-bail-hook, normal-module-factory
---

## Return Undefined From Bail Hooks Unless You Mean to Stop

`SyncBailHook` and `AsyncSeriesBailHook` stop iterating taps the moment any tap returns a value that is not `undefined`. Returning `false`, `null`, `0`, or `""` from a bail hook prevents every later-registered plugin from running — and webpack uses bail hooks for `shouldEmit`, `normalModuleFactory.beforeResolve`, `resolve`, `resolveOptions`, and many others. A handler that accidentally returns the result of an assignment or filter call silently disables half the toolchain.

**Incorrect (returning `false` from shouldEmit prevents any other plugin from emitting):**

```js
class GuardEmptyBuildsPlugin {
  apply(compiler) {
    compiler.hooks.shouldEmit.tap('GuardEmptyBuildsPlugin', (compilation) => {
      // Author meant: "I don't have an opinion if there are errors."
      // Actually says: "Cancel emit." — webpack writes nothing to disk.
      return compilation.errors.length === 0;
    });
  }
}
```

**Correct (return `undefined` to mean "no opinion", explicit `false` only when intentionally bailing):**

```js
class GuardEmptyBuildsPlugin {
  apply(compiler) {
    compiler.hooks.shouldEmit.tap('GuardEmptyBuildsPlugin', (compilation) => {
      if (compilation.errors.length > 0) {
        return false; // Explicitly cancel emit when there are errors
      }
      return undefined; // No opinion — let other plugins decide
    });
  }
}
```

**Bail hook return contract:**

| Return value | Effect |
|---|---|
| `undefined` | Continue to next tap (most common) |
| Any defined value (incl. `false`, `null`, `0`, `""`) | Stop iteration, return that value as the hook's result |

**Common bail hooks to be careful with:**

- `compiler.hooks.shouldEmit` — `false` cancels writing all assets to disk
- `compiler.hooks.entryOption` — `true` signals "I handled the entry, skip default"
- `normalModuleFactory.hooks.beforeResolve` — defined return cancels module resolution
- `normalModuleFactory.hooks.factorize` — defined return uses your value as the module instance

**Waterfall hooks have the inverse pitfall:** `SyncWaterfallHook` and `AsyncSeriesWaterfallHook` pass the return value to the next tap. Returning `undefined` from a waterfall passes `undefined` downstream — usually a bug. Always return the (possibly modified) input.

Reference: [Plugin API — Hook Types](https://webpack.js.org/api/plugins/) · [tapable — SyncBailHook](https://github.com/webpack/tapable#hook-types)
