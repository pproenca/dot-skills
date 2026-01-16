---
title: Test Features in Isolation
impact: MEDIUM
impactDescription: Enables faster tests; provides clear failure attribution
tags: test, isolation, mocking, independence
---

## Test Features in Isolation

Feature tests should mock cross-feature dependencies. When tests use real implementations of other features, they become slow, flaky, and failures are hard to attribute.

**Incorrect (integrated feature tests):**

```typescript
// Testing checkout feature but using real cart and user features
describe('CheckoutForm', () => {
  it('submits order', async () => {
    // Test depends on cart and user working correctly
    render(
      <QueryClientProvider client={queryClient}>
        <CartProvider>
          <UserProvider>
            <CheckoutForm />
          </UserProvider>
        </CartProvider>
      </QueryClientProvider>
    );

    // If cart has a bug, checkout tests fail
    // Slow because it's testing 3 features
  });
});
```

**Correct (isolated feature tests):**

```typescript
// src/features/checkout/components/__tests__/CheckoutForm.test.tsx
describe('CheckoutForm', () => {
  const mockItems = [
    { id: '1', name: 'Product', price: 100, quantity: 2 },
  ];

  it('submits order with provided items', async () => {
    const onSubmit = vi.fn();

    render(
      <CheckoutForm
        items={mockItems}
        userId="user-123"
        onSubmit={onSubmit}
      />
    );

    await userEvent.click(screen.getByRole('button', { name: /submit/i }));

    expect(onSubmit).toHaveBeenCalledWith({
      items: mockItems,
      userId: 'user-123',
    });
  });

  it('shows empty state when no items', () => {
    render(<CheckoutForm items={[]} userId="user-123" onSubmit={vi.fn()} />);

    expect(screen.getByText(/cart is empty/i)).toBeInTheDocument();
  });
});
```

**Mock cross-feature hooks:**

```typescript
// Mock the cart feature's exported hook
vi.mock('@/features/cart', () => ({
  useCart: () => ({
    items: [{ id: '1', name: 'Test', price: 50, quantity: 1 }],
    total: 50,
  }),
}));
```

**Benefits:**
- Fast tests (no unnecessary dependencies)
- Clear failure attribution
- Tests document the feature's interface

Reference: [Testing Library - Guiding Principles](https://testing-library.com/docs/guiding-principles)
