---
title: Extract Pure Functions to Increase Testability
impact: MEDIUM
impactDescription: 10x faster test execution, no React test renderer needed
tags: safety, pure-functions, testability, extraction
---

## Extract Pure Functions to Increase Testability

Business logic embedded inside components requires rendering, interacting, and querying the DOM to verify correctness. Each test needs React test infrastructure, increasing execution time and test complexity. Extracting logic into pure functions allows direct input/output testing with zero framework overhead.

**Incorrect (logic inside component — needs full render to test):**

```tsx
import { render, screen } from "@testing-library/react";

function InvoiceSummary({ lineItems }: { lineItems: LineItem[] }) {
  // Formatting and calculation logic trapped inside the component
  const subtotal = lineItems.reduce((sum, item) => sum + item.unitPrice * item.quantity, 0);
  const discount = subtotal > 1000 ? subtotal * 0.1 : subtotal > 500 ? subtotal * 0.05 : 0;
  const taxableAmount = subtotal - discount;
  const tax = taxableAmount * 0.2;
  const total = taxableAmount + tax;

  const formatted = new Intl.NumberFormat("en-US", {
    style: "currency",
    currency: "USD",
  }).format(total);

  return <div data-testid="invoice-total">{formatted}</div>;
}

// Testing requires rendering the entire component
test("invoice applies 10% discount over $1000", () => {
  const lineItems = [{ unitPrice: 600, quantity: 2, description: "Widget" }];
  render(<InvoiceSummary lineItems={lineItems} />);
  expect(screen.getByTestId("invoice-total")).toHaveTextContent("$1,296.00");
});
```

**Correct (extracted pure functions — test directly):**

```tsx
// invoiceCalculations.ts — pure functions, no React dependency
export function calculateInvoiceTotals(lineItems: LineItem[]) {
  const subtotal = lineItems.reduce((sum, item) => sum + item.unitPrice * item.quantity, 0);
  const discount = subtotal > 1000 ? subtotal * 0.1 : subtotal > 500 ? subtotal * 0.05 : 0;
  const taxableAmount = subtotal - discount;
  const tax = taxableAmount * 0.2;
  return { subtotal, discount, tax, total: taxableAmount + tax };
}

export function formatCurrency(amount: number): string {
  return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(amount);
}

// Pure function tests — no render, no DOM, 10x faster
test("applies 10% discount over $1000", () => {
  const lineItems = [{ unitPrice: 600, quantity: 2, description: "Widget" }];
  const { total, discount } = calculateInvoiceTotals(lineItems);
  expect(discount).toBe(120);
  expect(total).toBe(1296);
});

test("formats currency with USD symbol", () => {
  expect(formatCurrency(1296)).toBe("$1,296.00");
});

// Component becomes a thin rendering layer
function InvoiceSummary({ lineItems }: { lineItems: LineItem[] }) {
  const { total } = calculateInvoiceTotals(lineItems);
  return <div>{formatCurrency(total)}</div>;
}
```

Reference: [Kent C. Dodds - AHA Testing](https://kentcdodds.com/blog/aha-testing)
