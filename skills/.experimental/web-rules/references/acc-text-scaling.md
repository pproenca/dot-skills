---
title: All Text Scales to 200% Browser Zoom Without Horizontal Scroll
impact: CRITICAL
impactDescription: WCAG 1.4.4 requires 200% zoom support; ~7% of users override default browser text size; failing this excludes low-vision users entirely
tags: acc, text-scaling, zoom, rem, responsive, wcag-1-4-4
---

## All Text Scales to 200% Browser Zoom Without Horizontal Scroll

When a user zooms to 200%, every layout must reflow without producing horizontal scroll (except for explicitly horizontal content like data tables). The cause of failures is almost always: text sized in `px` instead of `rem`, fixed-width containers in `px`, or `overflow: hidden` swallowing the resized content. Use `rem` for typography and Tailwind's responsive utilities for layout.

**Incorrect (fixed-px text, fixed-width container, overflow-hidden hides resized content):**

```tsx
function Card() {
  return (
    <div className="w-[400px] overflow-hidden" style={{ fontSize: '14px' }}>
      <h2 style={{ fontSize: '18px' }}>Title</h2>
      <p style={{ fontSize: '14px' }}>Body copy that won't grow.</p>
    </div>
  )
}
```

**Correct (rem-based text, fluid width, allows reflow):**

```tsx
function Card() {
  return (
    <div className="w-full max-w-md">
      <h2 className="text-lg font-semibold">Title</h2>
      <p className="text-sm text-muted-foreground">
        Body copy that grows with the user's preferred text size.
      </p>
    </div>
  )
}
```

**Tailwind text sizes are rem-based by default:**

```text
text-xs   → 0.75rem  (12px at default)
text-sm   → 0.875rem (14px)
text-base → 1rem     (16px) ← matches user's browser setting
text-lg   → 1.125rem (18px)
text-xl   → 1.25rem  (20px)
```

**Container patterns that reflow correctly:**

```tsx
// Use min-h instead of h for content containers
<aside className="min-h-svh w-64 shrink-0">...</aside>

// Use grid with minmax for fluid columns
<div className="grid grid-cols-[minmax(0,1fr)_auto] gap-4">
  <main className="min-w-0">{/* min-w-0 prevents overflow */}</main>
  <aside>...</aside>
</div>

// Container queries when components must adapt at their own size
<div className="@container">
  <div className="grid @md:grid-cols-2 gap-4">...</div>
</div>
```

**Rule:**
- Never set `font-size` in `px` — use Tailwind's text sizes or `rem` values
- Never set fixed `width` in `px` on text containers; use `max-w-*` or fluid grid tracks
- `min-w-0` on flex/grid children that contain text — prevents the "intrinsic min-content" trap
- Test at 200% browser zoom (Cmd/Ctrl + `=` four times) and verify no horizontal scroll on the document
- Use the Lighthouse accessibility audit "Document doesn't use 'user-scalable' meta tag" to catch zoom-blocking viewport configs

Reference: [WCAG 1.4.4 Resize Text](https://www.w3.org/WAI/WCAG22/Understanding/resize-text.html)
