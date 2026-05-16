---
title: Compute Subresource Integrity Hashes Per Asset
impact: HIGH
impactDescription: enables strict CSP and tamper detection on cached assets
tags: meta, sri, csp, integrity, security
---

## Compute Subresource Integrity Hashes Per Asset

## Problem

You're enabling Content Security Policy with `Strict-Transport-Security` and `Trusted-Types`, and the security team is asking for Subresource Integrity (SRI) hashes on every `<script src="...">` and `<link rel="stylesheet">`. SRI prevents a compromised CDN (or a malicious tamper of a cached asset) from running modified code in users' browsers. The browser hashes the downloaded asset and refuses to execute it if the hash doesn't match the `integrity` attribute.

The widely-used [`webpack-subresource-integrity`](https://github.com/waysact/webpack-subresource-integrity) plugin handles `HtmlWebpackPlugin` integration but doesn't expose the hashes to your SSR server or service worker. You need a `sri-manifest.json` mapping `asset.4f3a8e1b.js → sha384-...`, so the server can write `<script src="..." integrity="...">` tags and the service worker can verify its precache.

## Pattern

Tap `processAssets` at `PROCESS_ASSETS_STAGE_OPTIMIZE_HASH` so it runs AFTER content hashes are final (otherwise asset bytes will change after we hash). For each text/script asset, compute the SHA-384 (browser CSP standard recommends SHA-384) via webpack's own hash function (so xxhash64 etc. are honored), emit `sri-manifest.json`, and also annotate `asset.info.contenthash` so other plugins (like the bundled subresource-integrity plugin) can use it.

**Incorrect (without a plugin — hashes computed at deploy time, not build time):**

```bash
# In CI deploy step
for f in dist/*.js; do
  hash=$(openssl dgst -sha384 -binary "$f" | openssl base64)
  echo "$f: sha384-$hash" >> sri-manifest.txt
done
# Hashes the deployed bytes, but:
#   - Service worker is already built — can't include integrity in precache manifest
#   - HtmlWebpackPlugin already rendered tags — can't inject `integrity=...`
#   - Brittle: deploy step has to know which files need SRI
```

**Correct (with this plugin — integrity computed at build time, available to all downstream):**

```js
const { validate } = require('schema-utils');

const schema = {
  type: 'object',
  properties: {
    filename: { type: 'string' },
    algorithm: { enum: ['sha256', 'sha384', 'sha512'] },
    extensions: {
      type: 'array',
      items: { type: 'string', pattern: '^\\.' },
    },
  },
  additionalProperties: false,
};

const DEFAULTS = {
  filename: 'sri-manifest.json',
  algorithm: 'sha384',  // browser CSP standard
  extensions: ['.js', '.mjs', '.css'],
};

class SriManifestPlugin {
  constructor(options = {}) {
    validate(schema, options, { name: 'SriManifestPlugin', baseDataPath: 'options' });
    this.options = { ...DEFAULTS, ...options };
  }

  apply(compiler) {
    const { Compilation, sources, util } = compiler.webpack;

    compiler.hooks.thisCompilation.tap('SriManifestPlugin', (compilation) => {
      compilation.hooks.processAssets.tap(
        {
          name: 'SriManifestPlugin',
          // After hashes are final — we hash the FINAL bytes that will be served
          stage: Compilation.PROCESS_ASSETS_STAGE_OPTIMIZE_HASH,
          additionalAssets: true,  // run again if new assets appear after our stage
        },
        (assets) => {
          const manifest = {};

          for (const name of Object.keys(assets)) {
            if (!this.options.extensions.some((ext) => name.endsWith(ext))) continue;

            const asset = compilation.getAsset(name);
            const bytes = asset.source.buffer();

            // SHA-384 of asset bytes, base64-encoded — SRI format
            const hasher = util.createHash(this.options.algorithm);
            hasher.update(bytes);
            const base64 = hasher.digest('base64');
            const integrity = `${this.options.algorithm}-${base64}`;

            manifest[name] = integrity;

            // Annotate the asset so subresource-integrity-style plugins downstream
            // can read it (also visible in stats output)
            compilation.updateAsset(name, asset.source, (info) => ({
              ...info,
              contenthash: [...(info.contenthash ?? []), base64],
              integrity,  // non-standard but commonly read by tooling
            }));
          }

          const json = JSON.stringify(manifest, null, 2);
          compilation.emitAsset(
            this.options.filename,
            new sources.RawSource(json),
            { development: false, immutable: false },
          );
        },
      );
    });
  }
}

module.exports = SriManifestPlugin;
```

## Output example

```json
{
  "main.4f3a8e1b.js":    "sha384-r6IDdc6t+jpRG+lkBfqLh5DhmlW3T/PXa1G2u83mFs1Rzpa9fA9eF/Tn3F0/v5Hs",
  "vendors.91ab30.js":   "sha384-CqQX/g0z2OcyrjpDfGGzVxR+t+jpRGFsi7VJ8/MM2gqJ8a+9k3GpV5sgRxR9Cy5L",
  "main.81bf3022.css":   "sha384-9TfBl7d1HX2QFNRNl+0aEHWtKQQrxhCAg/2qX5RKD3+8gqJ7d+gVbV6xQfFcLZ7y"
}
```

Server use:

```js
// server.js
const sri = require('./dist/sri-manifest.json');
const manifest = require('./dist/manifest.json');

app.get('/', (req, res) => {
  const { js, css } = manifest.entrypoints.main;
  res.send(`
    <link rel="stylesheet" href="${css[0]}" integrity="${sri[basename(css[0])]}" crossorigin>
    <script src="${js[0]}" integrity="${sri[basename(js[0])]}" crossorigin></script>
  `);
});
```

## How it works

- **`PROCESS_ASSETS_STAGE_OPTIMIZE_HASH`** is the canonical stage for hash-based work — runs after all asset transformations are finalized; the bytes we hash are the bytes the browser will receive. See [`webpack-plugin-authoring/hook-process-assets-stage`].
- **`additionalAssets: true`** runs our hook AGAIN if a later plugin (`compression-webpack-plugin`, an inline script extractor) emits new assets that need integrity — without it, those late assets are missing from the manifest.
- **`util.createHash(algorithm)`** uses webpack's own hash provider so xxhash64 / md4 / sha384 all work consistently with the rest of the build. See [`webpack-plugin-authoring/asset-content-hash-via-output-options`].
- **SHA-384** is the W3C SRI recommendation — SHA-256 is acceptable but SHA-384 has stronger collision resistance; SHA-512 is overkill for SRI purposes
- **`info.integrity`** annotation lets downstream plugins (HtmlWebpackPlugin via `webpack-subresource-integrity`) reuse the hash instead of recomputing
- **`compilation.updateAsset(name, asset.source, infoUpdater)`** mutates info WITHOUT changing the source — the second-arg-as-function form. See [`webpack-plugin-authoring/asset-emit-asset-not-direct-assignment`].

## Variations

- **Multiple algorithms in one integrity string** (browser picks strongest):
  ```js
  const sha256 = util.createHash('sha256').update(bytes).digest('base64');
  const sha384 = util.createHash('sha384').update(bytes).digest('base64');
  const integrity = `sha256-${sha256} sha384-${sha384}`;
  ```
- **Strip from manifest** the assets that don't need SRI (sourcemaps, fonts loaded via CSS @font-face)
- **Emit as JS module** for service worker consumption:
  ```js
  compilation.emitAsset('sri-manifest.js', new sources.RawSource(
    `export const sri = ${JSON.stringify(manifest)};`,
  ));
  ```
- **Pair with CSP header generation**: emit a Content-Security-Policy header value alongside the manifest

## When NOT to use this pattern

- You use `webpack-subresource-integrity` and HtmlWebpackPlugin together — they handle the script/link tags automatically; only need this plugin if SSR / service worker needs the hashes too
- Your assets are inline (no separate cacheable .js files) — SRI is for cross-origin / CDN-cached assets
- Browser support is too narrow (you're targeting IE11 etc.) — though falling back to no-integrity is safe; the browser just ignores the attribute

Reference: [SRI specification](https://www.w3.org/TR/SRI/) · [webpack-subresource-integrity](https://github.com/waysact/webpack-subresource-integrity) · [MDN — Subresource Integrity](https://developer.mozilla.org/en-US/docs/Web/Security/Subresource_Integrity)
