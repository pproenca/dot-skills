---
title: Use `fn()` spies on callback args, then assert in `play`
impact: HIGH
impactDescription: enables behavior assertions on every story without duplicate fixtures
tags: test, fn, spies, assertions
---

## Use `fn()` spies on callback args, then assert in `play`

A story that displays a "submit" button but doesn't assert that clicking it calls `onSubmit` is a screenshot, not a test. `fn()` from `storybook/test` returns a Vitest-compatible mock with `.toHaveBeenCalled*` matchers and `.mock.calls` introspection — declared once in `meta.args` (or per-story `args`), it's available in every `play` function as `args.onSubmit`. The pattern is: declare the spy, drive the UI, assert the spy was called with the expected payload.

**Incorrect (no spy — story is just a render check, behaviour is untested):**

```tsx
const meta = {
  component: LoginForm,
} satisfies Meta<typeof LoginForm>;
export default meta;

export const Submits: StoryObj<typeof meta> = {
  args: {
    onSubmit: () => {}, // anonymous — can't be asserted
  },
  play: async ({ canvas, userEvent }) => {
    await userEvent.click(canvas.getByRole('button', { name: /sign in/i }));
    // No assertion — test passes whether onSubmit fires or not
  },
};
```

**Correct (`fn()` spy + assertion on call args):**

```tsx
import { expect, fn } from 'storybook/test';

const meta = {
  component: LoginForm,
  args: {
    onSubmit: fn(),
  },
} satisfies Meta<typeof LoginForm>;
export default meta;

type Story = StoryObj<typeof meta>;

export const SubmitsValidCredentials: Story = {
  play: async ({ args, canvas, userEvent }) => {
    await userEvent.type(canvas.getByLabelText(/email/i), 'ada@example.com');
    await userEvent.type(canvas.getByLabelText(/password/i), 'hunter2');
    await userEvent.click(canvas.getByRole('button', { name: /sign in/i }));

    await expect(args.onSubmit).toHaveBeenCalledOnce();
    await expect(args.onSubmit).toHaveBeenCalledWith({
      email: 'ada@example.com',
      password: 'hunter2',
    });
  },
};

export const ValidatesEmail: Story = {
  play: async ({ args, canvas, userEvent }) => {
    await userEvent.type(canvas.getByLabelText(/email/i), 'not-an-email');
    await userEvent.click(canvas.getByRole('button', { name: /sign in/i }));

    await expect(args.onSubmit).not.toHaveBeenCalled();
    await expect(canvas.getByText(/invalid email/i)).toBeInTheDocument();
  },
};
```

**Lifecycle:** Storybook resets `fn()` spies between story renders and between play runs. Within one play, you can call `args.onSubmit.mockClear()` to reset between sub-flows.

**Why this matters:** The same story file becomes documentation, design-system surface, and regression test — without duplicating fixtures across `*.test.tsx` and `*.stories.tsx`.

Reference: [Storybook fn API](https://storybook.js.org/docs/writing-tests/interaction-testing#actions-for-component-events)
