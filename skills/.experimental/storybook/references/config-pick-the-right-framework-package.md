---
title: Pick the framework package that matches your build
impact: CRITICAL
impactDescription: prevents broken RSC, image optimization, and routing in stories
tags: config, framework, nextjs, vite
---

## Pick the framework package that matches your build

Storybook framework packages bundle the integrations a given build expects — `next/image`, RSC support, App Router mocks, SvelteKit `$app/*` aliases, Vue's compiler. Picking `@storybook/react-vite` for a Next.js app means `next/image` renders broken, `next/navigation` throws, and Server Components silently fall back to client rendering. Picking the right package is a one-time decision that determines whether stories accurately mirror production or quietly diverge.

**Incorrect (Next.js app using the generic React-Vite framework — `next/*` imports break):**

```ts
// .storybook/main.ts (Next.js project)
import type { StorybookConfig } from '@storybook/react-vite';

const config = {
  framework: '@storybook/react-vite', // wrong: no next/image, next/link, RSC
  stories: ['../app/**/*.stories.tsx'],
  addons: ['@storybook/addon-docs'],
} satisfies StorybookConfig;

export default config;
```

**Correct (Next.js framework package — Vite-powered, with `next/*` integrations):**

```ts
// .storybook/main.ts
import type { StorybookConfig } from '@storybook/nextjs-vite';

const config = {
  framework: {
    name: '@storybook/nextjs-vite',
    options: {
      nextConfigPath: '../next.config.ts',
    },
  },
  stories: ['../app/**/*.stories.@(ts|tsx)', '../components/**/*.stories.@(ts|tsx)'],
  addons: ['@storybook/addon-docs', '@storybook/addon-a11y'],
} satisfies StorybookConfig;

export default config;
```

**Common framework packages:**
- `@storybook/nextjs-vite` — Next.js (App Router, Vite builder) — preferred over the legacy Webpack `@storybook/nextjs`
- `@storybook/react-vite` — plain React + Vite
- `@storybook/sveltekit` — SvelteKit
- `@storybook/vue3-vite` — Vue 3
- `@storybook/angular` — Angular (still Webpack)
- `@storybook/react-native-web-vite` — React Native rendered on web

**Why this matters:** The framework package wires the build, the renderer, and framework-specific decorators (router, navigation mocks, image components). Generic packages omit all of this and stories that pass locally fail when deployed to a static Storybook.

Reference: [Storybook framework packages](https://storybook.js.org/docs/get-started/install), [Next.js framework docs](https://storybook.js.org/docs/get-started/frameworks/nextjs)
