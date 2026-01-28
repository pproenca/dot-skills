---
title: Make the Primary Action Obvious
impact: HIGH
impactDescription: reduces time-to-action by 60-80%
tags: popup, primary-action, cta, visual-hierarchy, ux
---

## Make the Primary Action Obvious

Design popups with a single, visually prominent primary action. Users open popups with intent—make the main action impossible to miss.

**Incorrect (competing actions, unclear hierarchy):**

```html
<!-- popup.html - No clear primary action -->
<div class="popup-actions">
  <button class="btn">Save</button>
  <button class="btn">Share</button>
  <button class="btn">Copy</button>
  <button class="btn">Download</button>
  <button class="btn">Settings</button>
</div>

<style>
.btn {
  padding: 8px 16px;
  background: #f0f0f0;
  border: 1px solid #ccc;
}
/* All buttons look identical - user hesitates */
</style>
```

**Correct (clear visual hierarchy):**

```html
<!-- popup.html - Obvious primary action -->
<div class="popup-content">
  <div class="quick-actions">
    <button class="btn-primary">Save to Collection</button>
  </div>

  <div class="secondary-actions">
    <button class="btn-secondary" aria-label="Share">
      <svg aria-hidden="true"><!-- share icon --></svg>
    </button>
    <button class="btn-secondary" aria-label="Copy link">
      <svg aria-hidden="true"><!-- copy icon --></svg>
    </button>
    <button class="btn-secondary" aria-label="Download">
      <svg aria-hidden="true"><!-- download icon --></svg>
    </button>
  </div>

  <a href="#" class="settings-link">Settings</a>
</div>

<style>
.btn-primary {
  width: 100%;
  padding: 12px 24px;
  background: #4A90D9;
  color: white;
  font-weight: 600;
  font-size: 16px;
  border: none;
  border-radius: 8px;
}

.btn-secondary {
  padding: 8px;
  background: transparent;
  border: 1px solid #ddd;
  border-radius: 4px;
}

.settings-link {
  font-size: 12px;
  color: #666;
}
/* Primary action dominates, secondary actions accessible but subdued */
</style>
```

**Visual hierarchy principles:**
- Primary action: Largest, boldest, prominent color
- Secondary actions: Smaller, muted colors or outlined
- Tertiary actions: Text links or icon-only buttons
- Maximum one primary action per popup

Reference: [Designing a Superior User Experience](https://developer.chrome.com/blog/designing-a-superior-user-experience-with-the-new-side-panel-api)
