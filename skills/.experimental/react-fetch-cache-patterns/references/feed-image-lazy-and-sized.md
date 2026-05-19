---
title: Defer Off-Screen Feed Images with Explicit Dimensions
impact: MEDIUM-HIGH
impactDescription: prevents layout shift and saves 70-90% image bandwidth
tags: feed, images, lazy-loading, cls, dimensions
---

## Defer Off-Screen Feed Images with Explicit Dimensions

A feed of 100 items each with a 200kb hero image means a 20MB download if everything loads up front — but most users scroll through ~10 items. Native `loading="lazy"` defers off-screen images until the user scrolls near them. Explicit `width` and `height` (or `aspect-ratio`) prevent layout shift when each image arrives — without dimensions, the page jumps as images load, breaking infinite scroll.

`<img loading="lazy">` is supported in all evergreen browsers. For finer control, combine `IntersectionObserver` with a low-quality placeholder.

**Incorrect (eager-load all images, no dimensions, layout shifts as they arrive):**

```tsx
function FeedItem({ item }: { item: Item }) {
  return (
    <article>
      <img src={item.heroUrl} alt={item.title} />
      {/* No width/height — height is 0 until image loads, then expands and pushes everything */}
      <h3>{item.title}</h3>
    </article>
  );
}
// 100 items × 200kb = 20MB download on mount; CLS score destroyed
```

**Correct (lazy-loaded with explicit aspect ratio):**

```tsx
function FeedItem({ item }: { item: Item }) {
  return (
    <article>
      <img
        src={item.heroUrl}
        alt={item.title}
        width={1200}
        height={630}
        loading="lazy"
        decoding="async"
        style={{ aspectRatio: '1200 / 630', objectFit: 'cover', width: '100%', height: 'auto' }}
      />
      <h3>{item.title}</h3>
    </article>
  );
}
// Only images near viewport download; layout stable as images arrive
```

**With Next.js Image (optimized + lazy + responsive):**

```tsx
import Image from 'next/image';

function FeedItem({ item }: { item: Item }) {
  return (
    <article>
      <Image
        src={item.heroUrl}
        alt={item.title}
        width={1200}
        height={630}
        sizes="(max-width: 768px) 100vw, 720px" // serve appropriately sized image
        loading="lazy"
        placeholder="blur"
        blurDataURL={item.heroBlur} // tiny inline placeholder (~100 bytes)
      />
    </article>
  );
}
```

**For the first 1-3 items above the fold, eager-load:**

```tsx
{items.map((item, i) => (
  <FeedItem
    key={item.id}
    item={item}
    priority={i < 2} // first two get loading="eager" and fetchpriority="high"
  />
))}
```

**For carousels (off-screen but DOM-rendered):**

```tsx
// Native loading="lazy" only triggers on viewport intersection;
// horizontally-scrolled carousel items count as "in viewport" even when scrolled away
// → use IntersectionObserver on the carousel container instead
```

**Avoid CLS pitfalls:**

| Anti-pattern | Fix |
|--------------|-----|
| `<img src="..." />` with no dimensions | Add `width` + `height` attributes |
| Skeleton without matching dimensions | Skeleton must occupy the same space as the loaded image |
| Late-arriving CSS that shrinks image | Set dimensions in HTML, not just CSS |
| Cross-origin images blocked by CORS while measuring | Use `crossorigin="anonymous"` if you'll need bitmap access |

Reference: [MDN — Lazy loading](https://developer.mozilla.org/en-US/docs/Web/Performance/Lazy_loading) | [web.dev — Cumulative Layout Shift](https://web.dev/articles/cls)
