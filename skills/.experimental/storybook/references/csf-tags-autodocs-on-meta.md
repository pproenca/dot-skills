---
title: "Put `tags: ['autodocs']` on the meta, not on individual stories"
impact: CRITICAL
impactDescription: prevents missing or duplicated docs pages
tags: csf, autodocs, tags, meta
---

## Put `tags: ['autodocs']` on the meta, not on individual stories

The `autodocs` tag generates a `Docs` entry under the component in the sidebar, derived from the meta and *all* stories in the file. Putting it on a single story means only that one story's MDX/args feed the docs page (the others are excluded). Putting it on the meta — the canonical location — ensures the docs page reflects every story in the file. Per-story `tags` exist for a different purpose: filtering test runs (`!test`, `dev`, custom labels) and excluding stories from the sidebar.

**Incorrect (`autodocs` on a single story — docs page misses other stories):**

```tsx
const meta = { component: Card } satisfies Meta<typeof Card>;
export default meta;

type Story = StoryObj<typeof meta>;

export const Default: Story = {
  args: { title: 'Hello' },
  tags: ['autodocs'], // wrong: docs page generated, but only from this story
};

export const Loading: Story = { args: { loading: true } }; // missing from docs
export const Error: Story = { args: { error: 'Boom' } };  // missing from docs
```

**Correct (`autodocs` on the meta — docs page reflects all three stories):**

```tsx
const meta = {
  component: Card,
  tags: ['autodocs'],
} satisfies Meta<typeof Card>;
export default meta;

type Story = StoryObj<typeof meta>;

export const Default: Story = { args: { title: 'Hello' } };
export const Loading: Story = { args: { loading: true } };
export const Error: Story = { args: { error: 'Boom' } };
```

**Per-story tags are for run scopes, not docs:**

```tsx
// Exclude a story from the sidebar but keep it for visual regression
export const InternalDebugView: Story = {
  args: { debug: true },
  tags: ['!dev', 'visual-only'],
};

// Skip a story in interaction tests (e.g. relies on external network)
export const LiveAPI: Story = {
  args: { fetcher: realApi },
  tags: ['!test'],
};
```

**Tag conventions:**
- `autodocs` — generate a Docs entry (use on meta, project-wide via `preview.ts`, or rarely per-story).
- `!dev` / `!test` — exclude from dev sidebar / test runs.
- Custom tags — used by addons or to filter via the test-runner CLI.

Reference: [Storybook tags](https://storybook.js.org/docs/writing-stories/tags), [Autodocs](https://storybook.js.org/docs/writing-docs/autodocs)
