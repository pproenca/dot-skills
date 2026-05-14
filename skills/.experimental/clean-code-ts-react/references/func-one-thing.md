---
title: Do One Thing
impact: CRITICAL
impactDescription: prevents mixed-abstraction comprehension cost
tags: func, single-responsibility, one-thing, cohesion
---

## Do One Thing

A function should do one thing, do it well, and do it only. The operational test: can you extract a sub-function with a name that is *not* a tautology of its body? If yes, the outer function is doing more than one thing. A function that validates, calculates, persists, and notifies is four functions wearing a trench coat.

**Incorrect (one function juggling four concerns — name cannot capture them all):**

```ts
// "processOrder" hides four distinct responsibilities. Test surface explodes.
async function processOrder(order: Order): Promise<void> {
  if (!order.items.length) throw new Error('Empty order');
  if (order.total <= 0) throw new Error('Invalid total');

  const taxRate = await fetchTaxRate(order.shippingAddress.region);
  order.tax = order.total * taxRate;
  order.grandTotal = order.total + order.tax;

  await db.orders.insert(order);

  await emailService.send({
    to: order.customerEmail,
    subject: `Order ${order.id} confirmed`,
    body: `Total: ${order.grandTotal}`,
  });
}
```

**Correct (orchestrator does one thing — orchestrate — each step is its own function):**

```ts
// "processOrder" now does one thing at one level: orchestrate the order pipeline.
async function processOrder(order: Order): Promise<void> {
  validateOrder(order);
  const pricedOrder = await calculateTax(order);
  await saveOrder(pricedOrder);
  await sendConfirmationEmail(pricedOrder);
}

function validateOrder(order: Order): void { /* ... */ }
async function calculateTax(order: Order): Promise<Order> { /* ... */ }
async function saveOrder(order: Order): Promise<void> { /* ... */ }
async function sendConfirmationEmail(order: Order): Promise<void> { /* ... */ }
```

**When NOT to apply this pattern:**
- Orchestration functions like `processOrder` above *are* doing one thing — orchestrating. Don't try to extract the orchestration itself into another orchestrator; that's turtles all the way down.
- Pure transformations that legitimately combine two operations at the same abstraction level: `parseAndValidate(input)` is sometimes the right unit because the two steps are inseparable in practice (you can't validate without parsing first).
- Highly cohesive sequential operations on the same data structure where splitting adds parameter-passing noise without conceptual gain (e.g., a single-pass tokenizer that both reads and classifies in one loop).

**Why this matters:** When a function does one thing, its name can describe it precisely, its tests are focused, and its reuse becomes obvious.

Reference: [Clean Code, Chapter 3: Functions](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
