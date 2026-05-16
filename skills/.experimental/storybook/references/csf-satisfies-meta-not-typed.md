---
title: Use `satisfies Meta<typeof Component>`, not a type annotation
impact: CRITICAL
impactDescription: preserves narrow arg types so `StoryObj<typeof meta>` autocompletes
tags: csf, satisfies, typescript, meta
---

## Use `satisfies Meta<typeof Component>`, not a type annotation

`satisfies` checks the meta object against `Meta<typeof Component>` *without widening it* — `typeof meta` retains the literal `args` shape, which is exactly what `StoryObj<typeof meta>` needs to infer per-story arg autocomplete. The annotated form (`const meta: Meta<typeof Component> = ...`) widens `args` to `Partial<Props>`, which then makes every `StoryObj` accept any arg shape, defeating the type-check that catches stories drifting from the component's props.

**Incorrect (annotated meta — `args` autocomplete is gone in stories):**

```tsx
// Button.stories.tsx
import type { Meta, StoryObj } from '@storybook/react-vite';
import { Button } from './Button';

const meta: Meta<typeof Button> = {
  component: Button,
  args: { variant: 'primary' },
};
export default meta;

type Story = StoryObj<typeof meta>;

export const Primary: Story = {
  args: { variant: 'wrong-value' }, // does NOT fail; type is widened
};
```

**Correct (`satisfies Meta<typeof Button>` — `variant: 'wrong-value'` fails compile):**

```tsx
// Button.stories.tsx
import type { Meta, StoryObj } from '@storybook/react-vite';
import { Button } from './Button';

const meta = {
  component: Button,
  args: { variant: 'primary' },
} satisfies Meta<typeof Button>;
export default meta;

type Story = StoryObj<typeof meta>;

export const Primary: Story = {
  args: { variant: 'wrong-value' }, // fails: not assignable to 'primary' | 'secondary' | 'ghost'
};
```

**Why this matters:** The whole point of CSF3 + TypeScript is that the component's prop types flow into stories. Annotating `Meta<typeof Component>` short-circuits that and turns the file into a `Partial<Props>` free-for-all.

Reference: [Storybook CSF3 with TypeScript](https://storybook.js.org/docs/api/csf), [TS `satisfies` operator](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-4-9.html#the-satisfies-operator)
