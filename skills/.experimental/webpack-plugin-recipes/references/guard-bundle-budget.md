---
title: Fail Builds When Initial JS Exceeds a Per-Entry Budget
impact: CRITICAL
impactDescription: prevents silent bundle bloat across releases
tags: guard, bundle-size, performance-budget, ci
---

## Fail Builds When Initial JS Exceeds a Per-Entry Budget

## Problem

Your team agreed initial JavaScript for the main entry should stay under 250kb (gzipped) — that's the budget the perf team negotiated to hit a 3s LCP on 4G. But no one notices when a PR adds a 60kb dependency and pushes you over. CI passes (the build still succeeds), `webpack-bundle-analyzer` only runs when someone remembers to check it, and three weeks later the perf review catches that bundle size jumped 40%. You need CI to **fail** the build when the budget is exceeded — not warn, not log, fail.

Webpack ships `performance.maxAssetSize` / `maxEntrypointSize`, but they emit warnings only, don't honor compression, and apply globally (no per-entry budgets). This plugin gives you per-entry budgets with measurement against the actual on-the-wire size.

## Pattern

Tap `compilation.hooks.afterProcessAssets` (after hashing, before emit), sum the GZIP-COMPRESSED size of each entrypoint's initial chunks, compare against the configured budget per entry, and push a `WebpackError` to `compilation.errors` when any entry exceeds its budget.

**Incorrect (without a plugin — relying on webpack's built-in `performance` config):**

```js
// webpack.config.js — what people try first
module.exports = {
  performance: {
    maxAssetSize: 250000,        // applies globally — no per-entry budgets
    maxEntrypointSize: 400000,   // emits a WARNING only
    hints: 'error',              // measures UNCOMPRESSED bytes (~3x the gzipped reality)
  },
};
// Result: ships a 350kb-gzipped main bundle (~1.2MB uncompressed) and CI still passes.
```

**Correct (with this plugin — per-entry, gzipped, hard-fail):**

```js
const zlib = require('node:zlib');
const { validate } = require('schema-utils');

const schema = {
  type: 'object',
  properties: {
    budgets: {
      type: 'object',
      additionalProperties: { type: 'number', exclusiveMinimum: 0 },
      description: 'Map of entrypoint name → max gzipped bytes (e.g. { main: 250_000 })',
    },
    compression: { enum: ['gzip', 'brotli', 'none'] },
    failOn: { enum: ['error', 'warning'] },
  },
  required: ['budgets'],
  additionalProperties: false,
};

const DEFAULTS = { compression: 'gzip', failOn: 'error' };

class BundleBudgetPlugin {
  constructor(options) {
    validate(schema, options, { name: 'BundleBudgetPlugin', baseDataPath: 'options' });
    this.options = { ...DEFAULTS, ...options };
  }

  apply(compiler) {
    const { WebpackError } = compiler.webpack;

    compiler.hooks.thisCompilation.tap('BundleBudgetPlugin', (compilation) => {
      const logger = compilation.getLogger('BundleBudgetPlugin');

      compilation.hooks.afterProcessAssets.tap('BundleBudgetPlugin', () => {
        for (const [entryName, budget] of Object.entries(this.options.budgets)) {
          const entry = compilation.entrypoints.get(entryName);
          if (!entry) {
            const warn = new WebpackError(
              `BundleBudgetPlugin: budget set for unknown entry "${entryName}"`,
            );
            compilation.warnings.push(warn);
            continue;
          }

          let totalCompressed = 0;
          const breakdown = [];

          for (const chunk of entry.chunks) {
            for (const file of chunk.files) {
              if (!/\.(js|mjs)$/.test(file)) continue;
              const asset = compilation.getAsset(file);
              if (!asset) continue;
              const bytes = asset.source.buffer();
              const compressed = this.compress(bytes).length;
              totalCompressed += compressed;
              breakdown.push({ file, size: compressed });
            }
          }

          if (totalCompressed > budget) {
            const message =
              `BundleBudgetPlugin: entry "${entryName}" is ${fmt(totalCompressed)} ` +
              `(${this.options.compression}), exceeding budget of ${fmt(budget)} by ` +
              `${fmt(totalCompressed - budget)}\n` +
              breakdown
                .sort((a, b) => b.size - a.size)
                .map((b) => `  - ${b.file}: ${fmt(b.size)}`)
                .join('\n');

            const err = new WebpackError(message);
            err.hideStack = true;
            (this.options.failOn === 'warning' ? compilation.warnings : compilation.errors)
              .push(err);
          } else {
            logger.info(
              `entry "${entryName}": ${fmt(totalCompressed)} / ${fmt(budget)} ` +
              `(${Math.round((totalCompressed / budget) * 100)}%)`,
            );
          }
        }
      });
    });
  }

  compress(buffer) {
    switch (this.options.compression) {
      case 'brotli': return zlib.brotliCompressSync(buffer);
      case 'gzip':   return zlib.gzipSync(buffer, { level: 9 });
      case 'none':   return buffer;
    }
  }
}

function fmt(bytes) {
  return `${(bytes / 1024).toFixed(1)}kb`;
}

module.exports = BundleBudgetPlugin;
```

## How it works

- **`afterProcessAssets`** (not `afterEmit`) so the check happens before `emit`, allowing the build to fail before writing wrong bytes to disk. See [`webpack-plugin-authoring/hook-prefer-process-assets-over-emit`].
- **`entrypoints.get(name).chunks`** gives the initial chunks for an entry — async chunks are excluded automatically, which matches what users actually load on first paint.
- **`asset.source.buffer()`** returns bytes without UTF-8-coercing binary content. See [`webpack-plugin-authoring/asset-buffer-not-source-for-binary`].
- **`zlib.gzipSync({ level: 9 })`** measures what CDNs ship — most measure level 6, but level 9 is the conservative budget target.
- **`compilation.errors.push(WebpackError)`** instead of `throw` lets webpack collect all budget failures before exiting. See [`webpack-plugin-authoring/diag-push-webpack-error-not-throw`].

## Variations

- **Brotli budget for modern targets:** `compression: 'brotli'` — typically 15–25% smaller than gzip; tighten budgets accordingly
- **Warn in dev, error in CI:** `failOn: process.env.CI ? 'error' : 'warning'`
- **Per-chunk (not per-entry) budget:** swap `entry.chunks` for `compilation.chunks.filter(c => c.canBeInitial())`
- **Budget against last build (regression detection):** persist the previous total to `${CLAUDE_PLUGIN_DATA}/budgets-baseline.json` and fail when current grows >5% beyond baseline
- **Include CSS in the budget:** widen the regex to `/\.(js|mjs|css)$/`

## When NOT to use this pattern

- You already use `size-limit` or `bundlewatch` in CI — they do this with richer reporting
- Your app has hundreds of small dynamic-imported chunks with no clear "initial bundle" — per-chunk budgets are more useful
- You ship truly variable-size content per build (e.g., embedded translations for 30 languages) — single-number budgets are too coarse

Reference: [Webpack performance budgets](https://webpack.js.org/configuration/performance/) · [size-limit](https://github.com/ai/size-limit) · [Web.dev — Performance budgets 101](https://web.dev/articles/performance-budgets-101)
