---
title: Tap normalModuleFactory at the Right Resolution Stage
impact: CRITICAL
impactDescription: prevents resolver re-runs and infinite recursion
tags: hook, normalModuleFactory, resolve, beforeResolve, factorize
---

## Tap normalModuleFactory at the Right Resolution Stage

`NormalModuleFactory` exposes five sequential hooks for module resolution — `beforeResolve` → `factorize` → `resolve` → `afterResolve` → `createModule` — and they fire in that order for every `import` in the user's code. Tapping the wrong one short-circuits resolution unintentionally, mutates the request after webpack has already cached it, or causes the resolver to re-enter itself recursively. Most "why does my plugin's redirect work for half the imports?" bugs come from tapping `afterResolve` (too late to change the request) instead of `beforeResolve` (too early — no resolved path yet) instead of `resolve` (the right one for path rewriting).

**Incorrect (rewriting in `afterResolve` — the request is already resolved and cached):**

```js
compiler.hooks.normalModuleFactory.tap('AliasPlugin', (nmf) => {
  // afterResolve runs AFTER createData is computed and the module is cached.
  // Rewriting `data.resource` here doesn't affect the resolved Module — webpack
  // has already keyed it by the OLD path. The override silently has no effect.
  nmf.hooks.afterResolve.tap('AliasPlugin', (data) => {
    if (data.resource.includes('legacy-lodash')) {
      data.resource = data.resource.replace('legacy-lodash', 'lodash-es');
    }
  });
});
```

**Correct (rewrite in `resolve` — runs before the resolved path is locked in):**

```js
compiler.hooks.normalModuleFactory.tap('AliasPlugin', (nmf) => {
  // `resolve` is a SyncBailHook — return undefined to continue normal resolution
  nmf.hooks.beforeResolve.tap('AliasPlugin', (data) => {
    if (data.request === 'legacy-lodash') {
      data.request = 'lodash-es'; // mutate the request BEFORE the resolver runs
    }
    return undefined; // let resolution continue with the rewritten request
  });
});
```

**Stage cheatsheet (in execution order):**

| Hook | Type | Receives | Use for |
|---|---|---|---|
| `beforeResolve` | `AsyncSeriesBailHook` | `resolveData` (request, context, dependencies) | Rewriting the REQUEST string before resolution (aliases, virtual modules) |
| `factorize` | `AsyncSeriesBailHook` | `resolveData` | Returning a pre-built Module instance to skip resolution entirely (advanced) |
| `resolve` | `AsyncSeriesBailHook` | `resolveData` | Replacing the resolver — defined return becomes the result |
| `afterResolve` | `AsyncSeriesBailHook` | `resolveData` (now with `createData`) | Mutating loader chain, parser options, generator settings on the resolved module |
| `createModule` | `AsyncSeriesBailHook` | `createData`, `resolveData` | Returning a custom Module subclass instead of `NormalModule` |
| `module` | `SyncWaterfallHook` | `module`, `createData`, `resolveData` | Decorating the final Module (rarely needed) |

**For loader manipulation, `afterResolve` IS correct:**

```js
nmf.hooks.afterResolve.tap('InjectLoaderPlugin', (data) => {
  // createData.loaders is the loader chain — modify it AFTER resolution
  if (data.createData.resource?.endsWith('.tsx')) {
    data.createData.loaders.unshift({
      loader: require.resolve('./my-runtime-tracker-loader'),
      options: { /* ... */ },
    });
  }
  return undefined;
});
```

This is the pattern Next.js uses to inject the React Refresh runtime, and what `babel-loader-exclude-node-modules-except` uses to bypass loaders for specific paths.

**Bail-hook semantics matter here.** All five hooks are `AsyncSeriesBailHook` — returning ANY defined value short-circuits resolution. The classic bug: returning `data` from `beforeResolve` (intending to "pass it through") makes webpack treat your return value as the resolved module spec, skipping every other plugin's `beforeResolve`. Always `return undefined` unless you intentionally mean to handle the resolution yourself.

**Don't trigger re-resolution from inside a resolve tap.** Calling `compilation.params.normalModuleFactory.create(...)` from inside one of these hooks recursively re-enters the factory and may produce infinite recursion if the inner request matches your plugin's condition. If you need to resolve a SECOND request as a side effect, do it from `afterResolve` (after the primary resolution is done) and add the resolved file to `compilation.fileDependencies` rather than re-creating a Module.

Reference: [Module Methods — NormalModuleFactory hooks](https://webpack.js.org/api/normalmodulefactory-hooks/) · [vercel/next.js — getReactRefreshLoaderInjector](https://github.com/vercel/next.js/tree/canary/packages/next/src/build/webpack)
