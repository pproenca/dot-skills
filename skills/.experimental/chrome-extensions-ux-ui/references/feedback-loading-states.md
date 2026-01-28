---
title: Show Loading States for Async Operations
impact: MEDIUM
impactDescription: reduces perceived wait time by 40%
tags: feedback, loading, skeleton, async, perceived-performance
---

## Show Loading States for Async Operations

Display immediate feedback when operations take more than 100ms. Users perceive unresponsive UI as broken; loading indicators set expectations.

**Incorrect (no feedback during loading):**

```typescript
// popup.js - User sees nothing while data loads
async function loadData() {
  const response = await fetch('https://api.example.com/data')
  const data = await response.json()
  renderData(data)
}

document.addEventListener('DOMContentLoaded', loadData)
// User: clicks extension → blank screen for 2 seconds → content appears
// User thinks: "Is it broken?"
```

**Correct (immediate loading feedback):**

```typescript
// popup.js - Clear loading indication
async function loadData() {
  const container = document.getElementById('content')

  // Show loading state immediately
  container.innerHTML = `
    <div class="loading-state">
      <div class="spinner" role="status" aria-label="Loading"></div>
      <p>Loading your data...</p>
    </div>
  `

  try {
    const response = await fetch('https://api.example.com/data')
    const data = await response.json()
    renderData(data)
  } catch (error) {
    container.innerHTML = `
      <div class="error-state">
        <p>Unable to load data</p>
        <button onclick="loadData()">Try again</button>
      </div>
    `
  }
}
```

**Skeleton loading for better UX:**

```typescript
// popup.js - Skeleton screens reduce perceived wait
function showSkeleton() {
  return `
    <div class="item-skeleton">
      <div class="skeleton-avatar"></div>
      <div class="skeleton-lines">
        <div class="skeleton-line" style="width: 80%"></div>
        <div class="skeleton-line" style="width: 60%"></div>
      </div>
    </div>
    <div class="item-skeleton">
      <div class="skeleton-avatar"></div>
      <div class="skeleton-lines">
        <div class="skeleton-line" style="width: 70%"></div>
        <div class="skeleton-line" style="width: 50%"></div>
      </div>
    </div>
  `
}

// CSS for skeleton animation
const skeletonStyles = `
  .skeleton-avatar, .skeleton-line {
    background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%);
    background-size: 200% 100%;
    animation: shimmer 1.5s infinite;
  }

  @keyframes shimmer {
    0% { background-position: 200% 0; }
    100% { background-position: -200% 0; }
  }
`
```

**Button loading state:**

```typescript
// popup.js - Disable and indicate loading on buttons
async function handleSubmit(event) {
  const button = event.target
  const originalText = button.textContent

  button.disabled = true
  button.innerHTML = '<span class="spinner-small"></span> Saving...'

  try {
    await saveData()
    button.textContent = 'Saved!'
    setTimeout(() => {
      button.textContent = originalText
      button.disabled = false
    }, 1500)
  } catch (error) {
    button.textContent = 'Failed - Retry'
    button.disabled = false
  }
}
```

Reference: [UX Pattern Analysis: Loading](https://www.pencilandpaper.io/articles/ux-pattern-analysis-loading-feedback)
