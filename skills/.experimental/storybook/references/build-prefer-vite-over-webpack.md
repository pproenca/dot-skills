---
title: Prefer Vite-based framework packages over Webpack
impact: MEDIUM
impactDescription: 5-10x faster cold start and HMR vs Webpack-based frameworks
tags: build, vite, webpack, performance
---

## Prefer Vite-based framework packages over Webpack

Vite-based Storybook frameworks (`@storybook/react-vite`, `@storybook/nextjs-vite`, `@storybook/sveltekit`, `@storybook/vue3-vite`) start in seconds, hot-reload in milliseconds, and produce smaller static builds. The Webpack-based packages (`@storybook/nextjs` (legacy), `@storybook/angular`) are still maintained but cold-start in tens of seconds and HMR is noticeably slower. For new projects pick the Vite variant; for existing Webpack projects, migration is usually one package swap and a `viteFinal` for any custom Webpack loaders that have a Vite equivalent.

**Incorrect (legacy Webpack-Next.js framework on a new project — slow start, slow HMR):**

```ts
// .storybook/main.ts
import type { StorybookConfig } from '@storybook/nextjs';

const config = {
  framework: '@storybook/nextjs', // Webpack — cold start ~30s on a medium project
  stories: ['../app/**/*.stories.@(ts|tsx)'],
  addons: ['@storybook/addon-docs'],
} satisfies StorybookConfig;
```

**Correct (Vite-Next.js framework — cold start ~3s, HMR <100ms):**

```ts
import type { StorybookConfig } from '@storybook/nextjs-vite';

const config = {
  framework: {
    name: '@storybook/nextjs-vite',
    options: { nextConfigPath: '../next.config.ts' },
  },
  stories: ['../app/**/*.stories.@(ts|tsx)'],
  addons: ['@storybook/addon-docs'],
} satisfies StorybookConfig;
```

**Migration path (Webpack → Vite):**

1. Swap the `framework` package: `npm uninstall @storybook/nextjs && npm install --save-dev @storybook/nextjs-vite`.
2. Update `main.ts` to point at the new package.
3. If you had `webpackFinal`, port the equivalents to `viteFinal` — most Webpack loaders have a Vite plugin (CSS modules, SVG-as-component, etc.).
4. Run `storybook dev` and verify each story still renders.

**When Webpack is still the right call:**
- Angular (the only first-party framework still Webpack-only).
- Custom enterprise Webpack config that has no Vite plugin equivalent (rare in 2025).

**Why this matters:** Cold-start time determines whether developers actually open Storybook. A 30-second start ends the "let me check this in Storybook" workflow; a 3-second start preserves it.

Reference: [Storybook frameworks](https://storybook.js.org/docs/get-started/install), [Vite builder](https://storybook.js.org/docs/builders/vite)
