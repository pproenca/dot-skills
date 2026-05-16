---
title: Use `autodocs` for component pages, MDX for cross-cutting docs
impact: MEDIUM-HIGH
impactDescription: prevents handwritten prop-table drift while preserving MDX for cross-cutting docs
tags: docs, autodocs, mdx, design-system
---

## Use `autodocs` for component pages, MDX for cross-cutting docs

`tags: ['autodocs']` generates a Docs page from the meta and stories — the prop table comes from `argTypes`, the examples come from each story, and the source view comes from the story itself. It stays in sync because there's no separate file to update. MDX is the right tool when content can't be expressed as "props + stories": the design-system intro page, theming and tokens explanation, contribution guidelines, multi-component patterns. The wrong choice in either direction produces docs that drift (handwritten MDX where autodocs would suffice) or miss content (autodocs trying to carry conceptual prose).

**Incorrect (handwritten MDX duplicating what autodocs would generate from a single component's stories):**

```mdx
{/* docs/Card.mdx — duplicates what autodocs already produces */}
<Meta title="Components/Card" />

# Card

A surface for grouping related content. Props:

| Prop | Type | Default |
|------|------|---------|
| title | string | — |
| body | string | — |
| onAction | () => void | — |
{/* This table goes stale the moment Card.tsx adds a prop */}

## Default
{/* hand-written render — drifts from Card.stories.tsx */}
<Card title="Hello" body="World" />
```

**Correct (autodocs for a single component; MDX reserved for cross-cutting design pages):**

```tsx
// Card.stories.tsx — autodocs handles the prop table and examples
const meta = {
  component: Card,
  tags: ['autodocs'],
  parameters: {
    docs: {
      description: {
        component:
          'Surface for grouping related content. Use over `<section>` when you need ' +
          'visual elevation (shadow, border) or interactive affordances (hover, focus).',
      },
    },
  },
} satisfies Meta<typeof Card>;
```

```mdx
{/* docs/Theming.mdx — MDX for a conceptual, cross-component page */}
import { Meta, ColorPalette, ColorItem } from '@storybook/addon-docs/blocks';
import { tokens } from '../src/theme/tokens';

<Meta title="Foundations/Theming" />

# Theming

The design system uses a two-layer token model:

1. **Primitive tokens** — raw values (colors, sizes, type scales).
2. **Semantic tokens** — contextual aliases (`color.surface`, `color.text.primary`).

Components consume only semantic tokens, so re-theming means swapping the alias map.

<ColorPalette>
  {Object.entries(tokens.color.semantic).map(([name, value]) => (
    <ColorItem key={name} title={name} colors={[value]} />
  ))}
</ColorPalette>
```

**Mix when needed (MDX page that embeds a component's stories):**

```mdx
{/* docs/CardPatterns.mdx — conceptual prose with live story examples */}
import { Meta, Canvas, Story } from '@storybook/addon-docs/blocks';
import * as CardStories from '../components/Card/Card.stories';

<Meta title="Patterns/Card layouts" />

# Card layouts

Cards group content. Three common layouts:

## Default
<Canvas of={CardStories.Default} />

## With actions
<Canvas of={CardStories.WithActions} />
```

**Decision rule:**

| Content | Use |
|---------|-----|
| Single-component prop reference | `autodocs` |
| Multiple components in one explanation | MDX |
| Design tokens, type scale, color palette | MDX with `<ColorPalette>` / `<Typeset>` |
| Contributing / setup / philosophy | MDX |
| Live examples that should also drive controls | Stories (autodocs picks them up) |

Reference: [Storybook autodocs](https://storybook.js.org/docs/writing-docs/autodocs), [MDX docs](https://storybook.js.org/docs/writing-docs/mdx)
