---
title: Hide Vendor SDKs Behind a Gateway Interface
impact: MEDIUM
impactDescription: enables swappable billing, mail, CMS, monitoring providers
tags: arch, gateway, abstraction, provider, billing
---

## Hide Vendor SDKs Behind a Gateway Interface

Give your billing/mail/CMS/monitoring concerns the same shape: a `core` package defines the interface and shared schema, a `gateway` (or registry) resolves the active provider from config, and per-provider packages contain the vendor-specific SDK code. App code talks to the gateway, never the SDK. Switching from Stripe to Lemon Squeezy becomes a config change instead of a codebase change; adding a new provider means implementing the interface, not editing every consumer.

**Incorrect (consumer imports the SDK directly — locked in):**

```ts
// apps/web/app/[locale]/home/[account]/billing/page.tsx
import Stripe from 'stripe';   // ❌ Concrete vendor import.

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!);
const checkoutSession = await stripe.checkout.sessions.create({
  payment_method_types: ['card'],
  // ... Stripe-specific shape leaks into product code
});

// 50 files later, same import everywhere.
// "Let's evaluate Lemon Squeezy" → 50-file diff.
```

**Correct (consumer imports the gateway — provider-agnostic):**

```ts
// apps/web/app/[locale]/home/[account]/billing/page.tsx
import { getBillingGatewayProvider } from '@app/billing-gateway';
import { getServerClient } from '@app/supabase/server';

const provider = await getBillingGatewayProvider(getServerClient());
const { url } = await provider.createCheckoutSession({
  accountId,
  customerId,
  plan: { variantId: 'pro-monthly' },
  // ... shape defined by @app/billing-core, not by any one vendor
});

// Switching to Lemon Squeezy: change billing.config.ts, restart. No code change.
```

**The structure of the abstraction:**

```text
packages/billing/
├── core/                        # The interface + shared types.
│   └── src/
│       ├── billing-schema.ts    # Plan, Customer, Subscription, CheckoutSession types
│       └── billing-provider.interface.ts
├── gateway/                     # Reads config, returns the active provider.
│   └── src/
│       └── get-billing-gateway-provider.ts
├── stripe/                      # Stripe implementation (only place Stripe SDK is imported).
│   └── src/
│       └── stripe-billing-provider.ts
└── lemon-squeezy/               # Lemon Squeezy implementation.
    └── src/
        └── lemon-squeezy-billing-provider.ts
```

**The gateway's resolution logic:**

```ts
// packages/billing/gateway/src/get-billing-gateway-provider.ts
import billingConfig from '~/config/billing.config';

export async function getBillingGatewayProvider(client: DataClient) {
  switch (billingConfig.provider) {
    case 'stripe': {
      const { createStripeBillingProvider } = await import('@app/billing-stripe');
      return createStripeBillingProvider(client);
    }
    case 'lemon-squeezy': {
      const { createLemonSqueezyBillingProvider } = await import('@app/billing-lemon-squeezy');
      return createLemonSqueezyBillingProvider(client);
    }
    default:
      throw new Error(`Unknown billing provider: ${billingConfig.provider}`);
  }
}
```

**Why dynamic import per provider:** only the active provider's SDK is loaded. Stripe's SDK is ~500KB; bundling both wastes startup time on every server cold start.

**Each provider implements the same interface:**

```ts
// packages/billing/core/src/billing-provider.interface.ts
export interface BillingProvider {
  createCheckoutSession(params: CreateCheckoutParams): Promise<CheckoutSession>;
  cancelSubscription(subscriptionId: string): Promise<void>;
  getCustomer(customerId: string): Promise<Customer>;
  handleWebhookEvent(request: Request): Promise<void>;
}
```

**Where the pattern pays off across concerns:**

| Concern | Core package | Providers |
|---------|--------------|-----------|
| Billing | `packages/billing/core` (`@app/billing-core`) | `stripe`, `lemon-squeezy` |
| Mail | `packages/mailers/core` (`@app/mailers-core`) | `nodemailer`, `resend` |
| CMS | `packages/cms/core` (`@app/cms-core`) | `keystatic`, `wordpress` |
| Monitoring | `packages/monitoring/*` (`@app/monitoring`) | sentry, baselime, etc. |

**When the abstraction breaks:** if you find yourself adding a method to the interface that *only* one provider supports (e.g., `getStripeSubscriptionMetadata`), the abstraction is leaking. Either find an equivalent in the other providers, expose it as an optional capability the gateway can advertise, or keep it inside the Stripe-only code path and don't generalize.

**When to skip this pattern:** for a single-provider concern that's unlikely to ever swap (e.g., your internal feature flag service), the abstraction adds layers without benefit. Apply it where swap is plausible: billing, email, CMS, observability.

Reference: [Turborepo internal packages](https://turborepo.com/docs/core-concepts/internal-packages)
