---
title: Prevent Cumulative Layout Shift with Size Reservations
impact: HIGH
impactDescription: reduces CLS from 0.25+ to under 0.1
tags: cwv, cls, layout-shift, aspect-ratio, size-reservation
---

## Prevent Cumulative Layout Shift with Size Reservations

Dynamic content that loads without reserved space pushes existing elements around the page. Users clicking a button find their target has moved, and reading text gets interrupted. Reserving exact dimensions for images, ads, and dynamic embeds eliminates layout shifts.

**Incorrect (images load without dimensions, shifting content below):**

```tsx
function ArticlePage({ article }: { article: Article }) {
  return (
    <article>
      <h1>{article.headline}</h1>
      <img
        src={article.coverImageUrl}
        alt={article.coverAlt}
      />
      {/* content below shifts 300px down when image loads */}
      <p>{article.body}</p>

      <div className="ad-slot">
        <AdBanner slotId="article-mid" />
        {/* ad loads 250px tall, pushes footer down */}
      </div>

      <CommentSection articleId={article.id} />
    </article>
  )
}

// article.css
// .ad-slot {
//   /* no height reserved */
// }
```

**Correct (dimensions reserved, zero layout shift):**

```tsx
function ArticlePage({ article }: { article: Article }) {
  return (
    <article>
      <h1>{article.headline}</h1>
      <img
        src={article.coverImageUrl}
        alt={article.coverAlt}
        width={1200}
        height={630}
        style={{ aspectRatio: "1200 / 630", width: "100%", height: "auto" }}
      />
      <p>{article.body}</p>

      <div className="ad-slot">
        <AdBanner slotId="article-mid" />
      </div>

      <CommentSection articleId={article.id} />
    </article>
  )
}

// article.css
// .ad-slot {
//   min-height: 250px;  /* reserves space before ad loads */
//   contain: layout;
// }
```

Reference: [web.dev — Optimize CLS](https://web.dev/articles/optimize-cls)
