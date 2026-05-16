---
title: Delete Empty Chunks That Webpack Emits as Side Effects
impact: MEDIUM
impactDescription: removes 0-byte runtime/css chunks polluting the asset graph
tags: assets, empty-chunks, cleanup, ssr
---

## Delete Empty Chunks That Webpack Emits as Side Effects

## Problem

Your build produces files like `runtime~main.81bf30.js` (0 bytes — exports nothing), `pages_admin_index.css` (0 bytes — admin page has no CSS imports), or `manifest~vendor.js` (0 bytes — runtime artifact). These ship to your CDN, get listed in your asset manifest, and SSR servers waste network roundtrips to fetch them just to receive an empty file. They appear because of `splitChunks` or `mini-css-extract-plugin` emitting placeholder chunks when there's nothing to extract.

You can sometimes prevent these with config (`optimization.splitChunks.minSize: 30000`), but config gymnastics doesn't address the case where a route just happens to have no CSS that build. The cleanup belongs in a post-emit pass: detect empty chunks, delete the asset, remove the chunk's reference, and update any manifest plugins running after this stage.

## Pattern

Tap `processAssets` at `PROCESS_ASSETS_STAGE_OPTIMIZE` (before SUMMARIZE so the asset manifest plugin sees a clean view), find assets whose `info.size === 0` (or below a configured threshold), and remove them via `compilation.deleteAsset`. For chunks that become entirely empty, also remove the chunk's file reference.

**Incorrect (without a plugin — empty CSS chunks ship and clutter manifest):**

```text
dist/
├── main.4f3a8e1b.js    (140kb — real)
├── main.81bf3022.css   (12kb — real)
├── admin.a1c2.js       (45kb — real)
├── admin.0000000.css   (0 bytes — empty, the admin page has no CSS imports)
├── runtime~admin.js    (0 bytes — runtime chunk webpack emits unconditionally)
└── manifest.json       (references all 5 files including the empties)

# Server renders <link rel="stylesheet" href="/admin.0000000.css"> → 200 OK, 0 bytes
# Wasted RTT, wasted manifest entry, wasted CDN cache slot
```

**Correct (with this plugin — empty chunks deleted before manifest plugin runs):**

```js
const { validate } = require('schema-utils');

const schema = {
  type: 'object',
  properties: {
    maxBytes: { type: 'number', description: 'Delete assets smaller than this (default 0 = exactly empty)' },
    test: { type: 'string', description: 'Only consider assets matching this regex' },
    exclude: { type: 'string', description: 'Never delete assets matching this regex' },
  },
  additionalProperties: false,
};

const DEFAULTS = {
  maxBytes: 0,
  test: '\\.(js|mjs|css)$',
  exclude: '(runtime|manifest)', // be conservative — never delete runtime files even if empty
};

class SkipEmptyChunksPlugin {
  constructor(options = {}) {
    validate(schema, options, { name: 'SkipEmptyChunksPlugin', baseDataPath: 'options' });
    this.options = { ...DEFAULTS, ...options };
    this.testRe = new RegExp(this.options.test);
    this.excludeRe = new RegExp(this.options.exclude);
  }

  apply(compiler) {
    const { Compilation } = compiler.webpack;

    compiler.hooks.thisCompilation.tap('SkipEmptyChunksPlugin', (compilation) => {
      const logger = compilation.getLogger('SkipEmptyChunksPlugin');

      compilation.hooks.processAssets.tap(
        {
          name: 'SkipEmptyChunksPlugin',
          // Run BEFORE SUMMARIZE so a manifest plugin sees the cleaned graph
          stage: Compilation.PROCESS_ASSETS_STAGE_OPTIMIZE,
        },
        () => {
          const deleted = [];

          for (const name of Object.keys(compilation.assets)) {
            if (!this.testRe.test(name)) continue;
            if (this.excludeRe.test(name)) continue;

            const asset = compilation.getAsset(name);
            const size = asset.info.size ?? asset.source.size();

            // Strict check: empty means content is literally empty,
            // not just "0 bytes after gzip" or similar
            if (size > this.options.maxBytes) continue;

            // Cross-check: peek the source to confirm it's not whitespace-only
            // that happens to size() as 0 — unlikely but defensive
            const buf = asset.source.buffer();
            if (buf.length > this.options.maxBytes) continue;

            this.removeAsset(compilation, name);
            deleted.push(name);
          }

          if (deleted.length > 0) {
            logger.info(`Removed ${deleted.length} empty asset(s):`);
            for (const name of deleted) logger.info(`  - ${name}`);
          }
        },
      );
    });
  }

  removeAsset(compilation, name) {
    // Step 1: remove from chunk.files / auxiliaryFiles
    for (const chunk of compilation.chunks) {
      chunk.files.delete(name);
      chunk.auxiliaryFiles.delete(name);
    }

    // Step 2: clean any `related` references pointing at this asset
    for (const otherName of Object.keys(compilation.assets)) {
      const other = compilation.getAsset(otherName);
      const related = other.info.related;
      if (!related) continue;
      let dirty = false;
      const newRelated = {};
      for (const [k, v] of Object.entries(related)) {
        if (v === name) { dirty = true; continue; }
        if (Array.isArray(v)) {
          const filtered = v.filter((entry) => entry !== name);
          if (filtered.length !== v.length) { dirty = true; }
          newRelated[k] = filtered;
        } else {
          newRelated[k] = v;
        }
      }
      if (dirty) {
        compilation.updateAsset(otherName, other.source, () => ({
          ...other.info,
          related: newRelated,
        }));
      }
    }

    // Step 3: delete the asset
    compilation.deleteAsset(name);
  }
}

module.exports = SkipEmptyChunksPlugin;
```

## Usage

```js
new SkipEmptyChunksPlugin({
  test: '\\.(css|js)$',     // empty CSS is common with route-based splitting
  exclude: '(runtime|webpack)',  // never delete webpack's runtime chunks
})
```

## How it works

- **`PROCESS_ASSETS_STAGE_OPTIMIZE`** runs early enough that `SUMMARIZE` (`meta-asset-manifest` recipe) sees the cleaned set. Running later would leave empty chunks in the manifest and require the manifest plugin to filter them too.
- **`deleteAsset` is not enough on its own** — see [`webpack-plugin-authoring/asset-delete-then-emit-loses-info`]; you also need to clear `chunk.files`/`auxiliaryFiles` and `related` references, which the recipe does explicitly
- **Double-check via `buffer().length`** — `info.size` can be cached from before transformations; the actual byte length is the source of truth
- **Conservative exclude pattern** — runtime chunks and manifest files MAY be empty in some configurations but are required for the build to function; deleting them breaks runtime imports
- **Logger output** lists what was removed — gives the team visibility into which chunks were always-empty (a hint that splitChunks config might need tuning)

## Variations

- **Threshold-based (not strict empty)** — delete chunks under 1kb that webpack emits for trivial split-chunk side effects:
  ```js
  maxBytes: 1024
  ```
- **Per-extension threshold** (CSS empty often; JS empty rarely): split into two rule sets
- **Warning mode** (log instead of delete — useful for first run when finding what's safe):
  ```js
  if (this.options.warningOnly) {
    compilation.warnings.push(new WebpackError(`Empty asset: ${name}`));
    return;
  }
  ```
- **Tracking which chunks routinely emit empty** for splitChunks tuning: log in `${CLAUDE_PLUGIN_DATA}/empty-chunks.log`

## When NOT to use this pattern

- You don't have empty chunks — `ls dist/` shows nothing 0-byte. The plugin would be a no-op.
- Your runtime chunks are intentionally near-empty placeholder files that the runtime fetches as a sanity check (rare)
- You depend on the empty asset's PRESENCE as a deployment marker — extremely rare

Reference: [Compilation API — deleteAsset](https://webpack.js.org/api/compilation-object/#deleteasset) · [optimization.splitChunks](https://webpack.js.org/plugins/split-chunks-plugin/) · [MiniCssExtractPlugin](https://webpack.js.org/plugins/mini-css-extract-plugin/)
