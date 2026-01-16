---
title: Use Route Groups for Organization
impact: MEDIUM
impactDescription: enables separate layouts without URL nesting overhead
tags: route, organization, groups, structure, layouts
---

## Use Route Groups for Organization

Route groups use parentheses syntax `(groupName)` to organize routes logically without affecting the URL structure. This enables separate layouts for different sections, team-based code organization, and cleaner folder hierarchies without polluting URLs.

**Incorrect (flat structure creates organizational chaos):**

```text
app/
├── marketing-home/page.tsx        # URL: /marketing-home - ugly
├── marketing-about/page.tsx       # URL: /marketing-about
├── marketing-pricing/page.tsx
├── app-dashboard/page.tsx         # URL: /app-dashboard - redundant
├── app-settings/page.tsx
├── app-analytics/page.tsx
└── layout.tsx                     # One layout for everything
```

**Correct (route groups organize without URL impact):**

```text
app/
├── (marketing)/
│   ├── layout.tsx                 # Marketing layout with hero nav
│   ├── page.tsx                   # URL: /
│   ├── about/page.tsx             # URL: /about
│   └── pricing/page.tsx           # URL: /pricing
├── (app)/
│   ├── layout.tsx                 # App layout with sidebar
│   ├── dashboard/page.tsx         # URL: /dashboard
│   ├── settings/page.tsx          # URL: /settings
│   └── analytics/page.tsx         # URL: /analytics
└── layout.tsx                     # Root layout
```

**Multiple root layouts for different experiences:**

```tsx
// app/(marketing)/layout.tsx
export default function MarketingLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>
        <MarketingHeader />
        {children}
        <MarketingFooter />
      </body>
    </html>
  )
}

// app/(app)/layout.tsx
export default function AppLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>
        <Sidebar />
        <main>{children}</main>
      </body>
    </html>
  )
}
// Each section has completely different chrome, sharing no layout code
```

**Benefits:**
- Clean URLs without organizational prefixes
- Different layouts per section without route nesting
- Team-based folder ownership (marketing team owns `(marketing)/`)
- Easier refactoring since URLs are decoupled from folder names

Reference: [Route Groups](https://nextjs.org/docs/app/building-your-application/routing/route-groups)
