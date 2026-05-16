---
title: Pick the right knob — `args` vs `parameters` vs `globals`
impact: HIGH
impactDescription: prevents misuse that breaks controls, addons, or toolbar state
tags: args, parameters, globals, taxonomy
---

## Pick the right knob — `args` vs `parameters` vs `globals`

Storybook has three places to put state, and each is read by different tools. Misplacing state breaks the wrong thing: putting "background color" in `args` makes it part of the component's contract; putting `theme` in `args` couples every story to a per-story toggle. The rule:

- **`args`** — inputs the *component* receives. Drive controls. Show in autodocs prop table. Passed to `play`.
- **`parameters`** — story-level *metadata* read by addons (`a11y`, `viewport`, `backgrounds`, `msw`, `layout`). Not props.
- **`globals`** — *cross-story* user state surfaced in the toolbar (theme, locale, RTL). Persists as you navigate between stories.

**Incorrect (theme in `args` — every story gets a redundant theme control):**

```tsx
const meta = {
  component: Card,
  args: {
    theme: 'light', // wrong: not a Card prop, not story-specific, should be a toolbar global
  },
  argTypes: {
    theme: { control: 'radio', options: ['light', 'dark'] },
  },
} satisfies Meta<typeof Card>;
```

**Correct (theme as a global; viewport as a parameter; size as an arg):**

```ts
// .storybook/preview.ts — global toolbar toggle
const preview: Preview = {
  initialGlobals: { theme: 'light' },
  globalTypes: {
    theme: {
      description: 'Theme',
      toolbar: {
        icon: 'paintbrush',
        items: [
          { value: 'light', title: 'Light' },
          { value: 'dark', title: 'Dark' },
        ],
        dynamicTitle: true,
      },
    },
  },
  decorators: [
    (Story, { globals }) => (
      <ThemeProvider theme={globals.theme}>
        <Story />
      </ThemeProvider>
    ),
  ],
};
```

```tsx
// Card.stories.tsx
const meta = {
  component: Card,
  args: { size: 'md' },                                    // component prop → arg
  parameters: {
    viewport: { defaultViewport: 'tablet' },               // addon config → parameter
    layout: 'centered',                                    // story metadata → parameter
  },
  // globals: { theme: 'dark' }   // override toolbar default for this story only
} satisfies Meta<typeof Card>;
```

**Quick reference:**

| Need | Use | Read by |
|------|-----|---------|
| Pass a value to the component | `args` | The component, controls panel, autodocs, `play` |
| Configure an addon | `parameters` | The addon (`a11y`, `viewport`, `msw`, etc.) |
| Cross-story setting with a toolbar | `globals` + `globalTypes` | Decorators (via `context.globals`), toolbar UI |

**Why this matters:** Each surface is built around one of these three. Cross them and you produce stories where the controls panel is bloated, addons silently misconfigured, and theme switching reset every navigation.

Reference: [Storybook args](https://storybook.js.org/docs/writing-stories/args), [Parameters](https://storybook.js.org/docs/writing-stories/parameters), [Globals](https://storybook.js.org/docs/essentials/toolbars-and-globals)
