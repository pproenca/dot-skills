---
title: Add a toolbar `dir` toggle and verify every component in RTL
impact: MEDIUM-HIGH
impactDescription: prevents LTR-only layout bugs (margin-left, padding-right, raw arrows) from reaching RTL users
tags: deco, rtl, bidi, direction, globals
---

## Add a toolbar `dir` toggle and verify every component in RTL

If your design system claims to be internationalization-ready, every component has to lay out correctly under `dir="rtl"`. The failure mode is mundane and pervasive: `margin-left: 8px` should have been `margin-inline-start: 8px`; a `>` chevron should have flipped; an icon shifts off-center; a tooltip points the wrong way. None of these show up in code review and most don't show up in unit tests — but they all show up to a user in Arabic or Hebrew. A toolbar `dir` toggle in Storybook turns RTL into a one-click visual check, and pairing it with Chromatic modes (see `build-chromatic-modes-multi-theme`) means every PR snapshots both directions.

**Incorrect (no RTL switch — bugs slip through every release):**

```tsx
// .storybook/preview.tsx — only LTR is ever seen during dev
const preview: Preview = {
  decorators: [
    (Story) => <ThemeProvider><Story /></ThemeProvider>,
    // No `dir` toggle, no `globalTypes.direction`, no RTL story coverage
  ],
};
```

**Correct (toolbar `dir` toggle that wraps every story):**

```tsx
// .storybook/preview.tsx
import type { Preview } from '@storybook/react-vite';

const preview: Preview = {
  initialGlobals: { direction: 'ltr' },
  globalTypes: {
    direction: {
      description: 'Text direction',
      toolbar: {
        title: 'Direction',
        icon: 'transfer',
        items: [
          { value: 'ltr', title: 'LTR' },
          { value: 'rtl', title: 'RTL' },
        ],
        dynamicTitle: true,
      },
    },
  },
  decorators: [
    (Story, { globals, parameters }) => {
      const dir = parameters.direction ?? globals.direction ?? 'ltr';
      // `dir` on a wrapper, not <html> — keeps Storybook chrome LTR while flipping the canvas
      return (
        <div dir={dir} lang={dir === 'rtl' ? 'ar' : 'en'}>
          <Story />
        </div>
      );
    },
  ],
};

export default preview;
```

**Component-side: use logical properties, not physical ones:**

```css
/* Incorrect — physical properties don't flip in RTL */
.toast {
  margin-left: var(--space-3);
  padding-right: var(--space-4);
  border-left: 4px solid var(--color-accent);
}

/* Correct — logical properties flip with `dir` automatically */
.toast {
  margin-inline-start: var(--space-3);
  padding-inline-end:  var(--space-4);
  border-inline-start: 4px solid var(--color-accent);
}
```

**Per-story override (a story that must always render RTL — e.g., an Arabic copy fixture):**

```tsx
export const ArabicCopy: Story = {
  parameters: { direction: 'rtl' },
  args: { children: 'احفظ التغييرات' },
};
```

**Cover both directions in autodocs by adding sibling stories:**

```tsx
export const Default: Story = { args: { children: 'Save changes' } };
export const DefaultRtl: Story = {
  ...Default,
  parameters: { direction: 'rtl' },
  // Same args, opposite direction — autodocs shows them side-by-side
};
```

**Pair with `@storybook/addon-themes`** for combined direction × theme matrix:

```ts
// Chromatic snapshots: 2 directions × 2 themes = 4 visual baselines per story
parameters: {
  chromatic: {
    modes: {
      'light-ltr': { theme: 'light', direction: 'ltr' },
      'light-rtl': { theme: 'light', direction: 'rtl' },
      'dark-ltr':  { theme: 'dark',  direction: 'ltr' },
      'dark-rtl':  { theme: 'dark',  direction: 'rtl' },
    },
  },
},
```

**When NOT to use this pattern:**
- The product explicitly does not ship in RTL locales and the design system isn't intended for external consumption. Even then, the toggle is cheap — keep it as a forcing function for logical-property hygiene.
- A pure data-display component (charts) where the layout shouldn't flip — add `direction: 'inherit'` and document the exemption per story.

**Why this matters:** RTL bugs are a forever tax on a design system that didn't bake the switch in early. The toggle costs ten lines and forces every story author to think "does this look right in both directions?" The same logical-property discipline pays off again on Asian/long-text locales where padding compounds.

Reference: [Storybook globals and toolbars](https://storybook.js.org/docs/essentials/toolbars-and-globals), [I18n with Storybook](https://storybook.js.org/blog/internationalize-components-with-storybook/), [MDN CSS logical properties](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_logical_properties_and_values), [storybook-addon-rtl-direction](https://storybook.js.org/addons/storybook-addon-rtl-direction)
