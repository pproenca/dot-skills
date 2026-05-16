---
title: Use `fn()` from `storybook/test` for callback args
impact: HIGH
impactDescription: enables Actions tab logging and spy-based assertions in one line
tags: args, fn, actions, callbacks
---

## Use `fn()` from `storybook/test` for callback args

`fn()` from `storybook/test` returns a Vitest-compatible spy that Storybook also displays in the Actions tab whenever the callback fires. One declaration gives you (a) visual confirmation in dev that the handler ran, (b) an assertable spy in `play` functions (`expect(args.onSubmit).toHaveBeenCalledWith(...)`), and (c) Vitest test compatibility via the `addon-vitest` runner. The legacy `argTypes: { onClick: { action: 'clicked' } }` only does (a) and is being phased out in favour of `fn()`.

**Incorrect (separate action declaration — no spy, can't assert in play):**

```tsx
const meta = {
  component: SubmitButton,
  argTypes: {
    onSubmit: { action: 'submit' }, // logs in Actions tab but not assertable
  },
} satisfies Meta<typeof SubmitButton>;
```

**Correct (`fn()` — logs AND is assertable):**

```tsx
import { expect, fn, userEvent } from 'storybook/test';

const meta = {
  component: SubmitButton,
  args: {
    onSubmit: fn(),
  },
} satisfies Meta<typeof SubmitButton>;
export default meta;

type Story = StoryObj<typeof meta>;

export const Submits: Story = {
  args: { label: 'Send' },
  play: async ({ args, canvas, userEvent }) => {
    await userEvent.click(canvas.getByRole('button', { name: /send/i }));
    await expect(args.onSubmit).toHaveBeenCalledOnce();
  },
};
```

**Reset spies between play runs:** Storybook resets `fn()` spies automatically between story renders. If you have a play function that re-mounts within itself, call `args.onSubmit.mockClear()` between assertions.

**Why this matters:** A handler that "looks like it works" in dev but isn't asserted in tests is the exact failure mode component testing is meant to prevent. `fn()` collapses both into one arg.

Reference: [Storybook test API: fn](https://storybook.js.org/docs/writing-tests/interaction-testing#actions-for-component-events)
