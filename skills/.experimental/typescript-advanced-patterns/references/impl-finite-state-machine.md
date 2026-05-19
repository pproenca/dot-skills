---
title: Encode FSM Transitions in Function Signatures
impact: MEDIUM-HIGH
impactDescription: prevents 100% of illegal state transitions at the call site; eliminates "guard everywhere" runtime checks
tags: impl, fsm, state-machine, type-safety, transitions
---

## Encode FSM Transitions in Function Signatures

A discriminated-union state (see `[[impl-state-discriminated-union]]`) prevents illegal states. The next step — for workflows with strict ordering — is to prevent illegal *transitions*. The trick is to type each transition function by its *valid input states* and its *output state*: `pay(o: Pending): Paid`, `ship(o: Paid): Shipped`. The compiler now refuses to call `ship` on a `Pending` order without first calling `pay`. The runtime body still validates (defense in depth), but the type system carries the workflow contract.

**Incorrect (every method accepts any state — runtime guards everywhere):**

```typescript
interface Order {
  status: 'pending' | 'paid' | 'shipped' | 'delivered' | 'cancelled'
  /* … */
}

function pay(o: Order): Order {
  if (o.status !== 'pending') throw new Error(`cannot pay an order in ${o.status} state`)
  return { ...o, status: 'paid' }
}

function ship(o: Order): Order {
  if (o.status !== 'paid') throw new Error(`cannot ship an order in ${o.status} state`)
  return { ...o, status: 'shipped' }
}

// Callers can compose transitions in any order — the type system has no idea.
const final = ship(deliver(pay(cancelledOrder))) // compiles; throws at runtime
```

**Correct (transitions are typed by their valid source states):**

```typescript
type Pending   = { status: 'pending';   id: string; lineItems: LineItem[] }
type Paid      = { status: 'paid';      id: string; lineItems: LineItem[]; paymentId: string }
type Shipped   = { status: 'shipped';   id: string; lineItems: LineItem[]; paymentId: string; trackingId: string }
type Delivered = { status: 'delivered'; id: string; lineItems: LineItem[]; paymentId: string; trackingId: string; deliveredAt: Date }
type Cancelled = { status: 'cancelled'; id: string; reason: string }

type Order = Pending | Paid | Shipped | Delivered | Cancelled

function pay(o: Pending, payment: { id: string }): Paid {
  return { ...o, status: 'paid', paymentId: payment.id }
}

function ship(o: Paid, tracking: { id: string }): Shipped {
  return { ...o, status: 'shipped', trackingId: tracking.id }
}

function markDelivered(o: Shipped): Delivered {
  return { ...o, status: 'delivered', deliveredAt: new Date() }
}

function cancel<S extends Pending | Paid>(o: S, reason: string): Cancelled {
  return { status: 'cancelled', id: o.id, reason }
}

// Usage:
const pending: Pending = { status: 'pending', id: 'o_1', lineItems: [] }
const paid       = pay(pending, { id: 'p_1' })
const shipped    = ship(paid, { id: 't_1' })
const delivered  = markDelivered(shipped)

ship(pending, { id: 't_1' })       // Error: 'Pending' is not assignable to 'Paid'.
markDelivered(paid)                // Error: 'Paid' is not assignable to 'Shipped'.
cancel(shipped, 'late')            // Error: 'Shipped' is not assignable to 'Pending | Paid'.
```

The functions also *enrich* the state — `paymentId` only exists after `pay`, `trackingId` only after `ship`. Reading `delivered.trackingId` is safe without a null check; reading `paid.trackingId` is a type error.

For workflows with branches (paid → shipped *or* paid → refunded), give each branch its own transition function with the appropriate input type:

```typescript
function refund(o: Paid, reason: string): Refunded { /* … */ }
```

**When NOT to apply:**
- Workflows where transitions are determined at runtime by external events (UI buttons, API webhooks) — you still need the state union, but the transition discipline lives in the reducer that handles events.
- Domains with many states and most-to-most transitions — the per-transition function set explodes. Use a state-machine library (XState) that encodes the transition graph in data, and derive types from that.

**Scope delta:**
- Extends `[[impl-state-discriminated-union]]` from preventing illegal *states* to preventing illegal *transitions*. The discriminated-union rule answers "which states are valid"; this rule answers "which sequences of states are valid."

Reference: [XState — TypeScript Support](https://github.com/statelyai/xstate#typescript)
