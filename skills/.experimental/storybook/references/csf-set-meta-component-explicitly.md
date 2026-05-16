---
title: Always set `component` on the meta
impact: CRITICAL
impactDescription: enables autodocs, controls, prop-type inference, and arg autocompletion
tags: csf, meta, component, autodocs
---

## Always set `component` on the meta

`meta.component` is the anchor every Storybook tool reads from. Without it: the autodocs page has no prop table, the controls panel cannot derive `argTypes` from the component's props, `StoryObj<typeof meta>` cannot infer arg types, and the a11y addon has no way to associate violations with the component. A meta with only `title` and `parameters` is a broken meta — it boots, but every downstream tool degrades to "best-effort guessing from your render function."

**Incorrect (no `component` — autodocs and controls are degraded):**

```tsx
// Card.stories.tsx
const meta = {
  title: 'Components/Card',
  parameters: { layout: 'padded' },
} satisfies Meta;

export default meta;

export const Default: StoryObj<typeof meta> = {
  render: () => <Card title="Hello" body="World" />,
};
```

**Correct (`component` set — autodocs, controls, types all work):**

```tsx
// Card.stories.tsx
import { Card } from './Card';

const meta = {
  component: Card,
  title: 'Components/Card', // optional; can be inferred from path
  parameters: { layout: 'padded' },
  tags: ['autodocs'],
} satisfies Meta<typeof Card>;
export default meta;

export const Default: StoryObj<typeof meta> = {
  args: { title: 'Hello', body: 'World' },
};
```

**When NOT to use this pattern:**
- A story file that's a *gallery* of multiple components with no single primary component — even then, prefer one stories file per component and a separate MDX page for the gallery.

**Why this matters:** Autodocs, controls, and a11y are the three things teams adopt Storybook for. All three depend on `meta.component`.

Reference: [Storybook CSF: meta](https://storybook.js.org/docs/api/csf#default-export)
