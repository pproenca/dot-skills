/**
 * Recommender carousel template.
 *
 * Embedded patterns:
 *   - Summary/detail split ([[feed-split-summary-from-detail]])
 *   - Viewport-triggered detail fetch ([[feed-split-summary-from-detail]])
 *   - Hover prefetch ([[prefetch-hover-intent-links]])
 *   - Bulk endpoint for summaries ([[orch-prefer-bulk-endpoint-for-fanout]])
 *   - Per-item useQuery scoped to in-viewport cards only ([[render-cap-fanout-in-lists]])
 *   - Scoped error boundary + Suspense ([[resilience-scoped-error-boundaries]])
 *
 * Parameters to fill in:
 *   - ITEM_KIND: kebab-case label, e.g. "recommended" / "trending" / "recently-viewed"
 *   - ProductSummary / Product: replace with your domain types
 *   - fetchCarouselSummaries / fetchProduct: your API functions
 */

import { useEffect, useRef, useState } from 'react';
import { useQuery, useQueryClient } from '@tanstack/react-query';

// ─────────────────────────────────────────────────────────────────────────────
// Domain types — replace with yours
// ─────────────────────────────────────────────────────────────────────────────

type ProductSummary = {
  id: string;
  thumbnail: string;
  title: string;
  price: number;
};

type Product = ProductSummary & {
  description: string;
  variants: Array<{ id: string; name: string; price: number }>;
  reviews: Array<{ id: string; rating: number; text: string }>;
  // ... other heavy detail fields
};

// ─────────────────────────────────────────────────────────────────────────────
// API — replace with your client
// ─────────────────────────────────────────────────────────────────────────────

declare function fetchCarouselSummaries(
  kind: string,
  init?: { signal?: AbortSignal }
): Promise<ProductSummary[]>;

declare function fetchProduct(
  id: string,
  init?: { signal?: AbortSignal }
): Promise<Product>;

// ─────────────────────────────────────────────────────────────────────────────
// Carousel component
// ─────────────────────────────────────────────────────────────────────────────

