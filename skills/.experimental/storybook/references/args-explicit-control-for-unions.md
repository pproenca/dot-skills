---
title: Declare `control` and `options` for prop types Storybook can't infer
impact: HIGH
impactDescription: prevents invalid string inputs and enables proper select/radio controls
tags: args, argTypes, controls, unions
---

## Declare `control` and `options` for prop types Storybook can't infer

Storybook's argTypes inference works for inline string unions (`'sm' | 'md' | 'lg'`) but degrades for type aliases imported from elsewhere, types behind generics, or unions inferred via `keyof typeof`. When inference fails, the control falls back to a free-text input — designers can type any string and crash the component. Declaring `control: 'select'` (or `'radio'` for ≤4 options, `'inline-radio'`, `'multi-select'`) with explicit `options` restores a real picker and documents the valid values in autodocs.

**Incorrect (imported union — control degrades to text input):**

```tsx
// types.ts
export type Variant = 'primary' | 'secondary' | 'ghost' | 'danger';

// Button.stories.tsx — inference can't reach `Variant`, control is text input
const meta = {
  component: Button,
} satisfies Meta<typeof Button>;
```

**Correct (explicit `control` + `options` — proper select widget):**

```tsx
import { VARIANTS, type Variant } from './types'; // VARIANTS = ['primary', 'secondary', 'ghost', 'danger'] as const

const meta = {
  component: Button,
  argTypes: {
    variant: {
      control: 'select',
      options: VARIANTS, // single source of truth — exported alongside the type
      table: { defaultValue: { summary: 'primary' } },
    },
  },
} satisfies Meta<typeof Button>;
```

**Common control widgets:**

| Type | `control` | When |
|------|-----------|------|
| Small union (≤4) | `'radio'` or `'inline-radio'` | Fits inline; no popover overhead |
| Larger union | `'select'` | Standard picker |
| Multiple values | `'multi-select'` | Array of union members |
| Number range | `{ type: 'range', min, max, step }` | Bounded numeric prop |
| Color | `'color'` | Hex/rgb input with picker |
| Hidden from panel | `false` | For callbacks, internal refs |
| Date | `'date'` | Date picker |

**Why this matters:** A text input where a select belongs is a designer trap and an autodocs lie. The valid options are part of the contract.

Reference: [Storybook controls](https://storybook.js.org/docs/essentials/controls), [argTypes API](https://storybook.js.org/docs/api/arg-types)
