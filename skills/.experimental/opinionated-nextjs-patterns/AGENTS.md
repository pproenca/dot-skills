# Next.js 16 (App Router)

**Version 0.2.0**  
Community  
May 2026

---

## Abstract

Opinionated, backend-agnostic implementation-pattern reference for Next.js 16 (App Router) codebases. Contains 50 rules across 8 categories, prioritized by execution-lifecycle cascade impact — from authorization at the data layer (CRITICAL) and optional multi-tenant modeling (CRITICAL) through the proxy.ts request boundary, server-side loaders, mutations, client/server boundaries, architecture, and UI conventions. Each rule states a transferable principle and includes a why-it-matters explanation plus Incorrect/Correct code examples. Examples use Supabase as the concrete backend, with a Transferable note where the store matters (Drizzle, Prisma). The target structure is a Turbo monorepo of @app/* packages built on canonical libraries — next-safe-action, @supabase/ssr, @tanstack/react-query, react-hook-form + zod, shadcn/ui, next-intl, pino — that confine the backend behind one data-access package, rather than a vendored starter kit.

---

## Table of Contents

1. [Authorization & Data-Layer Access](references/_sections.md#1-authorization-&-data-layer-access) — **CRITICAL**
   - 1.1 [Authorize Once at the Data Layer — Don't Re-Check the Same Rule in App Code](references/auth-trust-rls-no-duplicate-checks.md) — CRITICAL (prevents drift between application-layer and database-layer authz)
   - 1.2 [Centralize the Auth Gate in One `requireUser()` Helper Instead of Scattering Raw Claim Checks](references/auth-use-require-user.md) — CRITICAL (prevents skipping the MFA verification gate)
   - 1.3 [Enforce MFA at the Proxy Boundary, Not Per-Page](references/auth-mfa-in-middleware.md) — CRITICAL (prevents MFA bypass on protected routes)
   - 1.4 [Gate the Privileged Client Behind an Authorization Check Done Before You Construct It](references/auth-gate-admin-client.md) — CRITICAL (prevents privilege escalation when the data layer is bypassed)
   - 1.5 [Mark Server-Only Modules with `import 'server-only'`](references/auth-server-only-imports.md) — CRITICAL (prevents server secrets from bundling into the client)
   - 1.6 [Read Through the Request-Scoped Auth-Bound Client, Never the Privileged Client by Default](references/auth-use-standard-server-client.md) — CRITICAL (prevents cross-tenant data leaks)
   - 1.7 [Use Reusable SQL Helper Functions Inside RLS Policies](references/auth-use-sql-policy-helpers.md) — CRITICAL (prevents inconsistent authorization logic across tables)
2. [Multi-Tenancy](references/_sections.md#2-multi-tenancy) — **CRITICAL *(when building multi-tenant SaaS; skip this category entirely for single-tenant apps)***
   - 2.1 [Anchor Every Tenant on One Root Table That Personal and Team Workspaces Both Reference](references/tenant-accounts-as-tenant-root.md) — CRITICAL (prevents fragmented authorization models)
   - 2.2 [Give Every Tenant-Scoped Table the Tenant Key, an Index on It, and a Policy That Filters by It](references/tenant-account-id-on-product-tables.md) — CRITICAL (prevents tenant isolation gaps and slow queries)
   - 2.3 [Namespace Object-Storage Paths by Tenant ID So Access Rules Can Match on the Path](references/tenant-storage-paths-include-account-id.md) — HIGH (enables per-tenant storage RLS + cleanup on account delete)
   - 2.4 [Put a Human-Readable Tenant Slug in Team URLs, Not the Tenant UUID](references/tenant-slug-in-team-urls.md) — HIGH (prevents UUID leakage in URLs and decouples routing from primary keys)
   - 2.5 [Treat Generated DB Types as Build Output — Regenerate, Never Hand-Edit](references/tenant-never-edit-generated-types.md) — HIGH (prevents silent type/schema drift)
3. [Request Boundary: Proxy](references/_sections.md#3-request-boundary:-proxy) — **HIGH**
   - 3.1 [Apply Strict CSP Headers Behind an Environment Flag](references/proxy-secure-headers-flagged.md) — MEDIUM (prevents broken dev workflows while enforcing XSS protection in prod)
   - 3.2 [Compose the Whole Request Pipeline in One `proxy.ts`](references/proxy-single-pipeline.md) — HIGH (prevents per-route request-handling drift)
   - 3.3 [Match Proxy Routes with `URLPattern`, Not String Comparisons](references/proxy-url-pattern-matching.md) — MEDIUM-HIGH (prevents over-matching and trailing-slash misses)
   - 3.4 [Perform Auth Redirects at the Proxy, Not in Pages](references/proxy-redirect-auth-at-boundary.md) — HIGH (prevents redirect duplication and double round-trips)
   - 3.5 [Set a Correlation ID at the Request Boundary](references/proxy-set-correlation-id.md) — MEDIUM-HIGH (enables end-to-end request tracing through services)
4. [Server-Side Data Loading](references/_sections.md#4-server-side-data-loading) — **HIGH**
   - 4.1 [Fetch Initial Data in Server Components, Not on the Client](references/server-fetch-in-server-components.md) — HIGH (100-500ms saved per page load (removes a hydration round-trip))
   - 4.2 [Load Independent Data in Parallel with `Promise.all`](references/server-promise-all-parallel-loads.md) — HIGH (2-3x faster loaders with N concurrent reads)
   - 4.3 [Read Through a Typed Data-Access Factory, Not Raw `from('table')`](references/server-use-feature-api-factories.md) — HIGH (prevents table-knowledge scattering across UI and loaders)
   - 4.4 [Redirect from the Loader When Workspace State Is Invalid](references/server-redirect-on-missing-workspace.md) — MEDIUM-HIGH (prevents rendering layouts with null data)
   - 4.5 [Services Receive the Data Client as a Constructor Argument](references/server-services-receive-client.md) — MEDIUM-HIGH (enables client-choice injection and unit-test mocking)
   - 4.6 [Use Generated Row Types (`Tables<'name'>`), Not Hand-Written Interfaces](references/server-use-tables-generic-for-types.md) — MEDIUM (prevents schema drift in application types)
   - 4.7 [Wrap Per-Request Loaders with `cache()` from React](references/server-cache-workspace-loaders.md) — HIGH (prevents N duplicate queries across nested layouts)
5. [Mutations: Server Actions & Route Handlers](references/_sections.md#5-mutations:-server-actions-&-route-handlers) — **HIGH**
   - 5.1 [Call `revalidatePath()` After a Successful Write So the UI Refreshes](references/mutate-revalidate-path-after-write.md) — HIGH (prevents stale UI after writes)
   - 5.2 [Keep the Action Thin — Put Business Logic in a Service](references/mutate-thin-action-service-holds-logic.md) — MEDIUM-HIGH (enables reuse across actions, route handlers, jobs, and tests)
   - 5.3 [Log Through a Structured Logger You Own, Not `console.log`](references/mutate-use-getlogger-not-console.md) — MEDIUM (enables structured logs with correlation IDs and severity routing)
   - 5.4 [Put Zod Schemas in Their Own `*.schema.ts` File Shared by Client and Server](references/mutate-zod-schema-separate-file.md) — HIGH (enables schema reuse between server action and client form)
   - 5.5 [Run Every Mutation Through a Typed Auth-Checked Action Client You Build on next-safe-action](references/mutate-use-safe-action-clients.md) — HIGH (prevents per-mutation auth/validation drift)
   - 5.6 [Webhook Routes Skip the User-Auth Wrapper and Verify the Provider Signature](references/mutate-webhook-verify-signature.md) — HIGH (prevents unauthenticated invocation of admin-privileged handlers)
   - 5.7 [Wrap Route Handlers in a Typed Handler That Owns Auth and Validation](references/mutate-enhance-route-handler.md) — HIGH (prevents per-route auth/validation drift across handlers)
6. [Client/Server Boundaries](references/_sections.md#6-client/server-boundaries) — **MEDIUM-HIGH**
   - 6.1 [Call Server Actions with `useAction` from `next-safe-action/hooks`](references/client-use-action-hook.md) — MEDIUM-HIGH (prevents per-form reimplementation of loading/error/typing)
   - 6.2 [Mark `'use client'` at Leaf Components, Not Page Roots](references/client-use-client-at-leaves.md) — HIGH (saves 50-200KB per misplaced boundary)
   - 6.3 [Pair a Memoized Browser Data Client with TanStack Query for Client-Side Reads](references/client-use-supabase-with-react-query.md) — MEDIUM-HIGH (prevents duplicate fetches across hooks)
   - 6.4 [Pass Server Data to Client Components as Props, Don't Refetch](references/client-pass-server-data-as-props.md) — HIGH (prevents double round-trip for already-loaded data)
   - 6.5 [Tear Down Any Subscription or Event Source in the `useEffect` Return](references/client-realtime-cleanup-subscription.md) — MEDIUM-HIGH (prevents memory leaks and duplicate event handlers per dep change)
   - 6.6 [Use Stable, Hierarchical Query Keys](references/client-stable-query-keys.md) — MEDIUM (prevents cache collisions and unnecessary refetches)
7. [Architecture & Services](references/_sections.md#7-architecture-&-services) — **MEDIUM**
   - 7.1 [Confine the Backend to One Data-Access Package with a Stable Surface](references/arch-data-access-adapter.md) — MEDIUM (keeps the data store swappable and testable)
   - 7.2 [Define Routes and Navigation in `config/`, Not Hardcoded in Components](references/arch-config-driven-navigation.md) — MEDIUM (prevents route-name drift across files)
   - 7.3 [Feature Packages Follow a `components / hooks / schema / server` Layout](references/arch-feature-package-layout.md) — MEDIUM (prevents structural drift across feature packages)
   - 7.4 [Hide Vendor SDKs Behind a Gateway Interface](references/arch-provider-gateway-pattern.md) — MEDIUM (enables swappable billing, mail, CMS, monitoring providers)
   - 7.5 [Import via the Package `exports` Map, Never Deep Internal Paths](references/arch-import-via-package-exports.md) — MEDIUM (prevents coupling consumers to internal file structure)
   - 7.6 [Model Business Rules in a Policy Layer You Own — Not Inline Conditionals](references/arch-policy-engine-for-business-rules.md) — MEDIUM-HIGH (prevents business-rule scatter across actions, forms, and services)
   - 7.7 [Place Reusable Capabilities in `packages/`, Product-Specific Code in `apps/web`](references/arch-app-vs-packages-boundary.md) — MEDIUM (prevents tight coupling between product composition and reusable platform)
8. [Forms & UI Conventions](references/_sections.md#8-forms-&-ui-conventions) — **MEDIUM**
   - 8.1 [Import UI from Your Design-System Package Surface, Never Internal Paths](references/ui-kit-ui-package-imports.md) — MEDIUM (prevents bypassing your design-system wrapper behavior)
   - 8.2 [Include `FormMessage` for Every Field](references/ui-form-message-per-field.md) — MEDIUM (prevents silent validation failures and unreadable error states)
   - 8.3 [Let `zodResolver` Infer Form Types — Don't Add `useForm` Generics](references/ui-rhf-zod-no-generics.md) — MEDIUM (prevents type/schema drift in forms)
   - 8.4 [Render Display Text Through `<Trans>` or `useTranslations`](references/ui-trans-for-display-text.md) — MEDIUM (prevents untranslated strings shipping to non-English locales)
   - 8.5 [Use Base UI `render` Prop, Not Radix `asChild`](references/ui-base-ui-render-not-aschild.md) — MEDIUM (prevents silent prop drops on misused composition)
   - 8.6 [Use Semantic Tailwind Tokens, Not Hardcoded Colors](references/ui-semantic-tailwind-tokens.md) — MEDIUM (prevents dark-mode and theme drift across components)

---

## References

1. [https://nextjs.org/docs/app](https://nextjs.org/docs/app)
2. [https://nextjs.org/docs/app/api-reference/file-conventions/proxy](https://nextjs.org/docs/app/api-reference/file-conventions/proxy)
3. [https://next-safe-action.dev/](https://next-safe-action.dev/)
4. [https://tanstack.com/query/latest/docs/framework/react/overview](https://tanstack.com/query/latest/docs/framework/react/overview)
5. [https://react.dev/reference/react/cache](https://react.dev/reference/react/cache)
6. [https://react.dev/reference/rsc/use-client](https://react.dev/reference/rsc/use-client)
7. [https://react-hook-form.com/](https://react-hook-form.com/)
8. [https://zod.dev/](https://zod.dev/)
9. [https://ui.shadcn.com/docs](https://ui.shadcn.com/docs)
10. [https://base-ui.com/react/handbook/composition](https://base-ui.com/react/handbook/composition)
11. [https://next-intl.dev/](https://next-intl.dev/)
12. [https://turborepo.com/docs/core-concepts/internal-packages](https://turborepo.com/docs/core-concepts/internal-packages)
13. [https://supabase.com/docs/guides/auth/server-side/nextjs](https://supabase.com/docs/guides/auth/server-side/nextjs)
14. [https://supabase.com/docs/guides/database/postgres/row-level-security](https://supabase.com/docs/guides/database/postgres/row-level-security)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |