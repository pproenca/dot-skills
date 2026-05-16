---
title: Organize Emitted Assets Into Type-Based Subdirectories
impact: MEDIUM
impactDescription: cleaner dist/ for CDN-config and human inspection
tags: assets, organization, rename, dist-layout
---

## Organize Emitted Assets Into Type-Based Subdirectories

## Problem

Webpack's default output dumps everything into `dist/`: `main.4f3a8e1b.js`, `vendors.91ab30.js`, `main.81bf30.css`, `hero.2c3d.png`, `inter.var.woff2`, `manifest.json` — all in one flat directory. When you look at the dist with 50+ entries, finding the CSS chunks among the JS ones is hard. Your CDN config wants different cache TTLs per type (`/img/*` long, `/js/*` long, `/*.html` short) — a flat dist makes glob patterns brittle. You can hand-write `output.assetModuleFilename` and per-loader `filename` overrides, but those settings are scattered across config and easy to get wrong.

You want one plugin that says "JS goes in `js/`, CSS in `css/`, images in `img/`, fonts in `fonts/`, leave manifest.json alone."

## Pattern

Tap `processAssets` at `PROCESS_ASSETS_STAGE_OPTIMIZE_HASH` (so we run AFTER real-content-hash is finalized — names are stable to rename). For each asset matching a configured rule, call `compilation.renameAsset(old, new)` which updates chunk references atomically.

**Incorrect (without a plugin — scattered config across loaders + output):**

```js
// webpack.config.js — what people end up writing
module.exports = {
  output: {
    assetModuleFilename: 'img/[name].[contenthash:8][ext]',
  },
  module: {
    rules: [
      {
        test: /\.css$/,
        use: [{ loader: MiniCssExtractPlugin.loader, options: { filename: 'css/[name].[contenthash:8].css' } }, ...],
      },
      {
        test: /\.(woff2?|ttf)$/,
        type: 'asset/resource',
        generator: { filename: 'fonts/[name].[contenthash:8][ext]' },
      },
    ],
  },
  plugins: [
    new MiniCssExtractPlugin({ filename: 'css/[name].[contenthash:8].css' }),
  ],
};
// Settings live in 3 different places; an asset/source loader added later
// without overriding `filename` lands in dist/ root.
```

**Correct (with this plugin — one configuration, applies after the fact):**

```js
const path = require('node:path');
const { validate } = require('schema-utils');

const schema = {
  type: 'object',
  properties: {
    routes: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          test: { type: 'string', description: 'Regex matched against asset path' },
          to: { type: 'string', description: 'Target directory (relative to output)' },
          rename: {
            instanceof: 'Function',
            description: '(name) => newName, runs after the to-prefix is applied',
          },
        },
        required: ['test', 'to'],
        additionalProperties: false,
      },
      minItems: 1,
    },
  },
  required: ['routes'],
  additionalProperties: false,
};

class RouteAssetsByTypePlugin {
  constructor(options) {
    validate(schema, options, { name: 'RouteAssetsByTypePlugin', baseDataPath: 'options' });
    this.routes = options.routes.map((r) => ({ ...r, testRe: new RegExp(r.test) }));
  }

  apply(compiler) {
    const { Compilation } = compiler.webpack;

    compiler.hooks.thisCompilation.tap('RouteAssetsByTypePlugin', (compilation) => {
      compilation.hooks.processAssets.tap(
        {
          name: 'RouteAssetsByTypePlugin',
          // OPTIMIZE_HASH: real-content-hash is now final, but we still run
          // before SUMMARIZE/ANALYSE/REPORT so manifest-style plugins see the
          // renamed assets.
          stage: Compilation.PROCESS_ASSETS_STAGE_OPTIMIZE_HASH,
        },
        () => {
          // Snapshot keys — renameAsset mutates the assets map mid-iteration
          const names = Object.keys(compilation.assets);

          for (const name of names) {
            // Skip already-routed assets (assets that came in with a directory)
            // unless route specifically says to re-route them
            if (name.includes('/')) continue;

            for (const route of this.routes) {
              if (!route.testRe.test(name)) continue;

              let newName = path.posix.join(route.to, name);
              if (route.rename) newName = route.rename(newName);

              compilation.renameAsset(name, newName);
              break; // first match wins
            }
          }
        },
      );
    });
  }
}

module.exports = RouteAssetsByTypePlugin;
```

## Usage

```js
new RouteAssetsByTypePlugin({
  routes: [
    { test: '\\.(js|mjs)(\\.map)?$', to: 'js' },
    { test: '\\.css(\\.map)?$',      to: 'css' },
    { test: '\\.(png|jpe?g|webp|avif|gif|svg)$', to: 'img' },
    { test: '\\.(woff2?|ttf|otf)$', to: 'fonts' },
    { test: '\\.(wasm)$',            to: 'wasm' },
    // Top-level files (don't route): manifest.json, robots.txt, sw.js, .br/.gz siblings
    // — these don't match any rule, so they stay in dist/ root
  ],
})
```

Output:

```text
dist/
├── index.html
├── manifest.json
├── sw.js
├── js/
│   ├── main.4f3a8e1b.js
│   ├── vendors.91ab30.js
│   └── runtime.92ad7c.js
├── css/
│   └── main.81bf3022.css
├── img/
│   ├── hero.2c3d4e5f.png
│   └── logo.7a8b9c.svg
└── fonts/
    └── inter-var.0123abc.woff2
```

## How it works

- **`renameAsset` (not deleteAsset + emitAsset)** — atomically updates `chunk.files`, `chunk.auxiliaryFiles`, `asset.info.related` references. See [`webpack-plugin-authoring/asset-delete-then-emit-loses-info`].
- **`PROCESS_ASSETS_STAGE_OPTIMIZE_HASH`** — content hashes are final, but `SUMMARIZE` (manifest plugins) hasn't run yet. So a manifest plugin emits the CORRECT new paths.
- **`path.posix.join`** (not `path.join`) — webpack asset paths use forward slashes universally; `path.join` on Windows would emit `\` paths
- **Skip assets already containing `/`** — they were already routed by an upstream plugin (e.g., a loader's `filename: 'img/[name]'` config) or by a previous run of this plugin in an additional-assets re-run. Don't double-prefix.
- **First-match-wins** with explicit `break` — predictable rule ordering, no accidental "two routes matched" surprises

## Variations

- **Sourcemap to a SEPARATE directory** (`.map` files): add `{ test: '\\.map$', to: 'sourcemaps' }` BEFORE the JS/CSS rules
- **Hash-prefix routing** (`/static/v1/4f3a8e1b/main.js` for atomic deploys): wrap `to` in `static/v1/${asset.contenthash}`
- **Excluded patterns**: add an `exclude` regex per rule
- **Preserve subdirectories from loader output** (`asset.foo.bar.js` → `js/asset.foo.bar.js` not just `asset.js`): the recipe already does this via `path.posix.join`

## When NOT to use this pattern

- Your CDN doesn't care about path structure (S3 + Cloudflare don't)
- You already configure `assetModuleFilename` and per-loader `filename` precisely — this plugin would conflict
- You have <10 assets — the structure isn't necessary
- You depend on flat-dist conventions for tools (some service workers expect assets at root)

Reference: [Compilation API — renameAsset](https://webpack.js.org/api/compilation-object/#renameasset) · [output.assetModuleFilename](https://webpack.js.org/configuration/output/#outputassetmodulefilename)
