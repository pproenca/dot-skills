---
title: Configure `storySort` in `preview.ts` for large design systems
impact: HIGH
impactDescription: prevents unsorted-sidebar chaos as the library grows past 30+ components
tags: config, story-sort, sidebar, atomic-design, hierarchy
---

## Configure `storySort` in `preview.ts` for large design systems

Out of the box, Storybook sorts the sidebar by file-system order — useful for a 10-component library, chaotic for a 50+ component design system. Without explicit `storySort`, "Welcome" ends up below "Z-Spinner," "Foundations/Colors" is buried in the middle, and every new component shows up wherever the bundler happened to import it. `parameters.options.storySort` lets you pin the top of the sidebar (Welcome → Foundations → Tokens) and alphabetize everything else, or define a full atomic-design / functional taxonomy. The configuration cascades: every new story falls into place without anyone touching the sidebar.

**Incorrect (no `storySort` — sidebar order = bundler import order):**

```ts
// .storybook/preview.ts
const preview: Preview = {
  parameters: {
    // No `options.storySort`. "Welcome" ends up wherever Vite resolves it;
    // adding a new "Button" story can shuffle 20 sibling positions.
  },
};
export default preview;
```

**Correct (explicit `storySort` with anchored top + alphabetized rest):**

```ts
// .storybook/preview.ts
import type { Preview } from '@storybook/react-vite';

const preview: Preview = {
  parameters: {
    options: {
      storySort: {
        method: 'alphabetical',
        order: [
          'Welcome',
          'Getting Started', ['Installation', 'Usage', 'Theming'],
          'Foundations',     ['Colors', 'Typography', 'Spacing', 'Radii', 'Shadows', 'Icons'],
          'Tokens',          ['Reference', 'Semantic', 'Component'],
          'Components',      ['*'],   // alphabetize everything inside Components/
          'Patterns',
          'Examples',
          'Internal',
        ],
        locales: 'en-US',
      },
    },
  },
};
export default preview;
```

**Atomic-design variant:**

```ts
options: {
  storySort: {
    order: [
      'Welcome',
      'Foundations', ['Colors', 'Typography', 'Spacing', '*'],
      'Atoms',       ['*'],
      'Molecules',   ['*'],
      'Organisms',   ['*'],
      'Templates',   ['*'],
      'Pages',       ['*'],
    ],
  },
},
```

**Pair with title-hierarchy on each meta** (see `csf-title-hierarchy-for-design-systems`):

```tsx
// src/atoms/Button/Button.stories.tsx
const meta = {
  title: 'Atoms/Button',       // matches the `Atoms` entry in storySort.order
  component: Button,
} satisfies Meta<typeof Button>;
```

**For >2-level nesting** (e.g., `Components/Forms/Inputs/TextInput`), the built-in sorter only goes two levels deep. Install [`storybook-multilevel-sort`](https://storybook.js.org/addons/storybook-multilevel-sort) and replace the built-in sorter:

```ts
import { storySort } from 'storybook-multilevel-sort';

const preview: Preview = {
  parameters: {
    options: {
      storySort: storySort({
        storyOrder: {
          Foundations: { Colors: null, Typography: null },
          Components:  { Forms: { Inputs: null, Pickers: null }, Layout: null },
        },
      }),
    },
  },
};
```

**Functional variant (for component-by-role grouping):**

```ts
options: {
  storySort: {
    order: [
      'Welcome',
      'Foundations',
      'Inputs',     ['Button', 'TextField', 'Select', 'Checkbox', 'Radio', '*'],
      'Layout',     ['Stack', 'Grid', 'Container', '*'],
      'Navigation', ['Tabs', 'Breadcrumbs', '*'],
      'Feedback',   ['Toast', 'Alert', 'Spinner', '*'],
      'Data Display',
      'Overlays',   ['Modal', 'Popover', 'Tooltip', '*'],
    ],
  },
},
```

**When NOT to use this pattern:**
- A tiny app-internal Storybook (<15 components). File-order sorting is fine; `storySort` is overhead.
- Pure documentation Storybooks (no components) where MDX titles already encode the order via filename prefixes (`01-intro.mdx`).

**Why this matters:** The sidebar is the first thing a designer or new engineer sees. A scrambled sidebar makes a 50-component library feel impenetrable; a curated sidebar makes the same library feel curated. The cost of getting this right is one config block.

Reference: [Storybook sidebar & URLs](https://storybook.js.org/docs/configure/user-interface/sidebar-and-urls), [Naming and hierarchy](https://storybook.js.org/docs/writing-stories/naming-components-and-hierarchy), [Structuring your Storybook](https://storybook.js.org/blog/structuring-your-storybook/), [storybook-multilevel-sort](https://storybook.js.org/addons/storybook-multilevel-sort)
