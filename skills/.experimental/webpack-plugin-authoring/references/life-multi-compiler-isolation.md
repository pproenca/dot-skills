---
title: One Plugin Instance Per Compiler in MultiCompiler Setups
impact: HIGH
impactDescription: prevents shared state corrupting parallel builds
tags: life, multi-compiler, ssr, isolation
---

## One Plugin Instance Per Compiler in MultiCompiler Setups

When `webpack.config.js` exports an array of configs, webpack creates a `MultiCompiler` with one `Compiler` per config. If the same plugin INSTANCE is added to multiple configs (e.g., via a shared `plugins: [sharedInstance]`), both compilers receive `apply(compiler)` calls and share any instance-level mutable state. For SSR setups with separate `client` + `server` compilers running in parallel, this means asset metadata from the client build leaks into the server's manifest.

**Incorrect (one instance reused across configs — state collides):**

```js
const manifestPlugin = new ManifestPlugin({ filename: 'manifest.json' });

module.exports = [
  {
    name: 'client',
    target: 'web',
    plugins: [manifestPlugin], // SAME instance
  },
  {
    name: 'server',
    target: 'node',
    plugins: [manifestPlugin], // SAME instance — apply() called twice, state shared
  },
];
```

**Correct (instantiate one per config — recommended):**

```js
function createManifestPlugin(name) {
  return new ManifestPlugin({ filename: `manifest.${name}.json` });
}

module.exports = [
  { name: 'client', target: 'web', plugins: [createManifestPlugin('client')] },
  { name: 'server', target: 'node', plugins: [createManifestPlugin('server')] },
];
```

**Alternative (plugin uses WeakMap<Compiler, State> internally — safe even if shared):**

```js
class ManifestPlugin {
  constructor(options) {
    this.options = options;
    this.perCompiler = new WeakMap();
  }

  apply(compiler) {
    // Each compiler gets its own state, even when the instance is shared
    let state = this.perCompiler.get(compiler);
    if (!state) {
      state = { entries: new Map() };
      this.perCompiler.set(compiler, state);
    }

    compiler.hooks.thisCompilation.tap('ManifestPlugin', (compilation) => {
      compilation.hooks.processAssets.tap(/* ... */, () => {
        state.entries.clear();
        for (const chunk of compilation.chunks) {
          for (const file of chunk.files) {
            state.entries.set(chunk.name, file);
          }
        }
      });
    });
  }
}
```

**Why Option B is the recommended posture for published plugins:**

- Users WILL share instances by accident — it looks natural and webpack doesn't warn
- Next.js, Remix, Storybook, and webpack-dev-server all use MultiCompiler internally
- `WeakMap<Compiler, T>` costs nothing when there's only one compiler

**Detecting MultiCompiler context:**

```js
apply(compiler) {
  const parent = compiler.parentCompilation?.compiler;
  if (parent) {
    // This is a child compilation — usually skip side-effect work
    return;
  }
  // ...
}
```

**Hook ordering across parallel compilers:** `MultiCompiler` runs each compiler's hooks independently. Do NOT assume `client.done` fires before `server.thisCompilation`. Use `MultiCompiler.hooks.done` (fires once after all children) when you need cross-compiler synchronization.

Reference: [MultiCompiler API](https://webpack.js.org/api/node/#multicompiler) · [Next.js webpack pattern: createWebpackConfig](https://github.com/vercel/next.js/tree/canary/packages/next/src/build/webpack)
