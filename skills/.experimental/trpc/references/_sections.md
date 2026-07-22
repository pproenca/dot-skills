# Sections

This file defines the categories and their order. The prefix in parentheses is
the filename prefix that groups rules. Categories are ordered by **importance ×
frequency** — the decisions that come up in every tRPC codebase, and cost most
when wrong, go first.

Every rule is pinned to **tRPC v11**, verified against `11.18.0` (2026-06-17).
There is no v12; APIs marked "will be removed in v12" still ship today.

---

## 1. React Client Surface (client)

**Description:** Which React integration a codebase is built on, and the four
things that change with it — how you read data, how you invalidate, how you
build query keys, how you subscribe. The costliest category because the
recommended integration
*flipped* in v11: `@trpc/tanstack-react-query` replaced `createTRPCReact`, and
a model reproducing v10-era React code lands on APIs that either no longer
exist on the new proxy or quietly opt the project out of future development.
Every downstream instruction in a codebase inherits this choice.

## 2. v10 → v11 Drift (mig)

**Description:** APIs that were renamed, removed, or made lazy between v10 and
v11, plus the peer-version floors that changed underneath them. Highest
frequency of *compile* breaks, and the source of the single most-reported tRPC
symptom — inference collapsing to `any` with no error anywhere. Distinct from
the other categories because the fix is mechanical once you know the new name;
the cost is entirely in not knowing.

## 3. Router & Procedure Construction (proc)

**Description:** How the router is initialized and how procedures are built up.
Two failure shapes live here: type holes, where a guard runs but the types
never narrow so the guarantee gets cast away downstream; and ordering bugs,
where the builder chain runs middleware against input that has not been
validated yet. Both survive review because the code reads correctly — the
defect is in what the chain *order* means, not in what any line says.

## 4. Error & Validation Semantics (err)

**Description:** What tRPC does when validation fails, and what reaches the
client when it does. Covers the validator-agnostic error shape (Standard
Schema, not just Zod), why output failures are server faults rather than client
errors, and the runtime condition under which stack traces ship to end users.
Errors are user-facing and security-adjacent, so a stale default here is
visible or dangerous rather than merely untidy.

## 5. Links, Transport & Serialization (link)

**Description:** The wire between client and server — link composition,
batching limits, transformer placement, HTTP adapters, and response caching.
The largest category because tRPC pushes an unusual amount of behavior into the
link chain, and because its defaults are tuned for getting started rather than
for production: batching is on with no size cap, and caching interacts with it
in a way that can serve one user's data to another.

## 6. SSR, RSC & Server-Side Calls (rsc)

**Description:** Rendering tRPC data on the server — prefetch and hydration
across the RSC boundary, how long a `QueryClient` may live, and when a
server-side caller is the wrong tool. Narrower in reach than the categories
above (it applies only to Next.js App Router and SSR setups) but dense in
consequence: the default lifetimes leak cache across requests, and the default
prefetch shape silently does no work.

## 7. Subscriptions & Streaming (sub)

**Description:** Realtime procedures, which v11 rebuilt around async generators
delivered over SSE rather than observables over WebSocket. The narrowest
surface, kept whole because its failures are the hardest to catch locally:
credentials serialized into URLs, keepalive that is off by default so idle
streams get reaped by intermediaries, and a listener-attachment race that drops
events only under load.
