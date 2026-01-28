---
title: Design Within Popup Size Limits
impact: HIGH
impactDescription: prevents content clipping and scroll issues
tags: popup, size, dimensions, layout, constraints
---

## Design Within Popup Size Limits

Design popup content to fit within Chrome's enforced size constraints (min 25×25px, max 800×600px). Content exceeding these limits gets clipped or requires scrolling that users don't expect.

**Incorrect (content exceeds popup limits):**

```html
<!-- popup.html - Content designed for larger viewport -->
<div class="popup-container" style="width: 900px; height: 700px;">
  <div class="dashboard">
    <aside class="sidebar" style="width: 200px;">Navigation</aside>
    <main class="content" style="width: 700px;">
      <!-- Long scrolling content list -->
    </main>
  </div>
</div>
<!-- Chrome clips to 800×600, layout breaks, content hidden -->
```

**Correct (responsive design within limits):**

```html
<!-- popup.html - Designed for constrained space -->
<div class="popup-container">
  <header class="compact-header">
    <h1>Extension Name</h1>
    <button class="settings-btn" aria-label="Settings"></button>
  </header>
  <main class="content">
    <!-- Prioritized, scannable content -->
  </main>
  <footer class="actions">
    <button class="primary">Main Action</button>
  </footer>
</div>

<style>
.popup-container {
  width: 350px;      /* Comfortable reading width */
  max-height: 500px; /* Leave room for browser chrome */
  overflow-y: auto;
}

/* Responsive for smaller content */
@media (max-width: 400px) {
  .popup-container {
    width: 280px;
  }
}
</style>
```

**Recommended popup dimensions:**

| Use Case | Width | Height |
|----------|-------|--------|
| Simple action | 200-280px | 150-250px |
| List/feed | 300-400px | 400-500px |
| Settings panel | 350-450px | 350-500px |
| Maximum practical | 600px | 500px |

**Auto-sizing popup:**

```css
/* Let content determine size within bounds */
.popup-container {
  min-width: 200px;
  max-width: 500px;
  max-height: 500px;
  width: fit-content;
}
```

Reference: [Add a Popup](https://developer.chrome.com/docs/extensions/develop/ui/add-popup)
