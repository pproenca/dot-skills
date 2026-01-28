---
title: Render Popup Content Instantly
impact: HIGH
impactDescription: 200-500ms perceived as laggy by users
tags: popup, performance, loading, instant, perceived-speed
---

## Render Popup Content Instantly

Display meaningful content immediately when the popup opens. Users perceive delays over 100ms as laggy. Fetch data after rendering the initial UI.

**Incorrect (popup waits for data before rendering):**

```typescript
// popup.js - Blank popup while fetching
document.addEventListener('DOMContentLoaded', async () => {
  const container = document.getElementById('content')

  // Nothing visible while this runs
  const data = await fetch('https://api.example.com/data')
  const items = await data.json()

  container.innerHTML = items.map(item => `
    <div class="item">${item.name}</div>
  `).join('')
})
// User sees empty popup for 500ms-2s
```

**Correct (instant shell, then populate):**

```typescript
// popup.js - Immediate skeleton, then hydrate
document.addEventListener('DOMContentLoaded', async () => {
  const container = document.getElementById('content')

  // Show skeleton immediately (already in HTML or inject fast)
  container.innerHTML = `
    <div class="skeleton-item"></div>
    <div class="skeleton-item"></div>
    <div class="skeleton-item"></div>
  `

  // Fetch and replace
  try {
    const data = await fetch('https://api.example.com/data')
    const items = await data.json()

    container.innerHTML = items.map(item => `
      <div class="item">${item.name}</div>
    `).join('')
  } catch (error) {
    container.innerHTML = `
      <div class="error">Unable to load. <button onclick="location.reload()">Retry</button></div>
    `
  }
})
```

**Even better - cache and show stale while revalidating:**

```typescript
// popup.js - Show cached immediately, update in background
document.addEventListener('DOMContentLoaded', async () => {
  const container = document.getElementById('content')

  // Render cached data instantly
  const cached = await chrome.storage.local.get('cachedItems')
  if (cached.cachedItems) {
    renderItems(cached.cachedItems)
  } else {
    showSkeleton()
  }

  // Fetch fresh data in background
  try {
    const response = await fetch('https://api.example.com/data')
    const freshItems = await response.json()
    await chrome.storage.local.set({ cachedItems: freshItems })
    renderItems(freshItems)  // Update UI with fresh data
  } catch (error) {
    if (!cached.cachedItems) {
      showError()
    }
    // If we have cache, silently keep showing it
  }
})
```

Reference: [Extension Performance](https://developer.chrome.com/docs/extensions/develop/concepts/performance)
