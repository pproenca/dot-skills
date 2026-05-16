---
title: Serve assets via `staticDirs`, not bundler imports
impact: CRITICAL
impactDescription: prevents broken asset paths in static builds
tags: config, assets, staticDirs, build
---

## Serve assets via `staticDirs`, not bundler imports

Stories often need fixtures the bundler can't process — fonts, sample SVGs, mock JSON, design-system images. `staticDirs` tells Storybook to serve these directories as-is at the root URL in both dev and the static build, so a `<img src="/logo.svg" />` in a story works identically locally and in the deployed build. Importing the asset through the bundler (`import logo from './logo.svg'`) couples the story to your bundler config and produces hashed paths that break when the design team browses the static Storybook on a CDN.

**Incorrect (bundler-imported asset — path differs between dev and build):**

```tsx
// LogoBlock.stories.tsx
import type { Meta, StoryObj } from '@storybook/react-vite';
import logo from '../../public/logo.svg'; // hashed path in build, breaks in CDN preview

const meta = { component: LogoBlock } satisfies Meta<typeof LogoBlock>;
export default meta;

export const Default: StoryObj<typeof meta> = {
  args: { src: logo },
};
```

**Correct (`staticDirs` + root-relative URL — works everywhere):**

```ts
// .storybook/main.ts
const config = {
  framework: '@storybook/react-vite',
  stories: ['../src/**/*.stories.@(ts|tsx)'],
  staticDirs: ['../public', { from: '../design-tokens', to: '/tokens' }],
} satisfies StorybookConfig;
```

```tsx
// LogoBlock.stories.tsx
const meta = { component: LogoBlock } satisfies Meta<typeof LogoBlock>;
export default meta;

export const Default: StoryObj<typeof meta> = {
  args: { src: '/logo.svg' }, // served from ../public, same path in dev and prod
};
```

**When NOT to use this pattern:**
- Component-internal assets that ship with the bundle (e.g., a 200-byte inline SVG icon) — bundler imports are appropriate; they get inlined.
- Per-story dynamic assets generated at runtime — pass them through args.

**Common `staticDirs` shape:**
- String: directory served at root (`'../public'` → files at `/`).
- Object: `{ from: 'src-path', to: 'url-path' }` for prefixed mounting.

Reference: [Storybook static assets](https://storybook.js.org/docs/configure/integration/images-and-assets)
