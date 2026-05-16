---
title: Open the Browser on the First Successful Dev Build
impact: MEDIUM
impactDescription: prevents 3-5s manual context switch on every dev-server start
tags: dx, dev-server, browser, watch-mode
---

## Open the Browser on the First Successful Dev Build

## Problem

You run `npm run dev`, wait 8 seconds for the dev-server to boot, switch to the browser, type `localhost:3000`, refresh. Multiply by 30 dev-server starts per day per developer per team — significant time spent on the same context switch. `webpack-dev-server --open` exists but opens the browser BEFORE the build completes, so you see `Cannot GET /` for 5 seconds while the first compile runs. `vite` opens AFTER first compile, which is what you want; webpack should do the same.

Also, the developer who's actively working may NOT want a new browser tab opened on every server restart (they have their existing tab refreshing via HMR). You want "open on first build only — not on rebuilds, not on every restart unless explicitly requested."

## Pattern

In `compiler.hooks.done` (which fires after first successful build), check a flag indicating we haven't yet opened, derive the URL from `webpack-dev-server`'s config (or accept it as plugin option), shell out to the OS-appropriate "open URL" command. Skip on errors. After first success, set the flag so subsequent rebuilds don't reopen.

**Incorrect (without a plugin — `webpack-dev-server --open`):**

```bash
$ npx webpack serve --open
# Opens http://localhost:3000 IMMEDIATELY (before compile finishes)
# Browser shows "Cannot GET /" for the first 5s
# When build completes, page doesn't auto-refresh (refresh is HMR for changes,
# not for the initial 404 → success transition)
# User manually refreshes anyway.
```

**Correct (with this plugin — opens AFTER first successful build):**

```js
const { exec } = require('node:child_process');
const { validate } = require('schema-utils');

const schema = {
  type: 'object',
  properties: {
    url: { type: 'string' },
    target: {
      enum: ['default', 'firefox', 'chrome', 'safari'],
      description: 'Open in this browser (uses OS default if not specified)',
    },
    skipIfCi: { type: 'boolean' },
    onlyOnFirstStart: { type: 'boolean' },
  },
  additionalProperties: false,
};

const DEFAULTS = { target: 'default', skipIfCi: true, onlyOnFirstStart: true };

class OpenBrowserPlugin {
  constructor(options = {}) {
    validate(schema, options, { name: 'OpenBrowserPlugin', baseDataPath: 'options' });
    this.options = { ...DEFAULTS, ...options };
    this.opened = false;
  }

  apply(compiler) {
    if (this.options.skipIfCi && process.env.CI === 'true') return;

    compiler.hooks.done.tap('OpenBrowserPlugin', (stats) => {
      if (stats.hasErrors()) return;                              // wait until first GREEN build
      if (this.options.onlyOnFirstStart && this.opened) return;    // already opened this session
      this.opened = true;

      const url = this.resolveUrl(compiler);
      if (!url) {
        compiler.getInfrastructureLogger('OpenBrowserPlugin').warn(
          'Could not determine dev-server URL; configure { url: "..." } explicitly.',
        );
        return;
      }

      this.openUrl(url, compiler);
    });
  }

  resolveUrl(compiler) {
    if (this.options.url) return this.options.url;
    // Try to read from devServer config (works in webpack 5)
    const ds = compiler.options.devServer;
    if (!ds) return null;
    const proto = ds.server === 'https' || ds.https ? 'https' : 'http';
    const host = ds.host && ds.host !== '0.0.0.0' ? ds.host : 'localhost';
    const port = ds.port ?? 8080;
    const base = typeof ds.devMiddleware?.publicPath === 'string' ? ds.devMiddleware.publicPath : '';
    return `${proto}://${host}:${port}${base}`;
  }

  openUrl(url, compiler) {
    const logger = compiler.getInfrastructureLogger('OpenBrowserPlugin');
    const platform = process.platform;
    let command;

    if (this.options.target === 'default') {
      command =
        platform === 'darwin' ? `open "${url}"`
        : platform === 'win32' ? `start "" "${url}"`
        : `xdg-open "${url}"`;
    } else {
      // Specific browser
      const browserMap = {
        darwin: { firefox: 'open -a "Firefox"', chrome: 'open -a "Google Chrome"', safari: 'open -a "Safari"' },
        win32:  { firefox: 'start firefox', chrome: 'start chrome' },
        linux:  { firefox: 'firefox', chrome: 'google-chrome' },
      };
      const cmd = browserMap[platform]?.[this.options.target];
      if (!cmd) {
        logger.warn(`OpenBrowserPlugin: target "${this.options.target}" not supported on ${platform}`);
        return;
      }
      command = `${cmd} "${url}"`;
    }

    exec(command, (err) => {
      if (err) {
        logger.warn(`OpenBrowserPlugin: failed to open browser (${err.message})`);
      } else {
        logger.info(`Opened ${url}`);
      }
    });
  }
}

module.exports = OpenBrowserPlugin;
```

## Usage

```js
new OpenBrowserPlugin({
  // optional: explicit URL if devServer config doesn't have all pieces
  url: 'http://localhost:3000',
  skipIfCi: true,        // don't open during Docker builds
  onlyOnFirstStart: true, // don't reopen on every save
})
```

## How it works

- **`done` hook with `stats.hasErrors()` check** — first build often has compile errors; opening the browser then shows a broken state. Wait for the first GREEN build.
- **`this.opened` instance flag** — survives only the current process (not desirable to persist across server restarts; users want a fresh tab when restarting deliberately). This IS legitimate cross-build instance state, per [`webpack-plugin-authoring/life-no-mutable-state-across-builds`] — note the explicit single-purpose state pattern.
- **`compiler.getInfrastructureLogger`** for "ran a setup-time action" logs — these go to the infrastructure log, not the per-compilation log. See [`webpack-plugin-authoring/diag-use-compilation-get-logger`].
- **`exec` with error logging** — never throw from a "convenience" feature; opening the browser failing should not break the build
- **Platform-specific commands** — `open` (macOS), `start ""` (Windows; the empty title is required when path is quoted), `xdg-open` (Linux)
- **Skip in CI** — opening a browser in a headless Docker container hangs forever waiting for `xdg-open` to find a display

## Variations

- **Open multiple URLs** (the app + a debugging dashboard): take `urls: string[]`
- **Wait for the server to actually be listening** (not just compiled): use `await fetch(url)` in a retry loop before invoking `exec`
- **Open in a SPECIFIC tab** (reuse existing if open, otherwise new): use `open --new-window` flag pattern (macOS only, complex)
- **Profile-specific browser launch** (incognito, no extensions): expand command with browser-specific flags
- **Disable via env var** (so terminals like JetBrains' that auto-spawn webpack-dev-server don't trigger another tab): `if (process.env.NO_OPEN) return;`

## When NOT to use this pattern

- You use `webpack-dev-server --open` and live with the early-open behavior — works for many
- You use Vite, Next.js, or Rspack — all open AFTER first compile by default
- Your workflow is "always have one terminal + one browser side by side" — opening another tab is friction
- You develop in a container where the host can't access localhost the same way (use port forwarding + manual URL)

Reference: [webpack-dev-server open option](https://webpack.js.org/configuration/dev-server/#devserveropen) · [Vite open behavior](https://vite.dev/config/server-options.html#server-open)
