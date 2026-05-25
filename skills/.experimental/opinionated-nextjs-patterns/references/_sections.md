# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

Categories are ordered by execution-lifecycle cascade: mistakes earlier in the
request flow (authorization, tenant modeling, request boundary, server loads,
mutations) block or corrupt every downstream stage; mistakes in client and
presentation layers only affect that subtree.

The rules are backend-agnostic in principle but use Supabase as the concrete
example backend. Where the backend genuinely matters, a rule carries a
*Transferable:* note explaining the pattern for other stores (Drizzle, Prisma).

---

## 1. Authorization & Data-Layer Access (auth)

**Impact:** CRITICAL
**Description:** Reaching for the privileged/service client by default, or re-deriving authorization in TypeScript instead of enforcing it once at the data layer, punches a hole through access control for every read and write that follows. Push authorization into the data layer (Postgres RLS here) and trust it.

## 2. Multi-Tenancy (tenant) — *optional, SaaS only*

**Impact:** CRITICAL
**Description:** *Optional — applies only when building multi-tenant SaaS; skip this category entirely for single-tenant apps.* For multi-tenant apps: a single tenant-root table, the tenant key + index + scoping policy on every product table, slug-based URLs, and tenant-namespaced storage paths are the shape every access rule depends on — getting it wrong is unfixable later without a backfill migration. A marketing site, blog, or internal tool can ignore this whole category.

## 3. Request Boundary: Proxy (proxy)

**Impact:** HIGH
**Description:** `proxy.ts` (Next.js 16's renamed middleware — exported `proxy`, Node.js runtime) is the single entry point for every request — handling i18n routing, auth redirects, MFA enforcement, secure headers, and request IDs in one pipeline so pages never repeat these checks.

## 4. Server-Side Data Loading (server)

**Impact:** HIGH
**Description:** `cache()`-wrapped loaders, `Promise.all` parallel reads, typed data-access factories, and generated row types keep server components fast and consistent — fetching on the client instead, or skipping `cache()`, creates waterfalls and duplicate queries on every layout render.

## 5. Mutations: Server Actions & Route Handlers (mutate)

**Impact:** HIGH
**Description:** A typed action client (built on next-safe-action) and a typed route-handler wrapper are the only two sanctioned write paths — they enforce Zod validation, authentication, structured logging, and `revalidatePath` so every mutation is safe, typed, and refreshes the right UI. Business logic lives in a service the action stays thin around.

## 6. Client/Server Boundaries (client)

**Impact:** MEDIUM-HIGH
**Description:** `'use client'` belongs at leaf components, server data flows down as props, and client data uses a memoized browser client + TanStack Query with stable keys — moving the boundary up the tree balloons the bundle, and refetching server-loaded data on the client wastes a render cycle.

## 7. Architecture & Services (arch)

**Impact:** MEDIUM
**Description:** Product composition lives in `apps/web`, reusable capabilities live in `packages/*` (`@app/*`), the backend is confined to one data-access package, business logic lives in services (not actions), authorization rules live in a policy layer, and providers (billing/mail/CMS) hide behind gateway interfaces — collapsing these boundaries makes the codebase resistant to future change and locks in the vendor.

## 8. Forms & UI Conventions (ui)

**Impact:** MEDIUM
**Description:** React Hook Form + Zod with a separate schema file, imports through your `@app/ui` design-system surface (shadcn/ui wrappers), semantic Tailwind tokens, Base UI `render` (not Radix `asChild`), `Trans`/`useTranslations` for display text, and `data-test` on interactive elements keep the UI consistent, translatable, and testable.
