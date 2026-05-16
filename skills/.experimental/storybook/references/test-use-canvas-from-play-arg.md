---
title: Destructure `canvas` and `userEvent` from the `play` argument
impact: HIGH
impactDescription: eliminates 2 lines of boilerplate per play function and aligns with v9+ test API
tags: test, canvas, userEvent, play
---

## Destructure `canvas` and `userEvent` from the `play` argument

Storybook 9 injects a pre-scoped `canvas` (already wrapped with `within(canvasElement)`) and a `userEvent` instance into the play function's first argument, so most plays can be written without any imports from `storybook/test` at all. This eliminates the legacy `const canvas = within(canvasElement)` line, scopes queries automatically to the story root, and avoids the global `userEvent` setup race that bit Testing Library users for years.

**Incorrect (legacy boilerplate — manual `within`, top-level `userEvent`):**

```tsx
import { userEvent, within } from 'storybook/test';

export const Submits: Story = {
  play: async ({ canvasElement }) => {
    const canvas = within(canvasElement); // boilerplate
    await userEvent.click(canvas.getByRole('button'));
  },
};
```

**Correct (destructured — no imports needed for the basic flow):**

```tsx
export const Submits: Story = {
  play: async ({ canvas, userEvent }) => {
    await userEvent.click(canvas.getByRole('button'));
  },
};
```

**You still import for assertions and spies:**

```tsx
import { expect, fn } from 'storybook/test';

const meta = {
  component: LoginForm,
  args: { onSubmit: fn() },
} satisfies Meta<typeof LoginForm>;

export const Submits: StoryObj<typeof meta> = {
  play: async ({ args, canvas, userEvent }) => {
    await userEvent.type(canvas.getByLabelText(/email/i), 'ada@example.com');
    await userEvent.type(canvas.getByLabelText(/password/i), 'hunter2');
    await userEvent.click(canvas.getByRole('button', { name: /sign in/i }));

    await expect(args.onSubmit).toHaveBeenCalledWith({
      email: 'ada@example.com',
      password: 'hunter2',
    });
  },
};
```

**When you DO need raw `canvasElement`:**
- Querying outside the story root (e.g., a portal at `document.body`). Use `within(document.body)` for that scope explicitly.

**Why this matters:** The injected `canvas`/`userEvent` is the v9+ contract; future test improvements (parallel runs, isolated DOM, browser-mode optimizations) plug in here.

Reference: [Storybook 9 play API](https://storybook.js.org/docs/writing-tests/interaction-testing#write-an-interaction-test)
