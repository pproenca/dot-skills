---
title: Keep Functions, Components & Hooks Small
impact: CRITICAL
impactDescription: prevents working-memory overflow on every read
tags: func, size, decomposition, readability
---

## Keep Functions, Components & Hooks Small

A reader can hold roughly 7 things in working memory at once; a 10-line function fits whole, a 100-line component fragments comprehension across scrolls. Smallness is not an aesthetic preference — it is the upper bound on how much logic a human can reason about without re-reading. In React, this applies equally to functions, components, and hooks: each is a unit of comprehension.

**Incorrect (60-line component mixing fetch, validation, layout, and submission):**

```tsx
function CheckoutPage({ cartId }: { cartId: string }) {
  const [cart, setCart] = useState<Cart | null>(null);
  const [errors, setErrors] = useState<string[]>([]);
  const [isSubmitting, setIsSubmitting] = useState(false);

  useEffect(() => {
    fetch(`/api/cart/${cartId}`).then((r) => r.json()).then(setCart);
  }, [cartId]);

  const validate = (cart: Cart) => {
    const errs: string[] = [];
    if (!cart.items.length) errs.push('Empty cart');
    if (!cart.shippingAddress) errs.push('No shipping address');
    if (cart.total <= 0) errs.push('Invalid total');
    return errs;
  };

  const handleSubmit = async () => {
    if (!cart) return;
    const errs = validate(cart);
    if (errs.length) { setErrors(errs); return; }
    setIsSubmitting(true);
    try {
      await fetch('/api/orders', { method: 'POST', body: JSON.stringify(cart) });
    } finally {
      setIsSubmitting(false);
    }
  };

  if (!cart) return <div>Loading...</div>;
  // ...30 more lines of JSX for summary, payment form, error list, submit button.
  return <div>{/* huge JSX tree */}</div>;
}
```

**Correct (composed of small, focused pieces — each fits on a screen):**

```tsx
// Reader scans the top-level component and sees the whole shape in 10 lines.
function CheckoutPage({ cartId }: { cartId: string }) {
  const cart = useCart(cartId);
  if (!cart) return <CheckoutSkeleton />;

  return (
    <CheckoutLayout>
      <OrderSummary cart={cart} />
      <PaymentForm cart={cart} />
      <SubmitButton cart={cart} />
    </CheckoutLayout>
  );
}

// Each extracted piece (useCart, OrderSummary, PaymentForm, SubmitButton) lives in its own file
// and is itself small. Validation lives next to PaymentForm; submission lives next to SubmitButton.
```

**When NOT to apply this pattern:**
- Ousterhout's *deep modules* critique: if extracting creates five shallow components each called exactly once, the reader must jump across five files to understand one behavior. Prefer one moderately sized component with a clear narrative over a constellation of one-line wrappers.
- Functions whose extracted name merely restates the body (`function addOneToCount(c) { return c + 1; }`) — the helper adds indirection without clarity. Inline it.
- Tight inner loops or hot-path code where call overhead matters and the function fits a single coherent operation; "small" sometimes means "exactly the right size," not "smaller still."

**Why this matters:** Small units compose into a hierarchy the reader can navigate top-down, the same way they read code top-to-bottom.

Reference: [Clean Code, Chapter 3: Functions](https://www.oreilly.com/library/view/clean-code-a/9780136083238/), [A Philosophy of Software Design (Ousterhout) — Deep Modules](https://web.stanford.edu/~ouster/cgi-bin/aposd.php)
