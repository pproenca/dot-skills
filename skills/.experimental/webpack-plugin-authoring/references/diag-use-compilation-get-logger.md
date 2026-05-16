---
title: Log via compilation.getLogger, Not console
impact: MEDIUM-HIGH
impactDescription: prevents log spam and integrates with stats filtering
tags: diag, logger, stats, infrastructure-log
---

## Log via compilation.getLogger, Not console

`console.log` from a plugin shows up unconditionally — in every CI log, in every IDE webpack output panel, even when the user passes `stats: 'errors-only'`. `compilation.getLogger('PluginName')` returns a logger that participates in webpack's stats output, respects `infrastructureLogging.level`, and lets users filter via `stats.logging`. The same plugin's logs can be silent in CI and verbose in `--verbose` mode without code changes.

**Incorrect (console.log — always prints, breaks `stats: 'errors-only'`):**

```js
compiler.hooks.done.tap('CompressPlugin', (stats) => {
  console.log(`[CompressPlugin] Compressed ${this.options.algorithm}`);
  console.log(`[CompressPlugin] ${stats.compilation.assets.length} assets processed`);
  // Pollutes every webpack log line, can't be suppressed without forking the plugin
});
```

**Correct (getLogger — respects user's logging level):**

```js
compiler.hooks.thisCompilation.tap('CompressPlugin', (compilation) => {
  const logger = compilation.getLogger('CompressPlugin');

  compilation.hooks.processAssets.tapPromise(/* ... */, async (assets) => {
    logger.time('compress');                 // start timing
    logger.info(`Compressing with ${this.options.algorithm}`);
    logger.debug(`Threshold: ${this.options.threshold} bytes`);

    for (const name of Object.keys(assets)) {
      logger.log(`  - ${name}`);             // visible only with verbose stats
    }

    await compressAll(assets);

    logger.timeEnd('compress');              // emits time-elapsed log entry
  });
});
```

**Log levels (from quietest to loudest):**

| Method | Level | When user sees |
|---|---|---|
| `.error(msg)` | error | Always (becomes compilation.errors entry in stats) |
| `.warn(msg)` | warn | Always (becomes compilation.warnings) |
| `.info(msg)` | info | Default and above |
| `.log(msg)` | log | `stats.logging: 'log'` and above |
| `.debug(msg)` | debug | `stats.logging: 'verbose'` |
| `.trace()` | verbose | `stats.logging: 'verbose'` |

**Time/group methods integrate with `stats.loggingDebug`:**

```js
logger.time('parse');       // logger.timeEnd('parse') logs elapsed
logger.group('Validation'); // logger.groupEnd() closes
logger.profile('build');    // logger.profileEnd() emits profiler marker
```

**Infrastructure logger vs compilation logger:**

| Logger | Use for | Lives on |
|---|---|---|
| `compilation.getLogger(name)` | Per-compilation events (asset processing, module-related logs) | Stats output, dev-server overlay |
| `compiler.getInfrastructureLogger(name)` | Setup/teardown logs, watcher events, cross-build notes | Stdout — respects `infrastructureLogging.level` |

Use infrastructure logger for things that happen ONCE per compiler, not per compilation: "Worker pool initialized", "Found 5 entry points", "Cache loaded from disk".

**Suppress logging by default in published plugins:** Production plugins log at `.debug()` level — users opt in via `stats: { loggingDebug: [/PluginName/] }`. This is the convention `mini-css-extract-plugin`, `terser-webpack-plugin`, and `compression-webpack-plugin` all follow.

Reference: [Logger API](https://webpack.js.org/api/logging/) · [stats.logging configuration](https://webpack.js.org/configuration/stats/#statslogging)
