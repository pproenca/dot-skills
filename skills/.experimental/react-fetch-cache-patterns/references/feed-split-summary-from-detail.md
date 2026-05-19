---
title: Split Carousel Summaries from Item Details
impact: MEDIUM-HIGH
impactDescription: reduces initial carousel payload 5-20×
tags: feed, carousel, summary, detail, lazy
---

## Split Carousel Summaries from Item Details

A recommender carousel needs *very little* per item to render: ID, thumbnail URL, title, often a price. But the same backend endpoint often returns the *full* product object — description, variants, reviews, related products — bloating the payload. Split the API: one endpoint returns lightweight summaries (10x smaller); detail endpoints fetch the rest on hover, click, or viewport.

For carousel-heavy pages, this is the difference between a 200kb response and a 20kb response — and the difference between fetching 30 detail-laden objects for items 90% of users never click.

**Incorrect (carousel fetches full objects up front):**

```tsx
function RecommendedCarousel() {
  const { data } = useQuery({
    queryKey: ['recs', 'full'],
    queryFn: fetchFullRecommendations, // returns full product objects: 80kb for 30 items
  });
  return (
    <Carousel>
      {data?.map(p => (
        <CarouselCard key={p.id} thumbnail={p.thumbnail} title={p.title} />
        // Each card uses 3 fields out of ~25 — the other 22 fields are wasted bytes
      ))}
    </Carousel>
  );
}
```

**Correct (summary + on-demand detail):**

```tsx
// Summary type: just what the card renders
type ProductSummary = { id: string; thumbnail: string; title: string; price: number };

function RecommendedCarousel() {
  const { data: summaries } = useQuery({
    queryKey: ['recs', 'summary'],
    queryFn: fetchRecommendationsSummary, // returns ProductSummary[]: 5kb for 30 items
  });

  return (
    <Carousel>
      {summaries?.map(s => (
        <CarouselCard
          key={s.id}
          summary={s}
          // Pre-fetch full detail on hover; quick-look popover uses it instantly
          onMouseEnter={() => queryClient.prefetchQuery({
            queryKey: ['product', s.id],
            queryFn: () => fetchProduct(s.id),
            staleTime: 60_000,
          })}
        />
      ))}
    </Carousel>
  );
}

// When the user clicks for a quick-look
function QuickLook({ productId }: { productId: string }) {
  const { data: product } = useQuery({
    queryKey: ['product', productId],
    queryFn: () => fetchProduct(productId),
  });
  return <DetailView product={product} />;
}
```

**API endpoint design pattern:**

```text
GET /api/recommendations
  → returns [{ id, thumbnail, title, price }, ...]   # 5kb for 30 items

GET /api/products/:id
  → returns full product object                       # 4kb for one item

GET /api/products?ids=a,b,c
  → returns full product objects, bulk                # 4kb × N for batched detail
```

**For carousels with viewport-triggered detail (only items the user sees get detailed):**

```tsx
function CarouselCard({ summary }: { summary: ProductSummary }) {
  const cardRef = useRef<HTMLDivElement>(null);
  const [inViewport, setInViewport] = useState(false);

  useEffect(() => {
    const obs = new IntersectionObserver(([e]) => setInViewport(e.isIntersecting));
    if (cardRef.current) obs.observe(cardRef.current);
    return () => obs.disconnect();
  }, []);

  // Only fetch detail for items the user actually scrolls past
  const { data: detail } = useQuery({
    queryKey: ['product', summary.id],
    queryFn: () => fetchProduct(summary.id),
    enabled: inViewport,
    staleTime: 60_000,
  });

  return <div ref={cardRef}>{/* render summary; show detail extras when present */}</div>;
}
```

**When NOT to split:** if the summary is already most of the object (a tweet has very few fields beyond the visible content), the split costs more than it saves.

**Cache normalization angle:** when summaries and details overlap on the same fields (title, thumbnail), pair this with [[cache-normalize-shared-entities]] so fetching the detail upgrades the summary in place rather than holding two copies.

Reference: [GraphQL — Fragments and Field Selection](https://graphql.org/learn/queries/#fragments) | [Vercel — Optimizing Data Fetching](https://vercel.com/blog/everything-about-data-fetching-in-nextjs)
