---
title: Optimize Images Through the Asset Pipeline With Cache Reuse
impact: MEDIUM
impactDescription: 40-80% smaller images without quality loss
tags: assets, images, sharp, optimization, cache
---

## Optimize Images Through the Asset Pipeline With Cache Reuse

## Problem

Your designers export PNG/JPEG at "Save for Web (Legacy)" quality 90; webpack passes them through verbatim; a 200kb hero image ships when 50kb would be visually identical. CDN-side image optimization (Cloudinary, Imgix) costs money and adds latency on first request. Build-time image optimization is the right place, but `sharp`/`imagemin` are slow (1–3s per image), and re-running them on every rebuild (200 images × 1s = 3 minutes added to every build) is unworkable.

The fix: optimize once, cache the result on its content hash, only re-optimize when the original image changes. That's the pattern this recipe implements.

## Pattern

Tap `processAssets` at `PROCESS_ASSETS_STAGE_OPTIMIZE_SIZE`, parallelize across images via Promise.all + jest-worker, use `compilation.getCache('ImageOptimizer').providePromise` keyed on the original asset's etag so unchanged images skip the work.

**Incorrect (without a plugin — manual `npm run images` step):**

```bash
# package.json
"scripts": {
  "images": "imagemin 'public/**/*.{png,jpg}' --out-dir=public",
  "build": "npm run images && webpack"
}
# Step doesn't track changes — optimizes EVERY image on every run (3 min added)
# Mutates the source files — git diff is noisy with re-encoded images
# Easy to forget; production deploys without optimization if CI script misses it
```

**Correct (with this plugin — cached, parallel, runs only on changed images):**

```js
const { validate } = require('schema-utils');

const schema = {
  type: 'object',
  properties: {
    test: { type: 'string' },
    plugins: {
      type: 'object',
      additionalProperties: { type: 'object' },
      description: 'imagemin plugin name → options',
    },
    maxConcurrency: { type: 'number' },
  },
  additionalProperties: false,
};

const DEFAULTS = {
  test: '\\.(png|jpe?g|webp)$',
  plugins: {
    'imagemin-mozjpeg': { quality: 80 },
    'imagemin-pngquant': { quality: [0.6, 0.8] },
  },
  maxConcurrency: 4,
};

class ImageOptimizerPlugin {
  constructor(options = {}) {
    validate(schema, options, { name: 'ImageOptimizerPlugin', baseDataPath: 'options' });
    this.options = { ...DEFAULTS, ...options };
    this.testRe = new RegExp(this.options.test);
  }

  apply(compiler) {
    const { Compilation, sources, WebpackError } = compiler.webpack;

    compiler.hooks.thisCompilation.tap('ImageOptimizerPlugin', (compilation) => {
      const logger = compilation.getLogger('ImageOptimizerPlugin');

      compilation.hooks.processAssets.tapPromise(
        {
          name: 'ImageOptimizerPlugin',
          stage: Compilation.PROCESS_ASSETS_STAGE_OPTIMIZE_SIZE,
          additionalAssets: true,
        },
        async (assets) => {
          const cache = compilation.getCache('ImageOptimizerPlugin');
          const candidates = Object.keys(assets).filter((n) => this.testRe.test(n));
          if (candidates.length === 0) return;

          // Resolve imagemin plugins from user's options
          let plugins;
          try {
            plugins = await this.resolvePlugins();
          } catch (err) {
            compilation.warnings.push(new WebpackError(`ImageOptimizerPlugin: ${err.message}`));
            return;
          }

          let totalBefore = 0;
          let totalAfter = 0;

          // Throttle to maxConcurrency
          const queue = [...candidates];
          await Promise.all(
            Array.from({ length: this.options.maxConcurrency }, () =>
              this.worker(queue, compilation, cache, plugins, (before, after) => {
                totalBefore += before;
                totalAfter += after;
              }),
            ),
          );

          const saved = totalBefore - totalAfter;
          if (saved > 0) {
            logger.info(
              `Optimized ${candidates.length} images: ` +
              `${fmt(totalBefore)} → ${fmt(totalAfter)} (saved ${fmt(saved)})`,
            );
          }
        },
      );
    });
  }

  async worker(queue, compilation, cache, plugins, onDone) {
    while (queue.length > 0) {
      const name = queue.shift();
      const original = compilation.getAsset(name);
      const etag = cache.getLazyHashedEtag(original.source);

      try {
        const optimizedSource = await cache.providePromise(name, etag, async () => {
          const buffer = original.source.buffer();
          const imagemin = await import('imagemin');
          const optimized = await imagemin.buffer(buffer, { plugins });
          if (optimized.length >= buffer.length) return original.source; // no improvement
          return new compilation.compiler.webpack.sources.RawSource(optimized);
        });

        const beforeSize = original.source.size();
        const afterSize = optimizedSource.size();
        if (afterSize < beforeSize) {
          compilation.updateAsset(name, optimizedSource);
        }
        onDone(beforeSize, afterSize);
      } catch (err) {
        const warn = new compilation.compiler.webpack.WebpackError(
          `ImageOptimizerPlugin: skipped ${name} (${err.message})`,
        );
        warn.hideStack = true;
        compilation.warnings.push(warn);
      }
    }
  }

  async resolvePlugins() {
    const resolved = [];
    for (const [pluginName, opts] of Object.entries(this.options.plugins)) {
      try {
        const mod = await import(pluginName);
        const factory = mod.default ?? mod;
        resolved.push(factory(opts));
      } catch (err) {
        throw new Error(
          `Cannot load imagemin plugin "${pluginName}". Install it: npm i -D ${pluginName}\n` +
          `Original error: ${err.message}`,
        );
      }
    }
    return resolved;
  }
}

function fmt(bytes) {
  return `${(bytes / 1024).toFixed(1)}kb`;
}

module.exports = ImageOptimizerPlugin;
```

