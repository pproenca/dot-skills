---
title: Use ARIA Labels for Icon-Only Buttons
impact: CRITICAL
impactDescription: makes UI comprehensible to screen reader users
tags: access, aria, screen-reader, labels, buttons
---

## Use ARIA Labels for Icon-Only Buttons

Provide text alternatives for buttons that only display icons. Screen readers announce nothing useful for unlabeled icon buttons.

**Incorrect (icon button with no accessible name):**

```html
<!-- popup.html - Screen reader announces "button" with no context -->
<button class="settings-btn">
  <svg viewBox="0 0 24 24">
    <path d="M19.14 12.94c.04-.31..."/>
  </svg>
</button>

<button class="close-btn">
  <span class="icon-x"></span>
</button>
<!-- Screen reader: "button" ... "button" - no information -->
```

**Correct (icon buttons with accessible names):**

```html
<!-- popup.html - Screen reader announces button purpose -->
<button class="settings-btn" aria-label="Open settings">
  <svg viewBox="0 0 24 24" aria-hidden="true">
    <path d="M19.14 12.94c.04-.31..."/>
  </svg>
</button>

<button class="close-btn" aria-label="Close panel">
  <span class="icon-x" aria-hidden="true"></span>
</button>
<!-- Screen reader: "Open settings, button" ... "Close panel, button" -->
```

**Alternative: visually hidden text:**

```html
<button class="settings-btn">
  <svg aria-hidden="true"><!-- icon --></svg>
  <span class="visually-hidden">Open settings</span>
</button>

<style>
.visually-hidden {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  white-space: nowrap;
  border: 0;
}
</style>
```

**Dynamic state in labels:**

```typescript
// Update label to reflect current state
function updateMuteButton(isMuted) {
  const button = document.getElementById('mute-btn')
  button.setAttribute('aria-label', isMuted ? 'Unmute audio' : 'Mute audio')
  button.setAttribute('aria-pressed', isMuted)
}
```

Reference: [WAI-ARIA Authoring Practices](https://www.w3.org/WAI/ARIA/apg/)
