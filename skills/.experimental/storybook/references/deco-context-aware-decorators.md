---
title: Read `context` in decorators to make them story-reactive
impact: HIGH
impactDescription: enables one decorator to handle theme, locale, and viewport changes
tags: deco, context, globals, parameters
---

## Read `context` in decorators to make them story-reactive

Decorators receive a `context` argument with `args`, `parameters`, `globals`, `viewMode`, and `id`. Ignoring it produces a static wrapper that can't react to toolbar changes (theme, locale, RTL) or to per-story parameter overrides. Destructuring `globals` for toolbar state and `parameters` for story metadata lets one decorator serve every story while still varying its behavior — the difference between "Storybook switches your theme" and "you have to redeploy to change theme."

**Incorrect (static decorator — toolbar theme toggle does nothing):**

```tsx
const preview: Preview = {
  decorators: [
    (Story) => (
      <ThemeProvider theme="light"> {/* hard-coded — toolbar can't change it */}
        <Story />
      </ThemeProvider>
    ),
  ],
};
```

**Correct (reads `context.globals` — toolbar drives the wrapper):**

```tsx
const preview: Preview = {
  initialGlobals: { theme: 'light', locale: 'en' },
  globalTypes: {
    theme: {
      toolbar: {
        icon: 'paintbrush',
        items: [
          { value: 'light', title: 'Light' },
          { value: 'dark', title: 'Dark' },
        ],
      },
    },
    locale: {
      toolbar: {
        icon: 'globe',
        items: [
          { value: 'en', title: 'English' },
          { value: 'pt', title: 'Português' },
        ],
      },
    },
  },
  decorators: [
    (Story, { globals, parameters }) => {
      const theme = parameters.forceTheme ?? globals.theme;
      return (
        <IntlProvider locale={globals.locale}>
          <ThemeProvider theme={theme}>
            <Story />
          </ThemeProvider>
        </IntlProvider>
      );
    },
  ],
};
```

**Per-story override via parameters:**

```tsx
// "Always render this story in dark mode regardless of toolbar"
export const DarkModeOnly: Story = {
  parameters: { forceTheme: 'dark' },
};
```

**Common context fields:**

| Field | Use |
|-------|-----|
| `globals` | Toolbar state (theme, locale, RTL) |
| `parameters` | Story metadata (addon config, layout, custom flags) |
| `args` | Resolved args (combined meta + story + control changes) |
| `viewMode` | `'story'` vs `'docs'` — vary rendering for the docs page |
| `id`, `name`, `title` | Story identity (useful for analytics decorators) |

**Why this matters:** Storybook's whole "interactive workshop" promise depends on toolbar globals + reactive decorators. Static wrappers turn it back into static screenshots.

Reference: [Storybook decorators with context](https://storybook.js.org/docs/writing-stories/decorators#context-for-mocking), [Globals and toolbars](https://storybook.js.org/docs/essentials/toolbars-and-globals)