export function RecommenderCarousel({ kind }: { kind: string }) {
  const summariesQuery = useQuery({
    queryKey: ['carousel', kind, 'summaries'],
    queryFn: ({ signal }) => fetchCarouselSummaries(kind, { signal }),
    staleTime: 5 * 60_000,
    retry: 1,
    throwOnError: false, // optional content — see [[resilience-graceful-degradation]]
  });

  if (summariesQuery.isError) return null;          // optional: silent failure
  if (!summariesQuery.data) return <CarouselSkeleton />;

  return (
    <section aria-label={`${kind} carousel`} className="overflow-x-auto">
      <div className="flex gap-4">
        {summariesQuery.data.map(summary => (
          <CarouselCard key={summary.id} summary={summary} />
        ))}
      </div>
    </section>
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Carousel card — fetches detail only when in viewport
// ─────────────────────────────────────────────────────────────────────────────

function CarouselCard({ summary }: { summary: ProductSummary }) {
  const queryClient = useQueryClient();
  const cardRef = useRef<HTMLDivElement>(null);
  const [inViewport, setInViewport] = useState(false);

  // Viewport-triggered detail fetch
  useEffect(() => {
    const el = cardRef.current;
    if (!el) return;
    const obs = new IntersectionObserver(
      ([entry]) => entry.isIntersecting && setInViewport(true),
      { rootMargin: '200px' }
    );
    obs.observe(el);
    return () => obs.disconnect();
  }, []);

  const detailQuery = useQuery({
    queryKey: ['product', summary.id],
    queryFn: ({ signal }) => fetchProduct(summary.id, { signal }),
    enabled: inViewport,
    staleTime: 5 * 60_000,
    retry: 1,
  });

  // Hover prefetch — also covers users who never scroll the card into view
  const prefetchDetail = () =>
    queryClient.prefetchQuery({
      queryKey: ['product', summary.id],
      queryFn: ({ signal }) => fetchProduct(summary.id, { signal }),
      staleTime: 5 * 60_000,
    });

  return (
    <div
      ref={cardRef}
      onMouseEnter={prefetchDetail}
      onPointerDown={prefetchDetail}
      className="flex-shrink-0 w-48"
    >
      <img
        src={summary.thumbnail}
        alt={summary.title}
        width={192}
        height={240}
        loading="lazy"
        decoding="async"
        style={{ aspectRatio: '192 / 240', objectFit: 'cover' }}
      />
      <h3 className="text-sm font-medium mt-2 truncate">{summary.title}</h3>
      <p className="text-xs">${summary.price.toFixed(2)}</p>
      {/* Show extra detail only after the detail fetch resolves */}
      {detailQuery.data && (
        <p className="text-xs text-muted mt-1 line-clamp-2">
          {detailQuery.data.description}
        </p>
      )}
    </div>
  );
}

function CarouselSkeleton() {
  return (
    <div className="flex gap-4 overflow-x-hidden">
      {Array.from({ length: 6 }).map((_, i) => (
        <div key={i} className="flex-shrink-0 w-48">
          <div className="w-full bg-gray-200 animate-pulse" style={{ aspectRatio: '192 / 240' }} />
          <div className="h-4 bg-gray-200 mt-2 animate-pulse" />
          <div className="h-3 bg-gray-200 mt-2 w-1/3 animate-pulse" />
        </div>
      ))}
    </div>
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// MULTI-CAROUSEL FEED — composing several carousels with failure isolation
// ─────────────────────────────────────────────────────────────────────────────
//
// A homepage often renders 5-10 themed carousels: trending, recommended,
// recently-viewed, "people also bought", seasonal, etc. Each one is its own
// recommender pipeline — any of them can fail independently. The pattern below
// keeps the feed working even when 2-3 carousels fail.
//
// Embedded patterns:
//   - Per-carousel scoped error boundary ([[resilience-scoped-error-boundaries]])
//   - Per-carousel Suspense — feed streams in, doesn't block on slowest ([[render-suspense-per-section]])
//   - Bounded concurrency on summary fetches ([[protect-concurrency-limit-fanout]])
//   - Tier-based fallbacks: critical shows error, decorative silently hides ([[resilience-graceful-degradation]])
//   - Viewport-triggered render for below-the-fold carousels ([[prefetch-viewport-triggered-next-page]])
//   - Priority ordering (critical-first reveals)

import { Suspense, useEffect, useRef, useState, type ReactNode } from 'react';
import { ErrorBoundary } from 'react-error-boundary';
import { useSuspenseQuery, useQueryClient } from '@tanstack/react-query';

type CarouselTier = 'critical' | 'important' | 'decorative';

type CarouselConfig = {
  kind: string;
  title: string;
  tier: CarouselTier;
};

const FEED: CarouselConfig[] = [
  { kind: 'continue-watching',  title: 'Continue watching',  tier: 'critical' },
  { kind: 'recommended-for-you', title: 'Recommended for you', tier: 'important' },
  { kind: 'trending',            title: 'Trending now',        tier: 'important' },
  { kind: 'recently-viewed',     title: 'Recently viewed',     tier: 'decorative' },
  { kind: 'because-you-watched', title: 'Because you watched', tier: 'decorative' },
  { kind: 'seasonal',            title: 'Seasonal picks',      tier: 'decorative' },
];

export function MultiCarouselFeed() {
  return (
    <div className="flex flex-col gap-12">
      {FEED.map((config, index) => (
        <CarouselSlot
          key={config.kind}
          config={config}
          // First 2 render eagerly (above fold); the rest defer to viewport
          eager={index < 2}
        />
      ))}
    </div>
  );
}

// Slot wraps a carousel with discipline-correct fallbacks:
//   - critical:   error visible with retry
//   - important:  minimal "couldn't load" placeholder
//   - decorative: silent — render nothing on failure
function CarouselSlot({
  config,
  eager,
}: { config: CarouselConfig; eager: boolean }) {
  return (
    <section aria-label={config.title}>
      <h2 className="text-xl font-semibold mb-4">{config.title}</h2>
      <CarouselErrorBoundary tier={config.tier} title={config.title}>
        <Suspense fallback={<CarouselSkeleton />}>
          {eager
            ? <SuspendingCarousel kind={config.kind} />
            : <DeferredCarousel kind={config.kind} />}
        </Suspense>
      </CarouselErrorBoundary>
    </section>
  );
}

// Tier-aware error fallback
function CarouselErrorBoundary({
  tier, title, children,
}: { tier: CarouselTier; title: string; children: ReactNode }) {
  return (
    <ErrorBoundary
      onError={(error) => {
        // Log every silent failure to observability — silence on the UI,
        // not silence in monitoring
        reportError({ carousel: title, tier, error });
      }}
      fallbackRender={({ resetErrorBoundary }) => {
        if (tier === 'decorative') return null;            // hidden — user doesn't notice
        if (tier === 'important')  return <CarouselError minimal onRetry={resetErrorBoundary} />;
        return <CarouselError onRetry={resetErrorBoundary} />;
      }}
    >
      {children}
    </ErrorBoundary>
  );
}

// Above-the-fold variant — uses useSuspenseQuery so it suspends until ready
function SuspendingCarousel({ kind }: { kind: string }) {
  const { data: summaries } = useSuspenseQuery({
    queryKey: ['carousel', kind, 'summaries'],
    queryFn: ({ signal }) => fetchCarouselSummaries(kind, { signal }),
    staleTime: 5 * 60_000,
  });

  return <CarouselTrack summaries={summaries} />;
}

// Below-the-fold variant — defer mounting until the slot enters the viewport
function DeferredCarousel({ kind }: { kind: string }) {
  const ref = useRef<HTMLDivElement>(null);
  const [inViewport, setInViewport] = useState(false);

  useEffect(() => {
    const el = ref.current;
    if (!el) return;
    const obs = new IntersectionObserver(
      ([entry]) => entry.isIntersecting && setInViewport(true),
      { rootMargin: '300px' }
    );
    obs.observe(el);
    return () => obs.disconnect();
  }, []);

  if (!inViewport) {
    // Reserve space so the slot has stable height while invisible
    return <div ref={ref} style={{ height: 280 }} />;
  }
  // Now Suspense kicks in via the inner component
  return <div ref={ref}><SuspendingCarousel kind={kind} /></div>;
}

function CarouselTrack({ summaries }: { summaries: ProductSummary[] }) {
  return (
    <div className="flex gap-4 overflow-x-auto">
      {summaries.map(s => <CarouselCard key={s.id} summary={s} />)}
    </div>
  );
}

function CarouselError({
  minimal = false, onRetry,
}: { minimal?: boolean; onRetry: () => void }) {
  if (minimal) {
    return (
      <button
        onClick={onRetry}
        className="text-sm text-muted underline"
      >
        Couldn't load — tap to retry
      </button>
    );
  }
  return (
    <div className="rounded border p-4 bg-yellow-50">
      <p className="font-medium">We couldn't load this section.</p>
      <button onClick={onRetry} className="mt-2 text-sm underline">
        Try again
      </button>
    </div>
  );
}

declare function reportError(payload: {
  carousel: string;
  tier: CarouselTier;
  error: unknown;
}): void;

// ─────────────────────────────────────────────────────────────────────────────
// CONCURRENCY GUARDRAIL FOR MULTI-CAROUSEL FEEDS
// ─────────────────────────────────────────────────────────────────────────────
//
// With 6 carousels each fetching ~30 items, the homepage can fire 6 summary
// requests + dozens of detail prefetches in parallel. Wire a global
// concurrency cap so the feed degrades to "smooth and a bit slower" rather
// than "all fail with timeouts."
//
// Configure once at QueryClient setup:
//
// const queryClient = new QueryClient({
//   defaultOptions: {
//     queries: {
//       // Default tier — overridden per-query for realtime / static data
//       staleTime: 60_000,
//       retry: (attempt, err) =>
//         attempt < 2 && !(err instanceof HttpError && err.status >= 400 && err.status < 500),
//       retryDelay: attempt => Math.random() * Math.min(30_000, 1000 * 2 ** attempt),
//     },
//   },
// });
//
// For the underlying `fetch` layer, wrap calls in the request collapser
// from `request-collapser.template.ts` — it caps concurrency at 6.

declare class HttpError extends Error {
  status: number;
}
