---
title: Wire design tokens into `preview.ts` as CSS variables, not story-local imports
impact: HIGH
impactDescription: makes every story render with the live token build and prevents per-story drift
tags: config, design-tokens, style-dictionary, tokens-studio, css-variables
---

## Wire design tokens into `preview.ts` as CSS variables, not story-local imports

Design tokens (color, spacing, type, radii, shadows) are the foundation every component reads from. The 2026 pipeline is Tokens Studio → JSON → Style Dictionary → CSS custom properties — and those properties have to load *before* any story renders. Importing the generated CSS once in `preview.ts` cascades it to every story, every autodocs page, every Chromatic snapshot. Letting individual stories import their own copy means token edits don't propagate until every story file is re-saved, dev and production drift apart, and a token rename silently breaks half the library.

**Incorrect (per-story token imports — half the library uses old values after rebuild):**

```tsx
// Card.stories.tsx
import '../src/theme/tokens.css'; // imported here, but Modal.stories forgets to
import { tokens } from '../src/theme/tokens.json'; // raw JSON — Style Dictionary output ignored

const meta = {
  component: Card,
  parameters: {
    backgrounds: { default: tokens.color.surface }, // hard-coded; no CSS var fallback
  },
} satisfies Meta<typeof Card>;
```

**Correct (`preview.ts` imports the generated CSS once — every story sees current tokens):**

```ts
// style-dictionary.config.json — generates dist/tokens.css with :root { --color-...: ...; }
{
  "source": ["tokens/**/*.json"],
  "platforms": {
    "css": {
      "transformGroup": "css",
      "buildPath": "dist/",
      "files": [{ "destination": "tokens.css", "format": "css/variables" }]
    }
  }
}
```

```ts
// .storybook/preview.ts
import type { Preview } from '@storybook/react-vite';
import '../dist/tokens.css';     // Style Dictionary output — :root --color-* CSS vars
import '../src/theme/global.css'; // resets, body font, font-face — depends on tokens above

const preview: Preview = {
  parameters: {
    backgrounds: {
      // Reference the CSS vars, not raw hex — backgrounds addon picks up theme changes
      options: {
        surface: { name: 'Surface', value: 'var(--color-surface-default)' },
        muted:   { name: 'Muted',   value: 'var(--color-surface-muted)' },
      },
    },
  },
};

export default preview;
```

```css
/* src/components/Card.module.css — components consume tokens via var(), never raw hex */
.card {
  background: var(--color-surface-elevated);
  border-radius: var(--radius-md);
  padding: var(--space-4);
  box-shadow: var(--shadow-card);
}
```

**Build script wiring (`package.json`):**

```json
{
  "scripts": {
    "tokens:build": "style-dictionary build --config style-dictionary.config.json",
    "storybook":    "npm run tokens:build && storybook dev -p 6006",
    "build-storybook": "npm run tokens:build && storybook build",
    "prepublishOnly":  "npm run tokens:build"
  }
}
```

**Watch mode for live token edits in dev:**

```json
{
  "scripts": {
    "tokens:watch": "chokidar 'tokens/**/*.json' -c 'npm run tokens:build'",
    "storybook":    "npm run tokens:build && concurrently \"npm:tokens:watch\" \"storybook dev -p 6006\""
  }
}
```

**Alternative (Tailwind CSS via tokens — same principle, different transform):**

```js
// tailwind.config.js — generated from Style Dictionary's tailwind format target
import tokens from './dist/tokens-tailwind.cjs';

export default {
  theme: {
    extend: {
      colors:       tokens.color,
      spacing:      tokens.space,
      borderRadius: tokens.radius,
    },
  },
};
```

```ts
// .storybook/preview.ts — Tailwind needs its generated CSS, not the raw tokens.css
import '../src/tailwind.css'; // contains @tailwind directives using the generated config
```

**When NOT to use this pattern:**
- A non-CSS platform (React Native, iOS) where tokens compile to JS objects — import the JS module instead, but still in `preview.ts` so every story sees the current build.

**Why this matters:** A design system's promise is "one token change ripples everywhere." That promise only holds if the build runs and the output is loaded once, before any story. Per-story imports turn one knob into 200 knobs.

Reference: [Style Dictionary docs](https://amzn.github.io/style-dictionary/), [Tokens Studio](https://tokens.studio/), [Storybook design-token integrations](https://storybook.js.org/integrations/tag/design-tokens/), [Tailwind via Style Dictionary](https://dev.to/philw_/using-style-dictionary-to-transform-tailwind-config-into-scss-variables-css-custom-properties-and-javascript-via-design-tokens-24h5)
