---
title: Keep the app shell consistent across pages
tags: flow, navigation, consistency
---

## Keep the app shell consistent across pages

Pages generated one at a time drift apart — the header height, nav, container width, and page padding end up slightly different on each route, so the product feels stitched together from separate templates rather than one app. Let a single shared layout own the chrome (nav, header, max-width, vertical rhythm) and have each route render only its own content.

```tsx
// app/(dashboard)/layout.tsx — every route below inherits one identical shell
export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="mx-auto max-w-5xl px-6">
      <SiteHeader />
      <main className="py-10">{children}</main>
    </div>
  );
}
```

Reference: [NN/g — 10 Usability Heuristics (Consistency and standards)](https://www.nngroup.com/articles/ten-usability-heuristics/)
