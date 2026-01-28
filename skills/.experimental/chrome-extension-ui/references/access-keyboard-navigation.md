---
title: Enable Complete Keyboard Navigation
impact: CRITICAL
impactDescription: required for accessibility compliance
tags: access, keyboard, navigation, tabindex, focus
---

## Enable Complete Keyboard Navigation

Ensure every interactive element is reachable and operable via keyboard. Users who cannot use a mouse, and power users who prefer keyboard, must access all features.

**Incorrect (keyboard users blocked):**

```html
<!-- popup.html - Custom buttons not keyboard accessible -->
<div class="toolbar">
  <div class="icon-button" onclick="handleSave()">
    <img src="save.svg" alt="Save">
  </div>
  <div class="icon-button" onclick="handleShare()">
    <img src="share.svg" alt="Share">
  </div>
  <div class="icon-button" onclick="handleDelete()">
    <img src="delete.svg" alt="Delete">
  </div>
</div>
<!-- Keyboard user: Tab key skips these entirely -->
```

**Correct (full keyboard support):**

```html
<!-- popup.html - All buttons keyboard accessible -->
<div class="toolbar" role="toolbar" aria-label="Actions">
  <button type="button" class="icon-button" onclick="handleSave()">
    <img src="save.svg" alt="">
    <span class="visually-hidden">Save</span>
  </button>
  <button type="button" class="icon-button" onclick="handleShare()">
    <img src="share.svg" alt="">
    <span class="visually-hidden">Share</span>
  </button>
  <button type="button" class="icon-button" onclick="handleDelete()">
    <img src="delete.svg" alt="">
    <span class="visually-hidden">Delete</span>
  </button>
</div>
<!-- Keyboard user: Tab navigates to each button, Enter/Space activates -->
```

**Custom element keyboard support:**

```typescript
// For custom interactive elements, add tabindex and key handlers
const customDropdown = document.querySelector('.custom-dropdown')
customDropdown.setAttribute('tabindex', '0')
customDropdown.setAttribute('role', 'combobox')

customDropdown.addEventListener('keydown', (event) => {
  switch (event.key) {
    case 'Enter':
    case ' ':
      toggleDropdown()
      event.preventDefault()
      break
    case 'ArrowDown':
      selectNextOption()
      event.preventDefault()
      break
    case 'ArrowUp':
      selectPreviousOption()
      event.preventDefault()
      break
    case 'Escape':
      closeDropdown()
      break
  }
})
```

Reference: [Support Accessibility](https://developer.chrome.com/docs/extensions/mv3/a11y/)
