---
title: Snapshot every story across themes and viewports with Chromatic `modes`
impact: MEDIUM-HIGH
impactDescription: prevents per-theme regressions invisible to single-mode snapshots; N×M baselines per story
tags: build, chromatic, modes, visual-regression, multi-theme
---

## Snapshot every story across themes and viewports with Chromatic `modes`

A multi-brand design system that snapshots only the default theme has no regression coverage for the other brands. A responsive design system that snapshots only desktop has no coverage for mobile. Chromatic's `modes` (and the matching `parameters.chromatic.modes` API) take one story and produce N visual baselines — one per declared mode — so a token edit that breaks dark mode but not light mode shows up immediately. Without modes, each theme needs duplicate stories or a separate Storybook deployment, both of which decay fast. With modes, every existing story automatically gets the matrix.

**Incorrect (single-mode snapshots — dark-mode regressions ship undetected):**

```yml
# .github/workflows/chromatic.yml — runs once per story, default theme only
- uses: chromaui/action@latest
  with:
    projectToken: ${{ secrets.CHROMATIC_PROJECT_TOKEN }}
    # No `modes` — only light theme + default viewport are snapshotted
```

**Correct (`.storybook/modes.ts` declares the matrix + per-story `parameters.chromatic.modes`):**

```ts
// .storybook/modes.ts — single source of truth for the visual-regression matrix
export const allModes = {
  'light desktop': { theme: 'light', viewport: 'desktop' },
  'dark  desktop': { theme: 'dark',  viewport: 'desktop' },
  'light mobile':  { theme: 'light', viewport: 'mobile'  },
  'dark  mobile':  { theme: 'dark',  viewport: 'mobile'  },
  'brand-a':       { theme: 'brand-a', viewport: 'desktop' },
  'brand-b':       { theme: 'brand-b', viewport: 'desktop' },
} as const;
```

```ts
// .storybook/preview.ts — wire the modes globally so every story gets them
import type { Preview } from '@storybook/react-vite';
import { withThemeByClassName } from '@storybook/addon-themes';
import { allModes } from './modes';

const preview: Preview = {
  parameters: {
    chromatic: {
      modes: allModes, // every story snapshots in all 6 modes
    },
  },
  decorators: [
    withThemeByClassName({
      themes: {
        light: 'theme-light', dark: 'theme-dark',
        'brand-a': 'theme-brand-a', 'brand-b': 'theme-brand-b',
      },
      defaultTheme: 'light',
      parentSelector: 'body',
    }),
  ],
};

export default preview;
```

**Per-story narrowing (a story that only needs a subset — e.g., a brand-specific component):**

```tsx
// BrandABanner.stories.tsx
import { allModes } from '../../.storybook/modes';

export const Default: Story = {
  parameters: {
    chromatic: {
      // Override the global matrix — this component only exists in brand-a
      modes: { 'brand-a': allModes['brand-a'] },
    },
  },
};
```

**Per-story expansion (a layout-sensitive component that needs extra breakpoints):**

```tsx
export const DataTable_Wide: Story = {
  parameters: {
    chromatic: {
      modes: {
        ...allModes,
        'light  tablet': { theme: 'light', viewport: 'tablet' },
        'light  widescreen': { theme: 'light', viewport: { width: 1920, height: 1080 } },
      },
    },
  },
};
```

**Disable modes for known-stable foundations** (e.g., a token palette story doesn't need 6 snapshots of the same hex values across viewports):

```tsx
// Foundations/Colors.stories.tsx
export const Palette: Story = {
  parameters: {
    chromatic: { disable: true }, // OR { modes: { default: { theme: 'light' } } }
  },
};
```

**CI: no workflow change needed** — Chromatic reads the `modes` parameter from the built Storybook:

```yml
# .github/workflows/chromatic.yml
- uses: chromaui/action@latest
  with:
    projectToken: ${{ secrets.CHROMATIC_PROJECT_TOKEN }}
    # `modes` declared in preview.ts; Chromatic snapshots all of them per story automatically
```

**Cost discipline** — the matrix multiplies snapshot count. Strategies that keep it bounded:

| Strategy | When |
|----------|------|
| Use modes only on `Components/**` | Skip Foundations/Examples/Patterns where mode coverage adds noise |
| Per-component `chromatic.modes` overrides | Custom matrix per area; keep the global default small (2-3 modes) |
| `chromatic.disable` on data-table-style stories with 50 args combos | Snapshot one representative; rely on play-function asserts for the rest |
| Test-suite tagging (`chromatic.tags`) | Snapshot the full matrix only on `main` and PRs touching `theme/` |

**When NOT to use this pattern:**
- Single-theme product (just light mode, desktop-only) — modes are overhead without regression value.
- Visual regression handled outside Chromatic (Argos, Playwright snapshots) — those tools have their own multi-mode primitives (Argos' [story modes](https://argos-ci.com/docs/storybook-story-modes), Playwright projects).
- Costs are billed per snapshot and the matrix is large enough to dominate the bill — consider running the full matrix only on the design-system repo, light-only on consumer apps.

**Why this matters:** A theme is a contract: "all our components work under this set of tokens." A multi-brand design system has N contracts. Without per-theme snapshots, the contracts aren't tested — they're just claimed. Modes make every PR validate every contract automatically.

Reference: [Chromatic modes docs](https://www.chromatic.com/docs/modes/), [Argos story modes](https://argos-ci.com/docs/storybook-story-modes), [Storybook visual testing](https://storybook.js.org/docs/writing-tests/visual-testing), [@storybook/addon-themes API](https://github.com/storybookjs/storybook/blob/next/code/addons/themes/docs/api.md)
