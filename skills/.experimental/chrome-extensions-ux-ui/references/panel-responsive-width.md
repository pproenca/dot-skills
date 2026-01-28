---
title: Design for Variable Panel Widths
impact: HIGH
impactDescription: prevents layout breaking when users resize
tags: panel, responsive, width, resize, layout
---

## Design for Variable Panel Widths

Build side panel layouts that adapt to user-resized widths. Users can drag the panel edge to resize; fixed-width designs break when resized.

**Incorrect (fixed-width layout breaks):**

```css
/* sidepanel.css - Fixed widths break on resize */
.panel-container {
  width: 400px;
}

.two-column-layout {
  display: flex;
}

.sidebar {
  width: 150px;
}

.content {
  width: 250px;
}
/* User resizes to 300px → content overflows or gets clipped */
```

**Correct (fluid responsive layout):**

```css
/* sidepanel.css - Adapts to any width */
.panel-container {
  width: 100%;
  min-width: 200px;
  max-width: 100%;
}

.two-column-layout {
  display: flex;
  flex-wrap: wrap;
}

.sidebar {
  flex: 0 0 auto;
  width: 100%;
}

.content {
  flex: 1 1 auto;
  min-width: 0; /* Prevents flex item overflow */
}

/* Stack columns when narrow */
@media (min-width: 350px) {
  .sidebar {
    width: 120px;
  }
}

/* Text truncation for narrow widths */
.item-title {
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

/* Responsive spacing */
.panel-section {
  padding: clamp(8px, 3vw, 16px);
}
```

**JavaScript-based responsive adjustments:**

```typescript
// sidepanel.js - Adapt UI based on panel width
const panelContainer = document.querySelector('.panel-container')

const resizeObserver = new ResizeObserver((entries) => {
  for (const entry of entries) {
    const width = entry.contentRect.width

    panelContainer.classList.toggle('narrow', width < 280)
    panelContainer.classList.toggle('medium', width >= 280 && width < 400)
    panelContainer.classList.toggle('wide', width >= 400)
  }
})

resizeObserver.observe(panelContainer)
```

```css
/* Width-based UI adaptations */
.panel-container.narrow .secondary-info {
  display: none;
}

.panel-container.narrow .action-buttons {
  flex-direction: column;
}

.panel-container.wide .expanded-view {
  display: block;
}
```

Reference: [CSS Logical Properties](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_logical_properties_and_values)
