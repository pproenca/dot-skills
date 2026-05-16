---
title: Surface component lifecycle with status tags and sidebar badges
impact: MEDIUM-HIGH
impactDescription: prevents consumers from adopting experimental APIs or depending on deprecated ones
tags: docs, status, lifecycle, deprecation
---

## Surface component lifecycle with status tags and sidebar badges

Design systems live across multiple stages — `experimental` (exploratory), `beta` (API stabilizing), `stable` (safe to depend on), `deprecated` (will be removed), `internal` (not for general use). Without surfacing this, consumers reach for whatever shows up in the sidebar and your design-system team gets bug reports against components flagged "do not use." Storybook tags + a sidebar-badge addon (e.g., `storybook-addon-tag-badges` or built-in tag styling in v9+) make lifecycle visible at a glance, both in the sidebar and in autodocs headers.

**Incorrect (no lifecycle metadata — consumers can't tell experimental from stable):**

```tsx
const meta = {
  component: NewExperimentalDataGrid,
  // Nothing flags this as experimental. Designers reach for it; team rewrites the API; consumers break.
} satisfies Meta<typeof NewExperimentalDataGrid>;
```

**Correct (status tag + sidebar badge config):**

```tsx
// NewDataGrid.stories.tsx
const meta = {
  component: NewDataGrid,
  tags: ['autodocs', 'experimental'],
  parameters: {
    docs: {
      description: {
        component:
          '> ⚠️ **Experimental.** API may change without a major version bump. ' +
          'Track stability in DESIGN-SYS-2310 before depending on it.',
      },
    },
  },
} satisfies Meta<typeof NewDataGrid>;
```

```ts
// .storybook/preview.ts — render badges in the sidebar for known tags
import { withTagBadges } from 'storybook-addon-tag-badges'; // or v9 built-in equivalent

const preview: Preview = {
  decorators: [withTagBadges],
  parameters: {
    tagBadges: [
      { tags: 'experimental', badge: { text: 'Experimental', style: { backgroundColor: '#ffb020' } } },
      { tags: 'beta',         badge: { text: 'Beta',         style: { backgroundColor: '#1ea7fd' } } },
      { tags: 'deprecated',   badge: { text: 'Deprecated',   style: { backgroundColor: '#ff4785' } } },
      { tags: 'internal',     badge: { text: 'Internal',     style: { backgroundColor: '#888' } } },
    ],
  },
};
```

**Deprecation pattern (point at the replacement):**

```tsx
const meta = {
  component: OldButton,
  tags: ['autodocs', 'deprecated'],
  parameters: {
    docs: {
      description: {
        component:
          '> ⛔️ **Deprecated.** Use [`Button`](?path=/docs/components-button--docs) instead. ' +
          'Removal scheduled for v3.0 (Q2 2026). See migration: MIGRATE-OldButton.md.',
      },
    },
  },
} satisfies Meta<typeof OldButton>;
```

**Suggested status taxonomy:**

| Tag | Meaning |
|-----|---------|
| `experimental` | API may change; not for production-critical paths |
| `beta` | Stabilizing; report breaking changes |
| `stable` | (default; usually no badge) |
| `deprecated` | Use the replacement; will be removed |
| `internal` | Not part of the public API surface |

**Why this matters:** Without lifecycle signals, the design system has no way to evolve — every component is implicitly stable, deprecation is impossible, and experiments get adopted before they're ready.

Reference: [Storybook tags](https://storybook.js.org/docs/writing-stories/tags), [storybook-addon-tag-badges](https://storybook.js.org/addons/storybook-addon-tag-badges)
