---
title: Type preview.ts with the framework's `Preview` type
impact: CRITICAL
impactDescription: prevents silently-ignored typos in global decorators, parameters, and globalTypes
tags: config, preview, typescript, decorators
---

## Type preview.ts with the framework's `Preview` type

`preview.ts` defines globals that wrap *every* story — decorators, parameters, `initialGlobals`, `globalTypes`. Without the `Preview` type, a misspelled `parmeters` key or a decorator with the wrong signature is silently ignored: theme is missing from every story, MSW handlers never register, the a11y addon never gets configured. The `Preview` type — exported from each framework package — makes the contract explicit and makes refactoring decorators safe.

**Incorrect (untyped — typos and bad signatures pass silently):**

```ts
// .storybook/preview.ts
const preview = {
  parmeters: { // typo: never applied
    backgrounds: { default: 'light' },
  },
  decorators: [(story) => <ThemeProvider>{story()}</ThemeProvider>], // wrong: story is a function
};

export default preview;
```

**Correct (typed `Preview` — typo and signature both fail compile):**

```ts
// .storybook/preview.tsx
import type { Preview } from '@storybook/react-vite';
import { ThemeProvider } from '../src/theme';

const preview: Preview = {
  parameters: {
    backgrounds: { default: 'light' },
    a11y: { test: 'error' },
  },
  decorators: [
    (Story) => (
      <ThemeProvider>
        <Story />
      </ThemeProvider>
    ),
  ],
  initialGlobals: {
    locale: 'en',
  },
};

export default preview;
```

**Notes on the decorator signature:**
- The decorator receives a `Story` *component*, not a function — render it as `<Story />`, not `{story()}`. The capitalized `Story` parameter name signals this.
- The second argument is the `context` (args, parameters, globals); destructure it when the wrapper depends on a story-level value.

Reference: [Storybook preview.ts API](https://storybook.js.org/docs/api/parameters), [Decorators API](https://storybook.js.org/docs/writing-stories/decorators)
