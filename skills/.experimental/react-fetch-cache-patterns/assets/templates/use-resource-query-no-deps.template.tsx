/**
 * Library-free data-fetching template.
 *
 * Implements the same patterns as `use-resource-query.template.tsx` but with
 * ZERO library dependencies — only `react` and the standard web platform
 * (fetch, AbortController, AbortSignal). Use this when:
 *   - You're in a tightly bundle-controlled app and can't add TanStack/SWR (~12-40kb)
 *   - You're inside a third-party widget that mustn't conflict with the host's libraries
 *   - You're vendoring patterns into a codebase that has banned new dependencies
 *   - You want to understand exactly what TanStack/SWR are doing under the hood
 *
 * What's implemented (all referenced rules):
 *   - Module-level cache with subscription model      ([[cache-stale-while-revalidate]])
 *   - Deterministic JSON key canonicalization         ([[cache-deterministic-keys]])
 *   - In-flight request deduplication by key          ([[orch-dedupe-in-flight-requests]])
 *   - staleTime + gcTime semantics                    ([[cache-set-stale-time]] / [[cache-tiered-stale-fresh]])
 *   - AbortSignal forwarding + auto-cancel on unmount ([[resilience-abort-on-unmount]])
 *   - Bounded timeout per fetch                       ([[resilience-bounded-timeouts]])
 *   - Exponential backoff with full jitter on retry   ([[protect-jittered-retry-backoff]])
 *   - 4xx errors do not retry                         ([[protect-jittered-retry-backoff]])
 *   - Concurrency-limited fetch wrapper               ([[protect-concurrency-limit-fanout]])
 *
 * What's NOT implemented (out of scope for a single file):
 *   - Normalized entity store
 *   - Optimistic mutations with rollback
 *   - Persistence (localStorage hydration)
 *   - SSR/hydration boundaries
 *   - Window-focus refetching
 *   For any of these, prefer adopting TanStack Query — re-implementing them
 *   correctly is 10x the code below.
 */

import { useEffect, useReducer, useRef, useSyncExternalStore } from 'react';

// ─────────────────────────────────────────────────────────────────────────────
// 1. CACHE — module-level singleton with pub/sub
// ─────────────────────────────────────────────────────────────────────────────

type CacheEntry<T> = {
  status: 'pending' | 'success' | 'error';
  data?: T;
  error?: unknown;
  updatedAt: number;          // last successful resolve time
  subscribers: Set<() => void>;
  inflight?: Promise<T>;      // shared in-flight promise for dedup
  gcTimer?: ReturnType<typeof setTimeout>;
};

const cache = new Map<string, CacheEntry<unknown>>();

function getEntry<T>(key: string): CacheEntry<T> {
  let entry = cache.get(key) as CacheEntry<T> | undefined;
  if (!entry) {
    entry = { status: 'pending', updatedAt: 0, subscribers: new Set() };
    cache.set(key, entry as CacheEntry<unknown>);
  }
  return entry;
}

