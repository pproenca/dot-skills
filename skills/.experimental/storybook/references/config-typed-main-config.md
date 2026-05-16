---
title: Type main.ts with `satisfies StorybookConfig`
impact: CRITICAL
impactDescription: prevents addon-name and framework-options typos from passing silently
tags: config, typescript, satisfies, framework
---

## Type main.ts with `satisfies StorybookConfig`

`satisfies StorybookConfig` validates the shape of the config without widening it — addon names get autocompleted, framework options are checked against the framework package, and a mistyped key fails `tsc` instead of producing a Storybook that boots but silently ignores half the config. The annotated form (`const config: StorybookConfig = ...`) widens the literal types so `framework.options` becomes `unknown` and addon arrays accept any string.

**Incorrect (untyped or annotated — silent typos pass through):**

```ts
// .storybook/main.ts
const config = {
  framework: '@storybook/react-vite',
  stories: ['../src/**/*.stories.tsx'],
  addons: ['@storybook/addon-essentials', '@storybook/addon-a11yy'], // typo: a11yy
};

export default config;
```

**Correct (`satisfies StorybookConfig` — typo above fails compile):**

```ts
// .storybook/main.ts
import type { StorybookConfig } from '@storybook/react-vite';

const config = {
  framework: {
    name: '@storybook/react-vite',
    options: {},
  },
  stories: ['../src/**/*.stories.@(ts|tsx)'],
  addons: ['@storybook/addon-docs', '@storybook/addon-a11y'],
} satisfies StorybookConfig;

export default config;
```

**When NOT to use this pattern:**
- A framework's `StorybookConfig` type isn't exported (rare; most ship one) — fall back to `: StorybookConfig` annotation.

Reference: [Storybook main.ts configuration](https://storybook.js.org/docs/api/main-config), [TypeScript `satisfies` operator](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-4-9.html#the-satisfies-operator)
