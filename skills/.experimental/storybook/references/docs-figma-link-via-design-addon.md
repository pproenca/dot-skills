---
title: Link each story to its Figma frame via `parameters.design`
impact: MEDIUM-HIGH
impactDescription: enables side-by-side Figma vs implementation review without context switching
tags: docs, figma, design, design-addon
---

## Link each story to its Figma frame via `parameters.design`

The `@storybook/addon-designs` (or `storybook-addon-designs`) package adds a Figma panel that embeds the linked frame next to the story. Designers can compare implementation to mock without a context switch; engineers can verify token values, spacing, and states against the design source. Wiring the link in `parameters.design` makes it a per-story commitment — every state (loading, empty, error) gets its own design link, not just one "happy path."

**Incorrect (no Figma link — designers and devs must switch tools to compare):**

```tsx
const meta = {
  component: Card,
  // No design link. The match between code and Figma is a "trust me" leap.
} satisfies Meta<typeof Card>;
```

**Correct (per-story Figma frames):**

```tsx
const meta = {
  component: Card,
  parameters: {
    design: {
      type: 'figma',
      url: 'https://www.figma.com/design/abc123/Design-System?node-id=42-1',
    },
  },
} satisfies Meta<typeof Card>;
export default meta;

type Story = StoryObj<typeof meta>;

// Each story can override with its own state-specific frame
export const Default: Story = {};

export const Loading: Story = {
  args: { loading: true },
  parameters: {
    design: {
      type: 'figma',
      url: 'https://www.figma.com/design/abc123/Design-System?node-id=42-2',
    },
  },
};

export const Empty: Story = {
  args: { items: [] },
  parameters: {
    design: {
      type: 'figma',
      url: 'https://www.figma.com/design/abc123/Design-System?node-id=42-3',
    },
  },
};
```

**Multi-design link (e.g., spec + interactive prototype):**

```tsx
parameters: {
  design: [
    { name: 'Spec', type: 'figma', url: 'https://figma.com/design/...?node-id=42-1' },
    { name: 'Prototype', type: 'figma', url: 'https://figma.com/proto/...?node-id=42-1' },
  ],
},
```

**Setup:**

```bash
npx storybook add @storybook/addon-designs
```

```ts
// .storybook/main.ts
const config = {
  addons: ['@storybook/addon-docs', '@storybook/addon-a11y', '@storybook/addon-designs'],
} satisfies StorybookConfig;
```

**Why this matters:** Without the Figma link, "match the design" is a verbal contract. With it, each PR shows the source design next to the rendered output, and reviewers can spot a drift in 5 seconds.

Reference: [@storybook/addon-designs](https://storybook.js.org/addons/@storybook/addon-designs)
