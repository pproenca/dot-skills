---
title: Put global providers in `preview.ts` decorators, not in every story
impact: HIGH
impactDescription: prevents per-story drift and silent provider gaps
tags: deco, providers, preview, theme
---

## Put global providers in `preview.ts` decorators, not in every story

Production wraps the app in a known stack — ThemeProvider, QueryClientProvider, RouterProvider, IntlProvider. Stories must mirror that stack to be honest. Wrapping per-story works for the first ten stories then drifts: a new story forgets the IntlProvider and silently renders raw translation keys; another forgets QueryClient and the React Query hook throws. Putting these decorators in `preview.ts` means *every* story (and every interaction test, and every Chromatic snapshot) gets the same providers automatically.

**Incorrect (per-story wrapping — drifts as the team grows):**

```tsx
// Card.stories.tsx
export const Default: StoryObj<typeof meta> = {
  render: (args) => (
    <ThemeProvider>
      <QueryClientProvider client={queryClient}>
        <Card {...args} />
      </QueryClientProvider>
    </ThemeProvider>
  ),
};

// Modal.stories.tsx — forgot QueryClientProvider; useQuery throws
export const Default: StoryObj<typeof meta> = {
  render: (args) => (
    <ThemeProvider>
      <Modal {...args} />
    </ThemeProvider>
  ),
};
```

**Correct (`preview.ts` global decorators — every story gets the same stack):**

```tsx
// .storybook/preview.tsx
import type { Preview } from '@storybook/react-vite';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { ThemeProvider } from '../src/theme';
import { IntlProvider } from '../src/i18n';

const queryClient = new QueryClient({
  defaultOptions: { queries: { retry: false, gcTime: 0 } },
});

const preview: Preview = {
  decorators: [
    (Story, { globals }) => (
      <IntlProvider locale={globals.locale ?? 'en'}>
        <QueryClientProvider client={queryClient}>
          <ThemeProvider theme={globals.theme ?? 'light'}>
            <Story />
          </ThemeProvider>
        </QueryClientProvider>
      </IntlProvider>
    ),
  ],
};
export default preview;
```

**Per-story decorators are appropriate for:**
- *Layout* wrappers specific to one story (`<div className="grid">`).
- *Stateful* wrappers a single story needs (e.g., a controlled input wrapper for a "controlled mode" story).
- Mocking decorators that vary by story (e.g., MSW handlers, `mockdate`).

**When NOT to use this pattern:**
- A provider that needs *different* values per story (e.g., a `FeatureFlagProvider` toggling individual flags). Push it to `globals` + a global decorator that reads the toolbar.

**Why this matters:** A story without the production stack passes locally, fails in a real app, and gets shipped because nobody noticed Storybook never tested the integration.

Reference: [Storybook decorators](https://storybook.js.org/docs/writing-stories/decorators), [preview.ts](https://storybook.js.org/docs/configure)
