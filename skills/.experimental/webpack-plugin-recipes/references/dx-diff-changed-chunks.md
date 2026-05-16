---
title: Print Which Chunks Actually Changed Between Rebuilds
impact: MEDIUM
impactDescription: 1-2 minutes saved per chunked watch-mode rebuild
tags: dx, watch-mode, chunk-hashes, incremental
---

## Print Which Chunks Actually Changed Between Rebuilds

## Problem

Your app produces 200+ chunks (route-based code splitting + vendor chunks + async imports). On a watch-mode rebuild after touching a single file, webpack happily rebuilds and reports "compiled successfully" — but you have no idea WHICH 3 chunks actually changed bytes. Did the import you just added land in the main chunk (cache invalidation for every user) or in an async chunk (only invalidates users hitting that route)? Without this signal you can't quickly assess "does this change feel right?"

`webpack --stats=detailed` lists every chunk in every build whether it changed or not — the noise hides the signal. You want a one-line-per-changed-chunk diff after every rebuild.

## Pattern

In `apply()`, keep a `Map<chunkId, contentHash>` of the previous build's chunk hashes. In `compiler.hooks.done`, walk current chunks, compare each `chunk.contentHash.javascript` to the previous, log a per-chunk line ONLY for those that changed (or were added/removed).

**Incorrect (without a plugin — `webpack --stats`):**

```text
$ webpack --watch --stats=detailed
asset main.4f3a8e1b.js 142 KiB ...    [emitted] [immutable]
asset vendors.91ab30.js 380 KiB ...    [emitted] [immutable]
asset checkout.81bf30.js 67 KiB ...   [emitted] [immutable]
asset blog-index.a1c290.js 22 KiB ...  [emitted] [immutable]
... 196 more chunks ...
# Which one actually changed bytes from the previous build? Search the previous run's output.
```

**Correct (with this plugin — only changed chunks shown):**

```js
const { validate } = require('schema-utils');

const schema = {
  type: 'object',
  properties: {
    minBytes: { type: 'number', description: 'Suppress chunks smaller than this (default 1024)' },
    showSize: { type: 'boolean' },
    showSizeDelta: { type: 'boolean' },
    onFirstBuild: { enum: ['silent', 'summary', 'all'] },
  },
  additionalProperties: false,
};

const DEFAULTS = {
  minBytes: 1024,
  showSize: true,
  showSizeDelta: true,
  onFirstBuild: 'summary',
};

class DiffChangedChunksPlugin {
  constructor(options = {}) {
    validate(schema, options, { name: 'DiffChangedChunksPlugin', baseDataPath: 'options' });
    this.options = { ...DEFAULTS, ...options };
    this.previous = null; // Map<key, { hash, size }>
  }

  apply(compiler) {
    compiler.hooks.done.tap('DiffChangedChunksPlugin', (stats) => {
      const compilation = stats.compilation;
      const logger = compilation.getLogger('DiffChangedChunksPlugin');

      const current = new Map();
      for (const chunk of compilation.chunks) {
        const key = chunk.id ?? chunk.name ?? `<anon-${chunk.runtime}>`;
        let totalSize = 0;
        for (const file of chunk.files) {
          totalSize += compilation.getAsset(file)?.info.size
            ?? compilation.getAsset(file)?.source.size()
            ?? 0;
        }
        current.set(String(key), {
          hash: chunk.contentHash?.javascript ?? chunk.hash,
          size: totalSize,
          name: chunk.name ?? String(chunk.id),
        });
      }

      if (this.previous === null) {
        this.handleFirstBuild(logger, current);
        this.previous = current;
        return;
      }

      const changed = [];
      const added = [];
      const removed = [];

      for (const [key, entry] of current) {
        const prev = this.previous.get(key);
        if (!prev) added.push(entry);
        else if (prev.hash !== entry.hash) changed.push({ ...entry, prevSize: prev.size });
      }
      for (const [key, entry] of this.previous) {
        if (!current.has(key)) removed.push(entry);
      }

      this.report(logger, changed, added, removed);
      this.previous = current;
    });
  }

  report(logger, changed, added, removed) {
    if (changed.length === 0 && added.length === 0 && removed.length === 0) {
      logger.info('No chunks changed.');
      return;
    }

    const fmt = (b) => `${(b / 1024).toFixed(1)}kb`;
    const delta = (now, then) => {
      const d = now - then;
      const sign = d >= 0 ? '+' : '';
      return ` (${sign}${(d / 1024).toFixed(1)}kb)`;
    };

    for (const entry of changed) {
      if (entry.size < this.options.minBytes) continue;
      logger.info(
        `~ ${entry.name}` +
        (this.options.showSize ? ` ${fmt(entry.size)}` : '') +
        (this.options.showSizeDelta ? delta(entry.size, entry.prevSize) : ''),
      );
    }
    for (const entry of added) {
      logger.info(`+ ${entry.name}${this.options.showSize ? ` ${fmt(entry.size)}` : ''}`);
    }
    for (const entry of removed) {
      logger.info(`- ${entry.name}`);
    }
  }

  handleFirstBuild(logger, current) {
    if (this.options.onFirstBuild === 'silent') return;
    if (this.options.onFirstBuild === 'all') {
      for (const entry of current.values()) {
        logger.info(`+ ${entry.name} ${entry.size}kb`);
      }
    } else {
      logger.info(`Tracking ${current.size} chunks for change detection.`);
    }
  }
}

module.exports = DiffChangedChunksPlugin;
```

