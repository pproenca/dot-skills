---
title: The default export is the `meta`, never a story
impact: CRITICAL
impactDescription: prevents silent story-discovery breakage
tags: csf, exports, meta, conventions
---

## The default export is the `meta`, never a story

CSF treats the default export as the file's `Meta` and *every named export* as a story. A file that default-exports something other than the meta — a story object, a component, a render function — is silently ignored by the story-discovery layer: the file appears in no sidebar entry, the controls/autodocs/test pipelines never see it, and there is no error message. This is a frequent failure mode when copy-pasting a component file into a new stories file or when wrapping with `React.memo`.

**Incorrect (default-exports the component, no meta — the file is invisible to Storybook):**

```tsx
// Card.stories.tsx
import { Card } from './Card';

// Wrong: default export is a component, not a Meta
export default Card;

export const Default = { args: { title: 'Hello' } };
```

**Incorrect (default-exports a story object — also wrong):**

```tsx
// Card.stories.tsx
const meta = { component: Card } satisfies Meta<typeof Card>;
type Story = StoryObj<typeof meta>;

export default { args: { title: 'Hello' } } satisfies Story; // Storybook treats this as the meta and breaks
export const Loading: Story = { args: { loading: true } };
```

**Correct (default = meta, named = stories):**

```tsx
// Card.stories.tsx
import type { Meta, StoryObj } from '@storybook/react-vite';
import { Card } from './Card';

const meta = {
  component: Card,
  tags: ['autodocs'],
} satisfies Meta<typeof Card>;
export default meta;

type Story = StoryObj<typeof meta>;

export const Default: Story = { args: { title: 'Hello' } };
export const Loading: Story = { args: { loading: true } };
```

**Tip:** ESLint plugin `eslint-plugin-storybook` includes the `storybook/default-exports` rule which catches this. Install as a regular dev dep:

```bash
npm install --save-dev eslint-plugin-storybook
```

```ts
// eslint.config.ts (flat config)
import storybook from 'eslint-plugin-storybook';

export default [
  ...storybook.configs['flat/recommended'],
];
```

Reference: [Storybook CSF default export](https://storybook.js.org/docs/api/csf#default-export), [eslint-plugin-storybook](https://github.com/storybookjs/eslint-plugin-storybook)
