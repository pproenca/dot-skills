---
title: Webhook Routes Skip the User-Auth Wrapper and Verify the Provider Signature
impact: HIGH
impactDescription: prevents unauthenticated invocation of admin-privileged handlers
tags: mutate, webhook, signature, security, route-handler
---

## Webhook Routes Skip the User-Auth Wrapper and Verify the Provider Signature

A webhook handler has no user session to authenticate against — the auth check will fail and redirect. Set `auth: false` on the route wrapper. But the route is publicly addressable: anyone who finds the URL can POST arbitrary payloads to handlers that typically use the privileged client to mutate billing or account state. Verify the signature header (`Stripe-Signature` for Stripe, `X-Supabase-Event-Signature` for a Supabase DB webhook) before doing anything else.

**Incorrect (`auth` defaults to true → the webhook is unreachable):**

```ts
// app/api/billing/webhook/route.ts
export const POST = enhanceRouteHandler(
  async ({ request }) => {
    // The provider POSTs here. There's no user session.
    // requireUser inside the wrapper fails → 302 redirect to /auth/sign-in.
    // The provider retries a few times, gives up, alerts you about failures.
    return new Response('OK');
  },
  // No config = auth defaults to true.
);
```

**Incorrect (`auth: false` but no signature check — anyone can invoke):**

```ts
export const POST = enhanceRouteHandler(
  async ({ request }) => {
    const payload = await request.text();
    const event = JSON.parse(payload); // Trusts arbitrary input.

    if (event.type === 'invoice.payment_succeeded') {
      // An attacker POSTs a fake event → we credit them with a subscription.
      const adminClient = getServiceRoleClient();
      await adminClient.from('subscriptions').insert({ accountId: event.accountId });
    }
  },
  { auth: false },
);
```

**Correct (`auth: false` + the signature verified before any mutation):**

```ts
// app/api/billing/webhook/route.ts
import { enhanceRouteHandler } from '@app/next/route-handler';
import { getLogger } from '@app/observability/logger';
import { getServiceRoleClient } from '@app/supabase/admin';

export const POST = enhanceRouteHandler(
  async ({ request }) => {
    const logger = await getLogger();
    const ctx = { name: 'billing.webhook', provider: billingConfig.provider };
    logger.info(ctx, 'Received billing webhook. Processing...');

    // The privileged client is necessary — billing webhooks mutate cross-tenant data.
    // The authorization gate is the signature verification inside the service.
    const adminClientProvider = () => getServiceRoleClient();
    const service = await getBillingEventHandlerService(
      adminClientProvider,
      billingConfig.provider,
      getPlanTypesMap(billingConfig),
    );

    try {
      // handleWebhookEvent reads the signature header, calls the provider's
      // constructEvent (Stripe's, etc.), and throws if the signature is invalid.
      await service.handleWebhookEvent(request);
      logger.info(ctx, 'Successfully processed billing webhook');
      return new Response('OK', { status: 200 });
    } catch (error) {
      logger.error({ ...ctx, error }, 'Failed to process billing webhook');
      return new Response('Failed to process billing webhook', { status: 500 });
    }
  },
  { auth: false }, // No user session for webhooks — the signature is the auth.
);
```

**Correct (DB webhook with an explicit signature read):**

```ts
// app/api/db/webhook/route.ts
export const POST = enhanceRouteHandler(
  async ({ request }) => {
    const signature = request.headers.get('X-Supabase-Event-Signature');
    if (!signature) {
      return new Response('Missing signature', { status: 400 });
    }

    const payload = await request.text();
    const service = getDatabaseWebhookHandlerService();
    await service.handleWebhook({ payload, signature });
    return new Response(null, { status: 200 });
  },
  { auth: false },
);
```

**Signature verification per provider:**

| Provider | Header | Verification |
|----------|--------|--------------|
| Stripe | `Stripe-Signature` | `stripe.webhooks.constructEvent(payload, signature, secret)` |
| Supabase DB Webhook | `X-Supabase-Event-Signature` | HMAC with `SUPABASE_DB_WEBHOOK_SECRET` |
| Lemon Squeezy | `X-Signature` | HMAC SHA-256 with `LEMON_SQUEEZY_SIGNING_SECRET` |
| Custom | Your own header | HMAC with a shared secret, compared via `crypto.timingSafeEqual` |

**`request.text()` BEFORE parsing.** Stripe's `constructEvent` requires the raw, unparsed body to compute the signature. Calling `request.json()` consumes the body, so a later text read returns empty. Always read as text first; parse JSON yourself afterwards (or let the provider SDK do it).

**Idempotency keys.** Providers retry on 5xx, so the same event ID can arrive more than once. Store processed event IDs (a `webhook_events` table or Redis) and skip duplicates — otherwise a transient 500 causes a duplicate insert on retry.

**Why `auth: false` is safe here:** the route is unauthenticated *for the framework*, but it has its own auth layer — the signature. The framework's auth would be wrong (there is no user), so opting out is correct *provided* the alternative auth runs inside the handler.

Reference: [Stripe webhook signatures](https://stripe.com/docs/webhooks/signatures)
