---
title: CSS Variables Documentation File
impact: LOW
impactDescription: documents CSS custom properties for consumer styling
tags: org, css, variables, documentation
---

## CSS Variables Documentation File

Create dedicated `CssVars.ts` files to document CSS custom properties exposed by components.

**Incorrect (undocumented CSS vars):**

```typescript
// CSS vars set in component with no documentation
element.style.setProperty('--collapsible-panel-height', `${height}px`)
```

**Correct (dedicated documentation):**

```typescript
// collapsible/panel/CollapsiblePanelCssVars.ts
export enum CollapsiblePanelCssVars {
  /**
   * The height of the panel's content.
   * Useful for CSS transitions on height.
   * @type {string}
   */
  height = '--collapsible-panel-height',

  /**
   * The width of the panel's content.
   * @type {string}
   */
  width = '--collapsible-panel-width',
}

// Usage in CSS:
// .panel {
//   height: var(--collapsible-panel-height);
//   transition: height 200ms ease;
// }
```

**When to use:**
- Components that expose CSS custom properties for animation/styling
- Collapsible panels, progress bars, sliders
