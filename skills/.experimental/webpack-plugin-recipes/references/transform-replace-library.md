---
title: Replace One Library With Another at Resolve Time
impact: MEDIUM-HIGH
impactDescription: 30-80kb savings replacing react with preact/compat
tags: transform, alias, resolve, preact, replacement
---

## Replace One Library With Another at Resolve Time

## Problem

Your bundle is 50kb heavier than it needs to be because `react`+`react-dom` are 130kb gzipped, while `preact/compat` (a drop-in replacement) is 10kb. Or you want to swap `moment` for `dayjs` without changing 800 source files. Or you're shipping a "lite" build that uses `lodash-es` while the regular build uses `lodash`. The simple answer is `resolve.alias`, but `alias` matches the request literally — it misses cases like `import 'react/jsx-runtime'`, breaks when a dependency does `require.resolve('react')`, and doesn't apply to type imports the same way.

You need a plugin that handles the request-prefix case (`react/X` → `preact/compat/X` mapping where it exists, otherwise `preact/compat`), works for both ESM and CommonJS requests, and respects user-specified exemptions.

## Pattern

Tap `compiler.hooks.normalModuleFactory` and register a `beforeResolve` handler that rewrites matching requests to the replacement library, falling back to the original request if no specific mapping exists.

**Incorrect (without a plugin — `resolve.alias` alone misses subpath imports):**

```js
// webpack.config.js
module.exports = {
  resolve: {
    alias: {
      'react': 'preact/compat',
      'react-dom': 'preact/compat',
    },
  },
};
// Misses: `import jsx from 'react/jsx-runtime'` — alias matches exact key by default
// Misses: subpaths like `react-dom/client`, `react-dom/test-utils`
// Workaround: list every subpath explicitly — drifts every preact release
```

**Correct (with this plugin — pattern-based replacement with subpath awareness):**

```js
const { validate } = require('schema-utils');

const schema = {
  type: 'object',
  properties: {
    replacements: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          from: { type: 'string', minLength: 1, description: 'Package name to replace' },
          to: { type: 'string', minLength: 1, description: 'Replacement package name' },
          subpaths: {
            type: 'object',
            additionalProperties: { type: 'string' },
            description: 'Optional explicit subpath map (default: 1:1)',
          },
          exclude: {
            type: 'array',
            items: { type: 'string' },
            description: 'Subpaths to NOT replace (passthrough to original)',
          },
        },
        required: ['from', 'to'],
        additionalProperties: false,
      },
      minItems: 1,
    },
    contextFilter: {
      type: 'string',
      description: 'Regex; only apply when requesting MODULE has this in its path',
    },
  },
  required: ['replacements'],
  additionalProperties: false,
};

class LibraryReplacementPlugin {
  constructor(options) {
    validate(schema, options, { name: 'LibraryReplacementPlugin', baseDataPath: 'options' });
    this.replacements = options.replacements;
    this.contextFilter = options.contextFilter ? new RegExp(options.contextFilter) : null;
  }

  apply(compiler) {
    const PLUGIN = 'LibraryReplacementPlugin';

    compiler.hooks.normalModuleFactory.tap(PLUGIN, (nmf) => {
      nmf.hooks.beforeResolve.tap(PLUGIN, (data) => {
        if (this.contextFilter && !this.contextFilter.test(data.context ?? '')) return;

        for (const rep of this.replacements) {
          const replaced = this.tryReplace(data.request, rep);
          if (replaced !== null) {
            data.request = replaced;
            return; // single replacement applied — proceed
          }
        }
      });
    });
  }

  tryReplace(request, rep) {
    // Exact match: `react` → `preact/compat`
    if (request === rep.from) return rep.to;

    // Subpath match: `react/jsx-runtime` → ?
    const prefix = `${rep.from}/`;
    if (!request.startsWith(prefix)) return null;

    const subpath = request.slice(prefix.length);

    // Excluded subpath: passthrough (use original library for this one)
    if (rep.exclude?.includes(subpath)) return null;

    // Explicit subpath mapping wins
    if (rep.subpaths?.[subpath]) return rep.subpaths[subpath];

    // Default: same subpath under the replacement
    return `${rep.to}/${subpath}`;
  }
}

module.exports = LibraryReplacementPlugin;
```

## Usage

```js
new LibraryReplacementPlugin({
  replacements: [
    {
      from: 'react',
      to: 'preact/compat',
      subpaths: {
        // react has no `compat/X` mapping, so explicit:
        'jsx-runtime': 'preact/jsx-runtime',
        'jsx-dev-runtime': 'preact/jsx-runtime',
      },
      exclude: ['server'],  // SSR still uses real react/server
    },
    {
      from: 'react-dom',
      to: 'preact/compat',
      exclude: ['server', 'server.browser'],
    },
    {
      from: 'moment',
      to: 'dayjs',
      // Note: dayjs has different subpath structure — won't work without adapters
      // This is a placeholder — real moment→dayjs requires a wrapper module
    },
  ],
})
```

## How it works

- **`beforeResolve` mutating `data.request` then returning `undefined`** lets the resolver continue with the rewritten request. The replacement package goes through normal resolution (with its own node_modules location, package.json exports field, etc.). See [`webpack-plugin-authoring/hook-normal-module-factory-stages`].
- **`contextFilter`** lets you scope the replacement: replace `react` only for code in `src/`, not for tools like `react-devtools` or test runners that need real React
- **No `resolve.alias` interference** — this runs before alias resolution; if you also have `resolve.alias`, the request is rewritten first then alias is applied to the new request
- **Single-pass replacement** (the inner `return`) — prevents replacement chains: `A → B → C` would be confusing

## Variations

- **Provide a wrapper module instead of direct replacement** (for incompatible APIs):
  ```js
  // src/moment-to-dayjs-adapter.js
  import dayjs from 'dayjs';
  export default (...args) => dayjs(...args);  // moment(...) → dayjs(...)

  // Plugin replaces `moment` → '/path/to/moment-to-dayjs-adapter.js'
  ```
- **Conditional by mode** (only in production):
  ```js
  if (compiler.options.mode === 'production') { /* register */ }
  ```
- **Per-entry replacement** (use real react in admin, preact in user-facing): check `data.context` against entry paths
- **TypeScript types compatibility**: pair with `tsconfig.json` `paths` mapping so editor sees correct types

## When NOT to use this pattern

- The libraries have non-trivial API differences (most cases — `lodash` to `lodash-es` is fine; `moment` to `dayjs` is NOT a drop-in)
- You can use `resolve.alias` and your imports don't touch subpaths
- Your build uses module federation — replacements collide with federated module identities

Reference: [Preact compat](https://preactjs.com/guide/v10/switching-to-preact/) · [resolve.alias](https://webpack.js.org/configuration/resolve/#resolvealias) · [NormalModuleFactory hooks](https://webpack.js.org/api/normalmodulefactory-hooks/)
