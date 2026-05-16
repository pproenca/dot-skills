---
title: Import test utilities from `storybook/test`, not `@storybook/test`
impact: HIGH
impactDescription: prevents silent breakage on Storybook 9+ upgrade
tags: test, imports, storybook-test, migration
---

## Import test utilities from `storybook/test`, not `@storybook/test`

Storybook 9 moved the test API from the standalone `@storybook/test` package into the core under the subpath `storybook/test`. The old package still resolves but is the v8 API and will not receive new features (the `canvas` and `userEvent` injected via `play` args land in `storybook/test`). Mixing the two paths in one project produces two copies of `expect`, two action contexts, and play functions that look identical but behave differently. Standardize on `storybook/test` everywhere.

**Incorrect (legacy import — won't track Storybook 9+ improvements):**

```tsx
import { expect, fn, userEvent, within } from '@storybook/test';

export const Submits: Story = {
  args: { onSubmit: fn() },
  play: async ({ args, canvasElement }) => {
    const canvas = within(canvasElement); // legacy: explicit within()
    await userEvent.click(canvas.getByRole('button'));
    await expect(args.onSubmit).toHaveBeenCalledOnce();
  },
};
```

**Correct (modern path + injected `canvas`/`userEvent`):**

```tsx
import { expect, fn } from 'storybook/test';

export const Submits: Story = {
  args: { onSubmit: fn() },
  play: async ({ args, canvas, userEvent }) => {
    await userEvent.click(canvas.getByRole('button'));
    await expect(args.onSubmit).toHaveBeenCalledOnce();
  },
};
```

**Migration pointer:** Run `npx storybook@latest upgrade`; the codemod replaces `@storybook/test` imports automatically. After upgrading, `@storybook/test` can be removed from `package.json`.

**Why this matters:** The two paths look identical and tests pass in both, so the divergence is invisible until you adopt a v9-only feature (e.g., the `play`-injected `canvas` and `userEvent`) and one half of your stories silently breaks.

Reference: [Storybook 9 release notes](https://storybook.js.org/blog/storybook-9), [Test API](https://storybook.js.org/docs/writing-tests/interaction-testing)
