---
title: Detect API Presence, Don't Check Webpack Versions
impact: LOW-MEDIUM
impactDescription: prevents brittle version-string parsing
tags: compat, feature-detection, version, webpack-5
---

## Detect API Presence, Don't Check Webpack Versions

Webpack ships new compiler hooks, new `compilation.cache` methods, and new asset-info fields across minor versions. Hard-coding `if (semver.gte(webpackVersion, '5.95.0'))` requires importing `semver`, depends on a version string that vendored/forked webpacks may not set correctly, and breaks if webpack ever skips a version number. Checking for the API directly (`if (compiler.hooks.validate)`) is one line, never wrong, and gracefully handles forks.

**Incorrect (version-string check — brittle, requires extra dep):**

```js
const semver = require('semver');
const { version: webpackVersion } = require('webpack/package.json');

apply(compiler) {
  if (semver.gte(webpackVersion, '5.106.0')) {
    compiler.hooks.validate.tap('Plugin', () => this.validate(compiler));
  }
  if (semver.gte(webpackVersion, '5.95.0')) {
    // ...
  }
  // Breaks with Next.js's vendored webpack (no version export) and webpack forks
}
```

**Correct (feature detection — one line, always right):**

```js
apply(compiler) {
  // Direct API check
  if (compiler.hooks.validate) {
    compiler.hooks.validate.tap('Plugin', () => this.validate(compiler));
  }

  // Namespace check
  if (compiler.webpack?.experiments?.schemes?.data) {
    // ...
  }

  // Method existence check
  const cache = compilation.getCache('Plugin');
  if (typeof cache.providePromise === 'function') {
    return cache.providePromise(name, etag, factory);
  } else {
    // Older API fallback
    return cache.getPromise(name, etag).then(v => v ?? factory());
  }
}
```

**Common feature-detection patterns:**

| Check | Tests for |
|---|---|
| `compiler.webpack` | Webpack 5+ (doesn't exist in 4) |
| `compiler.webpack.sources` | webpack-sources via namespace (always present in 5) |
| `compiler.hooks.validate` | Webpack 5.106+ |
| `compilation.fileSystemInfo` | Webpack 5+ snapshot API |
| `compilation.chunkGraph` | Webpack 5+ (replaces Chunk.modulesIterable) |
| `Compilation.PROCESS_ASSETS_STAGE_OPTIMIZE_INLINE` | Webpack 5.8.0+ |
| `compiler.options.experiments?.cacheUnaffected` | Incremental compilation (5.95+) |
| `typeof asset.info.javascriptModule === 'boolean'` | ESM-asset support (5.83+) |

**For the webpack-4 fallback (rare, but published plugins still hit it):**

```js
function getSources(compiler) {
  // Webpack 5: use the namespace
  if (compiler.webpack?.sources) return compiler.webpack.sources;
  // Webpack 4: fall back to the package
  return require('webpack-sources');
}

apply(compiler) {
  const { RawSource, ConcatSource } = getSources(compiler);
  // ...
}
```

**Document your minimum webpack version in package.json's peerDependencies:**

```json
{
  "peerDependencies": {
    "webpack": "^5.95.0"
  }
}
```

The peer-dep version range IS your "supported version" contract — feature detection handles the cases where the range allows older APIs to be absent.

**Don't try to be clever with `try/catch` around hook taps.** A failed `compiler.hooks.someNewHook.tap(...)` throws synchronously, not in a way that compiler reaches a usable state. Use `if (compiler.hooks.someNewHook)` guards instead.

Reference: [Webpack 5 release notes](https://webpack.js.org/blog/2020-10-10-webpack-5-release/) · [Webpack changelog](https://github.com/webpack/webpack/releases)
