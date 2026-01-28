---
title: Lazy Load Panel Sections
impact: HIGH
impactDescription: 50-80% faster initial panel render
tags: panel, lazy-loading, performance, sections, optimization
---

## Lazy Load Panel Sections

Load only visible panel sections initially. Defer loading of collapsed or below-the-fold sections until users need them.

**Incorrect (loads all sections upfront):**

```typescript
// sidepanel.js - Fetches everything on open
document.addEventListener('DOMContentLoaded', async () => {
  // All these run before user sees anything
  const recentItems = await fetchRecentItems()      // 200ms
  const savedPages = await fetchSavedPages()        // 300ms
  const analytics = await fetchAnalytics()          // 400ms
  const recommendations = await fetchRecommendations() // 500ms

  renderRecentItems(recentItems)
  renderSavedPages(savedPages)
  renderAnalytics(analytics)
  renderRecommendations(recommendations)
})
// Total: 1.4s before panel is usable
```

**Correct (load sections on demand):**

```typescript
// sidepanel.js - Load primary section immediately, defer rest
document.addEventListener('DOMContentLoaded', async () => {
  // Load only the most important section immediately
  const recentItems = await fetchRecentItems()
  renderRecentItems(recentItems)
  // Panel usable in 200ms

  // Set up lazy loading for other sections
  setupLazySection('saved-pages', fetchSavedPages, renderSavedPages)
  setupLazySection('analytics', fetchAnalytics, renderAnalytics)
  setupLazySection('recommendations', fetchRecommendations, renderRecommendations)
})

function setupLazySection(sectionId, fetchFn, renderFn) {
  const section = document.getElementById(sectionId)
  const header = section.querySelector('.section-header')
  let loaded = false

  // Load when section is expanded
  header.addEventListener('click', async () => {
    const isExpanded = section.classList.toggle('expanded')

    if (isExpanded && !loaded) {
      section.querySelector('.content').innerHTML = '<div class="loading">Loading...</div>'
      const data = await fetchFn()
      renderFn(data)
      loaded = true
    }
  })
}
```

**Intersection Observer for scroll-based loading:**

```typescript
// sidepanel.js - Load when section scrolls into view
function setupScrollLazyLoading() {
  const lazySections = document.querySelectorAll('[data-lazy-section]')

  const observer = new IntersectionObserver((entries) => {
    entries.forEach(async (entry) => {
      if (entry.isIntersecting) {
        const section = entry.target
        const sectionType = section.dataset.lazySection

        // Stop observing this section
        observer.unobserve(section)

        // Load content
        section.innerHTML = '<div class="loading">Loading...</div>'
        const data = await loadSectionData(sectionType)
        renderSection(section, data)
      }
    })
  }, {
    rootMargin: '100px' // Start loading slightly before visible
  })

  lazySections.forEach(section => observer.observe(section))
}
```

```html
<!-- sidepanel.html - Mark sections for lazy loading -->
<section id="recent" class="panel-section">
  <!-- Loaded immediately -->
</section>

<section data-lazy-section="saved" class="panel-section">
  <div class="placeholder">Saved items will load here</div>
</section>

<section data-lazy-section="analytics" class="panel-section">
  <div class="placeholder">Analytics will load here</div>
</section>
```

Reference: [Intersection Observer API](https://developer.mozilla.org/en-US/docs/Web/API/Intersection_Observer_API)
