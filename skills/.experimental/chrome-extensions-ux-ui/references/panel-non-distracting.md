---
title: Design Non-Distracting Side Panels
impact: HIGH
impactDescription: increases session duration by 3-5×
tags: panel, distraction-free, focus, user-experience, side-panel
---

## Design Non-Distracting Side Panels

Design side panels to enhance browsing without competing for attention. Panels that distract from page content get closed quickly and rarely reopened.

**Incorrect (attention-grabbing panel):**

```html
<!-- sidepanel.html - Competes with page content -->
<div class="panel">
  <div class="animated-banner">
    <span class="pulse">NEW FEATURE!</span>
  </div>

  <div class="notification-badge">3</div>

  <div class="auto-playing-content">
    <!-- Carousel that auto-advances -->
  </div>
</div>

<style>
.pulse {
  animation: pulse 1s infinite;
  background: linear-gradient(90deg, #ff0000, #ff6600);
  color: white;
}

@keyframes pulse {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.1); }
}
/* User's eyes pulled away from page content */
</style>
```

**Correct (complementary panel):**

```html
<!-- sidepanel.html - Supports browsing workflow -->
<div class="panel">
  <header class="panel-header">
    <h1>Research Notes</h1>
    <button class="minimize-btn" aria-label="Minimize panel">−</button>
  </header>

  <main class="panel-content">
    <div class="current-page-section">
      <h2>This Page</h2>
      <div id="page-notes"></div>
    </div>

    <div class="saved-section">
      <h2>Saved Highlights</h2>
      <ul id="highlights-list"></ul>
    </div>
  </main>
</div>

<style>
.panel {
  background: #fafafa;
  color: #333;
  font-size: 14px;
}

.panel-header {
  padding: 12px 16px;
  border-bottom: 1px solid #e0e0e0;
  background: white;
}

.panel-header h1 {
  font-size: 16px;
  font-weight: 500;
  margin: 0;
}
/* Subtle, professional, doesn't fight for attention */
</style>
```

**Non-distracting panel guidelines:**
- No animations unless user-initiated
- Muted color palette (complement browser chrome)
- No auto-playing media
- Notification badges only for user-relevant updates
- Easy minimize/collapse option

Reference: [Designing a Superior User Experience with Side Panel](https://developer.chrome.com/blog/designing-a-superior-user-experience-with-the-new-side-panel-api)
