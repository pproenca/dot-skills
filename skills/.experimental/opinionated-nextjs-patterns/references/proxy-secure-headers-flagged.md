---
title: Apply Strict CSP Headers Behind an Environment Flag
impact: MEDIUM
impactDescription: prevents broken dev workflows while enforcing XSS protection in prod
tags: proxy, csp, security-headers, env-flag
---

## Apply Strict CSP Headers Behind an Environment Flag

CSP enforcement is real defense against XSS, but always-on strict CSP breaks HMR, dev tools, source maps, and any third-party SDK that injects script tags. Gate strict CSP behind `ENABLE_STRICT_CSP=true` so production turns it on, dev leaves it off, and a dynamic import of the CSP module means the cost is paid only when the flag is enabled.

**Incorrect (always-on CSP — breaks dev, hardcoded directives):**

```ts
// proxy.ts
import { type NextRequest } from 'next/server';

export async function proxy(request: NextRequest) {
  const response = handleI18nRouting(request);

  // Applied to every environment. Dev HMR breaks, the payments SDK breaks,
  // and adding a new third-party means editing this string by hand.
  response.headers.set(
    'Content-Security-Policy',
    "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'",
  );

  return response;
}
```

**Correct (flag-gated, dynamically imported, nonce-generated):**

```ts
// apps/web/proxy.ts
import { type NextResponse } from 'next/server';

async function withSecureHeaders(response: NextResponse) {
  const enableStrictCsp = process.env.ENABLE_STRICT_CSP ?? 'false';

  // Dev: skip immediately, no module-load cost.
  if (enableStrictCsp !== 'true') {
    return response;
  }

  // Prod: load the CSP builder (it generates a per-request nonce and composes
  // the directive from env-derived allowlists).
  const { createCspResponse } = await import('./lib/create-csp-response');
  const cspResponse = await createCspResponse();

  if (cspResponse) {
    for (const [key, value] of cspResponse.headers.entries()) {
      response.headers.set(key, value);
    }
  }

  return response;
}
```

**Why the dynamic import:** the CSP module isn't trivial — it computes a nonce, reads provider config, and builds a comma-joined directive string. A static import makes dev pay that cost on every request even though the result is discarded. Dynamic import plus an early return confines the cost to where it matters.

**What belongs in `create-csp-response`:**

- A per-request nonce for inline `<script>` tags (cryptographically random, attached to a `<Script>` via the `nonce` prop).
- Provider allowlists derived from env (`STRIPE_PUBLISHABLE_KEY` implies `https://js.stripe.com`, etc.) so adding a provider doesn't require editing the CSP string by hand.
- A reporting endpoint for `report-uri` so violations are observable in production.

**Other env-flagged proxy concerns:**

| Flag | Default | When to turn on |
|------|---------|-----------------|
| `ENABLE_STRICT_CSP` | `false` | Production |
| `ENABLE_REQUEST_LOGGING` | `false` | Staging / debugging |
| `ENABLE_RATE_LIMITING` | `false` | Once a rate-limit store is actually wired |

**Don't gate auth or MFA enforcement behind flags.** Authorization is non-negotiable. CSP is a defense-in-depth layer that complements — never replaces — safe escaping in React.

Reference: [Next.js `proxy.ts` file convention](https://nextjs.org/docs/app/api-reference/file-conventions/proxy)
