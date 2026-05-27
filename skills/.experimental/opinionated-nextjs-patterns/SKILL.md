---
name: opinionated-nextjs-patterns
description: Use this skill when writing, reviewing, or refactoring any Next.js 16 (App Router) codebase that wants an opinionated, backend-agnostic architecture — covers authorization at the data layer, server-side loading with cache() and Promise.all, mutations through a typed next-safe-action client and typed route handlers, client/server boundaries ('use client' at leaves + TanStack Query), forms with React Hook Form + Zod, UI via shadcn/ui + Tailwind + Base UI + next-intl, request handling in proxy.ts (Next.js 16's renamed middleware), and a Turbo monorepo of @app/* packages confining the backend behind one data-access package. Examples use Supabase as the concrete backend but every rule states the transferable principle; multi-tenant SaaS modeling is an optional category. Trigger on server actions, route handlers, RSC vs 'use client' placement, TanStack Query, React Hook Form/Zod, proxy.ts, monorepo package layout, or any code generation in this stack — even when the user doesn't say "patterns" or "best practices".
metadata:
  internal: true
---
# Opinionated Next.js 16 Patterns

Implementation-pattern reference for **Next.js 16 (App Router)** codebases that want a single, opinionated architecture. Contains **50 rules across 8 categories**, prioritised by execution-lifecycle cascade impact — authorization and (optional) tenant modeling first, then the request boundary, server fetching, mutations, client boundaries, architecture, and UI conventions.

The rules are **backend-agnostic in principle but use Supabase as the concrete example**. Each rule teaches the transferable idea (e.g. "authorize at the data layer", "read through a typed repository"); where the backend genuinely matters, a `*Transferable:*` note explains the pattern for other stores (Drizzle, Prisma). The structure is a **Turbo monorepo** with `@app/*` packages you own — built on canonical libraries (`next-safe-action`, `@supabase/ssr`, `@tanstack/react-query`, `react-hook-form` + `zod`, `shadcn/ui`, `next-intl`, `pino`), not a vendored starter kit.

## When to Apply

Reach for these rules when:

- **Writing new code** — pages, layouts, server actions, route handlers, `proxy.ts`, feature packages, client components, hooks, the data-access package, SQL/migrations, forms.
- **Reviewing a PR** — authorization slips (privileged client without a guard, missing `'server-only'`), waterfalls (sequential awaits, client-fetching server data), drift (hand-edited generated types, deep package imports, hardcoded i18n strings).
- **Refactoring** — moving code between `apps/web` and `packages/*`, splitting actions and services, lifting `'use client'` boundaries, replacing raw queries with a typed data-access factory, swapping a backend behind the data-access package.
- **Designing a feature** — choosing the right client (request-scoped vs privileged vs browser), deciding action vs route handler, planning the form/server-action contract, scoping a tenant (if multi-tenant).
- **Onboarding** — understanding *why* the codebase looks the way it does, with concrete, transferable examples.

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Authorization & Data-Layer Access | **CRITICAL** | `auth-` |
| 2 | Multi-Tenancy *(optional, SaaS only)* | **CRITICAL** | `tenant-` |
| 3 | Request Boundary (Proxy) | **HIGH** | `proxy-` |
| 4 | Server-Side Data Loading | **HIGH** | `server-` |
| 5 | Mutations: Actions & Route Handlers | **HIGH** | `mutate-` |
| 6 | Client/Server Boundaries | **MEDIUM-HIGH** | `client-` |
| 7 | Architecture & Services | **MEDIUM** | `arch-` |
| 8 | Forms & UI Conventions | **MEDIUM** | `ui-` |

## Quick Reference

### 1. Authorization & Data-Layer Access (CRITICAL)

- [`auth-use-standard-server-client`](references/auth-use-standard-server-client.md) — Use the request-scoped, auth-bound client; never default to the privileged one.
- [`auth-gate-admin-client`](references/auth-gate-admin-client.md) — Authorize *before* constructing the service-role client.
- [`auth-trust-rls-no-duplicate-checks`](references/auth-trust-rls-no-duplicate-checks.md) — Authorize once at the data layer; don't re-check in app code.
- [`auth-use-sql-policy-helpers`](references/auth-use-sql-policy-helpers.md) — Centralize scoping predicates in reusable SQL policy helpers.
- [`auth-use-require-user`](references/auth-use-require-user.md) — Centralize the auth gate in one `requireUser()` helper.
- [`auth-server-only-imports`](references/auth-server-only-imports.md) — Mark privileged modules with `import 'server-only'`.
- [`auth-mfa-in-middleware`](references/auth-mfa-in-middleware.md) — Enforce MFA at the `proxy.ts` boundary, not per-page.

### 2. Multi-Tenancy (CRITICAL — optional, SaaS only)

- [`tenant-accounts-as-tenant-root`](references/tenant-accounts-as-tenant-root.md) — One tenant-root table both personal and team workspaces reference.
- [`tenant-account-id-on-product-tables`](references/tenant-account-id-on-product-tables.md) — Tenant key + index + scoping policy on every product table.
- [`tenant-slug-in-team-urls`](references/tenant-slug-in-team-urls.md) — Use a human-readable slug in team URLs, not the UUID.
- [`tenant-storage-paths-include-account-id`](references/tenant-storage-paths-include-account-id.md) — Namespace object-storage paths by tenant id.
- [`tenant-never-edit-generated-types`](references/tenant-never-edit-generated-types.md) — Treat generated DB types as build output; regenerate, never hand-edit.

### 3. Request Boundary: Proxy (HIGH)

- [`proxy-single-pipeline`](references/proxy-single-pipeline.md) — Compose the whole request pipeline in one `proxy.ts`.
- [`proxy-redirect-auth-at-boundary`](references/proxy-redirect-auth-at-boundary.md) — Perform auth redirects at the proxy, not in pages.
- [`proxy-url-pattern-matching`](references/proxy-url-pattern-matching.md) — Match proxy routes with `URLPattern`, not string comparisons.
- [`proxy-set-correlation-id`](references/proxy-set-correlation-id.md) — Set a correlation ID at the request boundary.
- [`proxy-secure-headers-flagged`](references/proxy-secure-headers-flagged.md) — Apply strict CSP headers behind an environment flag.

### 4. Server-Side Data Loading (HIGH)

- [`server-cache-workspace-loaders`](references/server-cache-workspace-loaders.md) — Wrap per-request loaders with `cache()` from React.
- [`server-promise-all-parallel-loads`](references/server-promise-all-parallel-loads.md) — Load independent data in parallel with `Promise.all`.
- [`server-use-feature-api-factories`](references/server-use-feature-api-factories.md) — Read through a typed data-access factory, not raw `from('table')`.
- [`server-redirect-on-missing-workspace`](references/server-redirect-on-missing-workspace.md) — Redirect from the loader when workspace state is invalid.
- [`server-fetch-in-server-components`](references/server-fetch-in-server-components.md) — Fetch initial data in server components, not on the client.
- [`server-use-tables-generic-for-types`](references/server-use-tables-generic-for-types.md) — Use generated row types, not hand-written interfaces.
- [`server-services-receive-client`](references/server-services-receive-client.md) — Services receive the data client as a constructor argument.

### 5. Mutations: Actions & Route Handlers (HIGH)

- [`mutate-use-safe-action-clients`](references/mutate-use-safe-action-clients.md) — Route mutations through a typed action client you build on next-safe-action.
- [`mutate-zod-schema-separate-file`](references/mutate-zod-schema-separate-file.md) — Put Zod schemas in their own `*.schema.ts` shared by client and server.
- [`mutate-thin-action-service-holds-logic`](references/mutate-thin-action-service-holds-logic.md) — Keep the action thin; put business logic in a service.
- [`mutate-use-getlogger-not-console`](references/mutate-use-getlogger-not-console.md) — Log through a structured logger you own, not `console.log`.
- [`mutate-revalidate-path-after-write`](references/mutate-revalidate-path-after-write.md) — Call `revalidatePath()` after a successful write.
- [`mutate-enhance-route-handler`](references/mutate-enhance-route-handler.md) — Wrap route handlers in a typed handler that owns auth and validation.
- [`mutate-webhook-verify-signature`](references/mutate-webhook-verify-signature.md) — Webhook routes skip user-auth and verify the provider signature.

### 6. Client/Server Boundaries (MEDIUM-HIGH)

- [`client-use-client-at-leaves`](references/client-use-client-at-leaves.md) — Mark `'use client'` at leaf components, not page roots.
- [`client-pass-server-data-as-props`](references/client-pass-server-data-as-props.md) — Pass server data to client components as props, don't refetch.
- [`client-use-supabase-with-react-query`](references/client-use-supabase-with-react-query.md) — Pair a memoized browser client with TanStack Query for client reads.
- [`client-realtime-cleanup-subscription`](references/client-realtime-cleanup-subscription.md) — Tear down any subscription or event source in the `useEffect` return.
- [`client-use-action-hook`](references/client-use-action-hook.md) — Call server actions with `useAction` from `next-safe-action/hooks`.
- [`client-stable-query-keys`](references/client-stable-query-keys.md) — Use stable, hierarchical query keys.

### 7. Architecture & Services (MEDIUM)

- [`arch-app-vs-packages-boundary`](references/arch-app-vs-packages-boundary.md) — Reusable capabilities in `packages/`, product-specific code in `apps/web`.
- [`arch-data-access-adapter`](references/arch-data-access-adapter.md) — Confine the backend to one data-access package with a stable surface.
- [`arch-feature-package-layout`](references/arch-feature-package-layout.md) — Feature packages follow a `components / hooks / schema / server` layout.
- [`arch-import-via-package-exports`](references/arch-import-via-package-exports.md) — Import via the package `exports` map, never deep internal paths.
- [`arch-provider-gateway-pattern`](references/arch-provider-gateway-pattern.md) — Hide vendor SDKs behind a gateway interface.
- [`arch-policy-engine-for-business-rules`](references/arch-policy-engine-for-business-rules.md) — Model business rules in a policy layer you own, not inline conditionals.
- [`arch-config-driven-navigation`](references/arch-config-driven-navigation.md) — Define routes and navigation in `config/`, not hardcoded in components.

### 8. Forms & UI Conventions (MEDIUM)

- [`ui-rhf-zod-no-generics`](references/ui-rhf-zod-no-generics.md) — Let `zodResolver` infer form types; don't add `useForm` generics.
- [`ui-form-message-per-field`](references/ui-form-message-per-field.md) — Include `FormMessage` for every field.
- [`ui-kit-ui-package-imports`](references/ui-kit-ui-package-imports.md) — Import UI from your `@app/ui` design-system surface, never internal paths.
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
