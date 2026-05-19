/**
 * Cursor-paginated infinite feed with virtualization.
 *
 * Embedded patterns:
 *   - Cursor pagination ([[feed-cursor-pagination]])
 *   - Bounded working set via maxPages ([[feed-bounded-working-set]])
 *   - Virtualization ([[feed-virtualize-long-lists]])
 *   - Viewport-triggered next-page prefetch ([[prefetch-viewport-triggered-next-page]])
 *   - Stable keys ([[feed-stable-keys-across-pages]])
 *   - Stale-while-revalidate ([[cache-stale-while-revalidate]])
 *   - AbortSignal forwarded to fetch ([[resilience-abort-on-unmount]])
 *
 * Parameters to fill in:
 *   - FEED_NAME: kebab-case feed identifier (e.g. "home-feed", "user-posts")
 *   - FeedItem: row type
 *   - fetchFeedPage: your paginated API
 *   - estimatedRowHeight: approximate row height for the virtualizer
 */

import { useEffect, useMemo, useRef } from 'react';
import { useInfiniteQuery } from '@tanstack/react-query';
import { useVirtualizer } from '@tanstack/react-virtual';

// ─────────────────────────────────────────────────────────────────────────────
// Domain types — replace with yours
// ─────────────────────────────────────────────────────────────────────────────

type FeedItem = {
  id: string;
  // ... your fields
};

type FeedPage = {
  items: FeedItem[];
  nextCursor: string | null;
};

declare function fetchFeedPage(
  cursor: string | null,
  init?: { signal?: AbortSignal }
): Promise<FeedPage>;

// ─────────────────────────────────────────────────────────────────────────────
// Component
// ─────────────────────────────────────────────────────────────────────────────

const FEED_NAME = 'FEED_NAME';
const ESTIMATED_ROW_HEIGHT = 120;
const OVERSCAN = 5;
const PREFETCH_ROOT_MARGIN = '800px';

export function InfiniteFeed() {
  const parentRef = useRef<HTMLDivElement>(null);

  const {
    data,
    fetchNextPage,
    hasNextPage,
    isFetchingNextPage,
    isError,
    isLoading,
  } = useInfiniteQuery({
    queryKey: [FEED_NAME],
    queryFn: ({ pageParam, signal }) => fetchFeedPage(pageParam, { signal }),
    initialPageParam: null as string | null,
    getNextPageParam: (last) => last.nextCursor,
    maxPages: 8,                // bounded working set
    staleTime: 30_000,
    refetchOnWindowFocus: false,
  });

  // Flatten + dedupe items across pages
  const items = useMemo(() => {
    const all = data?.pages.flatMap(p => p.items) ?? [];
    const seen = new Set<string>();
    return all.filter(item => seen.has(item.id) ? false : (seen.add(item.id), true));
  }, [data]);

  // Virtualizer — only ~25 rows in DOM regardless of items.length
  const virtualizer = useVirtualizer({
    count: hasNextPage ? items.length + 1 : items.length, // +1 slot for the next-page sentinel
    getScrollElement: () => parentRef.current,
    estimateSize: () => ESTIMATED_ROW_HEIGHT,
    overscan: OVERSCAN,
  });

  // Viewport-triggered next-page prefetch
  // Fires when the last virtual row is near the rendered range
  useEffect(() => {
    if (!hasNextPage || isFetchingNextPage) return;
    const lastVirtual = virtualizer.getVirtualItems().at(-1);
    if (lastVirtual && lastVirtual.index >= items.length - OVERSCAN) {
      fetchNextPage();
    }
  }, [
    virtualizer.getVirtualItems(),
    items.length,
    hasNextPage,
    isFetchingNextPage,
    fetchNextPage,
  ]);

  if (isLoading) return <FeedSkeleton />;
  if (isError && items.length === 0) return <FeedError />;

  return (
    <div ref={parentRef} className="h-screen overflow-y-auto" data-feed={FEED_NAME}>
      <div
        style={{ height: virtualizer.getTotalSize(), width: '100%', position: 'relative' }}
      >
        {virtualizer.getVirtualItems().map(virtualRow => {
          const item = items[virtualRow.index];
          const isLoaderRow = virtualRow.index > items.length - 1;

          return (
            <div
              key={isLoaderRow ? 'loader' : item.id}
              data-index={virtualRow.index}
              ref={virtualizer.measureElement}
              style={{
                position: 'absolute',
                top: 0,
                left: 0,
                width: '100%',
                transform: `translateY(${virtualRow.start}px)`,
              }}
            >
              {isLoaderRow ? (
                hasNextPage ? <Loader /> : <EndOfFeed />
              ) : (
                <FeedRow item={item} />
              )}
            </div>
          );
        })}
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Row — fill in your render
// ─────────────────────────────────────────────────────────────────────────────

function FeedRow({ item }: { item: FeedItem }) {
  return (
    <article className="border-b p-4">
      {/* Replace with your row content */}
      <div>{item.id}</div>
    </article>
  );
}

function FeedSkeleton() {
  return (
    <div className="space-y-4 p-4">
      {Array.from({ length: 8 }).map((_, i) => (
        <div key={i} className="h-24 bg-gray-200 animate-pulse rounded" />
      ))}
    </div>
  );
}
function Loader() { return <div className="p-4 text-center text-muted">Loading more…</div>; }
function EndOfFeed() { return <div className="p-4 text-center text-muted">End of feed</div>; }
function FeedError() { return <div className="p-4 text-center text-red-600">Couldn't load feed</div>; }
