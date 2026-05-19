# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

Categories are ordered by execution-lifecycle cascade: mistakes earlier in the
request flow (authorization, tenant modeling, middleware, server loads, mutations)
block or corrupt every downstream stage; mistakes in client and presentation layers
only affect that subtree.

---

## 1. Authorization & RLS (auth)

**Impact:** CRITICAL  
**Description:** Picking the wrong Supabase client variant or skipping the explicit super-admin guard punches a hole through tenant isolation for every read and write that follows.

## 2. Multi-Tenant Data Modeling (tenant)

**Impact:** CRITICAL  
**Description:** The `accounts` tenant root, the `account_id` foreign key on product tables, and slug-based URLs are the shape every RLS policy and storage path depends on — getting it wrong is unfixable later without a backfill migration.

## 3. Request Boundary: Proxy & Middleware (proxy)

**Impact:** HIGH  
**Description:** `proxy.ts` is the single entry point for every request — handling i18n routing, auth redirects, MFA enforcement, admin gating, secure headers, and request IDs in one pipeline so pages never repeat these checks.

## 4. Server-Side Data Loading (server)

**Impact:** HIGH  
**Description:** Cached workspace loaders, `Promise.all` parallel reads, and feature API factories keep server components fast and consistent — fetching on the client instead, or skipping `cache()`, creates waterfalls and duplicate queries on every layout render.

## 5. Mutations: Server Actions & Route Handlers (mutate)

**Impact:** HIGH  
**Description:** `authActionClient` and `enhanceRouteHandler` are the only two sanctioned write paths — they enforce Zod validation, authentication, CAPTCHA, structured logging, and `revalidatePath` so every mutation is safe, typed, and refreshes the right UI.

## 6. Client/Server Boundaries (client)

**Impact:** MEDIUM-HIGH  
**Description:** `'use client'` belongs at leaf components, server data flows down as props, and client data uses `useSupabase()` + React Query with stable keys — moving the boundary up the tree balloons the bundle, and refetching server-loaded data on the client wastes a render cycle.

## 7. Architecture & Services (arch)

**Impact:** MEDIUM  
**Description:** Product composition lives in `apps/web`, reusable capabilities live in `packages/*`, business logic lives in services (not actions), and providers (billing/mail/CMS) hide behind gateway interfaces — collapsing these boundaries makes the codebase resistant to future changes.

## 8. Forms & UI Conventions (ui)

**Impact:** MEDIUM  
**Description:** React Hook Form + Zod with a separate schema file, `@kit/ui/*` imports, semantic Tailwind tokens, Base UI `render` (not Radix `asChild`), `Trans` for display text, and `data-test` on interactive elements keep the UI consistent, translatable, and testable.
