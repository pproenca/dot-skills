---
title: Every Layout Works at 320 px Width Without Horizontal Scroll
impact: CRITICAL
impactDescription: WCAG 1.4.10 (Reflow) requires content to reflow at 320 px wide; ~5% of mobile traffic is on phones ≤ 360 px; horizontal scroll is the #1 cause of mobile bounce
tags: acc, responsive, reflow, mobile, container-queries, wcag-1-4-10
---

## Every Layout Works at 320 px Width Without Horizontal Scroll

320 px is the WCAG 1.4.10 reflow target. At that width, content reflows to a single column; tables and figures with `overflow-x-auto` are exceptions. Use Tailwind's mobile-first breakpoints (`sm:`, `md:`, `lg:`) — start with the mobile layout and add wider-viewport variants. For components that should react to *their own* width (rather than the viewport's), use container queries (`@container` + `@md:`).

**Incorrect (desktop-first layout, fixed-width content, no mobile breakpoint):**

```tsx
function Dashboard() {
  return (
    <div className="flex gap-8">
      <aside className="w-64 shrink-0">Sidebar</aside>
      <main className="w-[800px]">{/* fixed-width — overflows at 320px */}
        <div className="grid grid-cols-3 gap-4">
          {items.map((i) => <Card key={i.id} item={i} />)}
        </div>
      </main>
    </div>
  )
}
```

**Correct (mobile-first, fluid widths, breakpoints add complexity at wider sizes):**

```tsx
function Dashboard() {
  return (
    <div className="flex flex-col md:flex-row md:gap-8 md:p-6">
      <aside className="md:w-64 md:shrink-0 border-b md:border-b-0 md:border-r">
        <Sidebar />
      </aside>
      <main className="flex-1 min-w-0 p-4 md:p-0">
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {items.map((i) => <Card key={i.id} item={i} />)}
        </div>
      </main>
    </div>
  )
}
```

**Container queries — when a component must adapt at its own size:**

```tsx
// Card adapts based on its parent's width, not the viewport
function Card({ item }: { item: Item }) {
  return (
    <article className="@container rounded-lg border p-4">
      <div className="flex flex-col @md:flex-row @md:items-start gap-3">
        <img src={item.image} className="w-full @md:w-24 aspect-video @md:aspect-square rounded" />
        <div className="min-w-0">
          <h3 className="font-semibold truncate">{item.title}</h3>
          <p className="text-sm text-muted-foreground line-clamp-2">{item.description}</p>
        </div>
      </div>
    </article>
  )
}
```

**Tables — the legitimate exception (use `overflow-x-auto` and visible scroll hints):**

```tsx
<div className="overflow-x-auto rounded-md border" tabIndex={0} role="region" aria-label="Sales by month">
  <table className="w-full text-sm">
    <thead>...</thead>
    <tbody>...</tbody>
  </table>
</div>
```

**Rule:**
- Mobile-first: write the smallest-viewport layout first, then add `sm:`/`md:`/`lg:` modifiers
- Never set `width: Npx` on layout containers — use `max-w-*` or fluid grid tracks
- Always include `min-w-0` on flex/grid children that contain text — prevents intrinsic-size overflow
- Use container queries (`@container` + `@md:`) when a component must react to its own width
- Verify in Chrome DevTools "Toggle device toolbar" → set width to 320 — no horizontal scroll on the document

Reference: [WCAG 1.4.10 Reflow](https://www.w3.org/WAI/WCAG22/Understanding/reflow.html) · [Container queries — Tailwind 4](https://tailwindcss.com/docs/responsive-design#container-queries)
