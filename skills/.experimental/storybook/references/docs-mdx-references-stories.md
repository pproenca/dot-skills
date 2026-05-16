---
title: In MDX, reference stories with `<Canvas of={Story} />` instead of duplicating renders
impact: MEDIUM-HIGH
impactDescription: prevents MDX inline renders from drifting from the stories file
tags: docs, mdx, canvas, stories
---

## In MDX, reference stories with `<Canvas of={Story} />` instead of duplicating renders

Old MDX (Storybook 6 era) embedded story renders inline (`<Story name="Default">{() => <Card />}</Story>`), which created two sources of truth — the stories file and the MDX. Modern MDX (`addon-docs`) uses `<Canvas of={Story} />` and `<Stories />` blocks that reference the imported stories module. Edit the story, the doc updates. The pattern: stories are the source of truth for examples; MDX is prose around them.

**Incorrect (inline render in MDX — duplicates the stories file):**

```mdx
{/* docs/Card.mdx — inline render, drifts from Card.stories.tsx */}
import { Meta, Story } from '@storybook/addon-docs/blocks';
import { Card } from '../src/components/Card';

<Meta title="Components/Card" />

# Card

<Story name="Default">
  {() => <Card title="Inline render — won't pick up changes from Card.stories.tsx" />}
</Story>
```

**Correct (`<Canvas of={...} />` references the actual story):**

```mdx
{/* Card.mdx — references stories from Card.stories.tsx */}
import { Meta, Canvas, Stories, ArgTypes } from '@storybook/addon-docs/blocks';
import * as CardStories from '../src/components/Card/Card.stories';

<Meta of={CardStories} />

# Card

A surface for grouping related content. Use when content needs visual elevation
or interactive affordances.

## Default
<Canvas of={CardStories.Default} />

## All variants
<Stories />

## Props
<ArgTypes of={CardStories.Default} />
```

**Useful blocks from `@storybook/addon-docs/blocks`:**

| Block | Renders |
|-------|---------|
| `<Meta of={module} />` | Connects this MDX page to a stories file |
| `<Canvas of={Story} />` | One story with its source code panel |
| `<Stories />` | Every story from the connected meta as a series of canvases |
| `<ArgTypes of={Story} />` | The args/props table |
| `<Source of={Story} />` | Just the source code, no canvas |
| `<Title />`, `<Subtitle />`, `<Description />` | Reads from `meta.parameters.docs` |

**Why this matters:** When examples in MDX duplicate the stories file, they go stale within a sprint. `of={...}` makes the stories file the single source of truth — MDX is purely prose.

Reference: [Storybook MDX blocks](https://storybook.js.org/docs/writing-docs/mdx#defining-stories-with-mdx), [Doc Blocks API](https://storybook.js.org/docs/api/doc-blocks/doc-block-canvas)
