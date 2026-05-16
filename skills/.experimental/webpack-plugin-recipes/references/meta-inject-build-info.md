---
title: Inject Build Info (Commit Hash, Build Time) Into Source Code
impact: HIGH
impactDescription: enables runtime identification of which build is deployed
tags: meta, build-info, git, version, define-plugin
---

## Inject Build Info (Commit Hash, Build Time) Into Source Code

## Problem

A production bug report says "I clicked Save and nothing happened." Was that user running v1.4.2 (deployed Tuesday) or v1.4.3-hotfix (deployed Thursday)? Sentry shows the error but not the build. Your CDN serves multiple builds during canary rollouts, so URL doesn't tell you. You need every emitted bundle to know its OWN identity — git commit SHA, build timestamp, branch, CI run number — and expose them at runtime so the error reporter can attach them and the user-facing footer can display `v1.4.3-hotfix (a7f8c92)`.

`DefinePlugin` substitutes at build time but requires you to compute the values yourself in `webpack.config.js`, scattering git-shell-out logic across every project. A plugin centralizes the collection AND emits a `build-info.json` alongside the bundle for tools that read it server-side.

## Pattern

In the constructor, collect git/CI info synchronously (it's needed for cache-key correctness — see "How it works"). In `apply`, compose `DefinePlugin` to substitute the values into source, and tap `processAssets` at `PROCESS_ASSETS_STAGE_ADDITIONAL` to emit a `build-info.json` asset for server consumption.

**Incorrect (without a plugin — DefinePlugin set up by hand in every project):**

```js
// webpack.config.js — copy-pasted into every project, drifts independently
const { execSync } = require('child_process');
const commit = execSync('git rev-parse HEAD').toString().trim();  // throws if no git
const buildTime = new Date().toISOString();

module.exports = {
  plugins: [
    new webpack.DefinePlugin({
      __COMMIT__: JSON.stringify(commit),
      __BUILD_TIME__: JSON.stringify(buildTime),
      // No build-info.json emitted — SSR server can't read git info at runtime
      // No buildDependencies entry — persistent cache reuses across commits
    }),
  ],
};
```

**Correct (with this plugin — centralized collection + DefinePlugin + manifest + cache-correct):**

```js
const { execSync } = require('node:child_process');
const { validate } = require('schema-utils');

const schema = {
  type: 'object',
  properties: {
    filename: { type: 'string' },
    keys: {
      type: 'object',
      additionalProperties: { type: 'string' },
      description: 'Custom mapping of __KEY__ → value (overrides defaults)',
    },
    emitJson: { type: 'boolean', description: 'Emit build-info.json alongside bundle' },
  },
  additionalProperties: false,
};

class BuildInfoPlugin {
  constructor(options = {}) {
    validate(schema, options, { name: 'BuildInfoPlugin', baseDataPath: 'options' });

    // Collect once at construction — same values across all compilations of THIS process
    this.info = this.collect();
    Object.assign(this.info, options.keys ?? {});
    this.filename = options.filename ?? 'build-info.json';
    this.emitJson = options.emitJson ?? true;
  }

  collect() {
    const git = (cmd, fallback = '') => {
      try { return execSync(cmd, { stdio: ['ignore', 'pipe', 'ignore'] }).toString().trim(); }
      catch { return fallback; }
    };

    return {
      commit: git('git rev-parse HEAD', process.env.GIT_COMMIT ?? 'unknown'),
      shortCommit: git('git rev-parse --short HEAD', (process.env.GIT_COMMIT ?? '').slice(0, 7) || 'unknown'),
      branch: git('git rev-parse --abbrev-ref HEAD', process.env.GIT_BRANCH ?? 'unknown'),
      tag: git('git describe --tags --abbrev=0', ''),
      buildTime: new Date().toISOString(),
      buildId:
        process.env.GITHUB_RUN_ID
        ?? process.env.CIRCLE_BUILD_NUM
        ?? process.env.BUILDKITE_BUILD_NUMBER
        ?? `local-${Date.now()}`,
      nodeEnv: process.env.NODE_ENV ?? 'development',
    };
  }

  apply(compiler) {
    const { DefinePlugin, sources, Compilation } = compiler.webpack;

    // Substitute __BUILD_INFO__.X references in source
    const defines = Object.fromEntries(
      Object.entries(this.info).map(([k, v]) => [
        `__BUILD_INFO__.${k}`,
        JSON.stringify(v),
      ]),
    );
    defines.__BUILD_INFO__ = JSON.stringify(this.info);
    new DefinePlugin(defines).apply(compiler);

    if (!this.emitJson) return;

    compiler.hooks.thisCompilation.tap('BuildInfoPlugin', (compilation) => {
      compilation.hooks.processAssets.tap(
        {
          name: 'BuildInfoPlugin',
          // ADDITIONAL is for emitting brand-new assets, runs early
          stage: Compilation.PROCESS_ASSETS_STAGE_ADDITIONAL,
        },
        () => {
          const json = JSON.stringify(this.info, null, 2);
          compilation.emitAsset(
            this.filename,
            new sources.RawSource(json),
            { immutable: false, development: false },
          );
        },
      );

      // Make the build-info contribute to the build's persistent-cache key —
      // changes in build info should invalidate cache, otherwise rebuilds
      // could reuse a cache from a different commit
      compiler.hooks.beforeCompile.tap('BuildInfoPlugin', (params) => {
        params.buildDependencies = params.buildDependencies ?? new Set();
        // The .git/HEAD file changes on commit/checkout
        params.buildDependencies.add(path.join(compiler.context, '.git/HEAD'));
      });
    });
  }
}

module.exports = BuildInfoPlugin;
```

## Usage

In source code:

```js
// app/Footer.tsx
import { __BUILD_INFO__ } from 'virtual:build-info';  // or just use __BUILD_INFO__ directly

export function Footer() {
  return <footer>v{__BUILD_INFO__.tag} ({__BUILD_INFO__.shortCommit})</footer>;
}

// app/error-reporter.ts
import * as Sentry from '@sentry/react';
Sentry.init({
  release: __BUILD_INFO__.commit,
  environment: __BUILD_INFO__.nodeEnv,
});
```

In `webpack.config.js`:

```js
plugins: [new BuildInfoPlugin({ filename: 'build-info.json' })]
```

For TypeScript users, declare the global:

```ts
// build-info.d.ts
declare const __BUILD_INFO__: {
  commit: string;
  shortCommit: string;
  branch: string;
  tag: string;
  buildTime: string;
  buildId: string;
  nodeEnv: string;
};
```

## How it works

- **Collection in constructor, not `apply`** — same values for all compilations in this process. Git status doesn't change mid-build. See [`webpack-plugin-authoring/life-constructor-stores-options-only`] for the general rule; this is a narrow exception because the collected values are deterministic and cheap.
- **`DefinePlugin` composition** instead of asking users to wire it: the plugin owns both halves (collection + substitution) so users get one API.
- **`PROCESS_ASSETS_STAGE_ADDITIONAL`** is the correct stage for emitting brand-new assets — runs before optimization stages that might re-hash content. See [`webpack-plugin-authoring/hook-process-assets-stage`].
- **`buildDependencies.add('.git/HEAD')`** is the persistent-cache fix — without it, a cache from commit A serves builds at commit B, and the embedded commit hash is wrong. See [`webpack-plugin-authoring/cache-build-dependencies-for-persistent-cache`].

## Variations

- **Add CI-specific values** (`process.env.VERCEL_GIT_COMMIT_REF`, `process.env.NETLIFY_BUILD_ID`)
- **Emit as ESM virtual module** instead of JSON (combine with `virtual-module-from-memory` recipe)
- **Include dependency hash** for reproducibility audits: `shasum package-lock.json`
- **Per-locale or per-target** build info: shape the keys map per call
- **Server-only** vars: skip `DefinePlugin` (just emit JSON for the server to read) when bundling for Node

## When NOT to use this pattern

- Your framework already does this (Next.js exposes `NEXT_PUBLIC_VERCEL_GIT_COMMIT_SHA`, Nuxt exposes `useRuntimeConfig().buildInfo`)
- Your build runs OUTSIDE a git checkout (CI clones with `--depth=1` and discards .git, or you're building in a Docker layer without git) — fall back to env vars provided by the CI system
- You're not OK with `execSync` on every webpack startup (it's cheap — usually <50ms — but if you instantiate the plugin in a hot loop, it adds up)

Reference: [DefinePlugin](https://webpack.js.org/plugins/define-plugin/) · [Sentry release tracking](https://docs.sentry.io/platforms/javascript/configuration/releases/) · [Vercel build env vars](https://vercel.com/docs/projects/environment-variables/system-environment-variables)
