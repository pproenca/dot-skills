---
title: Use API Routes for Server-Side Data Fetching
impact: HIGH
impactDescription: keeps secrets secure and enables server-side logic
tags: data, api-routes, server, fetch
---

## Use API Routes for Server-Side Data Fetching

Expo Router API routes run on the server, allowing secure access to secrets and databases. Create them with the `+api.ts` suffix.

**Incorrect (exposing API keys in client code):**

```typescript
// Client-side - API key exposed in bundle
const response = await fetch('https://api.stripe.com/charges', {
  headers: {
    'Authorization': `Bearer ${process.env.EXPO_PUBLIC_STRIPE_KEY}`,  // EXPOSED!
  },
});
```

**Correct (API route keeps secrets server-side):**

```typescript
// app/api/create-charge+api.ts
import Stripe from 'stripe';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!);  // Server-only

export async function POST(request: Request) {
  const body = await request.json();
  const { amount, currency } = body;

  try {
    const charge = await stripe.charges.create({
      amount,
      currency,
    });
    return Response.json({ success: true, chargeId: charge.id });
  } catch (error) {
    return Response.json(
      { error: 'Payment failed' },
      { status: 400 }
    );
  }
}
```

```typescript
// Client component - calls API route
export default function PaymentScreen() {
  const handlePayment = async () => {
    const response = await fetch('/api/create-charge', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ amount: 1000, currency: 'usd' }),
    });
    const result = await response.json();
    if (result.success) {
      // Handle success
    }
  };

  return <Button title="Pay $10" onPress={handlePayment} />;
}
```

**Note:** API routes require a deployed server (EAS Hosting or custom server) for production.

Reference: [API Routes - Expo Documentation](https://docs.expo.dev/router/web/api-routes/)
