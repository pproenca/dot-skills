---
title: Add Read Files to compilation.fileDependencies
impact: HIGH
impactDescription: prevents stale builds in watch mode
tags: cache, fileDependencies, watch-mode, snapshot
---

## Add Read Files to compilation.fileDependencies

Webpack's watcher only re-runs the compilation when something in `compilation.fileDependencies` changes. A plugin that reads a config file or template without registering it as a dependency produces a build that is stale until the developer manually restarts the dev server. The same applies to persistent cache: webpack snapshots `fileDependencies` to decide whether the cache entry is still valid.

**Incorrect (reads `tailwind.config.js` but never declares it — edits don't trigger rebuild):**

```js
class TailwindConfigPlugin {
  constructor({ configPath }) { this.configPath = configPath; }

  apply(compiler) {
    compiler.hooks.thisCompilation.tap('TailwindConfigPlugin', (compilation) => {
      compilation.hooks.processAssets.tap(/* ... */, () => {
        const config = require(this.configPath); // every rebuild reads, but watch never fires
        emitTailwindArtifacts(config);
      });
    });
  }
}
```

**Correct (register the file as a dependency in the SAME hook that reads it):**

```js
class TailwindConfigPlugin {
  constructor({ configPath }) { this.configPath = path.resolve(configPath); }

  apply(compiler) {
    compiler.hooks.thisCompilation.tap('TailwindConfigPlugin', (compilation) => {
      compilation.hooks.processAssets.tap(/* ... */, () => {
        // Bust require's own cache so watch picks up edits
        delete require.cache[this.configPath];
        const config = require(this.configPath);
        emitTailwindArtifacts(compilation, config);

        // Tell webpack to re-run when this file changes
        compilation.fileDependencies.add(this.configPath);
      });
    });
  }
}
```

**Three dependency Sets, one rule each:**

| Set | When to add | Example |
|---|---|---|
| `compilation.fileDependencies` | Specific file you READ | `tailwind.config.js`, the manifest template |
| `compilation.contextDependencies` | DIRECTORY you scanned (any file change in it triggers rebuild) | `src/icons/` for an SVG sprite plugin |
| `compilation.missingDependencies` | File path you LOOKED FOR but didn't find — rebuild if it appears | `package.json` in a parent dir for monorepo root detection |

**Always use absolute paths.** Webpack normalizes path comparisons via the dependency snapshot system; relative paths produce ambiguous matches and warning output ("dependencies should be absolute paths").

**Add dependencies in the hook where you read the file — not in `apply()`.** The dependency Sets exist on `compilation`, not on `compiler`, so a tap is required. Adding in `make` or `thisCompilation` synchronously is fine; adding in `done` is too late.

**Don't forget on rebuild:** `compilation.fileDependencies` resets each compilation. You must re-add on every run, hence the pattern above where `.add()` lives inside the asset-emission tap.

Reference: [Compilation API — fileDependencies](https://webpack.js.org/api/compilation-object/#filedependencies) · [Persistent caching guide](https://github.com/webpack/changelog-v5/blob/master/guides/persistent-caching.md)
