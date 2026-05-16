---
title: Prefer `args` over `render` for single-component stories
impact: CRITICAL
impactDescription: enables controls, autodocs, and play-function arg injection
tags: csf, args, render, controls
---

## Prefer `args` over `render` for single-component stories

When `meta.component` is set and a story declares only `args`, Storybook auto-renders the component with those args, hooks them up to the controls panel, derives the autodocs prop table, and passes `args` into the `play` function. Adding a `render` override breaks this pipeline: controls still appear but no longer drive the rendered output, autodocs reads from the meta but the rendered DOM doesn't match, and `play` receives args the rendered component ignores. Use `render` only when no `args` shape can express what you need (compound stories, conditional wrappers, decorators that take props from args).

**Incorrect (`render` for what is just an arg passthrough):**

```tsx
// Button.stories.tsx
const meta = { component: Button } satisfies Meta<typeof Button>;
export default meta;

export const Primary: StoryObj<typeof meta> = {
  args: { variant: 'primary', children: 'Click me' },
  render: (args) => <Button {...args} />, // redundant — Storybook does this for you
};
```

**Correct (let Storybook auto-render):**

```tsx
// Button.stories.tsx
const meta = { component: Button } satisfies Meta<typeof Button>;
export default meta;

export const Primary: StoryObj<typeof meta> = {
  args: { variant: 'primary', children: 'Click me' },
};
```

**When `render` IS the right call:**

```tsx
// A composed story — multiple components in one frame, no single component arg shape
export const FormFieldShowcase: StoryObj<typeof meta> = {
  render: (args) => (
    <Stack gap="md">
      <Field label="Email"><Input {...args} type="email" /></Field>
      <Field label="Password"><Input {...args} type="password" /></Field>
    </Stack>
  ),
};

// A story whose layout depends on an arg — render needs to react to the arg
export const Stacked: StoryObj<typeof meta> = {
  args: { count: 3 },
  render: ({ count, ...rest }) => (
    <Stack>
      {Array.from({ length: count }).map((_, i) => <Card key={i} {...rest} />)}
    </Stack>
  ),
};
```

**Why this matters:** Each `render` override is a place where the rendered DOM, the controls panel, the autodocs table, and the play-function arg flow can diverge. The implicit render keeps them aligned by construction.

Reference: [Storybook stories: render](https://storybook.js.org/docs/writing-stories#default-component-render)
