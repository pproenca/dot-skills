---
title: Design Mobile-First with min-width Queries
impact: HIGH
impactDescription: 20-30% smaller CSS, supports 60%+ mobile traffic
tags: resp, mobile-first, media-queries, css, responsive
---

## Design Mobile-First with min-width Queries

Mobile-first design starts with the smallest viewport and progressively enhances for larger screens. Desktop-first approaches often result in broken or cramped mobile experiences.

**Incorrect (desktop-first with max-width degradation):**

```css
/* Desktop styles first */
.navigation {
  display: flex;
  gap: 32px;
}

.card-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
}

/* Then override everything for mobile */
@media (max-width: 768px) {
  .navigation {
    display: none; /* Just hide it?! */
  }

  .card-grid {
    grid-template-columns: 1fr;
  }
}
/* Mobile is an afterthought, features hidden or broken */
```

**Correct (mobile-first with min-width enhancement):**

```css
/* Mobile styles are the base */
.navigation {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.card-grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 16px;
}

/* Enhance for tablet */
@media (min-width: 768px) {
  .navigation {
    flex-direction: row;
    gap: 24px;
  }

  .card-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

/* Enhance for desktop */
@media (min-width: 1024px) {
  .card-grid {
    grid-template-columns: repeat(4, 1fr);
    gap: 24px;
  }
}
/* Mobile experience is complete, larger screens get enhancements */
```

**Mobile-first benefits:**
- Forces prioritization of essential content
- Smaller base CSS file (add vs. override)
- Better performance on slower mobile connections
- Aligns with Google's mobile-first indexing

Reference: [Google Mobile-First Indexing](https://developers.google.com/search/docs/crawling-indexing/mobile/mobile-sites-mobile-first-indexing)
