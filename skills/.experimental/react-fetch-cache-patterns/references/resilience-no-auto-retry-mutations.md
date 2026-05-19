---
title: Avoid Auto-Retrying Non-Idempotent Mutations
impact: HIGH
impactDescription: prevents double-charging, duplicate posts, double sends
tags: resilience, retry, mutations, idempotency
---

## Avoid Auto-Retrying Non-Idempotent Mutations

A retry of `GET /products/123` is safe — it returns the same thing. A retry of `POST /charge` may bill the customer twice. The risk isn't only on network failure: the request *may have succeeded* but the response was lost. The client sees "no response" → retries → server processes a second charge. Default mutation retry behavior in some clients defaults to retry, which silently turns rare race conditions into duplicate side effects.

Make mutations safe to retry by giving them an idempotency key, OR don't retry them at all. Decide per-mutation.

**Incorrect (auto-retry on a non-idempotent mutation):**

```tsx
const charge = useMutation({
  mutationFn: createCharge,
  retry: 3, // ❌ if the network drops after the server processed the charge,
            //    the retry processes a SECOND charge
});
```

**Correct (no auto-retry — let the user decide):**

```tsx
const charge = useMutation({
  mutationFn: createCharge,
  retry: false, // ← TanStack Query default is false for mutations; keep it
  onError: (err) => toast.error(`Charge failed — please try again`),
});

// User-initiated retry: a click; the user is aware they're trying again
<Button onClick={() => charge.mutate(params)} disabled={charge.isPending}>
  {charge.isError ? 'Retry payment' : 'Pay'}
</Button>
```

**Better: make the mutation safe to retry with an idempotency key:**

```ts
async function createCharge(params: ChargeParams): Promise<Charge> {
  return fetch('/api/charge', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Idempotency-Key': params.idempotencyKey, // ← server dedupes by this key
    },
    body: JSON.stringify(params),
  }).then(r => r.json());
}

const charge = useMutation({
  mutationFn: createCharge,
  retry: 2, // SAFE because the server enforces idempotency
});

// Generate the key once per attempt — same key across retries of the same logical operation
function PaymentForm() {
  const idempotencyKey = useRef(crypto.randomUUID());
  return (
    <Button onClick={() => charge.mutate({ ...formValues, idempotencyKey: idempotencyKey.current })}>
      Pay
    </Button>
  );
}
```

**Server-side enforcement (the actual idempotency):**

```ts
// Pseudocode for the API handler
async function handleCharge(req: Request) {
  const key = req.headers.get('Idempotency-Key');
  if (!key) return error('Idempotency-Key required for mutations');

  const cached = await redis.get(`idempotency:${key}`);
  if (cached) return Response.json(JSON.parse(cached)); // same response, no second charge

  const result = await processCharge(req.body);
  await redis.setex(`idempotency:${key}`, 86400, JSON.stringify(result));
  return Response.json(result);
}
```

**Mutation categories (decide retry per-category):**

| Mutation type | Auto-retry? | Notes |
|---------------|-------------|-------|
| Idempotent updates (PUT with full state) | Yes | `PUT /users/:id` with full object is idempotent by HTTP spec |
| DELETE | Usually yes | Re-deleting an already-deleted thing returns 404 — handle that as success |
| POST without idempotency key | No | User confirms via UI |
| POST with idempotency key | Yes | Server enforces dedup |
| POST with side effects (email, notification) | Only with idempotency key | Double emails are user-visible |

Reference: [Stripe — Idempotent Requests](https://docs.stripe.com/api/idempotent_requests) | [TanStack Query — Mutations](https://tanstack.com/query/latest/docs/framework/react/guides/mutations)
