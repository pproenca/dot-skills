---
title: Keep Components Small and Cohesive
impact: MEDIUM-HIGH
impactDescription: bounds what a single component has to be understood about
tags: comp, size, cohesion, react
---

## Keep Components Small and Cohesive

The same "keep functions small" principle applies to components, with a twist: cohesion matters as much as size. A 300-line `<CheckoutPage>` is too big — but splitting it into 30 ten-line components scattered across the codebase is worse. Aim for components that fit on a screen AND keep related state, JSX, and effects together; co-locate splits in a folder when they aren't reused.

**Incorrect (one 300-line component doing four jobs):**

```tsx
// Form, payment widget, error banner, confirmation modal — all inline.
// Three engineers can't work on it at once; nothing is independently testable.
function CheckoutPage({ cart }: { cart: Cart }) {
  const [shipping, setShipping] = useState<Shipping>(emptyShipping);
  const [payment,  setPayment]  = useState<Payment>(emptyPayment);
  const [error,    setError]    = useState<string | null>(null);
  const [confirmed, setConfirmed] = useState(false);
  // ...250 more lines of form, payment, modal, error JSX...
  return <div>{/* huge tree */}</div>;
}
```

**Correct (small cohesive pieces, co-located):**

```tsx
// checkout/CheckoutPage.tsx orchestrates; pieces live next to it.
function CheckoutPage({ cart }: { cart: Cart }) {
  const [error, setError] = useState<string | null>(null);
  const [confirmed, setConfirmed] = useState(false);
  return (
    <CheckoutLayout>
      <CheckoutForm cart={cart} onError={setError} onSuccess={() => setConfirmed(true)} />
      <PaymentMethodSelector />
      {error && <CheckoutErrorBanner message={error} />}
      {confirmed && <ConfirmationModal />}
    </CheckoutLayout>
  );
}
// checkout/CheckoutForm.tsx, PaymentMethodSelector.tsx, etc.
```

**When NOT to apply this pattern:**
- Components used in one place and already under ~50 lines — extracting splits cohesive code without payoff.
- Design tokens / theme primitives that are small by nature (`<Spacer />`, `<Stack />`) — further splitting is just noise.
- Performance-sensitive trees where extra component boundaries add re-render overhead; use the React compiler or `memo` strategically before splitting.

**Why this matters:** Components that fit on a screen and stay cohesive are easier to change, test, and parallelize across a team — the same locality principle as small functions.

Reference: [Clean Code, Chapter 3: Functions (Small!)](https://www.oreilly.com/library/view/clean-code-a/9780136083238/), [React Docs: Thinking in React](https://react.dev/learn/thinking-in-react)
