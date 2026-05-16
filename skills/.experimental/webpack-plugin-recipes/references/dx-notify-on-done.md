---
title: Send Desktop / Slack Notification on Build Done
impact: MEDIUM
impactDescription: prevents wasted time switching to terminal to check build status
tags: dx, notification, slack, desktop, watch-mode
---

## Send Desktop / Slack Notification on Build Done

## Problem

You're in your editor, you save a file, watch-mode kicks off — and now you wait. Did it finish? Did it fail? Switching to the terminal to check breaks flow. After several rebuilds in a session, the cumulative "did it finish?" tax is 10–20 seconds × 50 rebuilds/day. Same problem in CI: a 10-minute deploy build that you forget about, then context-switch back to in 30 minutes.

You want a notification — desktop notification for local watch mode, Slack message for CI builds — that fires on build completion (success OR failure), with enough detail to act: "Build failed: 3 errors in src/checkout.ts". Both [`webpack-notifier`](https://github.com/Turbo87/webpack-notifier) and Slack integrations exist separately; this recipe is one plugin that does both based on environment detection.

## Pattern

In `compiler.hooks.done`, build a result object (success/failure, error count, duration), then dispatch to one of several configured destinations. Local sends via `node-notifier`; CI sends via webhook POST (fetch is available without dep in Node 18+).

**Incorrect (without a plugin — `npm-watch` or shell scripts):**

```bash
# package.json
"scripts": {
  "watch": "webpack --watch && say 'Build done'"
}
# `&&` only fires on success — failures go silent
# `say` is macOS-only
# No content — just "done" with no detail
```

**Correct (with this plugin — desktop + Slack with full detail):**

```js
const { validate } = require('schema-utils');

const schema = {
  type: 'object',
  properties: {
    desktop: { type: 'boolean' },
    slackWebhook: { type: 'string', pattern: '^https://' },
    title: { type: 'string' },
    onSuccess: { enum: ['always', 'never', 'after-failure'] },
    onFailure: { type: 'boolean' },
    minDurationMs: { type: 'number', description: 'Skip notification for builds faster than this' },
  },
  additionalProperties: false,
};

const DEFAULTS = {
  desktop: process.env.CI !== 'true',
  title: 'webpack',
  onSuccess: 'after-failure',
  onFailure: true,
  minDurationMs: 3000,
};

class NotifyOnDonePlugin {
  constructor(options = {}) {
    validate(schema, options, { name: 'NotifyOnDonePlugin', baseDataPath: 'options' });
    this.options = { ...DEFAULTS, ...options };
    this.previousHadErrors = false;
  }

  apply(compiler) {
    let startedAt = null;
    compiler.hooks.beforeRun.tap('NotifyOnDonePlugin', () => { startedAt = Date.now(); });
    compiler.hooks.watchRun.tap('NotifyOnDonePlugin', () => { startedAt = Date.now(); });

    compiler.hooks.done.tapPromise('NotifyOnDonePlugin', async (stats) => {
      const elapsed = startedAt ? Date.now() - startedAt : 0;
      const hadErrors = stats.hasErrors();
      const hadWarnings = stats.hasWarnings();

      const shouldNotify = this.shouldNotify(hadErrors, elapsed);
      this.previousHadErrors = hadErrors;
      if (!shouldNotify) return;

      const summary = this.buildSummary(stats, elapsed, hadErrors, hadWarnings);

      await Promise.all([
        this.options.desktop ? this.notifyDesktop(summary, hadErrors) : null,
        this.options.slackWebhook ? this.notifySlack(summary, hadErrors) : null,
      ].filter(Boolean));
    });
  }

  shouldNotify(hadErrors, elapsed) {
    if (elapsed < this.options.minDurationMs && !hadErrors) return false; // skip fast green builds
    if (hadErrors) return this.options.onFailure;
    if (this.options.onSuccess === 'never') return false;
    if (this.options.onSuccess === 'after-failure') return this.previousHadErrors;
    return true; // 'always'
  }

  buildSummary(stats, elapsed, hadErrors, hadWarnings) {
    const errCount = stats.compilation.errors.length;
    const warnCount = stats.compilation.warnings.length;
    const fmt = (ms) => `${(ms / 1000).toFixed(1)}s`;

    if (hadErrors) {
      const first = stats.compilation.errors[0]?.message?.split('\n')[0] ?? 'unknown error';
      return {
        title: `${this.options.title}: build failed`,
        body: `${errCount} error${errCount > 1 ? 's' : ''} in ${fmt(elapsed)}\n${first}`,
        ok: false,
      };
    }
    return {
      title: `${this.options.title}: build succeeded`,
      body: hadWarnings
        ? `${fmt(elapsed)} (${warnCount} warning${warnCount > 1 ? 's' : ''})`
        : `${fmt(elapsed)}`,
      ok: true,
    };
  }

  async notifyDesktop(summary, isError) {
    try {
      const notifier = require('node-notifier');
      notifier.notify({
        title: summary.title,
        message: summary.body,
        sound: isError,
        wait: false,
      });
    } catch {
      // node-notifier not installed — fall back to terminal bell
      process.stdout.write('');
    }
  }

  async notifySlack(summary, isError) {
    const color = isError ? '#dc3545' : '#28a745';
    const payload = {
      attachments: [{
        color,
        title: summary.title,
        text: summary.body,
        ts: Math.floor(Date.now() / 1000),
        footer: process.env.GITHUB_REPOSITORY ?? 'webpack build',
      }],
    };
    try {
      await fetch(this.options.slackWebhook, {
        method: 'POST',
        headers: { 'content-type': 'application/json' },
        body: JSON.stringify(payload),
      });
    } catch (e) {
      // Don't fail the build because notification failed
      console.warn(`[NotifyOnDonePlugin] Slack post failed: ${e.message}`);
    }
  }
}

module.exports = NotifyOnDonePlugin;
```

## Usage

```js
new NotifyOnDonePlugin({
  desktop: process.env.CI !== 'true',
  slackWebhook: process.env.SLACK_BUILD_WEBHOOK,  // CI only
  title: 'my-app',
  onSuccess: 'after-failure',  // notify when build recovers; skip every-success spam
  minDurationMs: 3000,         // don't notify for 500ms watch rebuilds
})
```

## How it works

- **`done.tapPromise`** is async — Slack POST takes time we should respect, otherwise the next build can start while the notification is in-flight and skew error attribution
- **`onSuccess: 'after-failure'`** — the most useful default: notify on failures + notify when the build RECOVERS from a failure. Saves notification fatigue.
- **`minDurationMs: 3000`** — skip notifications for fast rebuilds (under 3s, you didn't have time to context-switch anyway). Failed builds always notify.
- **`require('node-notifier')` in a try/catch** — optional peer dep; degrades to terminal bell if not installed. Don't fail the build just because the user hasn't installed the optional dep.
- **`fetch` is native in Node 18+** — no `axios`/`node-fetch` dep needed; same API works in CI environments
- **Catch Slack errors silently** — a flaky webhook shouldn't break the build (only log)

## Variations

- **Webhook formats other than Slack** (Discord, Mattermost, MS Teams): take a `format: 'slack' | 'discord' | 'teams'` option and emit the right payload shape
- **Group rapid rebuilds** (debounce within 1s window): keep last notify timestamp, suppress if too recent
- **Per-environment notification** (only failures in CI, all builds in dev): conditional `onSuccess`
- **Sound only on regression** (combine with `dx-build-duration-report`): only `sound: true` when build was slower than median

## When NOT to use this pattern

- You already have CI status notifications in Slack via GitHub/CircleCI/etc — duplicates
- Your team uses email-only notifications (corporate IT) — different transport
- Builds are so fast (under 1s consistently) the notification overhead dwarfs the build

Reference: [node-notifier](https://github.com/mikaelbr/node-notifier) · [Slack incoming webhooks](https://api.slack.com/messaging/webhooks) · [webpack-notifier](https://github.com/Turbo87/webpack-notifier)
