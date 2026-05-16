---
title: Narrow the `stories` glob to story files only
impact: CRITICAL
impactDescription: 2-10x faster cold start, prevents accidental story matching
tags: config, performance, glob, stories
---

## Narrow the `stories` glob to story files only

Storybook scans every file matching the `stories` glob at startup, parses each one for default exports, and watches them all in dev. A loose glob like `'../src/**/*.@(ts|tsx)'` scans the entire app — including tests, hooks, and utilities — multiplying cold-start time and producing false matches when a non-story file happens to default-export a function. The pattern should be specific to story files (`*.stories.tsx`) and root-anchored to the directory that actually contains stories.

**Incorrect (matches every TS file, scans tests and utilities):**

```ts
// .storybook/main.ts
const config = {
  framework: '@storybook/react-vite',
  stories: [
    '../src/**/*', // scans everything; even non-stories get parsed
  ],
} satisfies StorybookConfig;
```

**Correct (matches story files only, plus dedicated docs):**

```ts
// .storybook/main.ts
const config = {
  framework: '@storybook/react-vite',
  stories: [
    '../src/**/*.mdx',
    '../src/**/*.stories.@(ts|tsx)',
  ],
} satisfies StorybookConfig;
```

**Alternative (split intro docs from component stories):**

```ts
stories: [
  // Intro/landing docs first so they appear at the top of the sidebar
  '../src/intro.mdx',
  '../src/**/*.mdx',
  '../src/components/**/*.stories.@(ts|tsx)',
];
```

**Why this matters:** Glob breadth is the single biggest lever on Storybook startup. A repo with 5,000 source files and a `**/*` glob spends seconds parsing files that contain zero stories on every restart.

Reference: [Storybook configure: stories](https://storybook.js.org/docs/configure#configure-story-loading)
