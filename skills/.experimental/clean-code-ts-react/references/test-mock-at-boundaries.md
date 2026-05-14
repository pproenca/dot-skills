---
title: Mock Only at True Boundaries
impact: MEDIUM
impactDescription: Real code paths get exercised; refactors stay safe
tags: test, msw, mocking, integration
---

## Mock Only at True Boundaries

Mocking your own modules turns tests into a specification of the mock, not of the behavior. If you mock `calculateTax` to return `5.00`, the test passes even when `calculateTax` is broken in real use. Mock the things you don't own — the network, the filesystem, the clock, randomness — and let your own code actually run.

**Incorrect (mocking an in-house module):**

```tsx
import { vi } from 'vitest';
import { render, screen } from '@testing-library/react';
import { Checkout } from './Checkout';

// Mocks our own pricing module. Now this test will pass even if
// calculateTax has a regression — the test is spec-of-the-mock.
vi.mock('@/lib/cart', () => ({
  calculateTax: vi.fn(() => 5.0),
  calculateSubtotal: vi.fn(() => 100.0),
}));

test('shows order total', () => {
  render(<Checkout items={[]} />);
  expect(screen.getByText(/\$105\.00/)).toBeInTheDocument();
});
```

**Correct (mock the network boundary, run the real domain code):**

```tsx
import { http, HttpResponse } from 'msw';
import { setupServer } from 'msw/node';
import { render, screen } from '@testing-library/react';
import { Checkout } from './Checkout';

// Mocks the EXTERNAL world (HTTP). The real calculateTax / calculateSubtotal run.
// A regression in pricing logic will fail this test, as it should.
const server = setupServer(
  http.get('/api/cart', () =>
    HttpResponse.json({ items: [{ sku: 'BOOK-1', price: 100, taxRate: 0.05 }] })
  )
);

beforeAll(() => server.listen());
afterAll(() => server.close());

test('shows order total', async () => {
  render(<Checkout />);
  expect(await screen.findByText(/\$105\.00/)).toBeInTheDocument();
});
```

**When NOT to apply this pattern:**
- Expensive external SDKs in a unit test (e.g., Stripe's SDK, AWS S3 clients) — mock them; reserve the real thing for integration tests.
- Non-deterministic inputs — clock, `Math.random`, `crypto.randomUUID` — always mock or inject; otherwise tests flake.
- Legacy codebases where wholesale module mocking is the existing convention — converge gradually rather than mixing styles within one file.

**Why this matters:** Mocks are seams between systems you control and systems you don't. Mocks placed inside your own system create false green; mocks at the boundary let you test the real thing safely.

Reference: [Clean Code, Chapter 9: Unit Tests](https://www.oreilly.com/library/view/clean-code-a/9780136083238/), [Kent C. Dodds — Stop Mocking Fetch](https://kentcdodds.com/blog/stop-mocking-fetch)
