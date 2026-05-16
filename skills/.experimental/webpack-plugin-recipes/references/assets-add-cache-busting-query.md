---
title: Append Cache-Busting Query Strings to Imports
impact: MEDIUM
impactDescription: enables atomic deploys to non-hash-aware hosts
tags: assets, cache-busting, query-string, deploy
---

## Append Cache-Busting Query Strings to Imports

## Problem

You deploy to a host that doesn't support per-file Cache-Control headers (Squarespace export, a shared static webserver, an embed widget on third-party sites). Content hashes in filenames work — `main.4f3a8e1b.js` is uniquely cacheable — but you ALSO ship `robots.txt`, `apple-touch-icon.png`, `manifest.json`, and external API documentation HTML, which CAN'T have hashes in their filenames (their paths are referenced by name from outside).

For those filename-fixed assets, you want `?v=<build-hash>` appended at the references TO them (e.g., `<link rel="manifest" href="manifest.json?v=a7f8c92">`), so the browser treats them as different URLs across deploys. Then a stale manifest.json doesn't get reused for 24 hours after deploy.

## Pattern

In `processAssets` at `PROCESS_ASSETS_STAGE_OPTIMIZE_TRANSFER` (after content hashes settled — we need the build hash), find configured "fixed-name" asset references INSIDE other text assets (`<link href="manifest.json">`, `import 'sw.js'`), and rewrite them to include the `?v=` query — using `ReplaceSource` to preserve source maps.

**Incorrect (without a plugin — manual ?v= updates in source code):**

```html
<!-- src/index.html — hand-edited every deploy -->
<link rel="manifest" href="manifest.json?v=2026-01-15">
<script src="sw.js?v=2026-01-15"></script>

<!-- Tomorrow's deploy: forgot to update the version → stale manifest cached for 24h -->
<!-- Or worse: stale offline-mode service worker that doesn't auto-update -->
```

**Correct (with this plugin — automatic, build-hash-keyed query strings):**

```js
const path = require('node:path');
const { validate } = require('schema-utils');

const schema = {
  type: 'object',
  properties: {
    assets: {
      type: 'array',
      items: { type: 'string', minLength: 1 },
      description: 'Asset filenames (relative to output) to cache-bust references to',
      minItems: 1,
    },
    versionStrategy: {
      enum: ['hash', 'timestamp', 'commit'],
      description: 'How to compute the ?v= value',
    },
    referencingFiles: {
      type: 'string',
      description: 'Regex for files in which to find/replace references (default text assets)',
    },
  },
  required: ['assets'],
  additionalProperties: false,
};

const DEFAULTS = {
  versionStrategy: 'hash',
  referencingFiles: '\\.(html|js|mjs|css)$',
};

class CacheBustingQueryPlugin {
  constructor(options) {
    validate(schema, options, { name: 'CacheBustingQueryPlugin', baseDataPath: 'options' });
    this.options = { ...DEFAULTS, ...options };
    this.referencingRe = new RegExp(this.options.referencingFiles);
  }

  apply(compiler) {
    const { Compilation, sources } = compiler.webpack;

    compiler.hooks.thisCompilation.tap('CacheBustingQueryPlugin', (compilation) => {
      compilation.hooks.processAssets.tap(
        {
          name: 'CacheBustingQueryPlugin',
          stage: Compilation.PROCESS_ASSETS_STAGE_OPTIMIZE_TRANSFER,
        },
        () => {
          const version = this.computeVersion(compilation);
          if (!version) return;

          // Build a regex that matches any reference to any of our fixed-name assets
          // Use a single pass per source to avoid O(n*m) overhead
          const escaped = this.options.assets.map(escapeRegExp);
          const refRe = new RegExp(`\\b(${escaped.join('|')})\\b(?!\\?)`, 'g');

          for (const name of Object.keys(compilation.assets)) {
            if (!this.referencingRe.test(name)) continue;
            // Don't rewrite references inside the target assets themselves
            if (this.options.assets.includes(path.basename(name))) continue;

            const asset = compilation.getAsset(name);
            const text = asset.source.source().toString();
            if (!refRe.test(text)) {
              refRe.lastIndex = 0;
              continue;
            }
            refRe.lastIndex = 0;

            const replacer = new sources.ReplaceSource(asset.source, name);
            let match;
            while ((match = refRe.exec(text)) !== null) {
              replacer.replace(
                match.index,
                match.index + match[0].length - 1,
                `${match[1]}?v=${version}`,
              );
            }
            compilation.updateAsset(name, replacer);
          }
        },
      );
    });
  }

  computeVersion(compilation) {
    switch (this.options.versionStrategy) {
      case 'timestamp':
        return Date.now().toString(36);
      case 'commit':
        return process.env.GIT_COMMIT?.slice(0, 8) ?? Date.now().toString(36);
      case 'hash':
      default:
        // Webpack 5: compilation.hash is the build hash (8+ chars)
        return compilation.hash?.slice(0, 8) ?? Date.now().toString(36);
    }
  }
}

function escapeRegExp(s) {
  return s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

module.exports = CacheBustingQueryPlugin;
```

