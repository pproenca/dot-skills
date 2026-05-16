---
title: Decorators receive a `Story` component — render it as `<Story />`, not `{story()}`
impact: HIGH
impactDescription: prevents lost story context (args, parameters, decorator chain)
tags: deco, decorator, signature, react
---

## Decorators receive a `Story` component — render it as `<Story />`, not `{story()}`

Storybook decorators receive the wrapped story as a *component reference*, not as a function to invoke. Calling it (`{story()}`) loses the story context: subsequent decorators in the chain stop receiving the right args, args-from-controls don't propagate, and parameters set in nested decorators get dropped. Rendering it as JSX (`<Story />`) lets Storybook continue weaving the chain — args, parameters, and globals all reach the underlying story render correctly.

**Incorrect (calling the story as a function — context drops at this point in the chain):**

```tsx
const preview: Preview = {
  decorators: [
    (story) => <ThemeProvider>{story()}</ThemeProvider>, // wrong: context lost
  ],
};
```

**Correct (rendering the Story component — context flows through):**

```tsx
const preview: Preview = {
  decorators: [
    (Story) => (
      <ThemeProvider>
        <Story />
      </ThemeProvider>
    ),
  ],
};
```

**Reading context from the second arg (when the wrapper depends on the story):**

```tsx
// Per-story: wrap with router only if the story declares a route
const preview: Preview = {
  decorators: [
    (Story, context) => {
      const route = context.parameters.route ?? '/';
      return (
        <MemoryRouter initialEntries={[route]}>
          <Story />
        </MemoryRouter>
      );
    },
  ],
};

// Story sets the parameter
export const ProfilePage: Story = {
  parameters: { route: '/profile/123' },
};
```

**The convention is the capitalized name:**
- `(Story, context) => ...` — capitalized `Story` is the React-component convention; signals "render with `<Story />`".
- `(story, context) => ...` — lowercase makes it look invokable. Don't.

**Why this matters:** Lost context is a silent failure — the story renders, but with stale args. The bug surfaces when someone changes a control and nothing happens, or when a play function gets undefined args.

Reference: [Storybook decorators](https://storybook.js.org/docs/writing-stories/decorators#component-decorators)
