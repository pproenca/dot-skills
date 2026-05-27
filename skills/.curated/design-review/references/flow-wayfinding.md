---
title: Show where the user is and the way back
tags: flow, navigation, wayfinding
---

## Show where the user is and the way back

When the nav doesn't mark the current section and deep pages carry no breadcrumb, users lose track of where they are and how to climb back up a hierarchy. Mark the active route with `aria-current` (which both styles it and announces it), give each route a descriptive document title, and add breadcrumbs once the hierarchy runs past two levels.

```tsx
// aria-current marks the active item for sighted users and assistive tech at once
<a
  href="/settings/billing"
  aria-current={pathname === '/settings/billing' ? 'page' : undefined}
  className={pathname === '/settings/billing' ? 'font-semibold text-slate-900' : 'text-slate-500'}
>
  Billing
</a>
```

Reference: [NN/g — Breadcrumbs in web design](https://www.nngroup.com/articles/breadcrumbs/)
