---
title: Add Code Inputs to buildDependencies for Persistent Cache
impact: HIGH
impactDescription: prevents cache poisoning across plugin upgrades
tags: cache, buildDependencies, persistent-cache, version-safety
---

## Add Code Inputs to buildDependencies for Persistent Cache

Webpack 5's persistent cache (`cache.type: 'filesystem'`) keys cache entries on a hash of `buildDependencies` — the files that, if changed, would change the build OUTPUT for the same input. When a plugin reads from a config file, template, or JSON schema and that file isn't in `buildDependencies`, editing the file leaves the cache valid even though the build is now different. The user sees stale output that survives `--watch` restarts; the only fix is `rm -rf node_modules/.cache`.

**Incorrect (plugin reads template.html but doesn't register it — cache survives edits):**

```js
class HtmlTemplatePlugin {
  constructor({ template }) { this.template = template; }
  apply(compiler) {
    compiler.hooks.thisCompilation.tap('HtmlTemplatePlugin', (compilation) => {
      compilation.hooks.processAssets.tap(/* ... */, () => {
        const html = fs.readFileSync(this.template, 'utf8');
        compilation.emitAsset('index.html', new sources.RawSource(html));
        compilation.fileDependencies.add(this.template); // watch invalidates
        // But persistent cache doesn't — template edits survive cache hit
      });
    });
  }
}
```

**Correct (declare buildDependencies in beforeCompile so the cache keys on them):**

```js
class HtmlTemplatePlugin {
  constructor({ template }) { this.template = path.resolve(template); }
  apply(compiler) {
    compiler.hooks.beforeCompile.tap('HtmlTemplatePlugin', (params) => {
      // Tell cache: changes to these files invalidate everything
      params.buildDependencies = params.buildDependencies ?? new Set();
      params.buildDependencies.add(this.template);
    });

    compiler.hooks.thisCompilation.tap('HtmlTemplatePlugin', (compilation) => {
      compilation.hooks.processAssets.tap(/* ... */, () => {
        const html = fs.readFileSync(this.template, 'utf8');
        compilation.emitAsset('index.html', new sources.RawSource(html));
        compilation.fileDependencies.add(this.template);
      });
    });
  }
}
```

**Even better — register your plugin's own source as a build dependency:**

```js
// Recommended Webpack docs pattern: also include the plugin source itself
module.exports = class HtmlTemplatePlugin {
  /* ... */
};

// Then in webpack.config.js:
module.exports = {
  cache: {
    type: 'filesystem',
    buildDependencies: {
      config: [__filename],           // invalidate cache when webpack.config.js changes
      plugin: [require.resolve('./html-template-plugin')], // invalidate when plugin upgrades
    },
  },
};
```

**`fileDependencies` vs `buildDependencies` — they solve different problems:**

| Dependency | Invalidates | Lives on |
|---|---|---|
| `compilation.fileDependencies` | Watch mode rebuild within the same process | `Compilation` |
| `compilation.buildDependencies` (via `beforeCompile`) | Persistent cache across processes | `CompilationParams` |

You need BOTH for files whose contents affect output: `fileDependencies` for watch, `buildDependencies` for persistent cache.

**What counts as a buildDependency:**

- Plugin source files (so plugin upgrades invalidate cache)
- Loader source files (declared via `cache.buildDependencies.loader`)
- Config files (`webpack.config.js`, `babel.config.js`, `tsconfig.json` if your plugin reads it)
- JSON schemas your plugin validates against

**Don't include node_modules wholesale.** Webpack hashes every buildDependency on every build — adding `node_modules/**` makes startup multi-second.

Reference: [cache.buildDependencies](https://webpack.js.org/configuration/cache/#cachebuilddependencies) · [Persistent caching guide](https://github.com/webpack/changelog-v5/blob/master/guides/persistent-caching.md)
