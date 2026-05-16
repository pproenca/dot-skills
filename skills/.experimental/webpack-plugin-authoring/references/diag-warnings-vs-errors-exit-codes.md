---
title: Choose Errors for Build Failures, Warnings for Quality Notices
impact: MEDIUM-HIGH
impactDescription: prevents CI surprises (silent pass / false fail)
tags: diag, warnings, errors, ci, exit-code
---

## Choose Errors for Build Failures, Warnings for Quality Notices

`compilation.errors` makes the build fail (exit code 1, CI red); `compilation.warnings` does not (exit code 0, CI green). Plugins routinely get this backwards: a "missing dependency" message pushed to `warnings` lets a broken build pass CI silently, while a "deprecated option" notice pushed to `errors` fails CI for an issue users could have ignored. The decision is binary and consequential — make it explicitly per call site.

**Incorrect (everything goes to warnings — broken builds pass CI):**

```js
compilation.hooks.processAssets.tap(/* ... */, (assets) => {
  if (!assets['manifest.json']) {
    // Missing manifest is a build failure — but we pushed it to warnings
    compilation.warnings.push(new WebpackError('manifest.json was not generated'));
  }
  if (this.options.legacy) {
    // Truly a warning, correctly placed
    compilation.warnings.push(new WebpackError('legacy: true is deprecated'));
  }
});
// CI runs `webpack --mode=production` — exits 0. Manifest missing in prod.
```

**Correct (errors fail the build; warnings inform):**

```js
compilation.hooks.processAssets.tap(/* ... */, (assets) => {
  const { WebpackError } = compiler.webpack;

  if (!assets['manifest.json']) {
    // Build cannot proceed — this is an error
    compilation.errors.push(new WebpackError(
      '[ManifestPlugin] manifest.json was not generated. ' +
      'Check that at least one entry produces an asset.',
    ));
  }
  if (this.options.legacy) {
    // Build works, but user should migrate — this is a warning
    compilation.warnings.push(new WebpackError(
      '[ManifestPlugin] legacy: true is deprecated; will be removed in v3.',
    ));
  }
});
```

**Decision matrix:**

| Symptom | errors or warnings? |
|---|---|
| Build output is wrong / missing | **errors** |
| User passed an option that won't work | **errors** (during validate or beforeRun) |
| User passed a deprecated option that still works | **warnings** |
| External tool produced something we couldn't process | **errors** |
| Optimization opportunity skipped (e.g., file too big) | **warnings** |
| Plugin couldn't find an OPTIONAL file | **warnings** |
| Plugin couldn't find a REQUIRED file | **errors** |
| User's code triggered a runtime issue (e.g., circular dep) | depends on `output.strictModuleErrorHandling` — usually errors |

**Webpack CLI flags users may set:**

- `--no-stats-warnings` — hide warnings from stats output (still exit 0)
- `--fail-on-warnings` (added in 5.78) — turn warnings into exit code 1 in CI
- `stats: { warningsFilter: [/regex/] }` — suppress specific warnings

Pushing to `warnings` doesn't mean the user will see it — they may filter it out. Pushing to `errors` always surfaces.

**Don't downgrade errors to warnings to silence CI.** If a user reports false-positive CI failures, the fix is to make the check more precise (better detection logic, more targeted condition), not to demote the severity. Demoted errors silently regress builds later.

**Per-mode severity is fine:**

```js
const severity = compiler.options.mode === 'production' ? 'errors' : 'warnings';
compilation[severity].push(new WebpackError('External CSS not minified'));
```

CSS not being minified is fatal in production but acceptable in dev.

Reference: [stats configuration](https://webpack.js.org/configuration/stats/) · [CLI flags — fail-on-warnings](https://webpack.js.org/api/cli/)
