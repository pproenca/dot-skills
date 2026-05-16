---
title: Push WebpackError to compilation.errors Instead of Throwing
impact: MEDIUM-HIGH
impactDescription: prevents one bad input from killing the whole build
tags: diag, WebpackError, compilation-errors, build-resilience
---

## Push WebpackError to compilation.errors Instead of Throwing

Throwing inside a tap aborts the entire compilation with a stack trace that points at webpack internals, not at the user's code. The correct surface for plugin-detected errors is `compilation.errors.push(new compiler.webpack.WebpackError(...))`: webpack continues processing other modules and assets, then exits with the full list at `done`. This is how `webpack --watch` keeps running through type errors, how the dev-server overlay knows what to display, and how Sentry-style error trackers receive structured input.

**Incorrect (throw aborts the build — one bad asset kills 999 good ones):**

```js
compilation.hooks.processAssets.tap(/* ... */, (assets) => {
  for (const name of Object.keys(assets)) {
    if (!name.endsWith('.json')) continue;
    try {
      JSON.parse(assets[name].source().toString());
    } catch (e) {
      // Throws here — compilation aborts, stack shows webpack internals,
      // dev-server overlay shows nothing meaningful
      throw new Error(`Invalid JSON in ${name}: ${e.message}`);
    }
  }
});
```

**Correct (collect, don't throw):**

```js
compilation.hooks.processAssets.tap(/* ... */, (assets) => {
  const { WebpackError } = compiler.webpack;

  for (const name of Object.keys(assets)) {
    if (!name.endsWith('.json')) continue;
    try {
      JSON.parse(assets[name].source().toString());
    } catch (e) {
      const err = new WebpackError(`Invalid JSON in ${name}: ${e.message}`);
      err.file = name;                  // dev-server overlay uses this
      err.details = e.stack;            // shown in `webpack --stats=detailed`
      compilation.errors.push(err);
    }
  }
});
```

**WebpackError vs warning:**

| Severity | Push to | Effect |
|---|---|---|
| Build failure (CI fails, exit code 1) | `compilation.errors` | Stats show errors, exit code 1 |
| Quality issue (notable but not blocking) | `compilation.warnings` | Stats show warnings, exit code 0, dev-server shows yellow |

**Useful properties to set on a WebpackError:**

| Property | Effect |
|---|---|
| `.file` | Filename the error is "about" (shown in stats and overlay) |
| `.module` | Reference to the `Module` instance (best when you have one) |
| `.loc` | `{ start: { line, column }, end: { line, column } }` for source highlighting |
| `.chunk` | Reference to the `Chunk` for chunk-level errors |
| `.details` | Long-form detail string shown by `--stats=detailed` |
| `.hideStack` | `true` to suppress webpack's stack trace addition |

**For module-related errors, use ModuleBuildError or ModuleParseError:**

```js
const { ModuleBuildError } = compiler.webpack;

compilation.errors.push(
  new ModuleBuildError(module, new Error('Parse failed'), { from: 'MyPlugin' }),
);
```

These integrate with `webpack-cli`'s output, the dev-server overlay's source-link feature, and IDE error decorations via `webpack-dev-server`'s WebSocket protocol.

**When throwing IS correct:** Truly unrecoverable errors that should kill the build immediately — e.g., the plugin's config file is malformed and there's no way to even start. In that case, throw in `apply()` or `beforeRun`, not deep inside a tap.

Reference: [Compilation API — errors](https://webpack.js.org/api/compilation-object/#errors) · [webpack/lib/WebpackError.js](https://github.com/webpack/webpack/blob/main/lib/WebpackError.js)
