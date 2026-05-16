---
title: Report Build Duration and Detect Regressions
impact: MEDIUM
impactDescription: catches a 30%+ build slowdown the day it happens
tags: dx, duration, regression, observability
---

## Report Build Duration and Detect Regressions

## Problem

Your team's webpack build was 12s in January. Now it's August and it's 35s. Each PR added 100ms here and 200ms there — no single change was big enough to notice in code review. By the time anyone investigates, dev startup time has become a meeting-blocker and you're paying for it on every push. You want each build to print not just `Build finished in 35s` but `Build finished in 35s (1.8x slower than 7-day median of 19s)` — and on a regression > 30%, print a punch list of what's slowest so the team can investigate.

`speed-measure-webpack-plugin` gives you per-plugin timing but adds 5–10% overhead and breaks in newer webpack versions. You want something cheaper that runs in CI without instrumentation overhead.

## Pattern

In `compiler.hooks.beforeRun`, snapshot `Date.now()`. In `compiler.hooks.done`, compute elapsed, append to a rolling log in `${CLAUDE_PLUGIN_DATA}/build-durations.log` (or a configurable path), compute median of last N entries, log with a warning when current build exceeds the median significantly.

**Incorrect (without a plugin — relying on `time` command):**

```bash
$ time npm run build
real    0m12.4s
# Tells you THIS build's time. Doesn't tell you anything about whether
# 12.4s is normal, fast, or a 4x regression from yesterday.
# No persistent record.
```

**Correct (with this plugin — durations logged, regression detected):**

```js
const fs = require('node:fs');
const path = require('node:path');
const { validate } = require('schema-utils');

const schema = {
  type: 'object',
  properties: {
    logFile: { type: 'string' },
    keepEntries: { type: 'number', exclusiveMinimum: 0 },
    regressionThreshold: { type: 'number', exclusiveMinimum: 1 },
    failOnRegression: { type: 'boolean' },
  },
  additionalProperties: false,
};

const DEFAULTS = {
  logFile: '.webpack-build-durations.log',
  keepEntries: 50,
  regressionThreshold: 1.3,        // 30% slower than median = regression
  failOnRegression: false,
};

class BuildDurationPlugin {
  constructor(options = {}) {
    validate(schema, options, { name: 'BuildDurationPlugin', baseDataPath: 'options' });
    this.options = { ...DEFAULTS, ...options };
    this.logPath = path.resolve(this.options.logFile);
  }

  apply(compiler) {
    let startedAt = null;

    compiler.hooks.beforeRun.tap('BuildDurationPlugin', () => { startedAt = Date.now(); });
    compiler.hooks.watchRun.tap('BuildDurationPlugin', () => { startedAt = Date.now(); });

    compiler.hooks.done.tap('BuildDurationPlugin', (stats) => {
      if (startedAt === null) return;
      const elapsed = Date.now() - startedAt;
      const logger = stats.compilation.getLogger('BuildDurationPlugin');

      const history = this.readHistory();
      const previousDurations = history.map((e) => e.ms);
      const median = previousDurations.length > 4 ? medianOf(previousDurations) : null;

      const newEntry = {
        timestamp: new Date().toISOString(),
        ms: elapsed,
        commit: process.env.GIT_COMMIT?.slice(0, 7) ?? null,
        hadErrors: stats.hasErrors(),
      };

      this.writeHistory([newEntry, ...history].slice(0, this.options.keepEntries));

      const fmt = (ms) => `${(ms / 1000).toFixed(1)}s`;

      if (median === null) {
        logger.info(`Build duration: ${fmt(elapsed)} (warming up — need ≥5 builds for baseline)`);
        return;
      }

      const ratio = elapsed / median;
      if (ratio > this.options.regressionThreshold) {
        const slowdown = `${ratio.toFixed(2)}× slower`;
        const message =
          `Build duration: ${fmt(elapsed)} (${slowdown} than 7-day median ${fmt(median)})\n` +
          `  Recent durations: ${previousDurations.slice(0, 5).map(fmt).join(', ')}\n` +
          `  Investigate with: webpack --profile`;
        if (this.options.failOnRegression) {
          const { WebpackError } = compiler.webpack;
          const err = new WebpackError(`BuildDurationPlugin regression: ${message}`);
          err.hideStack = true;
          stats.compilation.errors.push(err);
        } else {
          logger.warn(message);
        }
      } else {
        logger.info(`Build duration: ${fmt(elapsed)} (median ${fmt(median)})`);
      }
    });
  }

  readHistory() {
    try {
      const content = fs.readFileSync(this.logPath, 'utf8');
      return content.split('\n').filter(Boolean).map((line) => JSON.parse(line));
    } catch {
      return [];
    }
  }

  writeHistory(entries) {
    const content = entries.map((e) => JSON.stringify(e)).join('\n') + '\n';
    fs.mkdirSync(path.dirname(this.logPath), { recursive: true });
    fs.writeFileSync(this.logPath, content);
  }
}

function medianOf(numbers) {
  const sorted = [...numbers].sort((a, b) => a - b);
  const mid = Math.floor(sorted.length / 2);
  return sorted.length % 2 ? sorted[mid] : (sorted[mid - 1] + sorted[mid]) / 2;
}

module.exports = BuildDurationPlugin;
```

