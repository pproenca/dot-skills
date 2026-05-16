---
title: Report Progress via context.reportProgress
impact: MEDIUM-HIGH
impactDescription: prevents a frozen progress bar during 10-60s plugin work
tags: diag, progress, ProgressPlugin, reportProgress
---

## Report Progress via context.reportProgress

`webpack --progress` shows a progress bar that only counts events from plugins which opt into the progress API. A long-running asset processor that doesn't report progress appears as a frozen bar at 90% for 30 seconds; with progress reporting, the user sees `[CompressPlugin] 142/200 files`. Opt-in is a single hook option (`context: true`) plus calling `context.reportProgress(fraction, message)` at meaningful intervals.

**Incorrect (no progress reporting — user sees frozen bar during slow work):**

```js
compilation.hooks.processAssets.tapPromise(
  { name: 'CompressPlugin', stage: Compilation.PROCESS_ASSETS_STAGE_OPTIMIZE_TRANSFER },
  async (assets) => {
    const files = Object.keys(assets).filter((n) => n.endsWith('.js'));
    for (const name of files) {
      await compressOne(name);  // 200ms each × 100 files = 20s frozen
    }
  },
);
```

**Correct (context: true + reportProgress):**

```js
compilation.hooks.processAssets.tapPromise(
  {
    name: 'CompressPlugin',
    stage: Compilation.PROCESS_ASSETS_STAGE_OPTIMIZE_TRANSFER,
    context: true,                       // enables reportProgress
  },
  async (context, assets) => {
    const reportProgress = context?.reportProgress;
    const files = Object.keys(assets).filter((n) => n.endsWith('.js'));

    for (let i = 0; i < files.length; i++) {
      const name = files[i];
      reportProgress?.(i / files.length, name);  // fraction, message
      await compressOne(name);
    }
    reportProgress?.(1, 'done');
  },
);
```

**reportProgress signature:**

```ts
reportProgress(percentage: number, message: string, ...args: string[]): void
```

- `percentage` is 0..1 within the current hook's slice of overall progress
- `message` becomes the right-hand text after the progress bar
- Extra args appended as detail (shown with `--profile`)

**Note the signature change** when `context: true`: the handler receives `(context, ...originalArgs)`. The `context` is `{ reportProgress }` — extract `reportProgress` once and use it throughout.

**Don't call reportProgress on every iteration in a tight loop** — it forces a redraw and can dominate the work it's reporting on. Throttle to every Nth iteration or every Xms.

**Standard progress message format webpack-cli renders nicely:**

```js
reportProgress(i / total, 'compress', name);
// Renders: ◜ [CompressPlugin] compress 142/200 (assets/foo.js)
```

webpack groups progress events by plugin name and the first message keyword.

**ProgressPlugin compat:** `webpack.ProgressPlugin` (the bundled progress reporter) renders these reports. If the user has set up a custom progress handler via `new webpack.ProgressPlugin(handler)`, they receive the same events with the percentage already mapped to global build progress.

Reference: [ProgressPlugin](https://webpack.js.org/plugins/progress-plugin/) · [Plugin API — context: true](https://webpack.js.org/api/plugins/#context-parameter)