## Usage

```js
new DiffChangedChunksPlugin({ minBytes: 1024 })
```

Sample output across a watch-mode session:

```text
[DiffChangedChunksPlugin] Tracking 213 chunks for change detection.

# After editing src/checkout/form.tsx
[DiffChangedChunksPlugin] ~ checkout 67.2kb (+0.3kb)
[DiffChangedChunksPlugin] ~ main    142.4kb (+0.1kb)   # via runtime/module ID changes

# After upgrading lodash
[DiffChangedChunksPlugin] ~ vendors 412.8kb (+32.1kb)
[DiffChangedChunksPlugin] ~ main    142.3kb (-0.1kb)

# After deleting a page
[DiffChangedChunksPlugin] - blog-archive
[DiffChangedChunksPlugin] ~ main    141.9kb (-0.4kb)
```

## How it works

- **`chunk.contentHash.javascript`** is the canonical "did this chunk's content change?" indicator — not `chunk.hash`, which can change for unrelated reasons. The official [`webpack-plugin-authoring`] companion is the [Plugin Patterns guide](https://webpack.js.org/contribute/plugin-patterns/#detecting-changed-chunks).
- **`chunk.id ?? chunk.name`** as the tracking key — `id` is stable across builds with `optimization.chunkIds: 'deterministic'`; falls back to `name` for unnamed chunks
- **Comparing on a SEPARATE in-memory map** (`this.previous`) — across rebuilds within a single watch session. Survives a single dev-server session but not server restarts (which is fine: each session has its own baseline)
- **`info.size` first, `source.size()` fallback** — avoids materializing the source just to count bytes. See [`webpack-plugin-authoring/perf-avoid-source-toString-in-hot-paths`].
- **Mutable instance state EXPLICITLY for cross-build comparison** is the one legitimate use of mutable instance state per [`webpack-plugin-authoring/life-no-mutable-state-across-builds`] — note the "intentional cross-build state" pattern there

## Variations

- **Filter by chunk type** (only show initial chunks, ignore async):
  ```js
  if (!chunk.canBeInitial()) continue;
  ```
- **Markdown table output** for CI logs:
  ```js
  logger.info('| Chunk | Size | Δ |\n|---|---|---|\n' + changedRows.join('\n'));
  ```
- **Sort by delta magnitude** (biggest changes first)
- **Include module-level diff** (which modules MOVED chunks): inspect `chunkGraph.getChunkModules(chunk)` before/after

## When NOT to use this pattern

- You only do single-shot builds (no `--watch`) — every chunk is "new"; the diff is meaningless
- You already use [webpack-bundle-analyzer](https://github.com/webpack-contrib/webpack-bundle-analyzer) in `--mode=development` — duplicative
- You have chunk count under 5 — `--stats=detailed` is fine

Reference: [Plugin Patterns — Detecting Changed Chunks](https://webpack.js.org/contribute/plugin-patterns/#detecting-changed-chunks) · [chunk.contentHash](https://webpack.js.org/api/compilation-object/#chunks)
