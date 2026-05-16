---
title: Name stories by the state they capture, not the prop they set
impact: CRITICAL
impactDescription: enables designers and PMs to scan the sidebar without reading args
tags: csf, naming, stories, sidebar
---

## Name stories by the state they capture, not the prop they set

Story names appear in the sidebar, the docs page, the test runner output, and the Chromatic snapshot list. A name like `PrimaryTrue` or `SizeMd` describes a prop value but not why the story exists; readers must mentally translate to "what state is this?". A name like `Loading`, `Empty`, `WithLongTitle`, or `Disabled` describes the user-visible state and is immediately scannable. CSF3 lets you set explicit `name`, but the convention is: the *export name* is the state.

**Incorrect (named by prop value — sidebar reads as a prop matrix):**

```tsx
// Button.stories.tsx
const meta = { component: Button } satisfies Meta<typeof Button>;
export default meta;

type Story = StoryObj<typeof meta>;

export const VariantPrimary: Story = { args: { variant: 'primary' } };
export const VariantSecondary: Story = { args: { variant: 'secondary' } };
export const SizeSm: Story = { args: { size: 'sm' } };
export const DisabledTrue: Story = { args: { disabled: true } };
// Sidebar: Variant Primary / Variant Secondary / Size Sm / Disabled True
```

**Correct (named by state — sidebar reads as a UX catalog):**

```tsx
// Button.stories.tsx
const meta = { component: Button } satisfies Meta<typeof Button>;
export default meta;

type Story = StoryObj<typeof meta>;

export const Primary: Story = { args: { variant: 'primary' } };
export const Secondary: Story = { args: { variant: 'secondary' } };
export const Compact: Story = { args: { size: 'sm' } };
export const Disabled: Story = { args: { disabled: true, children: 'Submit' } };
export const LoadingWithLabel: Story = { args: { loading: true, children: 'Saving…' } };
// Sidebar: Primary / Secondary / Compact / Disabled / Loading With Label
```

**Override the display name when the export name is awkward:**

```tsx
export const ChromeOnMacOSWithDarkTheme: Story = {
  name: 'Chrome (macOS, dark theme)',
  args: { theme: 'dark' },
  globals: { browser: 'chrome', os: 'macos' },
};
```

**Why this matters:** Designers and PMs scan the sidebar; they don't read the args. State-named stories are self-documenting; prop-named stories make the sidebar a Cartesian product nobody navigates.

Reference: [Storybook stories: naming components and hierarchy](https://storybook.js.org/docs/writing-stories/naming-components-and-hierarchy)
