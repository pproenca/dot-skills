---
title: Event Handlers Use onX / handleX Convention
impact: CRITICAL
impactDescription: prevents prop-handler contract drift across components
tags: name, handler, event, props
---

## Event Handlers Use onX / handleX Convention

React's ecosystem has settled on a two-part naming split: `on*` names the *prop* (the contract a component exposes), and `handle*` names the *implementation* (the function that fulfills it). Mixing the two — or using neither — breaks the reader's ability to skim a component and instantly tell "this is what we expose" from "this is what we do." Worse, library APIs (React itself, react-hook-form, TanStack Query) assume the `on*` prop convention; deviating from it forces wrappers and adapters.

**Incorrect (handler naming is ad-hoc; prop vs. impl distinction is lost):**

```tsx
// `click` and `submit` don't read as event-handler props.
// `clickFn` and `submitFn` don't read as handler implementations.
type CheckoutButtonProps = {
  click: () => void;
  submit: (cart: Cart) => void;
};

function CheckoutPage({ cart }: { cart: Cart }) {
  const clickFn = () => console.log('clicked');
  const submitFn = (cart: Cart) => placeOrder(cart);
  return <CheckoutButton click={clickFn} submit={submitFn} />;
}
```

**Correct (props are `on*`, implementations are `handle*`):**

```tsx
// Props clearly state the contract: "when X happens, call me".
type CheckoutButtonProps = {
  onClick: () => void;
  onSubmit: (cart: Cart) => void;
};

function CheckoutPage({ cart }: { cart: Cart }) {
  const handleClick = () => console.log('clicked');
  const handleSubmit = (cart: Cart) => placeOrder(cart);
  return <CheckoutButton onClick={handleClick} onSubmit={handleSubmit} />;
}
```

**When NOT to apply this pattern:**
- Callbacks that are not event-shaped: a `comparator` for `Array.sort`, a `selectUser` data accessor, or a fetcher passed to TanStack Query. These follow general function naming, not the handler convention.
- Library-mandated callback names: react-hook-form's `register`, react-router's `loader`, or a third-party widget's `beforeUnload` — adopt the library's vocabulary at its boundary.
- Inline arrow handlers in trivial JSX (`onClick={() => setOpen(false)}`) — there is no `handle*` implementation to name, and inventing one purely to satisfy the convention adds noise.

**Why this matters:** A predictable handler convention lets a reader scan a 300-line component and find every event boundary in seconds.

Reference: [react.dev: Responding to Events](https://react.dev/learn/responding-to-events), [Clean Code, Chapter 2: Meaningful Names](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
