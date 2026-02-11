---
title: Avoid Snapshot Tests for Refactored Components
impact: MEDIUM
impactDescription: eliminates false test failures during refactoring, tests validate behavior
tags: safety, snapshot-tests, false-negatives, refactoring
---

## Avoid Snapshot Tests for Refactored Components

Snapshot tests serialize the entire rendered output, so any change to class names, wrapper elements, whitespace, or attribute order causes a failure. During refactoring, every structural improvement triggers a snapshot diff that developers blindly update with `--updateSnapshot`. The test provides zero confidence — it only proves the output changed, not whether the change was correct.

**Incorrect (snapshot test — fails on every structural change):**

```tsx
import { render } from "@testing-library/react";

test("PaymentStatus renders correctly", () => {
  const { container } = render(
    <PaymentStatus
      status="completed"
      amount={149.99}
      transactionId="txn_abc123"
    />
  );

  // Breaks when: class name changes, wrapper div added, attribute order shifts
  expect(container).toMatchSnapshot();
});

// Snapshot file contains 25 lines of serialized HTML
// Developer refactors CSS module names: snapshot fails
// Developer wraps in <section>: snapshot fails
// Developer reorders aria attributes: snapshot fails
// Every time: developer runs --updateSnapshot without reviewing diff
```

**Correct (explicit assertions — only fail when behavior regresses):**

```tsx
import { render, screen } from "@testing-library/react";

test("PaymentStatus displays completed transaction details", () => {
  render(
    <PaymentStatus
      status="completed"
      amount={149.99}
      transactionId="txn_abc123"
    />
  );

  expect(screen.getByText("Payment Complete")).toBeInTheDocument();
  expect(screen.getByText("$149.99")).toBeInTheDocument();
  expect(screen.getByText("txn_abc123")).toBeInTheDocument();
  expect(screen.getByRole("status")).toHaveAttribute("aria-live", "polite");
});

test("PaymentStatus displays failed state with retry", () => {
  render(<PaymentStatus status="failed" amount={149.99} transactionId="txn_abc123" />);

  expect(screen.getByText("Payment Failed")).toBeInTheDocument();
  expect(screen.getByRole("button", { name: "Retry Payment" })).toBeEnabled();
});
// Renaming CSS classes, restructuring markup, adding wrappers — tests still pass
```

Reference: [Kent C. Dodds - Effective Snapshot Testing](https://kentcdodds.com/blog/effective-snapshot-testing)