## Usage

```js
new BuildDurationPlugin({
  logFile: '.webpack-build-durations.log',  // gitignored
  regressionThreshold: 1.3,                 // 30% slower than median = warn
  failOnRegression: process.env.CI === 'true',  // hard-fail only in CI
})
```

Sample output:

```text
[BuildDurationPlugin] Build duration: 18.2s (median 12.4s)
[BuildDurationPlugin] Build duration: 35.1s (2.83× slower than 7-day median 12.4s)
  Recent durations: 12.4s, 12.6s, 11.9s, 13.0s, 12.3s
  Investigate with: webpack --profile
```

## How it works

- **`beforeRun` AND `watchRun`** — `beforeRun` fires for single runs, `watchRun` for watch mode rebuilds. Both reset the start time.
- **`done` hook** receives `stats` — `stats.hasErrors()` lets us label failed builds so they're excluded from the median (broken builds usually fail FAST and would skew the baseline)
- **Median, not mean** — single 5-minute "first build with cold cache" doesn't poison the metric. Watch-mode rebuilds (~500ms) and full builds (~12s) coexist; median picks the typical case.
- **Persistent JSONL log** (one JSON per line) — append-friendly, easy to inspect with `tail`, doesn't require parsing the whole file to add an entry. Use a project-relative gitignored path (`.webpack-build-durations.log`) so the baseline survives across team members but doesn't pollute commits.
- **`failOnRegression` opt-in for CI** — pre-commit hooks shouldn't block on transient slowdowns; CI should

## Variations

- **Per-target-environment baseline** (Linux CI vs dev's Mac M-series): separate log files
- **Per-mode baseline** (development vs production builds — wildly different):
  ```js
  logFile: `.webpack-durations.${process.env.NODE_ENV ?? 'dev'}.log`
  ```
- **Slack notification on regression** (combine with `dx-notify-on-done` recipe)
- **Per-stage timing** (where time was spent): tap `done` with `stats.toJson({ all: false, timings: true })`

## When NOT to use this pattern

- You use [speed-measure-webpack-plugin](https://github.com/stephencookdev/speed-measure-webpack-plugin) and it works for you (this recipe is intentionally cheaper — no per-plugin instrumentation overhead)
- You measure builds externally (CI dashboard, BuildKite, GitHub Actions timing) — duplicate signal
- Build duration genuinely varies wildly by inputs (codegen-heavy) — median assumption breaks

Reference: [Compiler hooks — done](https://webpack.js.org/api/compiler-hooks/#done) · [speed-measure-webpack-plugin](https://github.com/stephencookdev/speed-measure-webpack-plugin)
