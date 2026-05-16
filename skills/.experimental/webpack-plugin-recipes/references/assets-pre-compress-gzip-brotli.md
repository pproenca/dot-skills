---
title: Pre-Compress Assets to gzip and brotli for CDN
impact: MEDIUM
impactDescription: 60-80% smaller bytes delivered when CDN serves pre-compressed
tags: assets, compression, gzip, brotli, cdn
---

## Pre-Compress Assets to gzip and brotli for CDN

## Problem

You deploy to an S3/Cloudflare/Vercel-edge bucket; the CDN serves the bytes verbatim. If you ship `main.4f3a8e1b.js` (380kb) without a pre-compressed sibling, the CDN compresses on-the-fly per request (or worse — doesn't compress at all for cached responses, depending on tier). Both `main.4f3a8e1b.js.gz` (120kb) and `main.4f3a8e1b.js.br` (95kb) shipping in the dist directory lets the CDN match the client's `Accept-Encoding` header and serve the smaller bytes from cache without any compute work.

[`compression-webpack-plugin`](https://github.com/webpack-contrib/compression-webpack-plugin) exists and is the right plugin for this — but defaults to gzip-only, doesn't tune for brotli quality level, and emits non-content-hashed companion files that break cache invalidation. This recipe shows the production-shaped pattern.

## Pattern

Tap `processAssets` at `PROCESS_ASSETS_STAGE_OPTIMIZE_TRANSFER` (the stage explicitly designed for this), for each candidate asset compress in parallel via `jest-worker` (CPU-bound, embarrassingly parallel), emit `.gz` and `.br` siblings preserving asset.info.related metadata.

**Incorrect (without a plugin — relying on CDN's runtime compression):**

```text
# Cloudflare with default settings:
# - Gzips on the fly (per request, no caching)
# - Doesn't brotli unless on Pro+ plans
# - First request from each region takes the compression CPU hit
# Result: cold-cache responses are 3-8x slower than warm + you pay for compute time
```

**Correct (with this plugin — pre-compressed companions emitted at build time):**

```js
const zlib = require('node:zlib');
const path = require('node:path');
const { validate } = require('schema-utils');

const schema = {
  type: 'object',
  properties: {
    algorithms: {
      type: 'array',
      items: { enum: ['gzip', 'brotli'] },
      minItems: 1,
    },
    test: { type: 'string' },
    minBytes: { type: 'number' },
    gzipLevel: { type: 'number', minimum: 1, maximum: 9 },
    brotliQuality: { type: 'number', minimum: 0, maximum: 11 },
    deleteOriginal: { type: 'boolean' },
  },
  additionalProperties: false,
};

const DEFAULTS = {
  algorithms: ['gzip', 'brotli'],
  test: '\\.(js|mjs|css|html|json|svg|wasm)$',
  minBytes: 1024,
  gzipLevel: 9,
  brotliQuality: 11,
  deleteOriginal: false,
};

class PreCompressPlugin {
  constructor(options = {}) {
    validate(schema, options, { name: 'PreCompressPlugin', baseDataPath: 'options' });
    this.options = { ...DEFAULTS, ...options };
    this.testRe = new RegExp(this.options.test);
  }

  apply(compiler) {
    const { Compilation, sources } = compiler.webpack;

    compiler.hooks.thisCompilation.tap('PreCompressPlugin', (compilation) => {
      compilation.hooks.processAssets.tapPromise(
        {
          name: 'PreCompressPlugin',
          stage: Compilation.PROCESS_ASSETS_STAGE_OPTIMIZE_TRANSFER,
          additionalAssets: true,  // run again for late-added assets
        },
        async (assets) => {
          const cache = compilation.getCache('PreCompressPlugin');

          const tasks = Object.keys(assets)
            .filter((name) => this.testRe.test(name))
            .filter((name) => {
              if (name.endsWith('.gz') || name.endsWith('.br')) return false;  // already compressed
              const size = compilation.getAsset(name)?.info.size ?? assets[name].size();
              return size >= this.options.minBytes;
            })
            .flatMap((name) => this.options.algorithms.map((algo) => ({ name, algo })));

          await Promise.all(tasks.map(({ name, algo }) =>
            this.compressOne(compilation, cache, name, algo)));

          if (this.options.deleteOriginal) {
            for (const { name } of tasks) {
              if (this.allCompressedSiblingsExist(compilation, name)) {
                compilation.deleteAsset(name);
              }
            }
          }
        },
      );
    });
  }

  async compressOne(compilation, cache, name, algo) {
    const original = compilation.getAsset(name);
    const compressedName = `${name}.${algo === 'gzip' ? 'gz' : 'br'}`;
    if (compilation.getAsset(compressedName)) return; // already emitted by another plugin

    const etag = cache.getLazyHashedEtag(original.source);
    const cacheKey = `${compressedName}|${algo}|${this.qualityFor(algo)}`;

    const compressedSource = await cache.providePromise(cacheKey, etag, async () => {
      const buf = original.source.buffer();
      const compressed = await this.compress(buf, algo);
      return new compilation.compiler.webpack.sources.RawSource(compressed);
    });

    compilation.emitAsset(compressedName, compressedSource, {
      ...original.info,
      // The compressed sibling is NOT itself hashed in filename — its content
      // hash IS the original's hash. CDNs cache by name; this is fine.
      minimized: true,
      [algo]: true,                          // info.gzip = true or info.brotli = true
      related: { ...(original.info.related ?? {}), [algo]: compressedName },
    });

    // Annotate the ORIGINAL with `related` pointing at the compressed companion
    compilation.updateAsset(name, original.source, (info) => ({
      ...info,
      related: {
        ...(info.related ?? {}),
        [algo === 'gzip' ? 'gzipped' : 'brotli']: compressedName,
      },
    }));
  }

  qualityFor(algo) {
    return algo === 'gzip' ? this.options.gzipLevel : this.options.brotliQuality;
  }

  compress(buffer, algo) {
    return new Promise((resolve, reject) => {
      if (algo === 'gzip') {
        zlib.gzip(buffer, { level: this.options.gzipLevel },
          (err, out) => err ? reject(err) : resolve(out));
      } else {
        zlib.brotliCompress(buffer, {
          params: {
            [zlib.constants.BROTLI_PARAM_QUALITY]: this.options.brotliQuality,
          },
        }, (err, out) => err ? reject(err) : resolve(out));
      }
    });
  }

  allCompressedSiblingsExist(compilation, name) {
    return this.options.algorithms.every((algo) => {
      const ext = algo === 'gzip' ? '.gz' : '.br';
      return Boolean(compilation.getAsset(name + ext));
    });
  }
}

module.exports = PreCompressPlugin;
```

## Usage

```js
new PreCompressPlugin({
  algorithms: ['gzip', 'brotli'],
  minBytes: 1024,        // smaller files don't benefit and add overhead
  gzipLevel: 9,           // build-time can afford max compression
  brotliQuality: 11,      // brotli level 11 is ~3x slower than 6 but tighter
})
```

Deployment:

```nginx
# nginx serving pre-compressed
location ~* \.(?:js|css)$ {
    gzip_static on;
    brotli_static on;
}
```

For Cloudflare / Vercel, simply uploading `*.br` and `*.gz` siblings is enough — they're served when the client's `Accept-Encoding` matches.

## How it works

- **`PROCESS_ASSETS_STAGE_OPTIMIZE_TRANSFER`** is the canonical stage for compression — runs after minification, hashing, and SRI; the compressed output represents the FINAL bytes. See [`webpack-plugin-authoring/hook-process-assets-stage`].
- **`additionalAssets: true`** — if a LATER plugin emits a new asset, our hook runs again on those too. Without it, late-added assets ship uncompressed.
- **`getCache('PreCompressPlugin').providePromise`** — compression is the most expensive thing your build does (brotli level 11 is 2–4s per MB on a single core); caching it across rebuilds is essential. See [`webpack-plugin-authoring/perf-cache-results-with-compilation-cache`].
- **`Promise.all` over `tasks`** — gzip and brotli are CPU-bound and Node's zlib doesn't block the event loop (it uses libuv's threadpool). Parallel dispatch is "free" up to the threadpool size (default 4).
- **`asset.info.related`** annotation — downstream plugins (e.g., a manifest plugin emitting `<link rel="preload">` tags) can find the compressed siblings via `info.related.gzipped`
- **`minBytes: 1024`** — compressing a 500-byte asset adds gzip-header overhead and produces a BIGGER file; min threshold avoids it

## Variations

- **Brotli only for modern targets** (skip gzip): `algorithms: ['brotli']`
- **Worker pool for VERY large builds** (>1000 candidate assets): swap `zlib` for `jest-worker`-based compression — see [`webpack-plugin-authoring/perf-jest-worker-for-cpu-bound-work`]
- **Per-extension compression level** (lower for fonts because they're already compressed): `compressionLevels: { '.woff2': 1, '.js': 9 }`
- **Skip files smaller than compressed size** (gzip can make tiny files larger): post-compression check, discard if `compressed.length > original.length`

## When NOT to use this pattern

- Your CDN doesn't honor pre-compressed siblings (some legacy CDNs ignore `.gz` files)
- You use `compression-webpack-plugin` — it's the well-maintained webpack-contrib plugin for this
- Your output is dynamic (server-rendered HTML) — pre-compression doesn't apply

Reference: [compression-webpack-plugin](https://github.com/webpack-contrib/compression-webpack-plugin) · [zlib.brotli options](https://nodejs.org/api/zlib.html#class-brotlioptions) · [nginx http_gzip_static](https://nginx.org/en/docs/http/ngx_http_gzip_static_module.html)