function notify(entry: CacheEntry<unknown>) {
  entry.subscribers.forEach(cb => cb());
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. KEY CANONICALIZATION — equal-by-value produces equal-by-key
// ─────────────────────────────────────────────────────────────────────────────

export function canonicalKey(parts: unknown[]): string {
  return JSON.stringify(parts, function (this: unknown, _key, value) {
    if (value === undefined) return undefined;
    if (value === null || typeof value !== 'object') return value;
    if (Array.isArray(value)) return [...value].sort();
    return Object.keys(value as Record<string, unknown>)
      .sort()
      .reduce<Record<string, unknown>>((acc, k) => {
        const v = (value as Record<string, unknown>)[k];
        if (v !== undefined) acc[k] = v;
        return acc;
      }, {});
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. CONCURRENCY LIMITER — bounds parallel fetches
// ─────────────────────────────────────────────────────────────────────────────

function createLimiter(max: number) {
  let active = 0;
  const queue: Array<() => void> = [];
  const next = () => {
    if (active >= max || queue.length === 0) return;
    active++;
    queue.shift()!();
  };
  return <T,>(fn: () => Promise<T>): Promise<T> =>
    new Promise<T>((resolve, reject) => {
      queue.push(() =>
        fn().then(resolve, reject).finally(() => { active--; next(); })
      );
      next();
    });
}
const fetchLimit = createLimiter(6);

// ─────────────────────────────────────────────────────────────────────────────
// 4. RETRY + TIMEOUT WRAPPER
// ─────────────────────────────────────────────────────────────────────────────

export class HttpError extends Error {
  constructor(public status: number, public body: string) {
    super(`HTTP ${status}`);
    this.name = 'HttpError';
  }
}

type RunOpts = {
  signal?: AbortSignal;
  timeoutMs?: number;
  maxAttempts?: number;
};

async function runWithRetry<T>(
  fn: (signal: AbortSignal) => Promise<T>,
  { signal, timeoutMs = 8000, maxAttempts = 3 }: RunOpts = {}
): Promise<T> {
  for (let attempt = 0; attempt < maxAttempts; attempt++) {
    // Merge external cancel + per-attempt timeout
    const timeoutSig = AbortSignal.timeout(timeoutMs);
    const merged = signal
      ? AbortSignal.any([signal, timeoutSig])
      : timeoutSig;

    try {
      return await fn(merged);
    } catch (err) {
      // External cancel — propagate, no retry
      if (signal?.aborted) throw err;
      // 4xx — don't retry malformed/forbidden requests
      if (err instanceof HttpError && err.status >= 400 && err.status < 500) throw err;
      // Last attempt — give up
      if (attempt === maxAttempts - 1) throw err;
      // Full-jitter exponential backoff
      const cap = Math.min(30_000, 1000 * 2 ** attempt);
      const delay = Math.random() * cap;
      await new Promise(r => setTimeout(r, delay));
    }
  }
  throw new Error('unreachable');
}

// ─────────────────────────────────────────────────────────────────────────────
// 5. CORE FETCH — wraps a fetcher with cache + dedup + retry
// ─────────────────────────────────────────────────────────────────────────────

type FetchOpts<T> = {
  key: string;
  fetcher: (signal: AbortSignal) => Promise<T>;
  staleTime?: number;
  gcTime?: number;
  signal?: AbortSignal;
};

async function fetchAndStore<T>(opts: FetchOpts<T>): Promise<T> {
  const entry = getEntry<T>(opts.key);

  // In-flight dedup — concurrent callers share the same promise
  if (entry.inflight) return entry.inflight;

  entry.status = 'pending';
  entry.inflight = fetchLimit(() =>
    runWithRetry(opts.fetcher, { signal: opts.signal })
  )
    .then(data => {
      entry.status = 'success';
      entry.data = data;
      entry.error = undefined;
      entry.updatedAt = Date.now();
      return data;
    })
    .catch(err => {
      entry.status = 'error';
      entry.error = err;
      throw err;
    })
    .finally(() => {
      entry.inflight = undefined;
      notify(entry as CacheEntry<unknown>);
    });

  return entry.inflight;
}

function isFresh(entry: CacheEntry<unknown>, staleTime: number) {
  return entry.status === 'success' && Date.now() - entry.updatedAt < staleTime;
}

// ─────────────────────────────────────────────────────────────────────────────
// 6. PUBLIC HOOK — useResourceQuery
// ─────────────────────────────────────────────────────────────────────────────

export type QueryState<T> = {
  data: T | undefined;
  error: unknown;
  status: 'pending' | 'success' | 'error';
  isFetching: boolean;
  refetch: () => void;
};

export function useResourceQuery<T>(args: {
  keyParts: unknown[];
  fetcher: (signal: AbortSignal) => Promise<T>;
  staleTime?: number;      // default 30s
  gcTime?: number;         // default 5m
  enabled?: boolean;       // default true
}): QueryState<T> {
  const {
    keyParts,
    fetcher,
    staleTime = 30_000,
    gcTime = 5 * 60_000,
    enabled = true,
  } = args;

  const key = canonicalKey(keyParts);
  const entry = getEntry<T>(key);
  const [, forceRender] = useReducer((n: number) => n + 1, 0);
  const fetcherRef = useRef(fetcher);
  fetcherRef.current = fetcher;

  // Subscribe to cache updates for this key — via useSyncExternalStore for
  // concurrent-rendering safety
  useSyncExternalStore(
    (cb) => {
      entry.subscribers.add(cb);
      return () => {
        entry.subscribers.delete(cb);
        // Schedule GC if no subscribers remain
        if (entry.subscribers.size === 0) {
          entry.gcTimer = setTimeout(() => {
            if (entry.subscribers.size === 0) cache.delete(key);
          }, gcTime);
        }
      };
    },
    () => entry.updatedAt,
    () => 0 // SSR snapshot
  );

  // Trigger a fetch if needed
  useEffect(() => {
    if (!enabled) return;
    if (entry.gcTimer) { clearTimeout(entry.gcTimer); entry.gcTimer = undefined; }
    if (isFresh(entry, staleTime)) return;
    if (entry.inflight) return;

    const ctrl = new AbortController();
    fetchAndStore({
      key,
      fetcher: (sig) => fetcherRef.current(sig),
      staleTime,
      gcTime,
      signal: ctrl.signal,
    }).then(forceRender, () => forceRender());

    // Cancel this component's fetch on unmount — but only if it's still
    // the active inflight (other subscribers may have completed it already)
    return () => {
      if (entry.subscribers.size === 0) ctrl.abort();
    };
  }, [key, enabled, staleTime, gcTime]);

  const refetch = () => {
    if (entry.inflight) return;
    const ctrl = new AbortController();
    fetchAndStore({
      key,
      fetcher: (sig) => fetcherRef.current(sig),
      staleTime,
      gcTime,
      signal: ctrl.signal,
    }).catch(() => {});
  };

  return {
    data: entry.data,
    error: entry.error,
    status: entry.status,
    isFetching: !!entry.inflight,
    refetch,
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// 7. IMPERATIVE HELPERS — prefetch and setQueryData equivalents
// ─────────────────────────────────────────────────────────────────────────────

export function prefetchResource<T>(
  keyParts: unknown[],
  fetcher: (signal: AbortSignal) => Promise<T>,
  staleTime = 30_000
): Promise<T> {
  const key = canonicalKey(keyParts);
  const entry = getEntry<T>(key);
  if (isFresh(entry, staleTime) && entry.data !== undefined) {
    return Promise.resolve(entry.data);
  }
  return fetchAndStore({ key, fetcher, staleTime });
}

export function setCacheValue<T>(keyParts: unknown[], data: T): void {
  const key = canonicalKey(keyParts);
  const entry = getEntry<T>(key);
  entry.status = 'success';
  entry.data = data;
  entry.error = undefined;
  entry.updatedAt = Date.now();
  notify(entry as CacheEntry<unknown>);
}

export function invalidateCache(predicate: (key: string) => boolean): void {
  for (const [key, entry] of cache) {
    if (!predicate(key)) continue;
    // Mark stale by zeroing updatedAt — next mount refetches
    entry.updatedAt = 0;
    notify(entry as CacheEntry<unknown>);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// USAGE EXAMPLES
// ─────────────────────────────────────────────────────────────────────────────
//
// // Define a resource fetcher
// type Product = { id: string; name: string; price: number };
//
// const fetchProduct = (id: string) => (signal: AbortSignal) =>
//   fetch(`/api/products/${id}`, { signal }).then(async r => {
//     if (!r.ok) throw new HttpError(r.status, await r.text());
//     return r.json() as Promise<Product>;
//   });
//
// // Use in a component — fully library-free
// function ProductCard({ id }: { id: string }) {
//   const { data, error, status, refetch } = useResourceQuery({
//     keyParts: ['product', id],
//     fetcher: fetchProduct(id),
//     staleTime: 5 * 60_000,
//   });
//
//   if (status === 'pending') return <Skeleton />;
//   if (status === 'error')   return <button onClick={refetch}>Retry</button>;
//   return <Card product={data!} />;
// }
//
// // Hover-prefetch — re-use prefetchResource imperatively
// <a
//   href={`/product/${id}`}
//   onMouseEnter={() => prefetchResource(['product', id], fetchProduct(id))}
// />

declare function Skeleton(): JSX.Element;
declare function Card(props: { product: unknown }): JSX.Element;
