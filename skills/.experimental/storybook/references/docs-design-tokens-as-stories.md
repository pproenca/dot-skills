---
title: Document design tokens as stories, not just MDX
impact: MEDIUM-HIGH
impactDescription: enables visual regression on token changes and prevents MDX hex-value drift
tags: docs, design-tokens, tokens, mdx
---

## Document design tokens as stories, not just MDX

Tokens (colors, spacing, type, shadows, radii) are the foundation of the design system; treating them as static MDX means a token change might pass review without anyone noticing the visual shift. Render tokens through *stories* and they get the same treatment as components: visual regression via Chromatic, autodocs prop tables (when each story shows one token category), and the `<ColorPalette>`/`<Typeset>`/`<IconGallery>` docs blocks for nicely formatted display in autodocs.

**Incorrect (hard-coded MDX — no diff coverage, drifts from the token source):**

```mdx
{/* docs/Colors.mdx — hand-pasted hex values; drifts when tokens.ts changes */}
<Meta title="Foundations/Colors" />

# Colors

- Primary: `#1ea7fd`
- Secondary: `#ff4785`
- Success: `#66bf3c`
```

**Correct (tokens fed into a `<ColorPalette>` story — autoupdates and gets Chromatic snapshots):**

```tsx
// Tokens.stories.tsx
import type { Meta, StoryObj } from '@storybook/react-vite';
import { ColorPalette, ColorItem, Typeset, IconGallery, IconItem } from '@storybook/addon-docs/blocks';
import { tokens } from '../src/theme/tokens';
import { icons } from '../src/icons';

const meta = {
  title: 'Foundations/Tokens',
  tags: ['autodocs'],
  parameters: { layout: 'padded' },
} satisfies Meta;
export default meta;

type Story = StoryObj<typeof meta>;

export const Colors: Story = {
  render: () => (
    <ColorPalette>
      {Object.entries(tokens.color.semantic).map(([name, value]) => (
        <ColorItem key={name} title={name} subtitle={value} colors={{ [name]: value }} />
      ))}
    </ColorPalette>
  ),
};

export const Typography: Story = {
  render: () => (
    <Typeset
      fontSizes={tokens.type.sizes}
      fontWeight={400}
      sampleText="The quick brown fox jumps over the lazy dog"
      fontFamily={tokens.type.sans}
    />
  ),
};

export const Icons: Story = {
  render: () => (
    <IconGallery>
      {Object.entries(icons).map(([name, Icon]) => (
        <IconItem key={name} name={name}>
          <Icon className="size-6" />
        </IconItem>
      ))}
    </IconGallery>
  ),
};
```

**Bonus: per-token stories with controls for live tinkering:**

```tsx
export const ColorPickerPlayground: Story = {
  args: {
    foreground: tokens.color.semantic['text.primary'],
    background: tokens.color.semantic['surface.default'],
  },
  argTypes: {
    foreground: { control: 'color' },
    background: { control: 'color' },
  },
  render: ({ foreground, background }) => (
    <div style={{ background, color: foreground, padding: 24 }}>
      Contrast preview — adjust controls to test combinations.
    </div>
  ),
};
```

**Why this matters:** Tokens are state that propagates to every component. Story-based docs catch drift the same way component stories do; MDX-only docs go stale silently.

Reference: [Storybook design-system docs blocks](https://storybook.js.org/docs/api/doc-blocks/doc-block-colorpalette), [ColorPalette / Typeset / IconGallery](https://storybook.js.org/docs/api/doc-blocks/doc-block-typeset)
