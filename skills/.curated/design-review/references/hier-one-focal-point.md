---
title: Establish one clear focal point per screen
tags: hier, hierarchy, emphasis
---

## Establish one clear focal point per screen

By default a generated layout gives every section the same size, weight, and colour, so the eye has no entry point and the screen reads as flat. Pick the one thing that matters most on this view — the key metric, the page title, the primary action — and make it visibly dominant while everything else recedes.

```tsx
// The balance dominates; label and timestamp recede in size, weight, and colour
<section className="account-summary">
  <p className="text-sm font-medium text-slate-500">Available balance</p>
  <p className="text-5xl font-bold tracking-tight text-slate-900">£12,480.50</p>
  <p className="text-sm text-slate-500">Updated 2 minutes ago</p>
</section>
```

Reference: [Refactoring UI — Hierarchy](https://www.refactoringui.com/)
