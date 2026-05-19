# Next.js 16 + Supabase SaaS

**Version 0.1.0**  
Makerkit  
May 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Implementation-pattern reference for Next.js 16 + Supabase SaaS codebases that follow the Makerkit Turbo architecture. Contains 49 rules across 8 categories, prioritized by execution-lifecycle cascade impact — from authorization & RLS (CRITICAL) and multi-tenant data modeling (CRITICAL) through request middleware, server-side loaders, server actions, route handlers, client/server boundaries, architecture, policy engine, and UI conventions. Each rule includes a quantified impact, a why-it-matters explanation, and Incorrect/Correct code examples drawn from the canonical kit patterns. Rules name the exact @kit/* package APIs (authActionClient, getSupabaseServerClient, enhanceRouteHandler, createAccountsApi, useSupabase, useAction, definePolicy, createPoliciesEvaluator, etc.) so guidance maps directly to imports.

---

## Table of Contents

1. [Authorization & RLS](references/_sections.md#1-authorization-&-rls) — **CRITICAL**
   - 1.1 [Enforce MFA at the Middleware, Not Per-Page](references/auth-mfa-in-middleware.md) — CRITICAL (prevents MFA bypass on protected routes)
   - 1.2 [Gate the Admin Client Behind an Explicit Authorization Check](references/auth-gate-admin-client.md) — CRITICAL (prevents privilege escalation when RLS is bypassed)
   - 1.3 [Mark Server-Only Modules with `import 'server-only'`](references/auth-server-only-imports.md) — CRITICAL (prevents server secrets from bundling into the client)
   - 1.4 [Trust RLS — Do Not Duplicate Authorization Checks in App Code](references/auth-trust-rls-no-duplicate-checks.md) — CRITICAL (prevents drift between application-layer and database-layer authz)
   - 1.5 [Use `requireUser()` Instead of Raw `client.auth.getClaims()`](references/auth-use-require-user.md) — CRITICAL (prevents skipping the MFA verification gate)
   - 1.6 [Use SQL Helper Functions in RLS Policies](references/auth-use-sql-policy-helpers.md) — CRITICAL (prevents inconsistent authorization logic across tables)
   - 1.7 [Use the Standard Server Client for RLS-Enforced Reads](references/auth-use-standard-server-client.md) — CRITICAL (prevents cross-tenant data leaks)
2. [Multi-Tenant Data Modeling](references/_sections.md#2-multi-tenant-data-modeling) — **CRITICAL**
   - 2.1 [Embed `account_id` in Supabase Storage Paths](references/tenant-storage-paths-include-account-id.md) — HIGH (enables per-tenant storage RLS + cleanup on account delete)
   - 2.2 [Every Product Table Needs `account_id` + RLS + FK Index](references/tenant-account-id-on-product-tables.md) — CRITICAL (prevents tenant isolation gaps and slow queries)
   - 2.3 [Never Hand-Edit `database.types.ts` — Regenerate It](references/tenant-never-edit-generated-types.md) — HIGH (prevents silent type/schema drift)
   - 2.4 [Use `accounts` as the Single Tenant Root for Personal and Team Workspaces](references/tenant-accounts-as-tenant-root.md) — CRITICAL (prevents fragmented authorization models)
   - 2.5 [Use Account Slug in Team URLs, Not the Account UUID](references/tenant-slug-in-team-urls.md) — HIGH (prevents UUID leakage in URLs and decouples routing from primary keys)
3. [Request Boundary: Proxy & Middleware](references/_sections.md#3-request-boundary:-proxy-&-middleware) — **HIGH**
   - 3.1 [Apply Strict CSP Headers Behind an Environment Flag](references/proxy-secure-headers-flagged.md) — MEDIUM (prevents broken dev workflows while enforcing XSS protection in prod)
   - 3.2 [Compose the Request Pipeline in One `proxy.ts`](references/proxy-single-pipeline.md) — HIGH (prevents per-route middleware drift)
   - 3.3 [Match Middleware Routes with `URLPattern`, Not String Comparisons](references/proxy-url-pattern-matching.md) — MEDIUM-HIGH (prevents over-matching and trailing-slash misses)
   - 3.4 [Perform Auth Redirects at the Middleware, Not in Pages](references/proxy-redirect-auth-at-boundary.md) — HIGH (prevents redirect duplication and double round-trips)
   - 3.5 [Set a Correlation ID at the Request Boundary](references/proxy-set-correlation-id.md) — MEDIUM-HIGH (enables end-to-end request tracing through services)
4. [Server-Side Data Loading](references/_sections.md#4-server-side-data-loading) — **HIGH**
   - 4.1 [Fetch Initial Data in Server Components, Not on the Client](references/server-fetch-in-server-components.md) — HIGH (100-500ms saved per page load (removes a hydration round-trip))
   - 4.2 [Load Independent Data in Parallel with `Promise.all`](references/server-promise-all-parallel-loads.md) — HIGH (2-3x faster loaders with N concurrent reads)
   - 4.3 [Query Through Feature API Factories, Not Raw `from('table')`](references/server-use-feature-api-factories.md) — HIGH (prevents table-knowledge scattering across UI and loaders)
   - 4.4 [Redirect from the Loader When Workspace State Is Invalid](references/server-redirect-on-missing-workspace.md) — MEDIUM-HIGH (prevents rendering layouts with null data)
   - 4.5 [Services Receive the Supabase Client as a Constructor Argument](references/server-services-receive-client.md) — MEDIUM-HIGH (enables client-choice injection and unit-test mocking)
   - 4.6 [Use `Tables<'name'>` for Row Types, Not Hand-Written Interfaces](references/server-use-tables-generic-for-types.md) — MEDIUM (prevents schema drift in application types)
   - 4.7 [Wrap Per-Request Loaders with `cache()` from React](references/server-cache-workspace-loaders.md) — HIGH (prevents N duplicate queries across nested layouts)
5. [Mutations: Server Actions & Route Handlers](references/_sections.md#5-mutations:-server-actions-&-route-handlers) — **HIGH**
   - 5.1 [Call `revalidatePath()` After Successful Mutations](references/mutate-revalidate-path-after-write.md) — HIGH (prevents stale UI after writes)
   - 5.2 [Keep Actions Thin — Put Business Logic in a Service](references/mutate-thin-action-service-holds-logic.md) — MEDIUM-HIGH (enables reuse across actions, route handlers, jobs, and tests)
   - 5.3 [Log with `getLogger()` from `@kit/shared/logger`, Not `console.log`](references/mutate-use-getlogger-not-console.md) — MEDIUM (enables structured logs with correlation IDs and severity routing)
   - 5.4 [Put Zod Schemas in Their Own `*.schema.ts` File](references/mutate-zod-schema-separate-file.md) — HIGH (enables schema reuse between server action and client form)
   - 5.5 [Webhook Routes Use `auth: false` and Verify the Signature](references/mutate-webhook-verify-signature.md) — HIGH (prevents unauthenticated invocation of admin-privileged handlers)
   - 5.6 [Wrap API Routes with `enhanceRouteHandler`](references/mutate-enhance-route-handler.md) — HIGH (prevents per-route auth/validation drift across handlers)
   - 5.7 [Wrap Mutations with `authActionClient` / `publicActionClient` / `captchaActionClient`](references/mutate-use-safe-action-clients.md) — HIGH (prevents per-mutation auth/validation drift)
6. [Client/Server Boundaries](references/_sections.md#6-client/server-boundaries) — **MEDIUM-HIGH**
   - 6.1 [Call Server Actions with `useAction` from `next-safe-action/hooks`](references/client-use-action-hook.md) — MEDIUM-HIGH (prevents per-form reimplementation of loading/error/typing)
   - 6.2 [Clean Up Supabase Realtime Subscriptions in the `useEffect` Return](references/client-realtime-cleanup-subscription.md) — MEDIUM-HIGH (prevents memory leaks and duplicate event handlers per dep change)
   - 6.3 [Combine `useSupabase()` with React Query for Client-Side Data](references/client-use-supabase-with-react-query.md) — MEDIUM-HIGH (prevents duplicate fetches across hooks)
   - 6.4 [Mark `'use client'` at Leaf Components, Not Page Roots](references/client-use-client-at-leaves.md) — HIGH (saves 50-200KB per misplaced boundary)
   - 6.5 [Pass Server Data to Client Components as Props, Don't Refetch](references/client-pass-server-data-as-props.md) — HIGH (prevents double round-trip for already-loaded data)
   - 6.6 [Use Stable, Hierarchical Query Keys](references/client-stable-query-keys.md) — MEDIUM (prevents cache collisions and unnecessary refetches)
7. [Architecture & Services](references/_sections.md#7-architecture-&-services) — **MEDIUM**
   - 7.1 [Define Routes and Navigation in `config/`, Not Hardcoded in Components](references/arch-config-driven-navigation.md) — MEDIUM (prevents route-name drift across files)
   - 7.2 [Feature Packages Follow a `components / hooks / schema / server` Layout](references/arch-feature-package-layout.md) — MEDIUM (prevents structural drift across feature packages)
   - 7.3 [Hide Vendor SDKs Behind a Gateway Interface](references/arch-provider-gateway-pattern.md) — MEDIUM (enables swappable billing, mail, CMS, monitoring providers)
   - 7.4 [Import via `@kit/*` Package Exports, Never Deep Internal Paths](references/arch-import-via-package-exports.md) — MEDIUM (prevents coupling consumers to internal file structure)
   - 7.5 [Place Reusable Code in `packages/`, Product-Specific Code in `apps/web`](references/arch-app-vs-packages-boundary.md) — MEDIUM (prevents tight coupling between product composition and reusable platform)
   - 7.6 [Use `@kit/policies` for Configurable Business Rules — Not Inline Conditionals](references/arch-policy-engine-for-business-rules.md) — MEDIUM-HIGH (prevents business-rule scatter across actions, forms, and services)
8. [Forms & UI Conventions](references/_sections.md#8-forms-&-ui-conventions) — **MEDIUM**
   - 8.1 [Import UI Components from `@kit/ui/<name>`, Never Internal Paths](references/ui-kit-ui-package-imports.md) — MEDIUM (prevents bypassing makerkit-wrapped behavior)
   - 8.2 [Include `FormMessage` for Every Field](references/ui-form-message-per-field.md) — MEDIUM (prevents silent validation failures and unreadable error states)
   - 8.3 [Let `zodResolver` Infer Form Types — Don't Add `useForm` Generics](references/ui-rhf-zod-no-generics.md) — MEDIUM (prevents type/schema drift in forms)
   - 8.4 [Render Display Text Through `<Trans>` or `useTranslations`](references/ui-trans-for-display-text.md) — MEDIUM (prevents untranslated strings shipping to non-English locales)
   - 8.5 [Use Base UI `render` Prop, Not Radix `asChild`](references/ui-base-ui-render-not-aschild.md) — MEDIUM (prevents silent prop drops on misused composition)
   - 8.6 [Use Semantic Tailwind Tokens, Not Hardcoded Colors](references/ui-semantic-tailwind-tokens.md) — MEDIUM (prevents dark-mode and theme drift across components)

---

## References

1. [https://makerkit.dev/docs/next-supabase-turbo](https://makerkit.dev/docs/next-supabase-turbo)
2. [https://nextjs.org/docs/app](https://nextjs.org/docs/app)
3. [https://supabase.com/docs/guides/auth/server-side/nextjs](https://supabase.com/docs/guides/auth/server-side/nextjs)
4. [https://supabase.com/docs/guides/database/postgres/row-level-security](https://supabase.com/docs/guides/database/postgres/row-level-security)
5. [https://next-safe-action.dev/](https://next-safe-action.dev/)
6. [https://tanstack.com/query/latest/docs/framework/react/overview](https://tanstack.com/query/latest/docs/framework/react/overview)
7. [https://react.dev/reference/rsc/use-client](https://react.dev/reference/rsc/use-client)
8. [https://react.dev/reference/react/cache](https://react.dev/reference/react/cache)
9. [https://base-ui.com/react/handbook/composition](https://base-ui.com/react/handbook/composition)
10. [https://next-intl-docs.vercel.app/](https://next-intl-docs.vercel.app/)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |