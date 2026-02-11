---
title: Use CSS Containment to Isolate Layout Recalculation
impact: HIGH
impactDescription: reduces layout recalculation scope by 60-90%
tags: render, css-containment, layout, browser-optimization
---

## Use CSS Containment to Isolate Layout Recalculation

By default, any DOM change triggers layout recalculation for the entire document. CSS `contain` tells the browser that an element's internals are independent from the rest of the page, allowing the engine to skip recalculating layout, paint, and style outside the contained subtree.

**Incorrect (sidebar toggle triggers full-page layout recalculation):**

```tsx
function DashboardPanel({ widgets }: { widgets: Widget[] }) {
  const [collapsed, setCollapsed] = useState(false)

  return (
    <div className="dashboard-panel">
      <button onClick={() => setCollapsed(!collapsed)}>
        {collapsed ? "Expand" : "Collapse"}
      </button>
      <div className="widget-grid">
        {widgets.map((widget) => (
          <div key={widget.id} className="widget-card">
            {/* height changes here recalculate layout for entire page */}
            <WidgetContent widget={widget} collapsed={collapsed} />
          </div>
        ))}
      </div>
    </div>
  )
}

// dashboard-panel.css
// .widget-card {
//   padding: 16px;
//   border: 1px solid #e5e7eb;
// }
```

**Correct (containment isolates layout recalculation to each card):**

```tsx
function DashboardPanel({ widgets }: { widgets: Widget[] }) {
  const [collapsed, setCollapsed] = useState(false)

  return (
    <div className="dashboard-panel">
      <button onClick={() => setCollapsed(!collapsed)}>
        {collapsed ? "Expand" : "Collapse"}
      </button>
      <div className="widget-grid">
        {widgets.map((widget) => (
          <div key={widget.id} className="widget-card">
            <WidgetContent widget={widget} collapsed={collapsed} />
          </div>
        ))}
      </div>
    </div>
  )
}

// dashboard-panel.css
// .widget-card {
//   contain: layout style paint;  /* browser skips recalc outside this subtree */
//   padding: 16px;
//   border: 1px solid #e5e7eb;
// }
//
// .widget-grid {
//   content-visibility: auto;  /* offscreen cards skip rendering entirely */
//   contain-intrinsic-size: 0 300px;
// }
```

Reference: [CSS Containment — MDN](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_containment)
