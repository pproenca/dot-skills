# Conventions

The four files this skill generates aren't arbitrary — every choice exists to prevent a specific class of bug we've seen in production nuqs codebases. If you fork a template, read this doc first so you know what protections you're giving up.

## 1. The shared client-safe parser map lives at `lib/{module}-search-params.ts`

**Why:** Both `useQueryStates` (client) and `createSearchParamsCache` (server) must reference the **same parser objects**, not just the same shape. If a client component imports `parseAsInteger.withDefault(1)` and the server file separately defines `parseAsInteger.withDefault(0)`, the hydration check passes (both are numbers) but the rendered output disagrees by one. The fix is structural: one file, two consumers.

**Why this file uses `nuqs` and not `nuqs/server`:** The parser builders (`parseAsX`) are pure values exported from `'nuqs'`. The `'use client'` marker on `'nuqs'` is a *runtime* marker (it taints components, not constants); pulling parser builders out of `'nuqs'` does not turn the file into a Client Component. The corollary: do not put hooks, side effects, or React in this file.

## 2. The server file is a sibling, not under `app/`

**Why:** Files under `app/` are router-aware in Next.js. A `searchParams.server.ts` placed in `app/search/` would be picked up as part of the route tree if the framework ever decides a `.server.ts` segment means something. Keeping it in `lib/` future-proofs against that, and matches Next.js's documented "shared utilities live in `lib/`" pattern.

**Why two files instead of one with conditional exports:** Next.js doesn't reliably tree-shake `'use client'`-marked modules out of Server Component bundles. Splitting the file makes the boundary explicit and the import-time cost zero on the server.

## 3. File naming is kebab-case

**Why:** macOS is case-insensitive by default; Linux is case-sensitive. `SearchFilters.tsx` and `searchFilters.tsx` resolving to the same file on a developer's Mac but two different files in CI is a class of bug that costs hours to debug. Kebab-case removes the failure mode entirely. The compromise is that the file `search-filters.tsx` exports `<SearchFilters />` — slight redundancy, but the export name follows React conventions.

If your project insists on PascalCase filenames, set `config.file_case: "pascal"`.

## 4. Imports are grouped: external → nuqs → internal → relative

```ts
// 1. External (React, etc.)
import { useState } from 'react';

// 2. nuqs (always its own group — makes drift between client/server bindings visible at review time)
import { useQueryStates } from 'nuqs';

// 3. Internal absolute (anything from `@/...`)
import { searchParams } from '@/lib/search-search-params';

// 4. Relative
import { Pagination } from './pagination';
```

**Why nuqs gets its own group:** During code review, the line you most want to spot is "is this file importing from `nuqs` or `nuqs/server`?" Putting nuqs alone in group 2 makes that single line easy to find. Auto-formatters (Prettier with `import-sort`) will preserve this grouping if you add a blank line between groups.

## 5. The component always uses `useQueryStates`, not individual `useQueryState` calls

**Why:** Atomic updates. When a user clicks "Reset", `setFilters(null)` clears every key in one URL flush. With individual hooks, you'd need to call each setter in sequence — nuqs batches them, but the type-safety win is gone, and a future refactor that introduces a conditional setter will silently break atomicity.

**Trade-off:** `useQueryStates` re-renders whenever ANY key changes, even on non-Next.js adapters with key isolation. For a filters panel that's fine — every input lives in this one component. If you later split the panel across multiple components and only care about specific keys, switch those leaf components to individual `useQueryState` calls (see the `perf-key-isolation` rule in the companion `nuqs` skill).

## 6. The `Reset` button calls `setFilters(null)`

**Why:** Passing `null` to `useQueryStates` is the documented way to clear every key back to its parser default. Passing `{ q: null, page: null, ... }` works but adds maintenance burden — every new param requires updating the reset call.

## 7. The server file always emits all four exports (`loadSearchParams`, `Cache`, `serialize`, `Schema`)

**Why:** They're cheap (tree-shakeable pure functions) and removing one is harder than keeping it. Most pages only end up using `loadSearchParams` and `serialize`, but having `Cache` and `Schema` available for free pays off the first time someone adds a nested Server Component or wires up tRPC.

## 8. `serialize` uses `processUrlSearchParams: params.sort()`

**Why:** Stable URL key ordering. `/search?b=2&a=1` and `/search?a=1&b=2` are different cache keys to Google, browsers, and CDNs even though they render identically. Sorting keys before serialisation eliminates that source of duplicate URLs. The cost is purely cosmetic (the URL looks less "natural" to humans) — worth it.

**Counter-case:** If your URLs are user-facing and you care about typing order (e.g., a builder UI where the URL "remembers" the order the user added filters), set `processUrlSearchParams: (p) => p` to disable sorting.

## 9. Tests use `NuqsTestingAdapter`, not the real Next.js adapter

**Why:** `NuqsTestingAdapter` takes `searchParams` as a prop, so each test starts from a known URL state. The real `nuqs/adapters/next/app` relies on the Next.js router context — testing against it requires either Playwright or a Next.js-aware mock, both heavier than necessary for unit tests of filter logic.

The trade-off: tests pass `searchParams` as a `Record<string, string>` or query string, so multi-value keys (`array-of-string-native`) need the query-string form: `?tag=a&tag=b`.

## When to fork the templates

Almost never. The conventions above each protect against a specific bug class; removing one usually re-opens that bug class. Reasonable forks:

- **Different test runner** — set `config.test_runner: "jest"` and adjust the test template's imports.
- **`generateMetadata` already lives elsewhere** — drop `serialize__NAME__` from the server file.
- **Project uses module-scoped CSS or Tailwind classes** — extend the component template's JSX; the form-structure choices above still apply.

Don't fork to:
- Move parser definitions into the component file (defeats client/server sharing).
- Use individual `useQueryState` calls for "performance" (filters panels don't need it).
- Drop `processUrlSearchParams: params.sort()` "for now" (SEO bills come due).
