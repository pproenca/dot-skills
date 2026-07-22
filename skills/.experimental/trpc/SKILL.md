---
name: trpc
description: Corrects the wrong defaults a model has for tRPC v11 (verified against 11.18.0). Use when code imports initTRPC, createTRPCContext, createTRPCOptionsProxy, createTRPCReact, httpBatchLink, httpSubscriptionLink, fetchRequestHandler, or TRPCError, or when building routers, procedures, middleware, links, or RSC prefetching. Covers the v10 to v11 drift that makes stale code fail — the React client that flipped to @trpc/tanstack-react-query, transformers moving into links, renamed type exports, observable subscriptions replaced by async generators over SSE — plus the defaults that are unsafe rather than merely stale — uncapped batching, CDN cache headers that serve one user's data to another, stack traces shipped from edge runtimes, and middleware that runs before input validation. NOT for TanStack Query semantics generally (use tanstack-query), Zod schema authoring (use zod), or Next.js App Router routing (use nextjs).
---

# tRPC v11

The decisions tRPC forces and how to settle them, written so an agent applies them while writing or reviewing code. Every rule names the wrong default it corrects; there is no rule for what the model already gets right.

**Pinned to tRPC v11, verified against `11.18.0` (2026-06-17).** There is no v12 — but several APIs here carry `@deprecated … will be removed in v12` and still ship today. Peers: `typescript >=5.7.2`, `@tanstack/react-query ^5.80.3`, `react >=18.2.0`.

## When to Apply

Use this skill when:

- Code imports `initTRPC`, `createTRPCContext`, `createTRPCOptionsProxy`, `createTRPCReact`, `createTRPCClient`, `httpBatchLink`, `httpSubscriptionLink`, `splitLink`, `fetchRequestHandler`, `createCallerFactory`, or `TRPCError` — or defines procedures with `.input()` / `.output()` / `.use()` / `.query()` / `.mutation()` / `.subscription()`
- The user says "everything types as `any`", "invalidation isn't working", "`contextMap[utilName] is not a function`", "the transformer property moved", "414 / 413 on the dashboard", "subscriptions won't connect", "the prefetch isn't hydrating", or "it 404s every procedure"
- Migrating a codebase from tRPC v10, or reviewing tRPC code written against v10-era examples — the highest-yield moment, because the recommended React client changed and stale code often still compiles
- Adding the first subscription, the first file upload, or the first RSC prefetch to an existing router — each crosses into a surface where v11 replaced the v10 approach outright
- Reviewing a batched client as the app grows, where the uncapped defaults turn into intermittent production failures

This skill is NOT for:

- General TanStack Query semantics — cache lifetimes, retry, `useMutation` ergonomics (→ `tanstack-query`)
- Authoring or migrating the Zod schemas used as validators (→ `zod`)
- Next.js App Router routing, streaming, or caching beyond the tRPC handler (→ `nextjs`)
- General TypeScript narrowing and generics (→ `typescript`)

## Rule Categories

| # | Category | Prefix | Covers |
|---|----------|--------|--------|
| 1 | React Client Surface | `client-` | Which integration, options factories, query keys, invalidation, subscribing |
| 2 | v10 → v11 Drift | `mig-` | Renamed, removed, and lazily-materialized APIs; peer-version floors |
| 3 | Router & Procedure Construction | `proc-` | Instance identity, builder order, context narrowing, input merging |
| 4 | Error & Validation Semantics | `err-` | What surfaces, what leaks, which error class |
| 5 | Links, Transport & Serialization | `link-` | Link chain, batching limits, transformers, adapters, caching |
| 6 | SSR, RSC & Server-Side Calls | `rsc-` | Prefetch and hydration, QueryClient lifetime, caller misuse |
| 7 | Subscriptions & Streaming | `sub-` | Async generators over SSE, auth, keepalive, backlog races |

## Quick Reference

### 1. React Client Surface

- [`client-tanstack-integration`](references/client-tanstack-integration.md) — Build React data fetching on `@trpc/tanstack-react-query`; `createTRPCReact` is now the classic path
- [`client-invalidate-with-query-filters`](references/client-invalidate-with-query-filters.md) — `useUtils()` does not exist on the new proxy; invalidate via `queryClient` + `pathFilter()` / `queryFilter()`
- [`client-derive-query-keys`](references/client-derive-query-keys.md) — `getQueryKey()` is not on the new proxy; keys come off it as `queryKey()` / `pathKey()` / `infiniteQueryKey()`
- [`client-subscription-options`](references/client-subscription-options.md) — `.useSubscription()` is not on the new proxy; feed `subscriptionOptions()` to `useSubscription` from `@trpc/tanstack-react-query`

### 2. v10 → v11 Drift

- [`mig-formdata-is-native`](references/mig-formdata-is-native.md) — All six `experimental_*` upload APIs were removed; FormData is a native input behind a `splitLink`
- [`mig-renamed-type-exports`](references/mig-renamed-type-exports.md) — `AnyRouter` → `AnyTRPCRouter` and friends; `inferRouterInputs`/`Outputs` did *not* change
- [`mig-await-get-raw-input`](references/mig-await-get-raw-input.md) — `rawInput` is `undefined`; inputs are lazy, so `await getRawInput()`
- [`mig-typescript-version-floor`](references/mig-typescript-version-floor.md) — TS `>=5.7.2`, and an editor on a different TS silently types everything as `any`

### 3. Router & Procedure Construction

