---
name: nextjs-supabase-saas-patterns
description: Use this skill whenever writing, reviewing, or refactoring Next.js + Supabase SaaS code that follows the Makerkit Turbo architecture — covers authorization & RLS, multi-tenant data modeling (accounts as tenant root + account_id), request middleware (proxy.ts), server-side data loading with cache() and feature APIs, server actions wrapped with authActionClient, route handlers with enhanceRouteHandler, client/server boundaries ('use client' discipline), React Query hooks with useSupabase, forms with React Hook Form + Zod, and feature-package layout. Trigger on tasks involving @kit/* package APIs (authActionClient, enhanceRouteHandler, createAccountsApi, getSupabaseServerClient, getSupabaseServerAdminClient, useSupabase, useAction), 'use client' placement, RLS policies, account_id-based tenancy, Supabase realtime, or any code generation in a Makerkit-style monorepo. Trigger even when the user does not explicitly mention "patterns" or "best practices" — this skill applies to all coding tasks in this stack.
---

# Makerkit Next.js 16 + Supabase SaaS Best Practices

Implementation-pattern reference for Next.js 16 + Supabase SaaS codebases that follow the Makerkit Turbo architecture. Contains **49 rules across 8 categories**, prioritised by lifecycle-cascade impact — authorization and tenant modeling first, then request boundary, server fetching, mutations, client boundaries, architecture, and UI conventions.

Each rule is a focused, actionable check with an **Incorrect → Correct** code example drawn from the canonical kit patterns. Rules name the exact `@kit/*` package APIs (`authActionClient`, `getSupabaseServerClient`, `enhanceRouteHandler`, etc.) so guidance maps directly to imports in the codebase.

## When to Apply

Reach for these rules when:

- **Writing new code** — pages, layouts, server actions, route handlers, feature packages, client components, hooks, Supabase clients, SQL migrations, forms.
- **Reviewing a PR** in this codebase — authorization slips (admin client without guard, missing `'server-only'`), waterfalls (sequential awaits, client-fetching server data), drift (hand-edited types, hardcoded paths, hardcoded i18n strings).
- **Refactoring** — moving code between `apps/web` and `packages/*`, splitting actions and services, lifting `'use client'` boundaries, replacing raw queries with feature APIs.
- **Designing a new feature** — choosing the right Supabase client variant, deciding action vs route handler, picking a tenant scoping strategy, planning the form/server-action contract.
- **Onboarding** — understanding *why* the codebase looks the way it does, with concrete pointers to the canonical exemplar files.

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Authorization & RLS | **CRITICAL** | `auth-` |
| 2 | Multi-Tenant Data Modeling | **CRITICAL** | `tenant-` |
| 3 | Request Boundary (Proxy & Middleware) | **HIGH** | `proxy-` |
| 4 | Server-Side Data Loading | **HIGH** | `server-` |
| 5 | Mutations: Actions & Route Handlers | **HIGH** | `mutate-` |
| 6 | Client/Server Boundaries | **MEDIUM-HIGH** | `client-` |
| 7 | Architecture & Services | **MEDIUM** | `arch-` |
| 8 | Forms & UI Conventions | **MEDIUM** | `ui-` |

## Quick Reference

### 1. Authorization & RLS (CRITICAL)

- [`auth-use-standard-server-client`](references/auth-use-standard-server-client.md) — Use the standard server client for RLS-enforced reads.
- [`auth-gate-admin-client`](references/auth-gate-admin-client.md) — Gate the admin client behind an explicit authorization check.
- [`auth-use-sql-policy-helpers`](references/auth-use-sql-policy-helpers.md) — Use SQL helper functions in RLS policies.
- [`auth-server-only-imports`](references/auth-server-only-imports.md) — Mark server-only modules with `import 'server-only'`.
- [`auth-use-require-user`](references/auth-use-require-user.md) — Use `requireUser()` instead of raw `client.auth.getClaims()`.
- [`auth-trust-rls-no-duplicate-checks`](references/auth-trust-rls-no-duplicate-checks.md) — Trust RLS; do not duplicate authz checks in app code.
- [`auth-mfa-in-middleware`](references/auth-mfa-in-middleware.md) — Enforce MFA at the middleware, not per-page.

### 2. Multi-Tenant Data Modeling (CRITICAL)

- [`tenant-accounts-as-tenant-root`](references/tenant-accounts-as-tenant-root.md) — Use `accounts` as the single tenant root for personal and team workspaces.
- [`tenant-account-id-on-product-tables`](references/tenant-account-id-on-product-tables.md) — Every product table needs `account_id` + RLS + FK index.
- [`tenant-slug-in-team-urls`](references/tenant-slug-in-team-urls.md) — Use account slug in team URLs, not the account UUID.
- [`tenant-storage-paths-include-account-id`](references/tenant-storage-paths-include-account-id.md) — Embed `account_id` in Supabase Storage paths.
- [`tenant-never-edit-generated-types`](references/tenant-never-edit-generated-types.md) — Never hand-edit `database.types.ts` — regenerate it.

### 3. Request Boundary (HIGH)

- [`proxy-single-pipeline`](references/proxy-single-pipeline.md) — Compose the request pipeline in one `proxy.ts`.
- [`proxy-redirect-auth-at-boundary`](references/proxy-redirect-auth-at-boundary.md) — Perform auth redirects at the middleware, not in pages.
- [`proxy-url-pattern-matching`](references/proxy-url-pattern-matching.md) — Match middleware routes with `URLPattern`, not string comparisons.
- [`proxy-set-correlation-id`](references/proxy-set-correlation-id.md) — Set a correlation ID at the request boundary.
- [`proxy-secure-headers-flagged`](references/proxy-secure-headers-flagged.md) — Apply strict CSP headers behind an environment flag.

### 4. Server-Side Data Loading (HIGH)

- [`server-cache-workspace-loaders`](references/server-cache-workspace-loaders.md) — Wrap per-request loaders with `cache()` from React.
- [`server-promise-all-parallel-loads`](references/server-promise-all-parallel-loads.md) — Load independent data in parallel with `Promise.all`.
- [`server-use-feature-api-factories`](references/server-use-feature-api-factories.md) — Query through feature API factories, not raw `from('table')`.
- [`server-redirect-on-missing-workspace`](references/server-redirect-on-missing-workspace.md) — Redirect from the loader when workspace state is invalid.
- [`server-fetch-in-server-components`](references/server-fetch-in-server-components.md) — Fetch initial data in server components, not on the client.
- [`server-use-tables-generic-for-types`](references/server-use-tables-generic-for-types.md) — Use `Tables<'name'>` for row types, not hand-written interfaces.
- [`server-services-receive-client`](references/server-services-receive-client.md) — Services receive the Supabase client as a constructor argument.

### 5. Mutations: Actions & Route Handlers (HIGH)

- [`mutate-use-safe-action-clients`](references/mutate-use-safe-action-clients.md) — Wrap mutations with `authActionClient` / `publicActionClient` / `captchaActionClient`.
- [`mutate-zod-schema-separate-file`](references/mutate-zod-schema-separate-file.md) — Put Zod schemas in their own `*.schema.ts` file.
- [`mutate-thin-action-service-holds-logic`](references/mutate-thin-action-service-holds-logic.md) — Keep actions thin — put business logic in a service.
- [`mutate-use-getlogger-not-console`](references/mutate-use-getlogger-not-console.md) — Log with `getLogger()` from `@kit/shared/logger`, not `console.log`.
- [`mutate-revalidate-path-after-write`](references/mutate-revalidate-path-after-write.md) — Call `revalidatePath()` after successful mutations.
- [`mutate-enhance-route-handler`](references/mutate-enhance-route-handler.md) — Wrap API routes with `enhanceRouteHandler`.
- [`mutate-webhook-verify-signature`](references/mutate-webhook-verify-signature.md) — Webhook routes use `auth: false` and verify the signature.

### 6. Client/Server Boundaries (MEDIUM-HIGH)

- [`client-use-client-at-leaves`](references/client-use-client-at-leaves.md) — Mark `'use client'` at leaf components, not page roots.
- [`client-pass-server-data-as-props`](references/client-pass-server-data-as-props.md) — Pass server data to client components as props, don't refetch.
- [`client-use-supabase-with-react-query`](references/client-use-supabase-with-react-query.md) — Combine `useSupabase()` with React Query for client-side data.
- [`client-realtime-cleanup-subscription`](references/client-realtime-cleanup-subscription.md) — Clean up Supabase realtime subscriptions in the `useEffect` return.
- [`client-use-action-hook`](references/client-use-action-hook.md) — Call server actions with `useAction` from `next-safe-action/hooks`.
- [`client-stable-query-keys`](references/client-stable-query-keys.md) — Use stable, hierarchical query keys.

### 7. Architecture & Services (MEDIUM)

- [`arch-app-vs-packages-boundary`](references/arch-app-vs-packages-boundary.md) — Place reusable code in `packages/`, product-specific code in `apps/web`.
- [`arch-feature-package-layout`](references/arch-feature-package-layout.md) — Feature packages follow a `components / hooks / schema / server` layout.
- [`arch-provider-gateway-pattern`](references/arch-provider-gateway-pattern.md) — Hide vendor SDKs behind a gateway interface.
- [`arch-policy-engine-for-business-rules`](references/arch-policy-engine-for-business-rules.md) — Use `@kit/policies` for configurable business rules, not inline conditionals.
- [`arch-import-via-package-exports`](references/arch-import-via-package-exports.md) — Import via `@kit/*` package exports, never deep internal paths.
- [`arch-config-driven-navigation`](references/arch-config-driven-navigation.md) — Define routes and navigation in `config/`, not hardcoded in components.

### 8. Forms & UI Conventions (MEDIUM)

- [`ui-rhf-zod-no-generics`](references/ui-rhf-zod-no-generics.md) — Let `zodResolver` infer form types; don't add `useForm` generics.
- [`ui-form-message-per-field`](references/ui-form-message-per-field.md) — Include `FormMessage` for every field.
- [`ui-kit-ui-package-imports`](references/ui-kit-ui-package-imports.md) — Import UI components from `@kit/ui/<name>`, never internal paths.
- [`ui-semantic-tailwind-tokens`](references/ui-semantic-tailwind-tokens.md) — Use semantic Tailwind tokens, not hardcoded colors.
- [`ui-base-ui-render-not-aschild`](references/ui-base-ui-render-not-aschild.md) — Use Base UI `render` prop, not Radix `asChild`.
- [`ui-trans-for-display-text`](references/ui-trans-for-display-text.md) — Render display text through `<Trans>` or `useTranslations`.

## How to Use

Read individual reference files for detailed explanations and code examples:

- [Section definitions](references/_sections.md) — Category structure, impact levels, lifecycle rationale.
- [Rule template](assets/templates/_template.md) — Template for adding new rules.
- [AGENTS.md](AGENTS.md) — Auto-generated TOC for fast navigation.

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering by lifecycle impact |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for adding new rules |
| [metadata.json](metadata.json) | Version, organization, references |

## Related Skills

- **`base-ui-migrator`** — bulk-migrate Radix `asChild` patterns to Base UI `render` props.
- **`tailwind-refactor`** — refactor hardcoded colors to semantic tokens.
- **`react-optimise`** — performance optimisations for React components.
- **`nextjs-bundle-optimizer`** — bundle analysis and reduction for Next.js apps.
