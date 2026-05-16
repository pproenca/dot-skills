---
title: Prefer `findBy*` over `waitFor` + `getBy*` for async appearance
impact: HIGH
impactDescription: reduces flakiness and improves failure messages by 2-3x
tags: test, async, findBy, waitFor
---

## Prefer `findBy*` over `waitFor` + `getBy*` for async appearance

`findByRole`/`findByText`/etc. are async queries that retry until the element exists or the timeout expires. They're purpose-built for "wait for this element to appear" — the failure message tells you which query failed and what was on screen, and the default timeout is calibrated to React's render rhythm. `waitFor(() => expect(getByRole(...)).toBeInTheDocument())` does the same job manually but with worse error messages and a higher chance that someone forgets the inner assertion. Reach for `waitFor` only when the condition isn't an element query (a state value, a derived count, a network-cache key).

**Incorrect (`waitFor` + `getBy*` — verbose, opaque failure):**

```tsx
export const LoadsAndShowsList: Story = {
  play: async ({ canvas, userEvent }) => {
    await userEvent.click(canvas.getByRole('button', { name: /load/i }));
    await waitFor(() => {
      expect(canvas.getByRole('listitem')).toBeInTheDocument();
    });
    // Fails with: "expected 1 element, found 0" — no info about timing
  },
};
```

**Correct (`findByRole` — purpose-built, clearer error):**

```tsx
import { expect } from 'storybook/test';

export const LoadsAndShowsList: Story = {
  play: async ({ canvas, userEvent }) => {
    await userEvent.click(canvas.getByRole('button', { name: /load/i }));

    const firstItem = await canvas.findByRole('listitem');
    await expect(firstItem).toBeInTheDocument();
    // Fails with: "Unable to find an accessible element with role 'listitem'
    // [renders the current DOM tree]"
  },
};
```

**`waitFor` IS the right call when the condition isn't a query:**

```tsx
export const RetriesUntilSuccess: Story = {
  play: async ({ args }) => {
    // Wait for a derived value: spy was called > 3 times
    await waitFor(() => {
      expect(args.fetcher).toHaveBeenCalledTimes(4);
    });
  },
};
```

**Useful query mapping:**

| Sync (already there) | Async (wait to appear) | Async (wait to disappear) |
|----------------------|------------------------|---------------------------|
| `getByRole` | `findByRole` | `waitForElementToBeRemoved` |
| `getByText` | `findByText` | |
| `queryByRole` (no error if absent) | — | |

**Why this matters:** Tests that grow `waitFor(() => expect(getBy...))` everywhere become unreadable. `findBy*` is the idiomatic way to wait — and the default 1000ms timeout matches React's rendering cadence, so you don't tune it.

Reference: [Testing Library async](https://testing-library.com/docs/dom-testing-library/api-async/), [Storybook play tests](https://storybook.js.org/docs/writing-tests/interaction-testing)
