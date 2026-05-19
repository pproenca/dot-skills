---
title: Isolate Failure Across a Feed of Carousels
impact: MEDIUM-HIGH
impactDescription: prevents one failing carousel from breaking the homepage
tags: feed, carousel, error-boundary, isolation, suspense
---

## Isolate Failure Across a Feed of Carousels

A homepage feed of 6 carousels (trending, recommended, recently-viewed, "people also bought", seasonal, personalized) means 6 independent recommender pipelines. At any given moment, one of them is degraded — a model is being redeployed, a data source is rate-limited, a personalization service is on call. Without isolation, *one* failing carousel cascades to break the whole feed (one Suspense root → all wait for the slowest; one ErrorBoundary root → one failure crashes everything).

The pattern: wrap each carousel in its own `ErrorBoundary` + `Suspense`, tier carousels by importance (critical, important, decorative), and apply tier-appropriate fallbacks. Combine with bounded concurrency at the fetch layer so 6 parallel summary fetches don't drown the user-initiated request happening at the same time.

This is the multi-section version of [[resilience-scoped-error-boundaries]] and [[render-suspense-per-section]], with the failure-tier logic from [[resilience-graceful-degradation]].

**Incorrect (single boundary — one failure kills the entire feed):**

```tsx
function HomepageFeed() {
  return (
    <ErrorBoundary fallback={<FullPageError />}>
      <Suspense fallback={<FullFeedSkeleton />}>
        <ContinueWatchingCarousel />
        <RecommendedCarousel />
        <TrendingCarousel />
        <RecentlyViewedCarousel />     {/* this one errors */}
        <SeasonalCarousel />
        {/* → entire homepage now shows FullPageError because one decorative
             carousel had a 500. User sees nothing. */}
      </Suspense>
    </ErrorBoundary>
  );
}
```

**Correct (per-carousel isolation with tier-appropriate fallbacks):**

```tsx
type Tier = 'critical' | 'important' | 'decorative';

const FEED: Array<{ kind: string; title: string; tier: Tier }> = [
  { kind: 'continue-watching', title: 'Continue watching',  tier: 'critical' },
  { kind: 'recommended',       title: 'Recommended for you', tier: 'important' },
  { kind: 'trending',          title: 'Trending now',        tier: 'important' },
  { kind: 'recently-viewed',   title: 'Recently viewed',     tier: 'decorative' },
  { kind: 'seasonal',          title: 'Seasonal picks',      tier: 'decorative' },
];

function HomepageFeed() {
  return (
    <div className="flex flex-col gap-12">
      {FEED.map((cfg, i) => (
        <ErrorBoundary
          key={cfg.kind}
          onError={(e) => reportError({ section: cfg.kind, tier: cfg.tier, error: e })}
          fallbackRender={({ resetErrorBoundary }) => {
            if (cfg.tier === 'decorative') return null;                   // silent
            if (cfg.tier === 'important')  return <MiniError onRetry={resetErrorBoundary} />;
            return <FullError title={cfg.title} onRetry={resetErrorBoundary} />;
          }}
        >
          <Suspense fallback={<CarouselSkeleton title={cfg.title} />}>
            {i < 2
              ? <Carousel kind={cfg.kind} />        // above the fold — eager
              : <DeferredCarousel kind={cfg.kind} />} // below the fold — viewport-triggered
          </Suspense>
        </ErrorBoundary>
      ))}
    </div>
  );
}
```

**Eager and deferred carousel variants:**

```tsx
// Above-the-fold — suspends on first fetch
function Carousel({ kind }: { kind: string }) {
  const { data } = useSuspenseQuery({
    queryKey: ['carousel', kind, 'summaries'],
    queryFn: ({ signal }) => fetchCarouselSummaries(kind, { signal }),
    staleTime: 5 * 60_000,
  });
  return <Track items={data} />;
}

// Below-the-fold — defer mounting (and fetching) until in viewport
function DeferredCarousel({ kind }: { kind: string }) {
  const ref = useRef<HTMLDivElement>(null);
  const [visible, setVisible] = useState(false);
  useEffect(() => {
    const obs = new IntersectionObserver(
      ([e]) => e.isIntersecting && setVisible(true),
      { rootMargin: '300px' }
    );
    if (ref.current) obs.observe(ref.current);
    return () => obs.disconnect();
  }, []);
  if (!visible) return <div ref={ref} style={{ height: 280 }} />; // reserve space
  return <div ref={ref}><Carousel kind={kind} /></div>;
}
```

**Tier fallbacks table:**

| Tier | On failure | Why |
|------|-----------|-----|
| `critical` | Full error UI with retry; visible | User came specifically for this content (Continue Watching) — they need to know it failed |
| `important` | Minimal retry placeholder | Visible degradation maintains trust without breaking layout |
| `decorative` | `null` (silently hidden) | Failure shouldn't punish the user for absent ad-side rails |

**Concurrency guardrail at the fetch layer:**

Six carousels mounting at once means six parallel summary requests, plus dozens of detail prefetches if items hover-prefetch. Cap parallelism so the feed degrades to "smooth but a bit slower" instead of "all timing out":

```ts
// At fetch wiring time — see [[protect-concurrency-limit-fanout]]
import { collapsedFetch } from './request-collapser';
// collapsedFetch caps at 6 concurrent requests + dedupes identical GETs
async function fetchCarouselSummaries(kind: string, init: { signal: AbortSignal }) {
  const res = await collapsedFetch(`/api/carousels/${kind}/summaries`, init);
  return res.json();
}
```

**Render-priority ordering matters:**

Even with per-section Suspense, *render order* in the JSX determines reveal order in the SSR streaming case. Put critical carousels first — they get the first reserved layout slot and the first streamable chunk. Decorative carousels last, so their slow data sources don't push the critical ones below the fold.

**Observability rule:** silent failures are not invisible failures. Decorative carousels rendering `null` on failure must still emit a structured error to your logging stack (`onError={reportError}`) so an outage is detectable. A degraded recommender that quietly serves zero items for a week is a silent revenue leak.

**When NOT to use this pattern:**
- Single-carousel pages — the overhead of tiering buys nothing
- Synchronously-loaded feeds where every carousel ships in the initial HTML payload — Suspense isn't doing meaningful work
- Critical compliance flows where ANY missing data is a hard fail — there `tier: critical` isn't strong enough; refuse to render the page at all

**Pair with [[feed-split-summary-from-detail]]:** each carousel's summary fetch returns lightweight payloads; viewport-triggered detail fetches keep working-set bounded across the whole feed.

Reference: [react-error-boundary](https://github.com/bvaughn/react-error-boundary) | [Vercel — Streaming with Suspense](https://nextjs.org/docs/app/building-your-application/routing/loading-ui-and-streaming)
