---
title: Avoid Layout Thrashing in Content Scripts
impact: MEDIUM
impactDescription: reduces page reflows by 80-90%
tags: ui, layout, reflow, performance, dom
---

## Avoid Layout Thrashing in Content Scripts

Reading layout properties then writing causes forced synchronous reflows. Batch reads and writes separately to avoid layout thrashing on host pages.

**Incorrect (interleaved reads and writes):**

```typescript
export default defineContentScript({
  matches: ['*://*/*'],
  main() {
    const elements = document.querySelectorAll('.product-card')

    elements.forEach((el) => {
      // Read triggers layout
      const height = el.offsetHeight

      // Write invalidates layout
      el.style.minHeight = `${height + 20}px`

      // Next iteration: read triggers layout again
      // N elements = N forced reflows
    })
  }
})
```

**Correct (batched reads then writes):**

```typescript
export default defineContentScript({
  matches: ['*://*/*'],
  main() {
    const elements = document.querySelectorAll('.product-card')

    // Batch all reads first
    const heights = Array.from(elements).map((el) => el.offsetHeight)

    // Then batch all writes
    elements.forEach((el, i) => {
      el.style.minHeight = `${heights[i] + 20}px`
    })
    // Only 1 reflow total
  }
})
```

**Alternative (requestAnimationFrame for complex updates):**

```typescript
export default defineContentScript({
  matches: ['*://*/*'],
  main() {
    const elements = document.querySelectorAll('.product-card')

    // Read phase in current frame
    const updates: Array<{ el: Element; height: number }> = []
    elements.forEach((el) => {
      updates.push({ el, height: el.offsetHeight })
    })

    // Write phase in next frame
    requestAnimationFrame(() => {
      updates.forEach(({ el, height }) => {
        (el as HTMLElement).style.minHeight = `${height + 20}px`
      })
    })
  }
})
```

**Layout-triggering properties to batch:**
- `offsetWidth`, `offsetHeight`, `offsetTop`, `offsetLeft`
- `clientWidth`, `clientHeight`
- `scrollWidth`, `scrollHeight`, `scrollTop`, `scrollLeft`
- `getComputedStyle()`, `getBoundingClientRect()`

Reference: [What forces layout/reflow](https://gist.github.com/paulirish/5d52fb081b3570c81e3a)
