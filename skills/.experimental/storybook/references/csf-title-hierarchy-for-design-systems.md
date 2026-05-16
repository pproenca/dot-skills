---
title: Title each meta with a design-system taxonomy, not just the component name
impact: HIGH
impactDescription: prevents flat-sidebar collapse at 20+ components; enables sidebar taxonomy at scale
tags: csf, title, hierarchy, taxonomy, foundations
---

## Title each meta with a design-system taxonomy, not just the component name

A `title` of `'Button'` ends up at the top level of the sidebar, jostling with `'Foundations'`, `'Welcome'`, and a hundred peers. A `title` of `'Atoms/Button'` (or `'Components/Inputs/Button'`) slots cleanly into the curated `storySort` order, lets you group related stories under one folder, and is what `<Canvas of={Default} />` references resolve against. The taxonomy is part of the design system's vocabulary — `Foundations/`, `Components/`, `Patterns/`, `Examples/` give designers and engineers a shared mental model and let CI / Chromatic scope diffs by area (e.g., "show me only Foundations changes in this PR").

**Incorrect (flat titles — sidebar is one long list of components):**

```tsx
// src/Button/Button.stories.tsx
const meta = {
  title: 'Button',          // top-level — next to "Card", "Modal", "Welcome"
  component: Button,
} satisfies Meta<typeof Button>;
```

**Correct (taxonomy-aware title — slots into the design system):**

```tsx
// src/components/inputs/Button/Button.stories.tsx
const meta = {
  title: 'Components/Inputs/Button',
  component: Button,
  tags: ['autodocs'],
} satisfies Meta<typeof Button>;

export default meta;

export const Primary:   StoryObj<typeof meta> = { args: { variant: 'primary',   children: 'Save' } };
export const Secondary: StoryObj<typeof meta> = { args: { variant: 'secondary', children: 'Cancel' } };
```

**Recommended taxonomy for a generic design system:**

| Top-level | When to use | Examples |
|-----------|-------------|----------|
| `Welcome` | Single landing page | `Welcome` |
| `Getting Started` | Onboarding docs | `Getting Started/Installation`, `Getting Started/Theming` |
| `Foundations` | Non-component primitives | `Foundations/Colors`, `Foundations/Typography`, `Foundations/Spacing` |
| `Tokens` | Token-level docs separate from foundations | `Tokens/Reference`, `Tokens/Semantic` |
| `Components` | The component library itself | `Components/Inputs/Button`, `Components/Layout/Stack` |
| `Patterns` | Compositions of multiple components | `Patterns/Form`, `Patterns/Empty State`, `Patterns/Filter Bar` |
| `Examples` | Real-world usage (full pages) | `Examples/Settings Page`, `Examples/Checkout` |
| `Internal` | Engineering-only, not for designers | `Internal/Test Fixtures`, `Internal/Playground` |

**Atomic-design variant:**

| Top-level | Definition |
|-----------|------------|
| `Foundations` | Tokens, type scale, color, motion |
| `Atoms` | Smallest standalone components (Button, Input, Icon) |
| `Molecules` | Composed atoms (Search field = Input + Button) |
| `Organisms` | Larger sections (Header, Card, DataTable) |
| `Templates` | Layout skeletons without real content |
| `Pages` | Filled-in templates representing real screens |

**Pair with `storySort` order in `preview.ts`** (see `config-story-sort-for-large-libraries`) — the title taxonomy is meaningless if the sidebar order is implicit:

```ts
options: {
  storySort: {
    order: ['Welcome', 'Foundations', 'Tokens', 'Components', 'Patterns', 'Examples', 'Internal'],
  },
},
```

**Co-locate the file with the source, but title independently of the path:**

```text
src/components/inputs/Button/
├── Button.tsx
├── Button.module.css
├── Button.test.tsx
└── Button.stories.tsx     // title: 'Components/Inputs/Button' — not tied to file path
```

The file path drives glob matching in `main.ts`'s `stories` field; the `title` drives the sidebar. Decoupling them means refactoring the directory structure (e.g., moving `inputs/` to `forms/`) doesn't reshuffle the sidebar.

**When NOT to use this pattern:**
- A flat app-level Storybook (not a design system) with <15 stories — taxonomy is overkill.
- MDX-only docs that use filename prefixes (`01-intro.mdx`, `02-tokens.mdx`) for ordering — those don't need title hierarchy.

**Why this matters:** Without taxonomy, the sidebar is a dump of file names. With taxonomy, it's a navigable map of the design system. The model also generates better sibling stories when the title encodes "this is an Input component" — it knows what kinds of stories belong (states, disabled, error, loading) without re-reading every neighbor.

Reference: [Storybook naming components and hierarchy](https://storybook.js.org/docs/writing-stories/naming-components-and-hierarchy), [Structuring your Storybook](https://storybook.js.org/blog/structuring-your-storybook/), [Atomic Design — Brad Frost](https://atomicdesign.bradfrost.com/chapter-2/)
