# Better Auth

**Version 0.1.0**  
Personal  
May 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Implementation and migration guide for Better Auth, the framework-agnostic TypeScript authentication and authorization library. Contains 42 rules across 8 categories prioritized by impact — from CRITICAL setup, database adapter, and route handler configuration to HIGH session, security, and provider concerns down to MEDIUM plugin ecosystem and migration paths from NextAuth/Auth.js, Clerk, Auth0, and Supabase Auth. Each rule includes incorrect and correct code examples covering Next.js (App and Pages Router), SvelteKit, Hono, Express, Nuxt, Astro, and React/Vue/Svelte clients.

---

## Table of Contents

1. [Setup & Configuration](references/_sections.md#1-setup-&-configuration) — **CRITICAL**
   - 1.1 [Configure an Explicit baseURL Per Environment](references/setup-base-url.md) — CRITICAL (prevents OAuth callback failures and incorrect redirect URLs)
   - 1.2 [Configure trustedOrigins for All Non-baseURL Callers](references/setup-trusted-origins.md) — CRITICAL (prevents CSRF-blocked sign-ins from extensions, mobile apps, and preview deploys)
   - 1.3 [Export a Single Auth Instance from a Server-Only Module](references/setup-singleton.md) — CRITICAL (prevents duplicate database connections, type drift, and leaked secrets)
   - 1.4 [Match the Client baseURL to the Server baseURL](references/setup-client-base-url.md) — CRITICAL (prevents cross-origin auth failures and silent CORS rejections)
   - 1.5 [Set a Strong BETTER_AUTH_SECRET in Every Environment](references/setup-secret.md) — CRITICAL (prevents session forgery and silent session invalidation)
2. [Database Adapters & Schema](references/_sections.md#2-database-adapters-&-schema) — **CRITICAL**
   - 2.1 [Extend the User Schema via additionalFields, Not Raw Columns](references/db-additional-fields.md) — CRITICAL (prevents type drift between database and Better Auth's session object)
   - 2.2 [Pick the Adapter That Matches Your ORM, Not the Default](references/db-adapter-selection.md) — CRITICAL (prevents runtime type errors and schema drift between Better Auth and your app)
   - 2.3 [Rename Plugin Tables and Columns via the schema Option, Not Migrations](references/db-plugin-schema-customization.md) — HIGH (prevents Better Auth from querying wrong table/column names after manual renames)
   - 2.4 [Run auth generate Then Your ORM Migrate Before Every Deploy](references/db-schema-generate.md) — CRITICAL (prevents all auth endpoints from 500-erroring after a plugin is added)
   - 2.5 [Share One Pooled Database Client With the Rest of Your App](references/db-connection-pooling.md) — HIGH (prevents connection exhaustion on serverless platforms (Vercel, Lambda))
   - 2.6 [Use databaseHooks for Cross-Cutting Logic, Not Application-Layer Wrappers](references/db-database-hooks.md) — HIGH (prevents missed paths when auth events are triggered by plugins or background jobs)
3. [API Route Handlers](references/_sections.md#3-api-route-handlers) — **CRITICAL**
   - 3.1 [Mount Auth Before Any Body-Parsing Middleware](references/route-no-body-consumers.md) — HIGH (prevents 400 "empty body" errors on POST sign-in / sign-up requests)
   - 3.2 [Mount the Catch-All Handler at /api/auth/[...all] (or Framework Equivalent)](references/route-mount-catchall.md) — CRITICAL (prevents 404 on every sign-in, OAuth callback, and session request)
   - 3.3 [Use the Node.js Runtime for Middleware That Calls auth.api](references/route-runtime-selection.md) — CRITICAL (prevents Edge Runtime crashes from database adapter incompatibility)
4. [Session & Cookies](references/_sections.md#4-session-&-cookies) — **HIGH**
   - 4.1 [Configure expiresIn and updateAge Together for Sliding-Window Sessions](references/session-expiry-tuning.md) — HIGH (prevents both premature logout and indefinite session lifetime)
   - 4.2 [Enable cookieCache to Cut Session Database Lookups by 99%](references/session-cookie-cache.md) — HIGH (100x improvement in session lookup latency on cached hits)
   - 4.3 [Enable crossSubDomainCookies for Multi-Subdomain Apps](references/session-cross-subdomain.md) — HIGH (prevents users from having to re-authenticate when navigating between subdomains)
   - 4.4 [Set sameSite, secure, and partitioned for Cross-Site Auth Flows](references/session-cookie-attributes.md) — HIGH (prevents browsers from silently dropping cookies in third-party contexts)
   - 4.5 [Use auth.api.getSession on the Server, authClient.useSession on the Client](references/session-server-vs-client.md) — HIGH (prevents always-null session in server components and stale data in client UI)
   - 4.6 [Use customSession to Add Computed Fields to the Session Response](references/session-customsession-fields.md) — MEDIUM-HIGH (prevents N+1 database queries from every protected page joining session→user→role)
5. [Auth Methods & Providers](references/_sections.md#5-auth-methods-&-providers) — **HIGH**
   - 5.1 [Add inferAdditionalFields to the Client to Keep Types in Sync](references/auth-infer-additional-fields.md) — HIGH (prevents type drift between server-defined user fields and client useSession types)
   - 5.2 [Enable requireEmailVerification and Implement sendVerificationEmail Together](references/auth-require-email-verification.md) — HIGH (prevents account-takeover via signup with someone else's email)
   - 5.3 [Implement sendMagicLink Before Enabling the magicLink Plugin](references/auth-magic-link-setup.md) — HIGH (prevents passwordless sign-in from silently failing in production)
   - 5.4 [Load OAuth Credentials From Environment, Never Inline in Source](references/auth-oauth-env-vars.md) — HIGH (prevents committed secret keys from leaking to repo history and CI logs)
   - 5.5 [Match OAuth redirectURI Exactly With the Provider Console](references/auth-oauth-redirect-uri.md) — HIGH (prevents redirect_uri_mismatch on every OAuth attempt in non-default environments)
   - 5.6 [Use authClient.signIn.social with callbackURL Instead of Hand-Rolled Redirects](references/auth-client-sign-in-helpers.md) — HIGH (prevents bypassing the CSRF state token and provider linking logic)
6. [Security & Hardening](references/_sections.md#6-security-&-hardening) — **HIGH**
   - 6.1 [Enable rateLimit With Persistent Storage in Production](references/security-rate-limit.md) — HIGH (prevents credential-stuffing attacks and CPU exhaustion from brute-force sign-ins)
   - 6.2 [Enable revokeSessionsOnPasswordReset to Invalidate All Active Sessions](references/security-revoke-on-password-reset.md) — HIGH (prevents a leaked session from surviving a password reset by the legitimate owner)
   - 6.3 [Never Wildcard trustedOrigins; List Origins Explicitly](references/security-trusted-origins-strict.md) — HIGH (prevents arbitrary cross-origin sites from initiating sign-in against your API)
   - 6.4 [Override the Password Hash Function When Migrating from bcrypt/argon2](references/security-password-hash-interop.md) — HIGH (prevents forcing all migrated users to reset passwords on first sign-in)
   - 6.5 [Set minPasswordLength to At Least 10, Not the Default 8](references/security-min-password-length.md) — MEDIUM-HIGH (prevents trivially-brute-forceable passwords from being accepted at signup)
7. [Plugins & Extensions](references/_sections.md#7-plugins-&-extensions) — **MEDIUM**
   - 7.1 [Define Access Control and Roles Once, Share Between Server and Client Plugins](references/plugins-shared-access-control.md) — MEDIUM-HIGH (prevents permission drift between server-enforced and client-checked roles)
   - 7.2 [Pair Every Server Plugin With Its Client Counterpart](references/plugins-pair-client-server.md) — MEDIUM-HIGH (prevents authClient method calls from being undefined at runtime)
   - 7.3 [Place nextCookies() as the LAST Plugin in Next.js Apps](references/plugins-next-cookies-last.md) — HIGH (prevents sign-in from server actions silently leaving cookies unset)
   - 7.4 [Set appName as the 2FA Issuer for Authenticator App Display](references/plugins-two-factor-issuer.md) — MEDIUM (prevents users seeing "Better Auth" in their authenticator app instead of your brand)
   - 7.5 [Set the Active Organization on Session, Don't Pass It Per-Request](references/plugins-organization-active-context.md) — MEDIUM (prevents inconsistent active-org state across tabs and stale auth checks)
   - 7.6 [Use admin Plugin's impersonate Method for Support Access, Not Manual Session Creation](references/plugins-admin-impersonation.md) — MEDIUM (prevents support sessions from looking indistinguishable from real user sessions in audit logs)
   - 7.7 [Use the jwt Plugin Only for External Service Consumers, Not Your Own Frontend](references/plugins-jwt-when-to-use.md) — MEDIUM (prevents needlessly turning revocable session cookies into long-lived bearer tokens)
8. [Migration from Other Auth](references/_sections.md#8-migration-from-other-auth) — **MEDIUM**
   - 8.1 [Map Legacy OAuth Identities to Better Auth account Rows, Preserving Provider IDs](references/migrate-oauth-account-mapping.md) — MEDIUM (prevents OAuth users from being treated as new users on first sign-in after migration)
   - 8.2 [Map NextAuth v5 Tables to Better Auth Schema Field-by-Field](references/migrate-nextauth-schema-mapping.md) — MEDIUM (prevents silent data loss when adapter expects fields the legacy schema doesn't have)
   - 8.3 [Run Better Auth Alongside Legacy Auth During Cutover, Don't Big-Bang Switch](references/migrate-parallel-cutover.md) — MEDIUM (prevents locking out users whose data didn't migrate cleanly)
   - 8.4 [Use forceAllowId During Bulk Migration to Preserve Existing User IDs](references/migrate-force-allow-id.md) — MEDIUM (prevents foreign keys in your business tables from pointing at obsolete user IDs)

---

## References

1. [https://www.better-auth.com/docs](https://www.better-auth.com/docs)
2. [https://www.better-auth.com/docs/installation](https://www.better-auth.com/docs/installation)
3. [https://www.better-auth.com/docs/concepts/database](https://www.better-auth.com/docs/concepts/database)
4. [https://www.better-auth.com/docs/concepts/session-management](https://www.better-auth.com/docs/concepts/session-management)
5. [https://www.better-auth.com/docs/concepts/cookies](https://www.better-auth.com/docs/concepts/cookies)
6. [https://www.better-auth.com/docs/concepts/rate-limit](https://www.better-auth.com/docs/concepts/rate-limit)
7. [https://www.better-auth.com/docs/concepts/typescript](https://www.better-auth.com/docs/concepts/typescript)
8. [https://www.better-auth.com/docs/reference/options](https://www.better-auth.com/docs/reference/options)
9. [https://www.better-auth.com/docs/reference/security](https://www.better-auth.com/docs/reference/security)
10. [https://www.better-auth.com/docs/integrations/next](https://www.better-auth.com/docs/integrations/next)
11. [https://www.better-auth.com/docs/integrations/svelte-kit](https://www.better-auth.com/docs/integrations/svelte-kit)
12. [https://www.better-auth.com/docs/integrations/hono](https://www.better-auth.com/docs/integrations/hono)
13. [https://www.better-auth.com/docs/integrations/express](https://www.better-auth.com/docs/integrations/express)
14. [https://www.better-auth.com/docs/integrations/astro](https://www.better-auth.com/docs/integrations/astro)
15. [https://www.better-auth.com/docs/integrations/nuxt](https://www.better-auth.com/docs/integrations/nuxt)
16. [https://www.better-auth.com/docs/adapters/drizzle](https://www.better-auth.com/docs/adapters/drizzle)
17. [https://www.better-auth.com/docs/adapters/prisma](https://www.better-auth.com/docs/adapters/prisma)
18. [https://www.better-auth.com/docs/authentication/email-password](https://www.better-auth.com/docs/authentication/email-password)
19. [https://www.better-auth.com/docs/authentication/google](https://www.better-auth.com/docs/authentication/google)
20. [https://www.better-auth.com/docs/plugins/2fa](https://www.better-auth.com/docs/plugins/2fa)
21. [https://www.better-auth.com/docs/plugins/organization](https://www.better-auth.com/docs/plugins/organization)
22. [https://www.better-auth.com/docs/plugins/admin](https://www.better-auth.com/docs/plugins/admin)
23. [https://www.better-auth.com/docs/plugins/jwt](https://www.better-auth.com/docs/plugins/jwt)
24. [https://www.better-auth.com/docs/plugins/magic-link](https://www.better-auth.com/docs/plugins/magic-link)
25. [https://www.better-auth.com/docs/plugins/custom-session](https://www.better-auth.com/docs/plugins/custom-session)
26. [https://www.better-auth.com/docs/guides/next-auth-migration-guide](https://www.better-auth.com/docs/guides/next-auth-migration-guide)
27. [https://www.better-auth.com/docs/guides/clerk-migration-guide](https://www.better-auth.com/docs/guides/clerk-migration-guide)
28. [https://www.better-auth.com/docs/guides/auth0-migration-guide](https://www.better-auth.com/docs/guides/auth0-migration-guide)
29. [https://www.better-auth.com/docs/guides/supabase-migration-guide](https://www.better-auth.com/docs/guides/supabase-migration-guide)
30. [https://github.com/better-auth/better-auth](https://github.com/better-auth/better-auth)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |