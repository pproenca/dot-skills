---
title: Write Integration Tests at App Layer
impact: MEDIUM
impactDescription: Verifies feature composition; catches integration bugs
tags: test, integration, e2e, app-layer
---

## Write Integration Tests at App Layer

While features should be tested in isolation, integration tests that verify features work together belong at the app layer. This matches the composition structure of the application.

**Incorrect (integration tests inside features):**

```typescript
// src/features/checkout/__tests__/checkout-integration.test.tsx
// WRONG: Integration test inside a feature folder
import { CartProvider } from '@/features/cart';
import { UserProvider } from '@/features/user';
import { CheckoutForm } from '../components/CheckoutForm';

describe('Checkout Integration', () => {
  it('completes checkout with cart and user', async () => {
    render(
      <CartProvider>
        <UserProvider>
          <CheckoutForm />
        </UserProvider>
      </CartProvider>
    );
    // Feature test depends on other features
  });
});
```

**Correct (integration tests at app layer):**

```typescript
// src/app/__tests__/checkout-flow.test.tsx
// Correct: Integration test at app layer where features are composed
describe('Checkout Flow Integration', () => {
  it('completes order from cart to confirmation', async () => {
    render(
      <AppProviders>
        <App />
      </AppProviders>
    );

    // Add product to cart (cart feature)
    await userEvent.click(screen.getByRole('button', { name: /add to cart/i }));

    // Navigate to checkout (routing)
    await userEvent.click(screen.getByRole('link', { name: /checkout/i }));

    // Fill checkout form (checkout feature)
    await userEvent.type(screen.getByLabelText(/email/i), 'test@example.com');
    await userEvent.click(screen.getByRole('button', { name: /place order/i }));

    // Verify confirmation (order feature)
    expect(await screen.findByText(/order confirmed/i)).toBeInTheDocument();
  });
});
```

**E2E tests for critical paths:**

```typescript
// e2e/checkout.spec.ts
test('complete purchase flow', async ({ page }) => {
  await page.goto('/products');
  await page.click('[data-testid="add-to-cart"]');
  await page.click('[data-testid="go-to-checkout"]');
  await page.fill('[name="email"]', 'test@example.com');
  await page.click('text=Place Order');
  await expect(page.locator('text=Order Confirmed')).toBeVisible();
});
```

**Test layer structure:**

```
tests/
├── unit/           # Fast, isolated tests (run on every commit)
├── integration/    # Feature composition tests (run on PR)
└── e2e/           # Full user journeys (run before deploy)
```

Reference: [Testing Trophy - Kent C. Dodds](https://kentcdodds.com/blog/the-testing-trophy-and-testing-classifications)
