/**
 * Standardized query hook template.
 *
 * Embeds the patterns this skill teaches:
 *   - Key factory ([[cache-shared-key-factory]])
 *   - Deterministic key serialization ([[cache-deterministic-keys]])
 *   - AbortSignal forwarding ([[resilience-abort-on-unmount]])
 *   - Per-endpoint timeout ([[resilience-bounded-timeouts]])
 *   - Jittered retry ([[protect-jittered-retry-backoff]])
 *   - Tiered staleTime ([[cache-tiered-stale-fresh]])
 *   - Optional Suspense via useSuspenseQuery ([[render-suspense-per-section]])
 *
 * Parameters to fill in:
 *   - RESOURCE_NAME: singular kebab-case name (e.g. "product", "user", "comment")
 *   - Resource:      TypeScript type for the resource
 *   - GetParams:     parameters for fetching a single resource
 *   - ListParams:    parameters for fetching a list (filters, sort, etc.)
 *   - apiBase:       the endpoint path (e.g. "/api/products")
 *   - staleTier:     one of STALE.realtime / fresh / warm / cold / static
 */

import {
  useQuery,
  useSuspenseQuery,
  useInfiniteQuery,
  type QueryClient,
  type UseQueryOptions,
} from '@tanstack/react-query';

// ─────────────────────────────────────────────────────────────────────────────
// Configuration tiers
// ─────────────────────────────────────────────────────────────────────────────

export const STALE = {
  realtime: 5_000,
  fresh:    30_000,
  warm:     5 * 60_000,
  cold:     60 * 60_000,
  static:   24 * 60 * 60_000,
} as const;

const TIMEOUT_MS = 8000;

// ─────────────────────────────────────────────────────────────────────────────
// Resource definition — duplicate this section per resource and rename
// ─────────────────────────────────────────────────────────────────────────────

const RESOURCE_NAME = 'RESOURCE_NAME'; // e.g. 'product'

type Resource = {
  id: string;
  // ... add fields
};

type GetParams = { id: string };
type ListParams = { /* filters */ };

const apiBase = '/api/RESOURCE_NAME';

// ─────────────────────────────────────────────────────────────────────────────
// Key factory — single source of truth for cache keys
// See [[cache-shared-key-factory]]
// ─────────────────────────────────────────────────────────────────────────────

export const resourceKeys = {
  all:     [RESOURCE_NAME] as const,
  lists:   () => [...resourceKeys.all, 'list'] as const,
  list:    (params: ListParams) => [...resourceKeys.lists(), canonical(params)] as const,
  details: () => [...resourceKeys.all, 'detail'] as const,
  detail:  (id: string) => [...resourceKeys.details(), id] as const,
};

// Canonicalize filter objects so equal-by-value produces equal-by-key
// See [[cache-deterministic-keys]]
function canonical<T extends Record<string, unknown>>(obj: T): T {
  return Object.fromEntries(
    Object.entries(obj)
      .filter(([, v]) => v !== undefined)
      .sort(([a], [b]) => a.localeCompare(b))
      .map(([k, v]) => [k, Array.isArray(v) ? [...v].sort() : v])
  ) as T;
}

// ─────────────────────────────────────────────────────────────────────────────
// Fetch functions — forward AbortSignal, bound timeout, throw on non-2xx
// See [[resilience-abort-on-unmount]] + [[resilience-bounded-timeouts]]
// ─────────────────────────────────────────────────────────────────────────────

async function fetchResource(
  { id }: GetParams,
  { signal }: { signal?: AbortSignal } = {}
): Promise<Resource> {
  const merged = signal
    ? AbortSignal.any([signal, AbortSignal.timeout(TIMEOUT_MS)])
    : AbortSignal.timeout(TIMEOUT_MS);

  const res = await fetch(`${apiBase}/${encodeURIComponent(id)}`, { signal: merged });
  if (!res.ok) throw new HttpError(res.status, await res.text());
  return res.json();
}

async function fetchResourceList(
  params: ListParams,
  { signal }: { signal?: AbortSignal } = {}
): Promise<{ items: Resource[]; nextCursor: string | null }> {
  const merged = signal
    ? AbortSignal.any([signal, AbortSignal.timeout(TIMEOUT_MS)])
    : AbortSignal.timeout(TIMEOUT_MS);
  const search = new URLSearchParams(params as Record<string, string>).toString();
  const res = await fetch(`${apiBase}?${search}`, { signal: merged });
  if (!res.ok) throw new HttpError(res.status, await res.text());
  return res.json();
}

export class HttpError extends Error {
  constructor(public status: number, public body: string) {
    super(`HTTP ${status}: ${body.slice(0, 200)}`);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hooks
// ─────────────────────────────────────────────────────────────────────────────

export function useResource(
  params: GetParams,
  options?: Omit<UseQueryOptions<Resource>, 'queryKey' | 'queryFn'>
) {
  return useQuery({
    queryKey: resourceKeys.detail(params.id),
    queryFn: ({ signal }) => fetchResource(params, { signal }),
    staleTime: STALE.warm,
    retry: (attempt, err) => attempt < 2 && err instanceof HttpError && err.status >= 500,
    retryDelay: attempt => Math.random() * Math.min(30_000, 1000 * 2 ** attempt),
    ...options,
  });
}

/** Same hook but suspends — use inside <Suspense> + <ErrorBoundary>. */
export function useResourceSuspense(params: GetParams) {
  return useSuspenseQuery({
    queryKey: resourceKeys.detail(params.id),
    queryFn: ({ signal }) => fetchResource(params, { signal }),
    staleTime: STALE.warm,
  });
}

export function useResourceList(params: ListParams) {
  return useQuery({
    queryKey: resourceKeys.list(params),
    queryFn: ({ signal }) => fetchResourceList(params, { signal }),
    staleTime: STALE.fresh,
    placeholderData: (prev) => prev,
  });
}

/** Infinite/cursor-paginated list. See [[feed-cursor-pagination]]. */
export function useResourceInfinite(params: ListParams) {
  return useInfiniteQuery({
    queryKey: [...resourceKeys.lists(), 'infinite', canonical(params)] as const,
    queryFn: ({ pageParam, signal }) =>
      fetchResourceList({ ...params, cursor: pageParam } as ListParams, { signal }),
    initialPageParam: null as string | null,
    getNextPageParam: (last: { nextCursor: string | null }) => last.nextCursor,
    maxPages: 10, // bounded working set — see [[feed-bounded-working-set]]
    staleTime: STALE.fresh,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Prefetch helpers (for route loaders + intent prefetching)
// ─────────────────────────────────────────────────────────────────────────────

export function prefetchResource(qc: QueryClient, id: string) {
  return qc.prefetchQuery({
    queryKey: resourceKeys.detail(id),
    queryFn: ({ signal }) => fetchResource({ id }, { signal }),
    staleTime: STALE.warm,
  });
}

export function ensureResource(qc: QueryClient, id: string) {
  return qc.ensureQueryData({
    queryKey: resourceKeys.detail(id),
    queryFn: ({ signal }) => fetchResource({ id }, { signal }),
    staleTime: STALE.warm,
  });
}
