---
title: Import Source Classes From compiler.webpack.sources
impact: CRITICAL
impactDescription: prevents version drift breaking persistent cache
tags: asset, sources, peer-dependency, persistent-cache
---

## Import Source Classes From compiler.webpack.sources

`webpack-sources` ships its own `Source` base class with an internal `valueOf`/`buffer`/`map` contract. When a plugin imports `RawSource` from a different `webpack-sources` version than the host webpack uses, the resulting source objects fail `instanceof` checks inside webpack's persistent cache serializer — the build appears to succeed but every rebuild misses cache, and source maps may detach. `compiler.webpack.sources` exposes the exact instance webpack itself uses, with no version drift possible.

**Incorrect (direct import — version may differ from host webpack):**

```js
const { RawSource, ConcatSource } = require('webpack-sources');

class BannerPlugin {
  apply(compiler) {
    compiler.hooks.thisCompilation.tap('BannerPlugin', (compilation) => {
      compilation.hooks.processAssets.tap(/* ... */, (assets) => {
        for (const name of Object.keys(assets)) {
          // RawSource here may not be the SAME class webpack 5.95 uses internally
          compilation.updateAsset(name, (old) => new ConcatSource('/* banner */', old));
        }
      });
    });
  }
}
```

**Correct (use the namespace webpack itself exposes):**

```js
class BannerPlugin {
  apply(compiler) {
    const { sources, Compilation } = compiler.webpack;

    compiler.hooks.thisCompilation.tap('BannerPlugin', (compilation) => {
      compilation.hooks.processAssets.tap(
        { name: 'BannerPlugin', stage: Compilation.PROCESS_ASSETS_STAGE_ADDITIONS },
        (assets) => {
          for (const name of Object.keys(assets)) {
            compilation.updateAsset(
              name,
              (old) => new sources.ConcatSource('/* banner */', old),
            );
          }
        },
      );
    });
  }
}
```

**Everything `compiler.webpack` exposes (use it instead of importing `webpack`):**

| `compiler.webpack.X` | Replaces |
|---|---|
| `sources.RawSource` | `require('webpack-sources').RawSource` |
| `sources.ConcatSource` | `require('webpack-sources').ConcatSource` |
| `sources.SourceMapSource` | `require('webpack-sources').SourceMapSource` |
| `sources.OriginalSource` | `require('webpack-sources').OriginalSource` |
| `sources.ReplaceSource` | `require('webpack-sources').ReplaceSource` |
| `sources.CachedSource` | `require('webpack-sources').CachedSource` |
| `Compilation` | `require('webpack').Compilation` (for stage constants) |
| `WebpackError` | `require('webpack').WebpackError` |
| `ModuleFilenameHelpers` | `require('webpack').ModuleFilenameHelpers` |

**Why this is non-negotiable for persistent cache:** Webpack 5's persistent cache serializes `Source` instances by class name lookup. A `RawSource` from a different module instance has a different class identity and fails the lookup, falling back to a re-serialization path that doesn't survive across processes.

Reference: [Webpack 5 release — sources via compiler.webpack](https://webpack.js.org/blog/2020-10-10-webpack-5-release/) · [GitHub: webpack/webpack-sources](https://github.com/webpack/webpack-sources)
