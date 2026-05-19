---
title: "Webhook Routes Use `auth: false` and Verify the Signature"
impact: HIGH
impactDescription: prevents unauthenticated invocation of admin-privileged handlers
tags: mutate, webhook, signature, security, route-handler
---

## Webhook Routes Use `auth: false` and Verify the Signature

A webhook handler has no Supabase session to authenticate against — `requireUser` will fail and redirect. Set `auth: false` on `enhanceRouteHandler`. But the route is publicly addressable: anyone who finds the URL can POST arbitrary payloads to handlers that typically use the admin client to mutate billing or account state. Verify the signature header (`Stripe-Signature` for Stripe, `X-Supabase-Event-Signature` for DB webhooks) before doing anything else.

**Incorrect (`auth` defaults to true → webhook is unreachable):**

```ts
// app/api/billing/webhook/route.ts
export const POST = enhanceRouteHandler(
  async ({ request }) => {
    // Stripe POSTs here. There's no Supabase session.
    // requireUser inside enhanceRouteHandler fails → 302 redirect to /auth/sign-in.
    // Stripe retries 3 times, gives up, alerts you about webhook failures.
    return new Response('OK');
  },
  // No config = auth defaults to true.
);
```

**Incorrect (`auth: false` but no signature verification — anyone can invoke):**

```ts
export const POST = enhanceRouteHandler(
  async ({ request }) => {
    const payload = await request.text();
    const event = JSON.parse(payload);  // Trusts arbitrary input.

    if (event.type === 'invoice.payment_succeeded') {
      // An attacker POSTs a fake event → we credit them with a subscription.
      const adminClient = getSupabaseServerAdminClient();
      await adminClient.from('subscriptions').insert({...});
    }
  },
  { auth: false },
);
```

**Correct (the shipped pattern — `auth: false` + signature verified inside the handler):**

```ts
// app/api/billing/webhook/route.ts
import { enhanceRouteHandler } from '@kit/next/routes';

export const POST = enhanceRouteHandler(
  async ({ request }) => {
    const logger = await getLogger();
    const ctx = { name: 'billing.webhook', provider: billingConfig.provider };
    logger.info(ctx, 'Received billing webhook. Processing...');

    // The admin client is necessary — billing webhooks mutate cross-tenant data.
    // The authorization gate is the signature verification (inside the service).
    const supabaseProvider = () => getSupabaseServerAdminClient();
    const service = await getBillingEventHandlerService(
      supabaseProvider,
      billingConfig.provider,
      getPlanTypesMap(billingConfig),
    );

    try {
      // handleWebhookEvent reads the signature header, calls
      // Stripe's constructEvent (or equivalent), throws if invalid.
      await service.handleWebhookEvent(request);
      logger.info(ctx, 'Successfully processed billing webhook');
      return new Response('OK', { status: 200 });
    } catch (error) {
      logger.error({ ...ctx, error }, 'Failed to process billing webhook');
      return new Response('Failed to process billing webhook', { status: 500 });
    }
  },
  { auth: false },  // No user session for webhooks — signature is the auth.
);
```

**Correct (DB webhook with explicit signature read):**

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

**Signature verification rules:**

| Provider | Header | Verification |
|----------|--------|--------------|
| Stripe | `Stripe-Signature` | `stripe.webhooks.constructEvent(payload, sig, secret)` |
| Supabase DB Webhook | `X-Supabase-Event-Signature` | HMAC with `SUPABASE_DB_WEBHOOK_SECRET` |
| Lemon Squeezy | `X-Signature` | HMAC SHA256 with `LEMON_SQUEEZY_SIGNING_SECRET` |
| Custom | Use HMAC with a shared secret env var | `crypto.timingSafeEqual` to compare |

**`request.text()` BEFORE parsing:** Stripe's `constructEvent` requires the raw, unparsed body to compute the signature. Calling `request.json()` consumes the body, so the subsequent text read returns empty. Always read as text first; parse JSON yourself if needed (or let the provider SDK do it).

**Idempotency keys.** Providers retry on 5xx. The same event ID can arrive multiple times. Store processed event IDs (in a `webhook_events` table or Redis) and skip duplicates — otherwise a transient 500 causes a duplicate insert on retry.

**Why `auth: false` is safe here:** the route is unauthenticated *for the framework*, but it has its own authentication layer (the signature). The framework's auth would be wrong (no user), so opting out is correct — provided the alternative auth is implemented inside the handler.

Reference: [Stripe webhook signatures](https://stripe.com/docs/webhooks/signatures)