## Usage

```js
new ImageOptimizerPlugin({
  plugins: {
    'imagemin-mozjpeg': { quality: 80, progressive: true },
    'imagemin-pngquant': { quality: [0.6, 0.8] },
    'imagemin-svgo': {
      plugins: [{ name: 'preset-default', params: { overrides: { removeViewBox: false } } }],
    },
  },
  maxConcurrency: 4,  // sharp/imagemin are CPU-bound; 4 is good for most laptops
})
```

## How it works

- **`PROCESS_ASSETS_STAGE_OPTIMIZE_SIZE`** is the canonical stage for size optimization — runs alongside terser/css-minimizer. See [`webpack-plugin-authoring/hook-process-assets-stage`].
- **`cache.providePromise` keyed on asset etag** — the etag IS the original image's content hash. Unchanged image = cache hit = ~0ms. Changed image = cache miss = 1–3s of optimization. This is the highest-leverage caching pattern in webpack plugins. See [`webpack-plugin-authoring/perf-cache-results-with-compilation-cache`].
- **`maxConcurrency`** prevents thrashing — Node's libuv threadpool defaults to 4 threads; running 200 image jobs in parallel just queues them with overhead. Manual concurrency limit is more predictable.
- **`buffer()` not `source()`** — binary content, must not be UTF-8-coerced. See [`webpack-plugin-authoring/asset-buffer-not-source-for-binary`].
- **"No improvement" fallback** — if optimized > original (rare but happens for already-optimized images), keep the original. Otherwise quality stays good but file gets bigger.
- **Dynamic `import()` of imagemin plugins** — they're ESM-only and the host webpack.config.js may be CJS; dynamic import bridges this

## Variations

- **AVIF/WebP variants alongside originals** (HTML uses `<picture>` to pick): emit `image.png` AND `image.avif`, annotate `info.related`
- **Per-extension quality** (lossless for PNGs that have transparency, lossy for screenshots): inspect the buffer's PNG header
- **Skip below 4kb** (smaller files barely benefit, add overhead): add minBytes check
- **Sharp-based** (vastly faster than imagemin): swap the `imagemin.buffer()` call for `sharp(buffer).jpeg({ quality: 80 }).toBuffer()`

## When NOT to use this pattern

- You use [image-minimizer-webpack-plugin](https://github.com/webpack-contrib/image-minimizer-webpack-plugin) — it's the webpack-contrib equivalent
- Your images are served by an image CDN (Cloudinary, Imgix, Vercel) that does this on-the-fly with caching
- Your image set is small (< 20 images) — manual optimization in `public/` once is cheaper
- Build time matters more than image size (pre-release builds in CI) — selectively disable with `mode === 'production'` check

Reference: [imagemin](https://github.com/imagemin/imagemin) · [image-minimizer-webpack-plugin](https://github.com/webpack-contrib/image-minimizer-webpack-plugin) · [sharp](https://sharp.pixelplumbing.com/)
