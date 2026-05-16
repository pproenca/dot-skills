---
title: Resolve Imports to In-Memory Strings (Virtual Modules)
impact: HIGH
impactDescription: enables config-driven codegen without writing temp files to disk
tags: virtual, codegen, normal-module-factory, resolver
---

## Resolve Imports to In-Memory Strings (Virtual Modules)

## Problem

Your app needs build-time configuration injected as a module: `import { features } from 'virtual:feature-flags'` should resolve to a computed object based on the user's environment. Writing the file to `src/.generated/feature-flags.ts` works but pollutes the repo, requires .gitignore entries, breaks watch-mode (the generated file's edits trigger circular rebuilds), and racing CI processes corrupt each other. Vite has `import 'virtual:X'` natively; webpack doesn't. You need to teach webpack's resolver to recognize `virtual:` prefixed imports and serve them from memory.

This is also the pattern behind Nuxt's `#imports`, SvelteKit's `$app/...`, and Next.js's `next/dynamic` runtime injection.

## Pattern

Tap `compiler.hooks.normalModuleFactory` to register a resolver plugin that recognizes the `virtual:` scheme, returning a synthetic resolved request. Then tap `NormalModule.getCompilationHooks(compilation).readResource` to supply the source content when webpack tries to read the module.

**Incorrect (without a plugin — writing to disk then `import`-ing):**

```js
// scripts/generate-flags.js — runs in package.json prebuild
const flags = computeFlags();
fs.writeFileSync('src/.generated/feature-flags.ts', `export const features = ${JSON.stringify(flags)};`);

// src/app.ts
import { features } from './.generated/feature-flags';
// Drift: forget to run prebuild → stale flags
// Drift: file checked in by accident → wrong env's flags in repo
// Watch: generated file changes don't propagate (the GENERATOR isn't watched)
```

**Correct (with this plugin — `import 'virtual:feature-flags'` resolves to in-memory string):**

```js
const path = require('node:path');
const { validate } = require('schema-utils');

const schema = {
  type: 'object',
  properties: {
    modules: {
      type: 'object',
      additionalProperties: {
        oneOf: [
          { type: 'string', description: 'Static source code' },
          { instanceof: 'Function', description: '(compilation) => string | Promise<string>' },
        ],
      },
      description: 'Map of `virtual:NAME` → source code or producer function',
    },
    prefix: { type: 'string', description: 'Scheme prefix (default "virtual:")' },
  },
  required: ['modules'],
  additionalProperties: false,
};

class VirtualModulesPlugin {
  constructor(options) {
    validate(schema, options, { name: 'VirtualModulesPlugin', baseDataPath: 'options' });
    this.modules = options.modules;
    this.prefix = options.prefix ?? 'virtual:';
  }

  apply(compiler) {
    const PLUGIN = 'VirtualModulesPlugin';

    // Step 1: teach the resolver about `virtual:` prefix
    compiler.hooks.normalModuleFactory.tap(PLUGIN, (nmf) => {
      nmf.hooks.beforeResolve.tap(PLUGIN, (data) => {
        if (!data.request.startsWith(this.prefix)) return undefined;
        const name = data.request.slice(this.prefix.length);
        if (!this.modules[name]) return undefined; // unknown virtual — let resolution fail normally

        // Replace the request with a deterministic absolute path inside the compiler context.
        // This path doesn't need to exist; we'll intercept reads below.
        data.request = path.join(compiler.context, `__virtual__`, `${name}.js`);
        return undefined; // let normal resolution proceed with the rewritten request
      });
    });

    // Step 2: intercept file reads for our virtual paths
    compiler.hooks.compilation.tap(PLUGIN, (compilation) => {
      const NormalModule = compiler.webpack.NormalModule;
      NormalModule.getCompilationHooks(compilation).readResource
        .for(undefined) // any scheme
        .tapPromise(PLUGIN, async (loaderContext) => {
          const filePath = loaderContext.resourcePath;
          const marker = path.join(compiler.context, '__virtual__') + path.sep;
          if (!filePath.startsWith(marker)) return undefined;

          const name = path.basename(filePath, '.js');
          const source = this.modules[name];
          if (source === undefined) return undefined;

          const content = typeof source === 'function' ? await source(compilation) : source;
          return Buffer.from(content, 'utf8');
        });
    });
  }
}

module.exports = VirtualModulesPlugin;
```

## Usage

```js
// webpack.config.js
new VirtualModulesPlugin({
  modules: {
    'feature-flags': (compilation) => {
      const env = compilation.compiler.options.mode;
      const flags = computeFlagsForEnv(env);
      return `export const features = ${JSON.stringify(flags)};`;
    },
    'build-info': `export const commit = ${JSON.stringify(commitHash())};`,
  },
})

// src/app.ts
import { features } from 'virtual:feature-flags';
if (features.newCheckout) { /* ... */ }

// TypeScript: declare the virtual modules
// src/virtual.d.ts
declare module 'virtual:feature-flags' {
  export const features: { newCheckout: boolean };
}
```

## How it works

- **`beforeResolve.tap` returning `undefined`** lets resolution continue after rewriting the request — returning `data` would short-circuit. See [`webpack-plugin-authoring/hook-bail-hook-return-semantics`].
- **Rewriting the request to an absolute path inside `compiler.context`** plays well with webpack's caching (deterministic) and module ID generation (stable across rebuilds).
- **`NormalModule.getCompilationHooks(compilation).readResource`** is webpack 5's official extension point for synthesizing module content. The `.for(undefined)` matches any scheme; you can restrict to e.g. `.for('virtual')` if you wire the URL scheme version (see Variations).
- **`tapPromise`** matches the AsyncSeriesBailHook — important because the producer function may be async (compute from disk, fetch from API, etc.). See [`webpack-plugin-authoring/hook-tap-method-matches-hook-type`].

## Variations

- **URL-scheme variant** (cleaner — `import 'virtual:feature-flags'` stays as-is):
  ```js
  compilation.params.normalModuleFactory.hooks.resolveForScheme
    .for('virtual')
    .tap(PLUGIN, (resourceData) => { /* ... */ });
  ```
  Cleaner, doesn't require fake file paths. Slightly more setup; check webpack 5.20+ schemes API.
- **HMR for virtual modules** (rebuild when the producer's inputs change): pair with `compilation.fileDependencies.add(...)` for each file the producer reads. See [`webpack-plugin-authoring/cache-add-file-dependencies`].
- **Reactive virtual modules**: store the source provider and `compiler.watchFileSystem.watch(...)` for source-of-truth files
- **Loader emulation**: virtual modules with extensions other than `.js` — change the file path extension so loaders match

## When NOT to use this pattern

- You're using a framework that already supports virtual modules (Vite, Nuxt, SvelteKit, Next.js with the `next/dynamic` pattern)
- The content is truly static — a regular file is simpler and easier to debug
- You need IDE support — IDEs don't see virtual modules; you must hand-write `.d.ts` declarations

Reference: [Vite virtual modules](https://vite.dev/guide/api-plugin.html#virtual-modules-convention) · [NormalModule.getCompilationHooks](https://webpack.js.org/api/normalmodulefactory-hooks/) · [Nuxt #imports](https://nuxt.com/docs/api/utils/use-runtime-config)
