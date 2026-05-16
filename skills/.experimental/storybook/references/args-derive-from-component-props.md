---
title: Let `args` be inferred from props; only declare `argTypes` for opaque types
impact: HIGH
impactDescription: removes ~70% of argTypes boilerplate while keeping controls accurate
tags: args, argTypes, inference, controls
---

## Let `args` be inferred from props; only declare `argTypes` for opaque types

Storybook infers `argTypes` from the component's TypeScript props at build time — primitives become text/number/boolean controls, string unions become `select` controls, and JSDoc comments become control descriptions. Hand-writing `argTypes` for everything is duplicate truth: when the prop changes, the `argTypes` go stale and the controls panel lies. Reserve `argTypes` for the cases inference can't reach: callbacks (`fn()` from `storybook/test`), complex object props with shapes Storybook should pre-fill, and overrides where the inferred control is wrong.

**Incorrect (every prop hand-declared — duplicates the type, goes stale):**

```tsx
const meta = {
  component: Button,
  argTypes: {
    children: { control: 'text' },
    variant: {
      control: 'select',
      options: ['primary', 'secondary', 'ghost'],
    },
    disabled: { control: 'boolean' },
    size: {
      control: 'select',
      options: ['sm', 'md', 'lg'],
    },
    onClick: { action: 'clicked' }, // legacy action — prefer fn()
  },
} satisfies Meta<typeof Button>;
```

**Correct (rely on inference; declare only what inference can't see):**

```tsx
import { fn } from 'storybook/test';

const meta = {
  component: Button,
  args: {
    onClick: fn(), // spy-able in play, auto-logged in Actions tab
  },
  argTypes: {
    // The TS type is `(event: MouseEvent) => void` — unhelpful as a control.
    // Hide it from the controls panel; it's still inferred for the docs table.
    onClick: { control: false },
  },
} satisfies Meta<typeof Button>;
```

**When you DO need to declare `argTypes`:**
- The prop type is a runtime branded type or any-typed escape hatch.
- The inferred control widget is wrong (e.g., a number that should be a range slider).
- You want to add a `description` that JSDoc on the component can't express.

**Why this matters:** Inferred `argTypes` track the component automatically. Hand-written ones are a second source of truth that decays.

Reference: [Storybook argTypes](https://storybook.js.org/docs/api/arg-types), [Auto-generated controls](https://storybook.js.org/docs/essentials/controls#automatic-argtype-inference)
