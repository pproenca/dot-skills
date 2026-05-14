---
title: Avoid Premature Type Generics
impact: MEDIUM
impactDescription: Concrete types stay readable; generics earn their complexity
tags: emerge, yagni, typescript, generics
---

## Avoid Premature Type Generics

A `function fetchItems<T extends BaseEntity, K extends keyof T, R = T[K]>` that's called once with `fetchItems<Order>(...)` is a few bytes of value buried under generic gymnastics. Add type parameters when you have two or more concrete callers with different types — not because the function "might be reusable."

**Incorrect (speculative generics with one caller):**

```ts
// Used only by /api/orders. The TBody, TResponse, TError parameters
// are never instantiated with anything else. Readers must mentally
// substitute concrete types every time they read the signature.
async function makeRequest<
  TBody extends Record<string, unknown>,
  TResponse,
  TError = Error,
>(url: string, body: TBody): Promise<TResponse> {
  const res = await fetch(url, { method: 'POST', body: JSON.stringify(body) });
  if (!res.ok) throw new Error('failed') as TError;
  return (await res.json()) as TResponse;
}

const order = await makeRequest<CreateOrderInput, Order>('/api/orders', input);
```

**Correct (concrete now; generalize when a second caller arrives):**

```ts
// Boring. Obvious. Reads like its purpose.
// When /api/refunds or /api/shipments needs the same shape AND
// the shape is genuinely the same, extract a shared helper THEN.
async function createOrder(input: CreateOrderInput): Promise<Order> {
  const res = await fetch('/api/orders', {
    method: 'POST',
    body: JSON.stringify(input),
  });
  if (!res.ok) throw new Error('createOrder failed');
  return res.json();
}

const order = await createOrder(input);
```

**When NOT to apply this pattern:**
- Genuine library code with multiple external consumers — the generic IS the API (think TanStack Query's `useQuery<TData, TError>`).
- Utility types in `@types/*` packages or shared kits, where parameterization is the entire point.
- Cases where the only alternative is `any` — a generic that preserves the caller's type is doing real work and should stay.

**Why this matters:** Generics are a cost paid by every reader and a tax on every refactor. They should be earned by real-world reuse, not anticipated by imagination.

Reference: [Clean Code, Chapter 17: Smells and Heuristics (G33 — Encapsulate Boundary Conditions)](https://www.oreilly.com/library/view/clean-code-a/9780136083238/), [Matt Pocock — Don't reach for generics too soon](https://www.totaltypescript.com/)
