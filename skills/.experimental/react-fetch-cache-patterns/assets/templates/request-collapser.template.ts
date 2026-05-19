/**
 * In-flight request collapser + concurrency limiter.
 *
 * Embedded patterns:
 *   - Request collapsing by signature ([[protect-collapse-identical-requests]])
 *   - Concurrency limit for fan-out ([[protect-concurrency-limit-fanout]])
 *   - GET-only safe-method dedup; mutations never collapsed
 *
 * Use cases:
 *   - Imperative code paths that bypass useQuery (auth refresh, logging, polling)
 *   - APIs without a query library that still need dedup + concurrency limits
 *   - Pre-warming a cache where multiple modules might race to the same call
 *
 * Parameters to tune:
 *   - DEFAULT_CONCURRENCY: max simultaneous in-flight (6 is a safe default for HTTP/1.1)
 *   - signatureFn: how to derive a dedup signature from request input
 */

// ─────────────────────────────────────────────────────────────────────────────
// Concurrency limiter — bounded queue, no dependency
// ─────────────────────────────────────────────────────────────────────────────

export function createLimiter(max: number) {
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

// ─────────────────────────────────────────────────────────────────────────────
// Request collapser — dedup identical concurrent calls by signature
// ─────────────────────────────────────────────────────────────────────────────

type Signature = string;

const DEFAULT_CONCURRENCY = 6;

export class RequestCollapser {
  private inflight = new Map<Signature, Promise<unknown>>();
  private limit = createLimiter(DEFAULT_CONCURRENCY);

  constructor(opts?: { concurrency?: number }) {
    if (opts?.concurrency) this.limit = createLimiter(opts.concurrency);
  }

  /**
   * Collapse identical concurrent calls into a shared promise.
   *
   * @param signature  Unique key for the request. Same signature → shared result.
   * @param fn         The actual fetch — only invoked when no in-flight match exists.
   */
  collapse<T>(signature: Signature, fn: () => Promise<T>): Promise<T> {
    const existing = this.inflight.get(signature) as Promise<T> | undefined;
    if (existing) return existing;

    const p = this.limit(fn).finally(() => this.inflight.delete(signature));
    this.inflight.set(signature, p);
    return p;
  }

  /** For mutations / non-idempotent calls — always invokes fn, no dedup. */
  enqueue<T>(fn: () => Promise<T>): Promise<T> {
    return this.limit(fn);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Wrapped fetch — drop-in replacement for `fetch` with dedup + concurrency
// ─────────────────────────────────────────────────────────────────────────────

const collapser = new RequestCollapser({ concurrency: 6 });

/**
 * Fetch with automatic in-flight deduplication for GET requests and concurrency limit.
 * Non-GET methods bypass dedup (mutations are not idempotent).
 *
 * The returned Response is cloned for each caller so they can read the body independently.
 */
export function collapsedFetch(
  input: RequestInfo | URL,
  init?: RequestInit
): Promise<Response> {
  const method = (init?.method ?? 'GET').toUpperCase();
  const url = typeof input === 'string' ? input : input instanceof URL ? input.toString() : input.url;

  if (method !== 'GET' && method !== 'HEAD') {
    // Non-idempotent — never collapse, but still respect concurrency
    return collapser.enqueue(() => fetch(input, init));
  }

  const signature = `${method} ${url}`;

  return collapser
    .collapse(signature, () => fetch(input, init))
    .then(res => res.clone()); // each caller gets their own readable body
}

// ─────────────────────────────────────────────────────────────────────────────
// Usage example
// ─────────────────────────────────────────────────────────────────────────────
//
// // Two modules independently call this in the same tick → one HTTP request
// async function getConfig() {
//   const res = await collapsedFetch('/api/config');
//   return res.json();
// }
//
// // Fan-out limited to 6 concurrent — backend sees smooth pressure
// const products = await Promise.all(
//   ids.map(id => collapsedFetch(`/api/products/${id}`).then(r => r.json()))
// );
