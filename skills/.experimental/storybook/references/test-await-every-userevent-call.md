---
title: "Always `await` every `userEvent` call in `play` functions"
impact: HIGH
impactDescription: eliminates flaky CI runs from race conditions
tags: test, userEvent, async, flakiness
---

## Always `await` every `userEvent` call in `play` functions

`userEvent` is async — every interaction returns a Promise that resolves *after* React has flushed effects, the focus has moved, and the next paint has happened. Skipping `await` means the next assertion fires before the click has actually changed the DOM. The story passes in dev (the next paint usually wins by the time the assertion runs locally) and fails in CI (where browser scheduling is different). One missing `await` is the most common source of flaky Storybook tests.

**Incorrect (no `await` — race between click and assertion):**

```tsx
export const Submits: Story = {
  args: { onSubmit: fn() },
  play: async ({ args, canvas, userEvent }) => {
    userEvent.type(canvas.getByLabelText(/email/i), 'ada@example.com'); // no await
    userEvent.click(canvas.getByRole('button', { name: /sign in/i }));  // no await
    expect(args.onSubmit).toHaveBeenCalledOnce(); // races: may run before click resolves
  },
};
```

**Correct (`await` every interaction; assertions can also `await` to wait for async UI):**

```tsx
export const Submits: Story = {
  args: { onSubmit: fn() },
  play: async ({ args, canvas, userEvent }) => {
    await userEvent.type(canvas.getByLabelText(/email/i), 'ada@example.com');
    await userEvent.click(canvas.getByRole('button', { name: /sign in/i }));
    await expect(args.onSubmit).toHaveBeenCalledOnce();
  },
};
```

**Lint help:** `eslint-plugin-storybook` ships `storybook/await-interactions` which flags un-awaited `userEvent`/`expect`/`waitFor` calls. Enable it in your flat config; one less class of bug.

**Why this matters:** Flaky tests erode trust in the suite. The fix is mechanical (`await` everywhere) and the lint rule makes it permanent — but every team rediscovers this the hard way.

Reference: [Storybook play functions](https://storybook.js.org/docs/writing-tests/interaction-testing#run-interaction-tests-with-the-vitest-addon), [eslint-plugin-storybook](https://github.com/storybookjs/eslint-plugin-storybook)
