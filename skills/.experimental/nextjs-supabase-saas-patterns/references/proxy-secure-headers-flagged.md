---
title: Apply Strict CSP Headers Behind an Environment Flag
impact: MEDIUM
impactDescription: prevents broken dev workflows while enforcing XSS protection in prod
tags: proxy, csp, security-headers, env-flag
---

## Apply Strict CSP Headers Behind an Environment Flag

CSP enforcement is real defense against XSS, but always-on strict CSP breaks HMR, dev tools, source maps, and any third-party SDK that injects script tags. The kit gates strict CSP behind `ENABLE_STRICT_CSP=true` so production turns it on, dev leaves it off, and the dynamic import of the CSP module means the cost is paid only when the flag is enabled.

**Incorrect (always-on CSP — breaks dev, hardcoded directives):**

```ts
// proxy.ts
export default async function proxy(request: NextRequest) {
  const response = handleI18nRouting(request);

  // Strict CSP applied to every environment. Dev HMR breaks. Stripe.js
  // breaks. Adding a new third-party means editing this string.
  response.headers.set(
    'Content-Security-Policy',
    "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'"
  );

  return response;
}
```

**Correct (flag-gated, dynamically imported, nonce-generated):**

```ts
// apps/web/proxy.ts (the shipped pattern)
async function createResponseWithSecureHeaders(response: NextResponse) {
  const enableStrictCsp = process.env.ENABLE_STRICT_CSP ?? 'false';

  // Dev: skip immediately, no module load cost.
  if (enableStrictCsp === 'false') {
    return response;
  }

  // Prod: load the CSP builder (which generates a per-request nonce and
  // composes the directive from env-derived allowlists).
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

**Why the dynamic import:** the CSP module itself isn't trivial — it computes a nonce, reads provider config, builds a comma-joined directive string. With static import, dev environments pay that cost on every request even though the result is discarded. With dynamic import + early return, the cost only shows up where it matters.

**What belongs in `create-csp-response`:**

- Per-request nonce for inline `<script>` tags (cryptographically random, attached to a `<Script>` component via `nonce` prop).
- Provider allowlists derived from env (`STRIPE_PUBLISHABLE_KEY` implies `https://js.stripe.com`, etc.) so adding a provider doesn't require editing the CSP string by hand.
- Reporting endpoint for `report-uri` so violations are observable in production.

**Other env-flagged middleware concerns:**

| Flag | Default | When to turn on |
|------|---------|-----------------|
| `ENABLE_STRICT_CSP` | `false` | Production |
| `ENABLE_REQUEST_LOGGING` | `false` | Staging / debugging |
| `ENABLE_RATE_LIMITING` | `false` | When you actually have a rate-limit store wired |

**Don't gate auth or MFA enforcement behind flags.** Authorization is non-negotiable. CSP is a defense-in-depth layer that complements (not replaces) safe escape patterns in React.

Reference: [MDN Content Security Policy](https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP)
