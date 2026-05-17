---
title: Extract Parent Padding from Frame Insets, Not Child Margin
impact: CRITICAL
impactDescription: prevents 100% of margin-collapse bugs and :first/:last-child fragility under conditional render
tags: layout, padding-vs-margin, margin-collapsing, frame-insets
---

## Extract Parent Padding from Frame Insets, Not Child Margin

When Sketch children are inset from their parent group's frame, the geometric truth could be expressed as either parent padding OR child margins — but CSS margin collapsing makes margins inside flex/grid containers behave inconsistently across axes, and `:first-child` / `:last-child` margin tricks break under conditional rendering. Always express the inset as parent padding. Margin should be the exception (e.g., a single asymmetric override), not the rule.

The padding values are computed from the bounding-box gap between the parent's frame and the *outer* hull of its children:

```text
padding-top    = min(children.frame.y)
padding-left   = min(children.frame.x)
padding-right  = parent.width  - max(child.x + child.width)
padding-bottom = parent.height - max(child.y + child.height)
```

**Incorrect (margins on children):**

```css
.card { display: flex; flex-direction: column; }
.card > :first-child { margin-top: 16px; margin-left: 16px; margin-right: 16px; }
.card > :last-child  { margin-bottom: 16px; margin-left: 16px; margin-right: 16px; }
.card > :not(:first-child):not(:last-child) { margin: 0 16px; }
/* Conditional render dropping the first child: top inset disappears.
   margin-top of a column-flex first child also doesn't collapse — but the
   author had to know that. This is fragile. */
```

**Correct (padding on parent):**

```ts
function computeParentPadding(group: Group): { top: number; right: number; bottom: number; left: number } {
  const kids = group.layers;
  return {
    top:    Math.min(...kids.map(k => k.frame.y)),
    left:   Math.min(...kids.map(k => k.frame.x)),
    right:  group.frame.width  - Math.max(...kids.map(k => k.frame.x + k.frame.width)),
    bottom: group.frame.height - Math.max(...kids.map(k => k.frame.y + k.frame.height)),
  };
}

// After computing padding, REBASE the children's coordinates so x/y are
// relative to the content box, not the padding box.
function rebaseToContentBox(group: Group, padding: { top: number; left: number }): Layer[] {
  return group.layers.map(k => ({
    ...k,
    frame: { ...k.frame, x: k.frame.x - padding.left, y: k.frame.y - padding.top },
  }));
}
```

```css
.card {
  display: flex;
  flex-direction: column;
  padding: 16px;
  gap: 8px;
}
/* Reorder-safe, conditional-render-safe, and the inset doesn't depend on
   any child existing. */
```

**Why rebasing matters:** if you emit `padding: 16px` AND keep children's frames in parent-relative coordinates that already include the 16px offset, you get double padding. Always rebase after extracting padding.

**When margin IS correct:** when a single child needs an asymmetric inset that the others don't share (e.g., a "negative space" placeholder), express it as that child's margin. The default is padding; margin is the escape valve.

Reference: [MDN — Mastering margin collapsing](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_box_model/Mastering_margin_collapsing)
