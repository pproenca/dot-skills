---
title: Use `@storybook/addon-themes` for multi-brand theme switching
impact: HIGH
impactDescription: replaces ~30 lines of hand-rolled globalTypes per Storybook; prevents per-team drift
tags: deco, addon-themes, multi-brand, theme-switcher, css-variables
---

## Use `@storybook/addon-themes` for multi-brand theme switching

Storybook 9 ships `@storybook/addon-themes` as the official theme-switcher. It provides three decorators — `withThemeByClassName`, `withThemeByDataAttribute`, and `withThemeFromJSXProvider` — that wire up the toolbar dropdown, the `theme` global, and the wrapper element in one call. Hand-rolling `globalTypes` + a context-aware decorator (see `deco-context-aware-decorators`) still works, but it's 30 lines per Storybook, doesn't auto-integrate with Chromatic's `modes` for per-theme regression, and every team in a monorepo re-implements it slightly differently. For multi-brand design systems (where "theme" might mean Brand A vs Brand B, not just light vs dark), the addon is also the path that scales: register N themes once, get N sidebar previews, N Chromatic snapshots, and consistent class/attribute names across every story.

**Incorrect (hand-rolled — works, but doesn't integrate with addon-themes ecosystem):**

```tsx
// .storybook/preview.tsx — verbose, duplicates work the addon already does
const preview: Preview = {
  globalTypes: {
    theme: {
      toolbar: {
        title: 'Theme',
        icon: 'paintbrush',
        items: [{ value: 'light', title: 'Light' }, { value: 'dark', title: 'Dark' }],
      },
    },
  },
  initialGlobals: { theme: 'light' },
  decorators: [
    (Story, { globals }) => {
      // Manual class toggle; no Chromatic mode integration, no `theme` parameter override.
      const root = useRef<HTMLDivElement>(null);
      useEffect(() => {
        root.current?.classList.remove('theme-light', 'theme-dark');
        root.current?.classList.add(`theme-${globals.theme}`);
      }, [globals.theme]);
      return <div ref={root}><Story /></div>;
    },
  ],
};
```

**Correct (`withThemeByClassName` — one decorator, full integration):**

```tsx
// .storybook/preview.tsx
import type { Preview } from '@storybook/react-vite';
import { withThemeByClassName } from '@storybook/addon-themes';
import '../dist/tokens.css'; // CSS vars per theme: .theme-light { --color-...: ... } / .theme-brand-a { ... }

const preview: Preview = {
  decorators: [
    withThemeByClassName({
      themes: {
        light:    'theme-light',
        dark:     'theme-dark',
        'brand-a': 'theme-brand-a',
        'brand-b': 'theme-brand-b',
      },
      defaultTheme: 'light',
      parentSelector: 'body', // or a specific wrapper id
    }),
  ],
};

export default preview;
```

```ts
// .storybook/main.ts
const config = {
  addons: ['@storybook/addon-themes', /* ... */],
  // ...
} satisfies StorybookConfig;
```

**`withThemeByDataAttribute` variant (for design systems using `[data-theme]`):**

```tsx
import { withThemeByDataAttribute } from '@storybook/addon-themes';

const preview: Preview = {
  decorators: [
    withThemeByDataAttribute({
      themes: {
        light:   'light',
        dark:    'dark',
        'brand-a': 'brand-a',
      },
      defaultTheme: 'light',
      attributeName: 'data-theme', // <html data-theme="dark">
    }),
  ],
};
```

```css
/* dist/tokens.css — emitted by Style Dictionary; one block per theme */
[data-theme='light'] { --color-bg: #ffffff; --color-text: #111111; }
[data-theme='dark']  { --color-bg: #0b0b0c; --color-text: #f5f5f5; }
[data-theme='brand-a'] { --color-bg: #fef3f3; --color-text: #5b1212; }
```

**`withThemeFromJSXProvider` (when the brand is a real React provider, not just CSS):**

```tsx
import { withThemeFromJSXProvider } from '@storybook/addon-themes';
import { BrandAProvider, BrandBProvider } from '../src/theme';

const preview: Preview = {
  decorators: [
    withThemeFromJSXProvider({
      themes: { 'brand-a': BrandAProvider, 'brand-b': BrandBProvider },
      defaultTheme: 'brand-a',
    }),
  ],
};
```

**Per-story override** (sometimes a story should always render in a specific theme regardless of toolbar):

```tsx
export const DarkOnly: Story = {
  parameters: { themes: { themeOverride: 'dark' } },
};
```

**Pairs with Chromatic modes** for visual regression across every theme (see `build-chromatic-modes-multi-theme`):

```ts
parameters: {
  chromatic: {
    modes: {
      'light':   { theme: 'light' },
      'dark':    { theme: 'dark' },
      'brand-a': { theme: 'brand-a' },
    },
  },
},
```

**When NOT to use this pattern:**
- The theme is *not* a single class/attribute/provider swap — e.g., it requires re-mounting a `QueryClient` with different defaults. Hand-roll with `deco-context-aware-decorators` and gate the QueryClient inside the wrapper.
- You need the *toolbar* item but no wrapper change (theme drives some other addon's behavior). Use `globalTypes` directly without a decorator.

**Why this matters:** The 30 lines of hand-rolled theme code are 30 lines of drift waiting to happen. Three months later one story renders the wrong class, the test addon doesn't see the theme parameter, and Chromatic snapshots only one theme. The addon erases that whole class of bug for the standard case.

Reference: [@storybook/addon-themes API](https://github.com/storybookjs/storybook/blob/next/code/addons/themes/docs/api.md), [Themes essentials docs](https://storybook.js.org/docs/essentials/themes), [Styling addon blog post](https://storybook.js.org/blog/styling-addon-configure-styles-and-themes-in-storybook/), [Tailwind + themes recipe](https://github.com/storybookjs/storybook/blob/next/code/addons/themes/docs/getting-started/tailwind.md)
