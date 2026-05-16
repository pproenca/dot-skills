---
title: Install addons with `npx storybook add` instead of hand-editing
impact: CRITICAL
impactDescription: prevents missing peer-dependency installs and broken registration
tags: config, addons, cli, dependencies
---

## Install addons with `npx storybook add` instead of hand-editing

`npx storybook add <addon>` does three things hand-editing forgets: installs the package at the correct version pinned to your Storybook version, registers it in `main.ts` in the right position relative to other addons, and runs the addon's post-install setup (e.g. `addon-vitest` writes a `vitest.workspace.ts`, `addon-a11y` adds preview parameters). Manually editing `main.ts` and running `npm install` skips the post-install step and produces an addon that's installed but invisible.

**Incorrect (manual edit — version drift and missing post-install):**

```bash
# Pick a version off the top of your head
npm install --save-dev @storybook/addon-vitest@latest
```

```ts
// .storybook/main.ts — added by hand, post-install never runs
const config = {
  addons: [
    '@storybook/addon-docs',
    '@storybook/addon-vitest', // registered but vitest.workspace.ts missing
  ],
} satisfies StorybookConfig;
```

**Correct (CLI handles version pinning + post-install):**

```bash
npx storybook add @storybook/addon-vitest
# Installs at the version matching your Storybook
# Adds the entry to main.ts addons array
# Generates vitest.workspace.ts and updates package.json scripts
```

**When NOT to use this pattern:**
- Adding a private/internal addon not on npm — register it in `main.ts` with the absolute path, then handle its setup manually.

**Why this matters:** Storybook's addon ecosystem assumes versions march in lockstep with the core. An `addon-a11y@8` against `storybook@10` boots without errors but misses the new `parameters.a11y.test` API. The CLI is the upgrade path.

Reference: [Storybook addons: install](https://storybook.js.org/docs/addons/install-addons)
