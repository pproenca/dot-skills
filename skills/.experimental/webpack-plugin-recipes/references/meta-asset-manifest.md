---
title: Emit an Asset Manifest Mapping Logical Names to Hashed Filenames
impact: HIGH
impactDescription: enables SSR/server to reference hashed asset URLs
tags: meta, manifest, ssr, integration
---

## Emit an Asset Manifest Mapping Logical Names to Hashed Filenames

## Problem

Your bundles ship with content hashes: `main.4f3a8e1b.js`, `runtime.92ad7c.js`, `vendors.81bf30.css`. Your SSR server (Express, Fastify, Rails) needs to render `<script src="...">` tags with those exact hashes. Hard-coding them breaks on every deploy. Reading the dist directory at runtime requires sync I/O per request. You need a `manifest.json` that maps `main.js` → `main.4f3a8e1b.js` so the server can do `assets[ 'main.js' ]` and get the current hashed name. `webpack-manifest-plugin` exists but its output shape is opinionated; many teams need a manifest grouped by chunk with both JS and CSS siblings together, plus build info.

This is also what Next.js uses internally (BuildManifestPlugin), what Rails' `webpacker-pack` consumes, and what every "hand-rolled SSR" project ends up writing.

## Pattern

Tap `processAssets` at `PROCESS_ASSETS_STAGE_SUMMARIZE` (after all hashes are final, before reporting), iterate `compilation.chunks` (NOT `compilation.assets`, because we want chunk-level grouping), build a map of `chunk.name → { js: [...], css: [...], auxiliaryFiles: [...] }`, and emit as `manifest.json`.

**Incorrect (without a plugin — server reads dist directory on each request):**

```js
// server.js — what some teams do
import fs from 'fs';
app.get('/', (req, res) => {
  const files = fs.readdirSync('./dist');  // sync I/O per request
  const main = files.find((f) => f.startsWith('main.') && f.endsWith('.js'));
  res.send(`<script src="/${main}"></script>`);
  // No chunk grouping — can't find vendors.X.js companion
  // No entrypoint ORDER — runtime/vendors/main need to load in that sequence
});
```

**Correct (with this plugin — build-time manifest with chunk + entrypoint structure):**

```js
const { validate } = require('schema-utils');

const schema = {
  type: 'object',
  properties: {
    filename: { type: 'string' },
    publicPath: { type: 'string', description: 'Override compilation.outputOptions.publicPath' },
    includeAuxiliary: { type: 'boolean', description: 'Include source maps, .gz, etc.' },
    includeEntrypoints: { type: 'boolean', description: 'Include entrypoint → all chunks mapping' },
  },
  additionalProperties: false,
};

const DEFAULTS = {
  filename: 'manifest.json',
  includeAuxiliary: false,
  includeEntrypoints: true,
};

class AssetManifestPlugin {
  constructor(options = {}) {
    validate(schema, options, { name: 'AssetManifestPlugin', baseDataPath: 'options' });
    this.options = { ...DEFAULTS, ...options };
  }

  apply(compiler) {
    const { Compilation, sources } = compiler.webpack;

    compiler.hooks.thisCompilation.tap('AssetManifestPlugin', (compilation) => {
      compilation.hooks.processAssets.tap(
        {
          name: 'AssetManifestPlugin',
          // SUMMARIZE: all hashes final, all transforms done
          stage: Compilation.PROCESS_ASSETS_STAGE_SUMMARIZE,
        },
        () => {
          const publicPath = this.options.publicPath
            ?? compilation.outputOptions.publicPath
            ?? '';

          const chunks = {};
          for (const chunk of compilation.chunks) {
            if (!chunk.name) continue; // anonymous async chunks skipped

            const entry = { js: [], css: [], assets: [] };
            for (const file of chunk.files) {
              if (file.endsWith('.js') || file.endsWith('.mjs')) entry.js.push(prefix(publicPath, file));
              else if (file.endsWith('.css')) entry.css.push(prefix(publicPath, file));
              else entry.assets.push(prefix(publicPath, file));
            }
            if (this.options.includeAuxiliary) {
              for (const file of chunk.auxiliaryFiles) {
                entry.assets.push(prefix(publicPath, file));
              }
            }
            chunks[chunk.name] = entry;
          }

          // Entrypoints: name → ALL chunks needed to load this entry
          // (own chunk + split-out vendor + runtime + ...)
          const entrypoints = {};
          if (this.options.includeEntrypoints) {
            for (const [name, entry] of compilation.entrypoints) {
              const js = [];
              const css = [];
              for (const chunk of entry.chunks) {
                for (const file of chunk.files) {
                  if (file.endsWith('.js') || file.endsWith('.mjs')) js.push(prefix(publicPath, file));
                  else if (file.endsWith('.css')) css.push(prefix(publicPath, file));
                }
              }
              entrypoints[name] = { js, css };
            }
          }

          const manifest = { chunks, entrypoints };
          const json = JSON.stringify(manifest, null, 2);

          compilation.emitAsset(
            this.options.filename,
            new sources.RawSource(json),
            {
              immutable: false,                    // contents change every build
              development: false,                   // used by prod too
            },
          );
        },
      );
    });
  }
}

function prefix(publicPath, file) {
  if (!publicPath || publicPath === 'auto') return file;
  return publicPath.endsWith('/') ? publicPath + file : `${publicPath}/${file}`;
}

module.exports = AssetManifestPlugin;
```

