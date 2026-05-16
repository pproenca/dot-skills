---
title: Avoid Mutable State Across Compilations
impact: HIGH
impactDescription: prevents leaking partial state between rebuilds
tags: life, state, watch-mode, idempotency
---

## Avoid Mutable State Across Compilations

A plugin instance is reused across every `--watch` rebuild and across every child compilation. Mutable instance state (`this.assets`, `this.modulesSeen`, `this.warnings`) accumulates entries from previous builds: rebuild 5 reports warnings from rebuilds 1–4, and "added asset" lists grow unboundedly. Scope mutable state to ONE compilation by storing it in the compilation tap's closure, or by using a `WeakMap<Compilation, T>` if you need cross-hook sharing.

**Incorrect (this.collected accumulates across rebuilds — never cleared):**

```js
class CollectImportsPlugin {
  constructor() {
    this.collected = new Set(); // shared across every build
  }
  apply(compiler) {
    compiler.hooks.normalModuleFactory.tap('CollectImportsPlugin', (nmf) => {
      nmf.hooks.beforeResolve.tap('CollectImportsPlugin', (data) => {
        this.collected.add(data.request); // grows forever in watch mode
      });
    });

    compiler.hooks.afterEmit.tap('CollectImportsPlugin', (compilation) => {
      const content = JSON.stringify([...this.collected], null, 2);
      // Rebuild 10 emits a manifest with everything ever resolved across 10 builds.
      fs.writeFileSync('imports-manifest.json', content);
    });
  }
}
```

**Correct (state scoped to a single compilation):**

```js
class CollectImportsPlugin {
  apply(compiler) {
    // WeakMap so state is garbage-collected when the compilation is
    const perCompilation = new WeakMap();

    compiler.hooks.thisCompilation.tap('CollectImportsPlugin', (compilation) => {
      const collected = new Set();
      perCompilation.set(compilation, collected);

      compilation.params.normalModuleFactory.hooks.beforeResolve.tap(
        'CollectImportsPlugin',
        (data) => { collected.add(data.request); },
      );
    });

    compiler.hooks.afterEmit.tap('CollectImportsPlugin', (compilation) => {
      const collected = perCompilation.get(compilation);
      if (!collected) return;
      const content = JSON.stringify([...collected], null, 2);
      fs.writeFileSync('imports-manifest.json', content); // fresh each build
    });
  }
}
```

**Three correct patterns for plugin state:**

| Need | Pattern |
|---|---|
| State for ONE compilation | Local `const` inside the `thisCompilation` callback |
| State threaded compilation → compiler-level hook | `WeakMap<Compilation, T>` declared in `apply()` |
| State across compilations (e.g., previous chunk hashes) | Instance field, but RESET in `compiler.hooks.beforeCompile` |
| State across processes (persistent cache) | `compilation.getCache('plugin-name').store(...)` |

**The "previous build" pattern:**

```js
apply(compiler) {
  let previousHashes = new Map(); // intentional cross-build state

  compiler.hooks.done.tap('Plugin', (stats) => {
    const current = new Map();
    for (const chunk of stats.compilation.chunks) {
      current.set(chunk.id, chunk.contentHash.javascript);
    }
    const changed = [...current].filter(([id, hash]) => previousHashes.get(id) !== hash);
    onChangedChunks(changed);
    previousHashes = current; // explicit replacement, not accumulation
  });
}
```

This is the only legitimate use of instance state across rebuilds — when the cross-build comparison IS the point. The variable is REPLACED, not appended to.

Reference: [Plugin Patterns — Detecting Changed Chunks](https://webpack.js.org/contribute/plugin-patterns/#detecting-changed-chunks)
