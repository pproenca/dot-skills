---
title: Split a God-Function Along Its Cohesive Axis, Not by Line Count
impact: CRITICAL
impactDescription: reduces a 300-line procedure to 3-5 independently testable pieces
tags: frame, decomposition, cohesion, single-responsibility
---

## Split a God-Function Along Its Cohesive Axis, Not by Line Count

A long function or class is not bad because it's long — it's bad because it *bundles unrelated changes*. The judgment skill is finding the *axis of cohesion*: the natural seams along which the work breaks into pieces that change for different reasons. Splitting by line count ("extract every 30 lines into a helper") makes things worse — you get small functions with long names that pass 15 variables around. Splitting by cohesion makes each piece smaller, named after what it owns, and independently changeable.

**Incorrect (a "ProcessOrder" that mixes auth, pricing, fulfillment, and notification):**

```typescript
async function processOrder(req: Request, db: DB): Promise<Response> {
  // Auth
  const session = await db.sessions.find(req.cookies.sid);
  if (!session) return { status: 401 };
  const user = await db.users.find(session.userId);
  if (user.disabled) return { status: 403 };

  // Validate cart
  const cart = req.body.cart;
  if (!cart.items?.length) return { status: 400, error: 'empty' };
  for (const item of cart.items) {
    const product = await db.products.find(item.id);
    if (!product || product.stock < item.qty) return { status: 400, error: 'oos' };
  }

  // Price + tax
  let subtotal = 0;
  for (const item of cart.items) {
    const product = await db.products.find(item.id);    // re-fetched — also a bug
    subtotal += product.price * item.qty;
  }
  const tax = user.country === 'US' ? subtotal * 0.08 : subtotal * 0.20;
  const total = subtotal + tax;

  // Charge
  const charge = await stripe.charge(user.cardId, total);
  if (!charge.success) return { status: 402 };

  // Fulfill
  for (const item of cart.items) {
    await db.products.decrement(item.id, item.qty);
  }
  const order = await db.orders.create({ userId: user.id, items: cart.items, total });

  // Notify
  await email.send(user.email, `Order #${order.id} confirmed`);
  await analytics.track('order_placed', { userId: user.id, total });

  return { status: 200, orderId: order.id };
  // 30+ lines mixing 5 unrelated concerns. Test it: every test needs the whole stack.
}
```

**Correct (split by what changes together — each piece has one reason to change):**

```typescript
async function processOrder(req: Request, ctx: Context): Promise<Response> {
  const user = await authenticate(req, ctx);                if (!user) return UNAUTHORIZED;
  const cart = await validateCart(req.body.cart, ctx);      if ('error' in cart) return cart.error;
  const total = priceCart(cart, user.country);
  const charge = await ctx.payments.charge(user.cardId, total);
  if (!charge.success) return PAYMENT_FAILED;
  const order = await fulfill(user, cart, total, ctx);
  await notify(user, order, ctx);
  return ok(order);
  // Each helper has ONE axis of change.
  // priceCart: changes when tax rules change. Testable with a synthetic cart, no DB.
  // fulfill: changes when stock semantics change. Testable in isolation.
  // notify: changes when comm channels change. Easily mocked at one line.
}
```

**Finding the axis:**

For each block in the long function, ask: **"what causes this block to change?"** Blocks that share an answer belong together; blocks with different answers belong apart.

- "When tax rules change" → pricing block
- "When auth rules change" → auth block
- "When fulfillment partner changes" → fulfill block
- "When marketing wants a new email" → notify block

Four different answers means four functions. Same answer means one function with two sub-steps.

**When NOT to use this pattern:**

- The function is long but every block changes together for the same reason — keep it whole. Length alone is not the enemy; *bundled change* is.
- Premature splitting introduces parameter-passing chains worse than the original. If you're threading 8 variables to a helper, the helper isn't a clean piece.

Reference: [A Philosophy of Software Design — Deep Modules](https://web.stanford.edu/~ouster/cgi-bin/aposd.php), and [On the Criteria To Be Used in Decomposing Systems into Modules](https://www.cs.umd.edu/class/spring2003/cmsc838p/Design/criteria.pdf) (Parnas)
