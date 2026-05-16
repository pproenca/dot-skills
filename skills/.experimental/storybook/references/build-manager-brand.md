---
title: Brand `.storybook/manager.ts` so Storybook IS the design-system site
impact: MEDIUM
impactDescription: prevents the "Storybook looks like a dev tool" perception in 5 minutes of config
tags: build, manager, theming, branding, sidebar
---

## Brand `.storybook/manager.ts` so Storybook IS the design-system site

For most orgs the deployed Storybook *is* the design-system website — designers and PMs hit it daily, and it's the URL the design system team puts in onboarding docs. A default Storybook chrome (purple-on-white, the Storybook logo, generic "Storybook" title) reads like an internal dev tool, not a product surface. `.storybook/manager.ts` with a theme from `storybook/theming`'s `create()` swaps the logo, sidebar colors, and brand link in five lines — your tokens become the chrome and the design system stops looking like Storybook started looking like *yours*.

**Incorrect (no manager.ts — default Storybook branding):**

```text
.storybook/
├── main.ts
├── preview.ts
└── (no manager.ts — default purple theme, Storybook logo, "Storybook" in titlebar)
```

Designers see Storybook's logo at the top-left and a default page title. The first impression is "this is a developer tool I am borrowing," not "this is our design system."

**Correct (`manager.ts` registers a custom theme):**

```ts
// .storybook/manager.ts
import { addons } from 'storybook/manager-api';
import { acmeTheme } from './acme-theme';

addons.setConfig({
  theme: acmeTheme,
  sidebar: {
    showRoots: true,           // show top-level groups (Foundations / Components / Patterns)
    collapsedRoots: ['Internal'], // collapse engineering-only group by default
  },
  toolbar: {
    title:     { hidden: false },
    zoom:      { hidden: false },
    eject:     { hidden: true },  // hide "open canvas in new tab" if not used
    copy:      { hidden: false },
    fullscreen:{ hidden: false },
  },
});
```

```ts
// .storybook/acme-theme.ts
import { create } from 'storybook/theming';

export const acmeTheme = create({
  base: 'light', // or 'dark' — drives default UI palette

  // Brand
  brandTitle: 'Acme Design System',
  brandUrl:   'https://design.acme.com',
  brandImage: 'https://design.acme.com/logo.svg', // SVG > PNG; 200×40 px works well
  brandTarget: '_self',

  // Typography — uses your token-driven font stacks
  fontBase: 'Inter, ui-sans-serif, system-ui, sans-serif',
  fontCode: 'JetBrains Mono, ui-monospace, monospace',

  // Sidebar + main background
  appBg:           '#fafaf9',
  appContentBg:    '#ffffff',
  appBorderColor:  '#e7e5e4',
  appBorderRadius: 8,

  // Toolbar + buttons
  barTextColor:     '#57534e',
  barSelectedColor: '#0f172a',
  barBg:            '#ffffff',

  // Form / input chrome
  inputBg:           '#ffffff',
  inputBorder:       '#d6d3d1',
  inputTextColor:    '#0f172a',
  inputBorderRadius: 6,

  // Story canvas
  colorPrimary:    '#0f172a',
  colorSecondary:  '#3b82f6',
  textColor:       '#0f172a',
  textInverseColor:'#ffffff',
});
```

**Reference design-system tokens instead of hard-coded hex:**

```ts
// .storybook/acme-theme.ts — read CSS variables at build time via a small script,
// OR re-export the same JS module Style Dictionary emits
import { color, font } from '../dist/tokens.js'; // Style Dictionary JS target

export const acmeTheme = create({
  base: 'light',
  brandTitle: 'Acme Design System',
  brandUrl:   'https://design.acme.com',
  brandImage: '/logo.svg',

  fontBase:  font.family.sans,
  fontCode:  font.family.mono,

  appBg:          color.surface.muted,
  appContentBg:   color.surface.default,
  appBorderColor: color.border.subtle,
  colorPrimary:   color.brand.primary,
  colorSecondary: color.brand.accent,
});
```

**Dark-themed manager (for Storybook chrome itself — independent from the canvas theme):**

```ts
import { themes } from 'storybook/theming';

addons.setConfig({
  // Use Storybook's built-in dark as a base, then tweak brand fields
  theme: { ...themes.dark, brandTitle: 'Acme', brandImage: '/logo-dark.svg' },
});
```

**Pair with story `description` markdown** for branded docs pages (see `docs-autodocs-vs-mdx`):

```mdx
{/* .storybook/Welcome.mdx — first page designers see */}
import { Meta } from '@storybook/addon-docs/blocks';

<Meta title="Welcome" />

# Acme Design System

Welcome. This Storybook is the source of truth for Acme's UI.

- **[Foundations](?path=/docs/foundations--docs)** — tokens, type, spacing
- **[Components](?path=/docs/components--docs)** — reusable UI
- **[Figma](https://figma.com/file/...)** — the design source
```

**When NOT to use this pattern:**
- An app-internal Storybook that engineers exclusively use. Default branding is fine.
- A Storybook embedded only via Composition (`refs`) in another host — the host's `manager.ts` controls chrome; ref Storybooks render in iframes and the manager theme is ignored.

**Why this matters:** Branding is the lowest-effort, highest-perception change in a design-system Storybook. Five minutes of work makes the design system feel like a product, which makes stakeholders treat it like one.

Reference: [Storybook UI theming](https://storybook.js.org/docs/configure/user-interface/theming), [`create()` API](https://storybook.js.org/docs/api/storybook-theming), [manager.ts configuration](https://storybook.js.org/docs/configure/user-interface/features-and-behavior)
