---
title: Use Maximum Z-Index for Overlays
impact: MEDIUM-HIGH
impactDescription: ensures UI visibility on all websites
tags: inject, z-index, overlay, visibility, stacking-context
---

## Use Maximum Z-Index for Overlays

Set z-index to the maximum value (2147483647) for injected overlays. Many sites use high z-index values that can hide your extension's UI.

**Incorrect (arbitrary z-index gets buried):**

```css
/* toolbar.css - Arbitrary z-index */
.extension-overlay {
  position: fixed;
  z-index: 9999;
}

/* Problem: Many sites use z-index: 10000+ for modals/toasts */
/* Your overlay disappears behind site elements */
```

**Correct (maximum z-index guarantees visibility):**

```css
/* toolbar.css - Maximum possible z-index */
.extension-overlay {
  position: fixed;
  z-index: 2147483647; /* Maximum 32-bit signed integer */
}

/* Create stacking context to contain children */
.extension-root {
  position: fixed;
  z-index: 2147483647;
  isolation: isolate; /* Creates new stacking context */
}

.extension-modal {
  z-index: 2; /* Relative to .extension-root */
}

.extension-tooltip {
  z-index: 3; /* Above modal within same context */
}
```

**Managing multiple overlay layers:**

```typescript
// content.js - Layered UI system
const Z_BASE = 2147483647

function createOverlaySystem() {
  const root = document.createElement('div')
  root.id = 'extension-overlay-root'
  root.style.cssText = `
    position: fixed;
    top: 0;
    left: 0;
    z-index: ${Z_BASE};
    pointer-events: none;
  `

  // Layer definitions within the root
  const layers = {
    toolbar: createLayer(1),
    tooltip: createLayer(2),
    modal: createLayer(3),
    notification: createLayer(4)
  }

  function createLayer(level) {
    const layer = document.createElement('div')
    layer.style.cssText = `
      position: fixed;
      z-index: ${level};
      pointer-events: auto;
    `
    root.appendChild(layer)
    return layer
  }

  document.body.appendChild(root)
  return layers
}

// Usage
const layers = createOverlaySystem()
layers.toolbar.appendChild(toolbarElement)
layers.modal.appendChild(modalElement)
```

**Handling sites with `!important`:**

```css
/* Sometimes you need !important to override aggressive sites */
.extension-overlay {
  position: fixed !important;
  z-index: 2147483647 !important;
  display: block !important;
}
```

Reference: [CSS z-index](https://developer.mozilla.org/en-US/docs/Web/CSS/z-index)
