---
title: Set `parameters.a11y.test = 'error'` in `preview.ts`
impact: HIGH
impactDescription: enables a11y as a real CI gate instead of advisory warnings
tags: axe, a11y, preview, test
---

## Set `parameters.a11y.test = 'error'` in `preview.ts`

The `addon-a11y` v4+ `test` parameter has three values: `'off'` (panel only, no test integration), `'todo'` (warn but pass), and `'error'` (fail the test run on violation). The default is `'todo'` — which means by default, a11y violations show up in the panel but never break CI. Setting `test: 'error'` globally in `preview.ts` flips a11y into a real gate: every story that runs in the Vitest addon or test-runner will fail on a contrast issue, missing label, or invalid ARIA combination. Stories that legitimately need to bypass a check do so per-story.

**Incorrect (default — violations are visible but never fail builds):**

```ts
// .storybook/preview.ts
const preview: Preview = {
  parameters: {
    a11y: {
      // No `test` set — defaults to 'todo'. Panel shows violations, CI passes anyway.
    },
  },
};
```

**Correct (`test: 'error'` — a11y is a real gate):**

```ts
// .storybook/preview.ts
const preview: Preview = {
  parameters: {
    a11y: {
      test: 'error',
      options: {
        runOnly: ['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa', 'best-practice'],
      },
    },
  },
};
```

**Per-story relaxation (use sparingly, document why):**

```tsx
export const KnownContrastIssue: Story = {
  parameters: {
    a11y: {
      test: 'todo', // tracked in TICKET-1234; warn but don't fail
    },
  },
};
```

**Migration path for an existing codebase:**

The honest order of operations for adopting a11y as a gate on a codebase that already has violations:

1. Globally `test: 'todo'` — every story shows violations in the panel and a "TODO" badge but CI stays green.
2. Fix the existing violations in waves, story-by-story flipping per-story `test: 'error'`.
3. Once every story is clean, flip the global to `test: 'error'` and remove the per-story overrides.

Skipping straight to global `'error'` on a codebase with pre-existing violations means CI is red until everything is fixed — which usually means the global gets reverted instead.

**Why this matters:** Without `test: 'error'`, a11y is aspirational — it's "we have an audit panel" not "we won't ship a violation." With it, every PR that adds a story is also a WCAG check.

Reference: [Storybook a11y addon: configuration](https://storybook.js.org/docs/writing-tests/accessibility-testing#configure)
