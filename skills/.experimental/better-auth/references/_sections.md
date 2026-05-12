# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Setup & Configuration (setup)

**Impact:** CRITICAL  
**Description:** Missing or misconfigured secret, baseURL, or trusted origins breaks every downstream auth operation — wrong `BETTER_AUTH_SECRET` invalidates sessions, missing `baseURL` breaks OAuth redirects, and origin mismatches block all cross-origin requests.

## 2. Database Adapters & Schema (db)

**Impact:** CRITICAL  
**Description:** The adapter and schema connect the entire auth surface to your data layer — wrong adapter or stale schema causes silent runtime failures on every sign-in, session lookup, and account link, and plugin tables go missing without an explicit `generate` step.

## 3. API Route Handlers (route)

**Impact:** CRITICAL  
**Description:** Better Auth ships endpoints as a single handler that must be mounted correctly per framework — unmounted or wrongly-shaped routes return 404 on every auth request, and missing `nextCookies()` or middleware that consumes the body breaks server actions and session cookie setting.

## 4. Session & Cookies (session)

**Impact:** HIGH  
**Description:** Session retrieval, cookie attributes, and refresh strategy determine whether authenticated requests are honored — using `authClient.getSession` on the server returns null, wrong `sameSite`/`secure` breaks cross-site flows, and missing `cookieCache` floods the database with session lookups.

## 5. Auth Methods & Providers (auth)

**Impact:** HIGH  
**Description:** Email/password, OAuth, and magic link flows each have their own correctness gates — missing `sendVerificationEmail`, mismatched `redirectURI`, or skipped `requireEmailVerification` either silently disables features or opens account-takeover paths.

## 6. Security & Hardening (security)

**Impact:** HIGH  
**Description:** CSRF defense, rate limiting, password hash interop, and secret hygiene are the difference between a credible auth deployment and a compromise vector — Better Auth's defaults are safe, but production deployments need explicit `trustedOrigins`, persistent rate-limit storage, and revocation policies.

## 7. Plugins & Extensions (plugins)

**Impact:** MEDIUM  
**Description:** The plugin ecosystem (2FA, organization, admin, JWT, stripe) extends the core auth surface — most failures come from plugin ordering (`nextCookies` must be last), missing client/server plugin pairs, and inconsistent access-control definitions across the boundary.

## 8. Migration from Other Auth (migrate)

**Impact:** MEDIUM  
**Description:** Cross-provider migration patterns (cutover strategy, OAuth identity mapping, ID preservation) plus one NextAuth-specific schema migration. Provider-specific concerns from Clerk/Auth0/Supabase live across `security-password-hash-interop` (bcrypt/scrypt interop) and the official Better Auth migration guides linked from each rule — these rules cover the structural patterns common to all migrations.
