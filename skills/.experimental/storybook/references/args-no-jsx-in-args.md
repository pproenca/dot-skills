---
title: "Avoid JSX in `args` defaults — compose JSX in `render` instead"
impact: HIGH
impactDescription: prevents broken docs source code and Chromatic snapshot diffs
tags: args, jsx, render, serialization
---

## Avoid JSX in `args` defaults — compose JSX in `render` instead

`args` are serialized into the URL, displayed in the Controls panel, shown as the docs page source, and snapshotted by Chromatic. JSX values can't be serialized: the URL state breaks, the source view shows `[object Object]`, the Controls panel can't display them, and Chromatic snapshots the React element identity instead of the rendered output. When a story needs a JSX child, use `render` to compose it from primitive args; keep `args` as a plain-data shape.

**Incorrect (JSX in args — Controls broken, source broken, URL state broken):**

```tsx
const meta = {
  component: Card,
} satisfies Meta<typeof Card>;
export default meta;

export const WithIcon: StoryObj<typeof meta> = {
  args: {
    title: 'Settings',
    icon: <CogIcon className="size-5" />, // JSX in args — bad
    actions: <Button onClick={() => {}}>Save</Button>, // also bad
  },
};
```

**Correct (primitive args + `render` composes JSX):**

```tsx
const meta = {
  component: Card,
  args: {
    title: 'Settings',
    iconName: 'cog',                       // primitive: a discriminator
    actionLabel: 'Save',                   // primitive: rendered into the action slot
  },
  argTypes: {
    iconName: { control: 'select', options: ['cog', 'user', 'home'] },
  },
} satisfies Meta<typeof Card>;
export default meta;

const ICONS = { cog: CogIcon, user: UserIcon, home: HomeIcon };

export const WithIcon: StoryObj<typeof meta> = {
  args: { iconName: 'cog', actionLabel: 'Save' },
  render: ({ iconName, actionLabel, ...rest }) => {
    const Icon = ICONS[iconName];
    return (
      <Card
        {...rest}
        icon={<Icon className="size-5" />}
        actions={<Button>{actionLabel}</Button>}
      />
    );
  },
};
```

**When JSX in args IS unavoidable:**
- Story is a *one-off composition* with no design-system intent (e.g., a test fixture). In that case, the story shouldn't have controls and you can render JSX inline in `render` without making it an arg.

**Why this matters:** Args are the design-system contract — primitives flow through controls, autodocs source, URL deep-links, and Chromatic. JSX breaks every one of those.

Reference: [Storybook args](https://storybook.js.org/docs/writing-stories/args), [Render functions](https://storybook.js.org/docs/writing-stories#using-args)
