/**
 * Hover/intent prefetch link wrapper.
 *
 * Embedded patterns:
 *   - Hover + pointerdown prefetch ([[prefetch-hover-intent-links]])
 *   - Connection-aware gating ([[prefetch-budget-and-priority]])
 *   - Single trigger per hover session (avoid re-firing on mouse jitter)
 *
 * Parameters to fill in:
 *   - The `prefetch` argument: a function that primes the cache for the destination.
 *     Typically calls `queryClient.prefetchQuery` with the same key/queryFn the
 *     destination's component would use.
 *
 * Wrap your existing <Link> (Next, TanStack Router) — this works with any of them.
 */

import { useCallback, useRef, type AnchorHTMLAttributes, type ReactNode } from 'react';

type PrefetchLinkProps = {
  href: string;
  prefetch: () => Promise<unknown> | unknown;
  children: ReactNode;
  /** Tag to wrap with — defaults to plain anchor. Pass NextLink / TanStack Link if desired. */
  as?: React.ElementType;
} & Omit<AnchorHTMLAttributes<HTMLAnchorElement>, 'href'>;

export function PrefetchLink({
  href,
  prefetch,
  children,
  as: Component = 'a',
  ...anchorProps
}: PrefetchLinkProps) {
  const prefetchedRef = useRef(false);

  const tryPrefetch = useCallback(() => {
    if (prefetchedRef.current) return;
    // Skip on slow / save-data connections — respect user bandwidth
    // @ts-expect-error — Network Information API not in lib.dom
    const conn = typeof navigator !== 'undefined' ? navigator.connection : undefined;
    if (conn?.saveData) return;
    if (conn?.effectiveType === '2g' || conn?.effectiveType === 'slow-2g') return;

    prefetchedRef.current = true;
    try {
      const maybePromise = prefetch();
      if (maybePromise && typeof (maybePromise as Promise<unknown>).then === 'function') {
        // Swallow prefetch errors — never block navigation on a failed prefetch
        (maybePromise as Promise<unknown>).catch(() => {
          prefetchedRef.current = false; // allow retry on next hover
        });
      }
    } catch {
      prefetchedRef.current = false;
    }
  }, [prefetch]);

  return (
    <Component
      href={href}
      onMouseEnter={tryPrefetch}
      onFocus={tryPrefetch}
      onPointerDown={tryPrefetch}
      onTouchStart={tryPrefetch}
      {...anchorProps}
    >
      {children}
    </Component>
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Usage example
// ─────────────────────────────────────────────────────────────────────────────
//
// import { useQueryClient } from '@tanstack/react-query';
//
// function ProductLink({ id, name }: { id: string; name: string }) {
//   const queryClient = useQueryClient();
//   return (
//     <PrefetchLink
//       href={`/product/${id}`}
//       prefetch={() => queryClient.prefetchQuery({
//         queryKey: ['product', id],
//         queryFn: () => fetchProduct(id),
//         staleTime: 60_000,
//       })}
//     >
//       {name}
//     </PrefetchLink>
//   );
// }