## Usage

```js
new CacheBustingQueryPlugin({
  assets: [
    'manifest.json',
    'sw.js',
    'apple-touch-icon.png',
    'favicon.ico',
    'browserconfig.xml',
  ],
  versionStrategy: 'hash',
})

// Input (src/index.html):
//   <link rel="manifest" href="manifest.json">
//   <script src="sw.js"></script>

// Output (dist/index.html):
//   <link rel="manifest" href="manifest.json?v=a7f8c92">
//   <script src="sw.js?v=a7f8c92"></script>
```

## How it works

- **`PROCESS_ASSETS_STAGE_OPTIMIZE_TRANSFER`** runs after content-hash optimization, so `compilation.hash` has its final value. Earlier stages would use a stale hash.
- **`ReplaceSource` preserves source maps** — `RawSource(text.replace(...))` would lose them. See [`webpack-plugin-authoring/asset-preserve-source-maps`].
- **`(?!\\?)` lookahead** prevents double-versioning — if a reference already has `?` (a query string), skip it. Otherwise running the plugin twice (or another plugin adding a query) produces `?v=a7f8c92?v=b3e1f4`.
- **Single regex with alternation** (`(asset1|asset2|asset3)`) for O(text-length) scanning instead of O(text-length × asset-count)
- **Skip rewriting INSIDE the target assets themselves** — `manifest.json` referencing `manifest.json` (rare) would be a footgun
- **`escapeRegExp`** — `asset.svg` would otherwise match `assetXsvg`; literal regex match

## Variations

- **Per-asset version strategy** (manifest.json uses hash, sw.js uses timestamp):
  ```js
  assets: [
    { name: 'manifest.json', strategy: 'hash' },
    { name: 'sw.js', strategy: 'timestamp' },
  ]
  ```
- **HTML-only mode** (only rewrite in `.html` files): `referencingFiles: '\\.html$'`
- **CDN URL prefix** (rewrite to `https://cdn.example.com/manifest.json?v=hash`):
  ```js
  cdnPrefix: 'https://cdn.example.com/',
  // replacer.replace(start, end, `${cdnPrefix}${match[1]}?v=${version}`)
  ```
- **Per-environment opt-out** (skip in dev): `if (compiler.options.mode !== 'production') return;`

## When NOT to use this pattern

- Your host supports content hashes in filenames AND respects Cache-Control headers — this plugin solves a problem you don't have
- You use HTTP Cache-Control: no-cache for those specific files (manifest.json, sw.js) at the host level — also solves it without query strings
- Your service worker has its own cache versioning (Workbox) — adding ?v= here may conflict

Reference: [Compilation hash](https://webpack.js.org/api/compilation-object/#hash) · [webpack-sources ReplaceSource](https://github.com/webpack/webpack-sources)
