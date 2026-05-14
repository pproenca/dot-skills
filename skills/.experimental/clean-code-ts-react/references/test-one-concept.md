---
title: One Concept (Not One Assert) Per Test
impact: MEDIUM
impactDescription: Each test names a behavior; assertions describe it together
tags: test, structure, readability
---

## One Concept (Not One Assert) Per Test

"One assert per test" is a common misreading of Uncle Bob. The real principle is **one concept per test**. A test asserting "after submitting an invoice, the API is called with the right shape AND the modal closes AND the toast appears" is testing one concept (successful submit) with three observations. Splitting it into three tests triples the setup cost and obscures the behavior.

**Incorrect (concept fragmented across many tiny tests):**

```tsx
import { render, screen } from '@testing-library/react';
import { userEvent } from '@testing-library/user-event';
import { InvoiceForm } from './InvoiceForm';

// Same setup, same trigger, repeated three times.
// If the submit flow is slow, this test runs 3x slower for no extra coverage.
test('submit calls API', async () => {
  const onSubmit = vi.fn();
  render(<InvoiceForm onSubmit={onSubmit} />);
  await userEvent.click(screen.getByRole('button', { name: /submit/i }));
  expect(onSubmit).toHaveBeenCalled();
});

test('submit closes modal', async () => {
  render(<InvoiceForm />);
  await userEvent.click(screen.getByRole('button', { name: /submit/i }));
  expect(screen.queryByRole('dialog')).not.toBeInTheDocument();
});

test('submit shows toast', async () => {
  render(<InvoiceForm />);
  await userEvent.click(screen.getByRole('button', { name: /submit/i }));
  expect(screen.getByRole('status')).toHaveTextContent(/invoice sent/i);
});
```

**Correct (one concept, three observations):**

```tsx
import { render, screen } from '@testing-library/react';
import { userEvent } from '@testing-library/user-event';
import { InvoiceForm } from './InvoiceForm';

test('submits invoice and confirms to the user', async () => {
  const onSubmit = vi.fn();
  render(<InvoiceForm onSubmit={onSubmit} />);

  await userEvent.click(screen.getByRole('button', { name: /submit/i }));

  // One concept: "successful submit". Three observations describing it.
  expect(onSubmit).toHaveBeenCalledWith(
    expect.objectContaining({ status: 'sent' })
  );
  expect(screen.queryByRole('dialog')).not.toBeInTheDocument();
  expect(screen.getByRole('status')).toHaveTextContent(/invoice sent/i);
});
```

**When NOT to apply this pattern:**
- When later assertions would mask earlier failures and each is independently meaningful — split, so each gets its own failure message.
- Parameterized tests (`it.each([...])`) where you want one named case per row of data.
- Cross-cutting concerns that are genuinely separate concepts (e.g., "submits invoice" vs "marks form dirty on first keystroke") — those stay as separate tests.

**Why this matters:** The unit of a test is a behavior, not an assertion. Aligning test boundaries to behavior boundaries keeps the suite both expressive and fast.

Reference: [Clean Code, Chapter 9: Unit Tests](https://www.oreilly.com/library/view/clean-code-a/9780136083238/), [Kent C. Dodds — Write Fewer Longer Tests](https://kentcdodds.com/blog/write-fewer-longer-tests)