- [`proc-narrow-ctx-in-middleware`](references/proc-narrow-ctx-in-middleware.md) — Bare `next()` leaves `ctx.user` nullable, so the guard gets cast away with `!`
- [`proc-input-before-use`](references/proc-input-before-use.md) — `.use()` before `.input()` runs middleware against unvalidated input
- [`proc-single-trpc-instance`](references/proc-single-trpc-instance.md) — One `initTRPC.create()` per app; mismatched instances make `mergeRouters` throw at runtime
- [`proc-merge-only-object-inputs`](references/proc-merge-only-object-inputs.md) — Only object schemas merge; anything else silently replaces the earlier parser
- [`proc-concat-over-standalone-middleware`](references/proc-concat-over-standalone-middleware.md) — `experimental_standaloneMiddleware` is deprecated and cannot declare `.input()`; use `.concat()`

### 4. Error & Validation Semantics

- [`err-format-standard-schema-issues`](references/err-format-standard-schema-issues.md) — Parser dispatch is ordered, so a Zod-only `errorFormatter` returns `null` for Valibot / Effect (`StandardSchemaV1Error`) and for ArkType (`ArkErrors`)
- [`err-output-strips-fields`](references/err-output-strips-fields.md) — `.output()` returns the *parsed* value, so it strips unknown keys; its failure is a 500, not a 4xx
- [`err-nullish-cursor`](references/err-nullish-cursor.md) — `.optional()` cursors 400 only *after* an invalidate; use `.nullish()`
- [`err-set-isdev-explicitly`](references/err-set-isdev-explicitly.md) — Without an explicit `isDev`, edge runtimes ship `error.data.stack` to every client

### 5. Links, Transport & Serialization

- [`link-transformer-on-terminating-links`](references/link-transformer-on-terminating-links.md) — The transformer moved into the link; deleting it to clear the branded type error breaks `Date` at runtime
- [`link-route-subscriptions-separately`](references/link-route-subscriptions-separately.md) — `httpBatchLink` rejects subscription operations outright
- [`link-cap-batch-size`](references/link-cap-batch-size.md) — `maxItems` and `maxURLLength` default to `Infinity`; pair them with the server's `maxBatchSize`
- [`link-gate-cache-headers`](references/link-gate-cache-headers.md) — Batching plus blanket `responseMeta` caching lets a CDN serve one user's data to another
- [`link-default-to-httpbatchlink`](references/link-default-to-httpbatchlink.md) — `httpBatchStreamLink` cannot set response headers once streaming; it is not the default
- [`link-read-batch-headers-from-oplist`](references/link-read-batch-headers-from-oplist.md) — Batch links pass `{ opList }`, not `{ op }`; destructuring wrong makes every request 401
- [`link-scope-body-parsers`](references/link-scope-body-parsers.md) — A global `express.json()` drains the stream before tRPC reads it
- [`link-endpoint-matches-mount-path`](references/link-endpoint-matches-mount-path.md) — `endpoint` is the prefix tRPC strips; a mismatch 404s every procedure

### 6. SSR, RSC & Server-Side Calls

- [`rsc-query-client-per-request`](references/rsc-query-client-per-request.md) — A module-scope `QueryClient` serves one user's cache to the next request
- [`rsc-dehydrate-pending-queries`](references/rsc-dehydrate-pending-queries.md) — Without the pending override, `void prefetchQuery` never reaches the client
- [`rsc-prefetch-through-options-proxy`](references/rsc-prefetch-through-options-proxy.md) — Caller results never enter the cache, so the client fetches it all again
- [`rsc-share-logic-not-callers`](references/rsc-share-logic-not-callers.md) — A nested caller re-creates context and re-runs the whole middleware chain

### 7. Subscriptions & Streaming

- [`sub-write-async-generators`](references/sub-write-async-generators.md) — `observable()` is deprecated for removal, and only generators get `tracked()` reconnect-and-resume
- [`sub-keep-credentials-out-of-urls`](references/sub-keep-credentials-out-of-urls.md) — `connectionParams` serializes tokens into the query string, and into every log that sees it
- [`sub-enable-sse-keepalive`](references/sub-enable-sse-keepalive.md) — `ping.enabled` is `false` by default, so idle SSE streams get reaped by proxies and read as a flaky network
- [`sub-attach-listener-before-backlog`](references/sub-attach-listener-before-backlog.md) — Fetching history before attaching the listener drops events only under production load

## How to Use

Read a reference file when its decision comes up. Each rule names the wrong default it corrects, then shows the canonical way — with an incorrect/correct contrast only where the wrong way is a real trap.

Two shortcuts worth taking first:

- **Reviewing or migrating existing tRPC code?** Start with `client-` and `mig-`. Stale code frequently still compiles, so nothing points you at these; they are what everything else inherits.
- **Hardening something already working?** The security-shaped rules are `link-gate-cache-headers`, `rsc-query-client-per-request`, `err-set-isdev-explicitly`, `proc-input-before-use`, and `sub-keep-credentials-out-of-urls`.

- [Section definitions](references/_sections.md) — category structure and ordering rationale
- [Rule template](assets/templates/_template.md) — for adding new rules
- [AGENTS.md](AGENTS.md) — auto-built table of contents across all rules

## Related Skills

- [`tanstack-query`](../../.curated/tanstack-query/SKILL.md) — The query layer tRPC's React client now delegates to; owns cache semantics this skill assumes
- [`zod`](../../.curated/zod/SKILL.md) — Validator authoring and Zod 4 drift, including the `.flatten()` → `z.treeifyError()` change this skill only points at
- [`typescript`](../../.curated/typescript/SKILL.md) — General type-level work beyond tRPC's inference surface
