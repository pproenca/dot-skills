---
title: Place Primary Page Actions in the Page Header; Never Bury Them in Scroll
impact: CRITICAL
impactDescription: Actions placed below the fold are discovered by only 20-40% of users (NN/g); inverting CTA position can change conversion by 2-5×
tags: nav, page-actions, header, toolbar, cta, sticky
---

## Place Primary Page Actions in the Page Header; Never Bury Them in Scroll

Every content page has exactly one primary action. It lives in the top-right of the page header, visible without scrolling. Secondary actions sit to its left as ghost or outline buttons. On long-scroll pages, the primary action becomes sticky (mobile) or stays in the always-visible header (desktop). Floating action buttons are reserved for content creation in mobile-first products — never as a generic catch-all.

**Incorrect (primary action below the fold, ghost variant indistinguishable from secondary):**

```tsx
export default function Project() {
  return (
    <main className="p-6">
      <h1>Project: Atlas</h1>
      <section>{/* ... lots of content ... */}</section>
      <section>{/* ... lots of content ... */}</section>
      <div className="mt-12 flex gap-2">
        <button className="border px-3 py-1.5">Archive</button>
        <button className="border px-3 py-1.5">Share</button>
        <button className="border px-3 py-1.5">Publish</button>
      </div>
    </main>
  )
}
```

**Correct (primary action in header, clear hierarchy, sticky on mobile):**

```tsx
export default function Project() {
  return (
    <main>
      <header className="sticky top-0 z-10 flex items-center justify-between border-b bg-background/95 px-6 py-3 backdrop-blur">
        <div>
          <h1 className="text-xl font-semibold">Project: Atlas</h1>
          <p className="text-sm text-muted-foreground">Edited 2 min ago</p>
        </div>
        <div className="flex items-center gap-2">
          <Button variant="ghost" size="sm">Share</Button>
          <Button variant="outline" size="sm">Archive</Button>
          <Button size="sm">Publish</Button>{/* primary — filled, rightmost */}
        </div>
      </header>
      <section className="p-6">{/* ... */}</section>
    </main>
  )
}
```

**Rule:**
- One primary action per page — filled variant, rightmost position
- Maximum 3 secondary actions visible; overflow into a `…` dropdown
- Header has `sticky top-0` and `backdrop-blur` so actions remain reachable during scroll
- Destructive actions (Delete, Reset) are never primary; place them in an overflow menu or a separate "Danger zone" section
- Floating action buttons (FAB) only for create-content flows on mobile (`< 768 px`)

Reference: [F-Shaped Pattern of Reading — Nielsen Norman Group](https://www.nngroup.com/articles/f-shaped-pattern-reading-web-content/)
