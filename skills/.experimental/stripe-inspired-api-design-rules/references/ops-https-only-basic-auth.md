---
title: Enforce HTTPS Only and Use HTTP Basic Auth with the Key as Username
impact: HIGH
impactDescription: prevents key leakage over plaintext channels and trivialises curl usage
tags: ops, auth, https, basic-auth
---

## Enforce HTTPS Only and Use HTTP Basic Auth with the Key as Username

All requests must use HTTPS — plaintext HTTP requests are rejected outright (typically with a hard error, never a silent redirect that could leak credentials). Authentication is HTTP Basic Auth with the API key as the **username** and an empty password (`Authorization: Basic <base64(key:)>`). `Authorization: Bearer <key>` is also accepted for CORS scenarios where Basic Auth is awkward.

The HTTPS-only stance is non-negotiable for an API that carries credentials and PII. Allowing HTTP "for convenience" creates a class of bugs where a misconfigured client sends a key over plaintext once — and that key is now compromised. Basic Auth with key-as-username works in every HTTP client and shell tool without extra config; nobody needs to learn a custom auth scheme.

**Incorrect (HTTPS optional / silent HTTP→HTTPS redirect):**

```text
GET http://api.example.com/v1/customers/cus_X
Authorization: Basic c2tfbGl2ZV9hYmMxMjM6

# Server responds: 301 Moved Permanently
# Location: https://api.example.com/v1/customers/cus_X
```

```text
// The key was already transmitted in plaintext before the redirect.
// Anyone on the network path has it. Rotation required, audit trail needed.
// The "redirect to HTTPS" is the wrong fix — the damage was the first request.
```

**Incorrect (custom auth header — every client needs a special case):**

```text
GET /v1/customers/cus_X HTTP/1.1
X-Api-Key: sk_live_abc123
X-Account-Id: acct_X
X-Signature: hmac-sha256-of-...
```

```text
// Curl one-liner needs three -H flags.
// HTTP libraries don't know about it — every client writes auth code.
// Common bugs: missing header, wrong casing, signature edge cases.
```

**Correct (HTTPS-only, HTTP Basic Auth with key as username):**

```text
GET https://api.example.com/v1/customers/cus_X HTTP/1.1
Authorization: Basic c2tfbGl2ZV9hYmMxMjM6
# Decoded: sk_live_abc123:  (key as username, empty password)
```

```text
// HTTPS enforced — plaintext request rejected with 400 or connection refused.
// Basic Auth works in every HTTP library: requests.get(url, auth=(key, ''))
// Curl one-liner: curl https://api.example.com/v1/customers/cus_X -u sk_live_abc123:
```

**Why key-as-username + empty-password:**
- Most HTTP libraries accept Basic Auth as a tuple: `(username, password)` → key is the only string to handle
- Curl's `-u key:` syntax is one flag, no encoding
- No risk of forgetting to set the password field — it's always empty

**Bearer Auth is also accepted** for environments where Basic Auth is awkward (CORS preflight, browser-based tooling, JWT-style middleware):

```text
GET /v1/customers/cus_X HTTP/1.1
Authorization: Bearer sk_live_abc123
```

```text
// Same key, different transport. Server accepts both.
// Both produce identical behaviour — bearer is purely an ergonomic alternative.
```

**HSTS the API domain** to prevent downgrade attacks:

```text
Strict-Transport-Security: max-age=63072000; includeSubDomains; preload
```

After the first response, the browser/client refuses to make any non-HTTPS request to the domain — even if a misconfigured client attempts plaintext.

**TLS 1.2+ minimum.** Drop TLS 1.0/1.1 connections; they have known weaknesses and modern clients support 1.2+. Stripe announced and deprecated TLS 1.0/1.1 well ahead of forcing the cutoff.

**Reject keys sent in URL params** (`?api_key=sk_live_X`). URL-embedded credentials end up in browser history, server logs, referer headers, and CDN access logs. Always require credentials in the `Authorization` header.

**Document the auth scheme front-and-centre** in the API docs — first page after "getting started", not buried in a security section.

Reference: [Stripe authentication](https://docs.stripe.com/api/authentication)
