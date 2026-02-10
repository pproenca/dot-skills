---
title: Handle SPA Navigation with wxt:locationchange
impact: HIGH
impactDescription: prevents content script from breaking on SPA page transitions
tags: inject, spa, navigation, locationchange, match-pattern
---

## Handle SPA Navigation with wxt:locationchange

Content scripts don't re-execute on SPA (Single Page Application) navigation because the page doesn't fully reload. Use WXT's `wxt:locationchange` event to detect URL changes and re-run logic.

**Incorrect (only runs on initial page load):**

```typescript
export default defineContentScript({
  matches: ['*://*.youtube.com/watch*'],
  main(ctx) {
    // Only runs once on initial page load
    // Breaks when user navigates between videos via SPA
    const videoId = new URL(location.href).searchParams.get('v')
    injectOverlay(videoId)
  }
})
```

**Correct (react to SPA navigation):**

```typescript
export default defineContentScript({
  matches: ['*://*.youtube.com/*'],
  main(ctx) {
    const watchPattern = new MatchPattern('*://*.youtube.com/watch*')

    // Run on initial load if URL matches
    if (watchPattern.includes(location.href)) {
      mountVideoOverlay(ctx)
    }

    // React to SPA navigation
    ctx.addEventListener(window, 'wxt:locationchange', ({ newUrl }) => {
      if (watchPattern.includes(newUrl)) {
        mountVideoOverlay(ctx)
      }
    })
  }
})

function mountVideoOverlay(ctx: ContentScriptContext) {
  const videoId = new URL(location.href).searchParams.get('v')
  if (!videoId) return

  const ui = createIntegratedUi(ctx, {
    position: 'inline',
    anchor: '#movie_player',
    onMount: (container) => {
      container.textContent = `Overlay for ${videoId}`
    }
  })
  ui.mount()
}
```

**For dynamic elements, use autoMount():**

```typescript
export default defineContentScript({
  matches: ['*://*/*'],
  main(ctx) {
    const ui = createIntegratedUi(ctx, {
      position: 'inline',
      anchor: '#dynamic-target',
      onMount: (container) => {
        container.textContent = 'Mounted!'
      }
    })

    // Automatically mount/unmount as anchor appears/disappears
    ui.autoMount()
  }
})
```

**Key points:**
- Use broad `matches` pattern, then filter with `MatchPattern` inside the handler
- `wxt:locationchange` fires on both pushState and replaceState navigation
- `autoMount()` uses MutationObserver internally to handle dynamic DOM elements
- Use `ctx.addEventListener` for auto-cleanup on context invalidation

Reference: [WXT Content Scripts - SPAs](https://wxt.dev/guide/essentials/content-scripts)
