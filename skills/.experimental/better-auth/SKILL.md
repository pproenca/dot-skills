---
name: better-auth
description: Use this skill whenever writing, reviewing, or migrating Better Auth code in TypeScript — setting up the auth instance, picking adapters, wiring framework route handlers, configuring sessions and cookies, adding plugins (2FA, organization, admin, magicLink, JWT), or porting from NextAuth/Auth.js, Clerk, Auth0, or Supabase Auth. Covers Next.js, SvelteKit, Hono, Express, Nuxt, Astro, and React/Vue/Svelte clients. Trigger even when the user doesn't explicitly mention Better Auth but is working on TypeScript authentication, session cookies, OAuth providers, or auth-library migration. Contains 42 rules organized by impact across 8 categories.
---

# Better Auth Best Practices

Implementation and migration guide for [Better Auth](https://www.better-auth.com), the framework-agnostic TypeScript authentication and authorization library. This skill contains 42 rules organized by impact across 8 categories, derived from the official documentation and migration guides.

## When to Apply

Reference these guidelines when:

- Setting up a fresh Better Auth instance (config, adapter, route handler, client)
- Wiring framework-specific integrations (Next.js App/Pages Router, SvelteKit, Hono, Express, Nuxt, Astro)
- Configuring sessions, cookies, and security (rate limit, trusted origins, password hashing)
- Adding plugins: 2FA, organization, admin, magicLink, JWT, passkey, multi-session
- Migrating from another auth library (NextAuth/Auth.js, Clerk, Auth0, Supabase Auth)
- Debugging "session is null" / "redirect_uri_mismatch" / 403 CSRF errors
- Reviewing PRs that touch `lib/auth.ts`, `auth-client.ts`, or `/api/auth/` route handlers

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Setup & Configuration | CRITICAL | `setup-` |
| 2 | Database Adapters & Schema | CRITICAL | `db-` |
| 3 | API Route Handlers | CRITICAL | `route-` |
| 4 | Session & Cookies | HIGH | `session-` |
| 5 | Auth Methods & Providers | HIGH | `auth-` |
| 6 | Security & Hardening | HIGH | `security-` |
| 7 | Plugins & Extensions | MEDIUM | `plugins-` |
| 8 | Migration from Other Auth | MEDIUM | `migrate-` |

## Quick Reference

### 1. Setup & Configuration (CRITICAL)

- [`setup-secret`](references/setup-secret.md) — Set a strong `BETTER_AUTH_SECRET` per environment
- [`setup-base-url`](references/setup-base-url.md) — Configure an explicit `baseURL` per environment
- [`setup-client-base-url`](references/setup-client-base-url.md) — Match the client `baseURL` to the server
- [`setup-singleton`](references/setup-singleton.md) — Export a single auth instance from a server-only module
- [`setup-trusted-origins`](references/setup-trusted-origins.md) — Configure `trustedOrigins` for all non-baseURL callers

### 2. Database Adapters & Schema (CRITICAL)

- [`db-adapter-selection`](references/db-adapter-selection.md) — Pick the adapter that matches your ORM
- [`db-schema-generate`](references/db-schema-generate.md) — Run `auth generate` then ORM migrate before every deploy
- [`db-additional-fields`](references/db-additional-fields.md) — Extend the user schema via `additionalFields`
- [`db-plugin-schema-customization`](references/db-plugin-schema-customization.md) — Rename plugin tables via the `schema` option
- [`db-database-hooks`](references/db-database-hooks.md) — Use `databaseHooks` for cross-cutting logic
- [`db-connection-pooling`](references/db-connection-pooling.md) — Share one pooled DB client with the rest of your app

### 3. API Route Handlers (CRITICAL)

- [`route-mount-catchall`](references/route-mount-catchall.md) — Mount the catch-all handler at `/api/auth/[...all]`
- [`route-runtime-selection`](references/route-runtime-selection.md) — Use the Node.js runtime for middleware that calls `auth.api`
- [`route-no-body-consumers`](references/route-no-body-consumers.md) — Mount auth before any body-parsing middleware

### 4. Session & Cookies (HIGH)

- [`session-server-vs-client`](references/session-server-vs-client.md) — Use `auth.api.getSession` on server, `authClient.useSession` on client
- [`session-expiry-tuning`](references/session-expiry-tuning.md) — Configure `expiresIn` and `updateAge` together
- [`session-cookie-cache`](references/session-cookie-cache.md) — Enable `cookieCache` to cut session DB lookups
- [`session-cookie-attributes`](references/session-cookie-attributes.md) — Set `sameSite`, `secure`, `partitioned` for cross-site flows
- [`session-cross-subdomain`](references/session-cross-subdomain.md) — Enable `crossSubDomainCookies` for multi-subdomain apps
- [`session-customsession-fields`](references/session-customsession-fields.md) — Use `customSession` to add computed fields

### 5. Auth Methods & Providers (HIGH)

- [`auth-require-email-verification`](references/auth-require-email-verification.md) — Enable `requireEmailVerification` with `sendVerificationEmail`
- [`auth-oauth-redirect-uri`](references/auth-oauth-redirect-uri.md) — Match OAuth `redirectURI` exactly with the provider console
- [`auth-oauth-env-vars`](references/auth-oauth-env-vars.md) — Load OAuth credentials from environment, never inline
- [`auth-magic-link-setup`](references/auth-magic-link-setup.md) — Implement `sendMagicLink` before enabling the `magicLink` plugin
- [`auth-client-sign-in-helpers`](references/auth-client-sign-in-helpers.md) — Use `authClient.signIn.social` with `callbackURL`
- [`auth-infer-additional-fields`](references/auth-infer-additional-fields.md) — Add `inferAdditionalFields` to the client for type sync

### 6. Security & Hardening (HIGH)

- [`security-rate-limit`](references/security-rate-limit.md) — Enable `rateLimit` with persistent storage in production
- [`security-password-hash-interop`](references/security-password-hash-interop.md) — Override hash function when migrating from bcrypt/argon2
- [`security-revoke-on-password-reset`](references/security-revoke-on-password-reset.md) — Enable `revokeSessionsOnPasswordReset`
- [`security-min-password-length`](references/security-min-password-length.md) — Set `minPasswordLength` to at least 10
- [`security-trusted-origins-strict`](references/security-trusted-origins-strict.md) — Never wildcard `trustedOrigins`

### 7. Plugins & Extensions (MEDIUM)

- [`plugins-next-cookies-last`](references/plugins-next-cookies-last.md) — Place `nextCookies()` as the LAST plugin in Next.js
- [`plugins-two-factor-issuer`](references/plugins-two-factor-issuer.md) — Set `appName` as the 2FA issuer
- [`plugins-shared-access-control`](references/plugins-shared-access-control.md) — Define `ac` + roles once, share server/client
- [`plugins-pair-client-server`](references/plugins-pair-client-server.md) — Pair every server plugin with its client counterpart
- [`plugins-organization-active-context`](references/plugins-organization-active-context.md) — Set active organization on session
- [`plugins-jwt-when-to-use`](references/plugins-jwt-when-to-use.md) — Use the `jwt` plugin only for external service consumers
- [`plugins-admin-impersonation`](references/plugins-admin-impersonation.md) — Use admin plugin's `impersonate` method for support access

### 8. Migration from Other Auth (MEDIUM)

- [`migrate-parallel-cutover`](references/migrate-parallel-cutover.md) — Run Better Auth alongside legacy auth during cutover
- [`migrate-oauth-account-mapping`](references/migrate-oauth-account-mapping.md) — Map legacy OAuth identities to `account` rows
- [`migrate-force-allow-id`](references/migrate-force-allow-id.md) — Use `forceAllowId` to preserve existing user IDs
- [`migrate-nextauth-schema-mapping`](references/migrate-nextauth-schema-mapping.md) — Map NextAuth v5 columns field-by-field

## How to Use

For a fresh implementation, read in priority order: start with all `setup-` rules, then `db-`, then `route-` — these CRITICAL categories must be correct or nothing else works. After the foundation, pick the rules that match your scope: `session-` for cookie/expiry tuning, `auth-` for provider configuration, `security-` for production hardening.

For a migration from another auth library, read `migrate-parallel-cutover` first (strategy), then `security-password-hash-interop` (preserve user passwords), then `migrate-oauth-account-mapping` and `migrate-nextauth-schema-mapping` (data layout).

Read individual reference files for detailed explanations, incorrect vs. correct code examples, and links to the canonical Better Auth documentation.

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions ordered by impact |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for adding new rules |
| [metadata.json](metadata.json) | Version, references, and discipline metadata |
