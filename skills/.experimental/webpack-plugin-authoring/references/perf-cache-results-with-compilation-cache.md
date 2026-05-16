---
title: Cache Expensive Work via compilation.getCache
impact: MEDIUM
impactDescription: 10-100x faster watch rebuilds (skips unchanged assets)
tags: perf, cache, getCache, etag, watch-mode
---

## Cache Expensive Work via compilation.getCache

Webpack 5's compilation cache (`compilation.getCache(name)`) is a per-namespace key/value store that survives across `--watch` rebuilds and persists to disk when `cache.type: 'filesystem'` is set. Wrapping expensive transformations in `cache.getLazyHashedEtag(source).then(etag => cache.providePromise(name, etag, () => doWork()))` skips work for assets whose input hasn't changed — `terser-webpack-plugin` and `image-minimizer-webpack-plugin` use this to skip 95%+ of work on incremental rebuilds.

**Incorrect (re-runs SVG optimization for every asset on every build):**

```js
const svgo = require('svgo');

compilation.hooks.processAssets.tapPromise(/* ... */, async (assets) => {
  for (const name of Object.keys(assets)) {
    if (!name.endsWith('.svg')) continue;
    const src = assets[name].source().toString();
    const optimized = svgo.optimize(src).data; // ~50ms per file, every rebuild
    compilation.updateAsset(name, new sources.RawSource(optimized));
  }
});
```

**Correct (cache keyed on the source's etag — skipped when content unchanged):**

```js
const svgo = require('svgo');

compilation.hooks.processAssets.tapPromise(/* ... */, async (assets) => {
  const cache = compilation.getCache('SvgOptimizerPlugin');

  await Promise.all(
    Object.keys(assets).filter((n) => n.endsWith('.svg')).map(async (name) => {
      const source = assets[name];
      // etag changes only when source content changes
      const etag = cache.getLazyHashedEtag(source);

      const result = await cache.providePromise(
        name,                            // cache key
        etag,                            // version
        async () => {
          // Only runs on cache miss (asset is new or content changed)
          const optimized = svgo.optimize(source.source().toString()).data;
          return new sources.RawSource(optimized);
        },
      );

      compilation.updateAsset(name, result);
    }),
  );
});
```

**Cache API surface:**

| Method | Use |
|---|---|
| `cache.providePromise(name, etag, factory)` | Get-or-compute by name+etag — most common pattern |
| `cache.getPromise(name, etag)` | Get only, returns `undefined` on miss |
| `cache.storePromise(name, etag, data)` | Store explicitly (when factory pattern doesn't fit) |
| `cache.mergeEtags(a, b)` | Combine etags when result depends on multiple sources |
| `cache.getLazyHashedEtag(hashable)` | Defer etag computation until cache actually needs it |

**Multi-input etag (transform depends on TWO sources):**

```js
const sourceEtag = cache.getLazyHashedEtag(originalAsset);
const configEtag = cache.getLazyHashedEtag(configSource);
const combined = cache.mergeEtags(sourceEtag, configEtag);
const result = await cache.providePromise(name, combined, () => transform(...));
```

**What gets cached automatically vs needs explicit caching:**

| Work | Webpack caches it? |
|---|---|
| Module parsing | ✓ (built-in) |
| Loader output | ✓ (per loader's cacheable() declaration) |
| `processAssets` work | ✗ (you must do it) |
| `optimize*` hook work | ✗ |
| Custom asset transforms | ✗ |

**Etag must change when output would change.** If your transform depends on plugin options, include an option-version etag:

```js
const optionsHash = compiler.webpack.util.createHash('xxhash64')
  .update(JSON.stringify(this.options))
  .digest('hex');

cache.providePromise(name, `${etag}|${optionsHash}`, () => transform(...));
```

Otherwise users editing your plugin options in `webpack.config.js` get stale cached output.

Reference: [Compilation API — getCache](https://webpack.js.org/api/compilation-object/#getcache) · [terser-webpack-plugin cache usage](https://github.com/webpack-contrib/terser-webpack-plugin/blob/master/src/index.js)
