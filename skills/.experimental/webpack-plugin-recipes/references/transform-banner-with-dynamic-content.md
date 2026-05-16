---
title: Prepend a Per-Chunk Banner With Dynamic Content
impact: MEDIUM-HIGH
impactDescription: prevents broken license headers and stale copyright years
tags: transform, banner, license, copyright, header
---

## Prepend a Per-Chunk Banner With Dynamic Content

## Problem

Your legal team requires every emitted JavaScript file to start with a copyright/license header: `/*! @copyright 2026 Acme Corp · v1.4.3 (a7f8c92) · MIT */`. The bundled [`webpack.BannerPlugin`](https://webpack.js.org/plugins/banner-plugin/) takes a static string — but the year, version, and git commit hash change per build. You end up either:

1. Hardcoding the year (so January 1 you ship with "© 2025" — legal pushes back)
2. Building the banner in `webpack.config.js` (which runs once when config is loaded, not per build — git commit changes won't show)
3. Writing a custom plugin

Also, BannerPlugin prepends to ALL assets indiscriminately — sometimes you want a different banner for `.css` vs `.js`, or for vendor chunks vs first-party chunks. You want a plugin that takes a banner-producer function with access to chunk and asset info.

## Pattern

Tap `processAssets` at `PROCESS_ASSETS_STAGE_ADDITIONS` (which runs BEFORE minification), iterate assets matching the configured filter, prepend the banner via `ConcatSource` (which preserves source maps), and let the user supply a producer function `(name, chunk, compilation) => string` for full flexibility.

**Incorrect (without a plugin — webpack.BannerPlugin with computed-at-load string):**

```js
// webpack.config.js
const banner = `© ${new Date().getFullYear()} Acme Corp · v${pkg.version}`;
//                ^^ COMPUTED ONCE when config loads — not per build
//                Long-running dev server (started Dec 31, still running Jan 2)
//                ships © 2025 on Jan 1, 2026.

new webpack.BannerPlugin({ banner, raw: false });
// Also: applies to .css, .map, even non-text assets. No per-chunk customization.
```

**Correct (with this plugin — banner computed per chunk, per build):**

```js
const { validate } = require('schema-utils');

const schema = {
  type: 'object',
  properties: {
    banner: {
      oneOf: [
        { type: 'string' },
        { instanceof: 'Function', description: '({ name, chunk, compilation }) => string' },
      ],
    },
    include: { type: 'string', description: 'Regex against filename' },
    exclude: { type: 'string', description: 'Regex against filename' },
    raw: { type: 'boolean', description: 'If true, banner is inserted verbatim; otherwise wrapped as /*! ... */' },
  },
  required: ['banner'],
  additionalProperties: false,
};

const DEFAULTS = { include: '\\.(js|mjs|css)$', exclude: '\\.map$', raw: false };

class DynamicBannerPlugin {
  constructor(options) {
    validate(schema, options, { name: 'DynamicBannerPlugin', baseDataPath: 'options' });
    this.options = { ...DEFAULTS, ...options };
    this.includeRe = new RegExp(this.options.include);
    this.excludeRe = new RegExp(this.options.exclude);
  }

  apply(compiler) {
    const { Compilation, sources } = compiler.webpack;

    compiler.hooks.thisCompilation.tap('DynamicBannerPlugin', (compilation) => {
      compilation.hooks.processAssets.tap(
        {
          name: 'DynamicBannerPlugin',
          // ADDITIONS: before optimization/minification. Terser preserves
          // banner-style /*! comments by default, but only if they're present
          // BEFORE terser runs.
          stage: Compilation.PROCESS_ASSETS_STAGE_ADDITIONS,
        },
        () => {
          for (const chunk of compilation.chunks) {
            for (const name of chunk.files) {
              if (!this.includeRe.test(name)) continue;
              if (this.excludeRe.test(name)) continue;

              const rawBanner = typeof this.options.banner === 'function'
                ? this.options.banner({ name, chunk, compilation })
                : this.options.banner;
              if (!rawBanner) continue;

              const text = this.options.raw
                ? rawBanner + '\n'
                : `/*! ${rawBanner} */\n`;

              compilation.updateAsset(
                name,
                (old) => new sources.ConcatSource(text, old),
              );
            }
          }
        },
      );
    });
  }
}

module.exports = DynamicBannerPlugin;
```

## Usage

```js
const pkg = require('./package.json');
const { execSync } = require('node:child_process');

new DynamicBannerPlugin({
  banner: ({ name, chunk, compilation }) => {
    // Different banner for vendors vs first-party
    if (chunk.name?.includes('vendors')) {
      return `${name} · contains third-party code; see /LICENSES.txt`;
    }
    const year = new Date().getFullYear();
    const commit = execSync('git rev-parse --short HEAD').toString().trim();
    return `${pkg.name} v${pkg.version} (${commit}) · © ${year} Acme Corp · ${pkg.license}`;
  },
})

// Output (per chunk):
// /*! my-app v1.4.3 (a7f8c92) · © 2026 Acme Corp · MIT */
// !function(){ /* ... bundle ... */ }();
```

## How it works

- **`PROCESS_ASSETS_STAGE_ADDITIONS`** runs before `OPTIMIZE_SIZE` (where terser runs) — important because terser strips most comments BUT preserves `/*! ... */` style by default. See [`webpack-plugin-authoring/hook-process-assets-stage`].
- **`ConcatSource(banner, old)`** preserves the original source's source map; using `RawSource(banner + old.source())` would lose it. See [`webpack-plugin-authoring/asset-preserve-source-maps`].
- **Iterating `compilation.chunks` then `chunk.files`** instead of `Object.keys(compilation.assets)` — gives us the chunk context that the producer function can use. See [`webpack-plugin-authoring/perf-traverse-chunks-not-modules`].
- **`raw: false` wrapping in `/*! ... */`** ensures terser treats it as a preserved comment; otherwise terser strips it
- **Per-call evaluation of the banner function** — every build, every chunk gets fresh values (current year, current git commit, current asset name)

## Variations

- **CSS-only banner** (`include: '\\.css$'`) for `/*! @license MIT */` at CSS top:
  ```js
  raw: false, // wraps in CSS-compatible /* */ which CSS supports
  ```
- **Conditional banner** (only in production):
  ```js
  banner: ({ compilation }) => {
    if (compilation.compiler.options.mode !== 'production') return null;
    return computeBanner();
  }
  ```
- **Per-language banner** (i18n a build): take locale from chunk name
- **Hashed banner** (banner content includes the asset's content hash): combine with `asset.info.contenthash`

## When NOT to use this pattern

- The banner is genuinely static (year, name, version frozen at release time) — `webpack.BannerPlugin` is fine
- You only need source map "//# sourceMappingURL=" comments — webpack handles those
- Terser is configured to strip ALL comments (`output.comments: false`) — banner survives only if terser is configured to keep `/*!`

Reference: [webpack.BannerPlugin](https://webpack.js.org/plugins/banner-plugin/) · [Terser comments option](https://github.com/terser/terser#minify-options) · [Compilation API — updateAsset](https://webpack.js.org/api/compilation-object/#updateasset)