## Output example

```json
{
  "chunks": {
    "main": {
      "js": ["/static/main.4f3a8e1b.js"],
      "css": ["/static/main.81bf3022.css"],
      "assets": []
    },
    "vendors": {
      "js": ["/static/vendors.91ab30.js"],
      "css": [],
      "assets": []
    }
  },
  "entrypoints": {
    "main": {
      "js": ["/static/runtime.92ad7c.js", "/static/vendors.91ab30.js", "/static/main.4f3a8e1b.js"],
      "css": ["/static/main.81bf3022.css"]
    }
  }
}
```

Server use:

```js
// server.js
const manifest = require('./dist/manifest.json');

app.get('/', (req, res) => {
  const { js, css } = manifest.entrypoints.main;
  res.send(`
    <!DOCTYPE html>
    <html>
      <head>${css.map((href) => `<link rel="stylesheet" href="${href}">`).join('')}</head>
      <body>
        <div id="root"></div>
        ${js.map((src) => `<script src="${src}"></script>`).join('')}
      </body>
    </html>
  `);
});
```

## How it works

- **`PROCESS_ASSETS_STAGE_SUMMARIZE`** runs after `OPTIMIZE_HASH`, so `chunk.files` contains the FINAL hashed names. Earlier stages would emit a manifest pointing at provisional (pre-real-content-hash) filenames. See [`webpack-plugin-authoring/hook-process-assets-stage`].
- **`compilation.entrypoints`** is the right structure for SSR — `chunks` is just bundle internals; the `entrypoints[name].chunks` list gives the LOAD ORDER (runtime first, vendors, then main). See [`webpack-plugin-authoring/perf-traverse-chunks-not-modules`].
- **`chunk.files`** separates by extension at output level; `chunk.auxiliaryFiles` holds source maps, `.gz`, image assets — opt-in to keep manifest small in the common case.
- **`info.immutable: false`** because the manifest changes every build — letting it through with `immutable: true` would make CDNs cache a stale manifest.

## Variations

- **Webpack-manifest-plugin compat shape** (flat `main.js → main.4f3a8e1b.js`):
  ```js
  const flat = {};
  for (const [name, entry] of Object.entries(chunks)) {
    for (const file of [...entry.js, ...entry.css]) {
      flat[name + (file.endsWith('.css') ? '.css' : '.js')] = file;
    }
  }
  ```
- **Multiple output files** (one per server-side framework: Rails, Express, Phoenix)
- **Filter to specific chunks** (only the chunks the SSR server cares about)
- **Embed SRI hashes** (combine with `meta-sri-manifest` recipe)

## When NOT to use this pattern

- You use Next.js, Remix, Nuxt, SvelteKit — they have their own manifest plugins integrated into the framework's SSR
- You don't run an SSR server — for pure SPA with `HtmlWebpackPlugin`, the script/link tags are already injected; no manifest needed
- You use [webpack-manifest-plugin](https://github.com/shellscape/webpack-manifest-plugin) — it covers 80% of cases; this recipe is for when its shape doesn't fit

Reference: [Next.js BuildManifestPlugin](https://github.com/vercel/next.js/tree/canary/packages/next/src/build/webpack/plugins) · [webpack-manifest-plugin](https://github.com/shellscape/webpack-manifest-plugin) · [Compilation API — entrypoints](https://webpack.js.org/api/compilation-object/#entrypoints)
