---
title: Hash Asset Content With compilation.outputOptions.hashFunction
impact: CRITICAL
impactDescription: prevents hash collisions across builds with custom hashFunction
tags: asset, content-hash, hash-function, xxhash
---

## Hash Asset Content With compilation.outputOptions.hashFunction

Webpack 5 lets users configure `output.hashFunction` (commonly `xxhash64` for speed in Next.js builds, `md4` for legacy compatibility). Hardcoding `crypto.createHash('md5')` in a plugin produces filenames that don't match the hash function the rest of the build uses, breaks `realContentHash`, and causes `webpack-subresource-integrity` to compute a different hash than the filename. Always derive the hash function from `compilation.outputOptions`.

**Incorrect (hardcoded md5 — collides with user's xxhash64 config):**

```js
const crypto = require('node:crypto');

compilation.hooks.processAssets.tap(
  { name: 'EmitManifestPlugin', stage: Compilation.PROCESS_ASSETS_STAGE_ADDITIONAL },
  () => {
    const content = JSON.stringify(buildManifest());
    const hash = crypto.createHash('md5').update(content).digest('hex').slice(0, 8);
    compilation.emitAsset(`manifest.${hash}.json`, new sources.RawSource(content));
  },
);
```

**Correct (use the compilation's hash function — matches the rest of the build):**

```js
compilation.hooks.processAssets.tap(
  { name: 'EmitManifestPlugin', stage: Compilation.PROCESS_ASSETS_STAGE_ADDITIONAL },
  () => {
    const content = JSON.stringify(buildManifest());

    // Pick up user config: hashFunction, hashDigest, hashDigestLength
    const { hashFunction, hashDigest, hashDigestLength } = compilation.outputOptions;
    const hasher = compilation.compiler.webpack.util.createHash(hashFunction);
    const hash = hasher.update(content).digest(hashDigest).slice(0, hashDigestLength);

    compilation.emitAsset(`manifest.${hash}.json`, new sources.RawSource(content), {
      immutable: true,
      contenthash: [hash],
    });
  },
);
```

**Why the indirection (`compiler.webpack.util.createHash`):**

- Returns webpack's hash wrapper, which knows how to handle `'xxhash64'` (provided by webpack via `xxhash-addon`) — `crypto.createHash('xxhash64')` throws
- Reuses the same hash provider webpack uses internally → identical bytes
- Works with custom hash functions registered via `output.hashFunction: () => MyHasher`

**Pattern for filename generation that mirrors webpack's own:**

```js
const { ModuleFilenameHelpers } = compiler.webpack;
const filename = compilation.getAssetPath(
  compilation.outputOptions.assetModuleFilename || '[hash][ext]',
  { contentHash: hash, chunk: { name: 'manifest' } },
);
```

This passes through user-configured filename templates (`[name].[contenthash:8].js` etc.) instead of hardcoding a layout.

**When a fixed hash function IS appropriate:**

- The asset is consumed externally and the consumer requires a specific algorithm (e.g., generating a `package-lock.json`-style integrity field for a specific tool that requires SHA-512)
- In that case, hash with the required algorithm but DON'T put that hash in the filename used by webpack's contenthash pipeline

Reference: [Output options — hashFunction](https://webpack.js.org/configuration/output/#outputhashfunction) · [Real Content Hash Plugin](https://webpack.js.org/plugins/real-content-hash-plugin/)
