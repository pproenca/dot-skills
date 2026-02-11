---
title: Optimize Largest Contentful Paint with Priority Loading
impact: HIGH
impactDescription: 200-1000ms LCP improvement
tags: cwv, lcp, fetchpriority, preload, hero-image
---

## Optimize Largest Contentful Paint with Priority Loading

The LCP element (typically a hero image or heading) renders late when images use default lazy loading, fonts block rendering, or resources lack priority hints. Explicitly prioritizing the LCP resource tells the browser to fetch it before other assets.

**Incorrect (hero image loads with default priority, delayed by other resources):**

```tsx
function PropertyHero({ property }: { property: Property }) {
  return (
    <section className="hero">
      <img
        src={property.heroImageUrl}
        alt={property.title}
        loading="lazy" // defers the most important image on the page
      />
      <h1>{property.title}</h1>
      <p>{property.location}</p>
    </section>
  )
}

function PropertyPage({ property }: { property: Property }) {
  return (
    <>
      <head>
        <link rel="stylesheet" href="/fonts/custom-font.css" />
        {/* no preload hint — browser discovers hero image late */}
      </head>
      <PropertyHero property={property} />
      <PropertyDetails property={property} />
      <PropertyGallery images={property.galleryImages} />
    </>
  )
}
```

**Correct (LCP resources loaded with highest priority):**

```tsx
function PropertyHero({ property }: { property: Property }) {
  return (
    <section className="hero">
      <img
        src={property.heroImageUrl}
        alt={property.title}
        fetchPriority="high" // browser fetches this before lower-priority resources
        loading="eager"
        decoding="async"
      />
      <h1>{property.title}</h1>
      <p>{property.location}</p>
    </section>
  )
}

function PropertyPage({ property }: { property: Property }) {
  return (
    <>
      <head>
        <link
          rel="preload"
          href={property.heroImageUrl}
          as="image"
          fetchPriority="high"
        />
        <link
          rel="preload"
          href="/fonts/brand-heading.woff2"
          as="font"
          type="font/woff2"
          crossOrigin="anonymous"
        />
      </head>
      <PropertyHero property={property} />
      <PropertyDetails property={property} />
      <PropertyGallery images={property.galleryImages} />
    </>
  )
}
```

Reference: [web.dev — Optimize LCP](https://web.dev/articles/optimize-lcp)
