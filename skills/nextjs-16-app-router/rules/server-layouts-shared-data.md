---
title: Fetch Shared Data in Layouts
impact: HIGH
impactDescription: eliminates duplicate database queries, reduces server load by 40-70% for repeated data
tags: server, layouts, data-fetching, deduplication
---

## Fetch Shared Data in Layouts

Layouts persist across page navigations and wrap all child pages. Fetch data needed by multiple pages in the layout once, rather than duplicating fetches in each page. Next.js automatically deduplicates identical fetch requests, but explicit layout fetching is clearer and more maintainable.

**Incorrect (duplicated fetches in pages):**

```tsx
// app/dashboard/settings/page.tsx
export default async function SettingsPage() {
  const user = await getCurrentUser()  // Fetched here
  const subscription = await getSubscription(user.id)

  return <SettingsForm user={user} subscription={subscription} />
}

// app/dashboard/billing/page.tsx
export default async function BillingPage() {
  const user = await getCurrentUser()  // Fetched AGAIN
  const invoices = await getInvoices(user.id)

  return <BillingHistory user={user} invoices={invoices} />
}

// app/dashboard/profile/page.tsx
export default async function ProfilePage() {
  const user = await getCurrentUser()  // Fetched AGAIN
  return <ProfileEditor user={user} />
}
// getCurrentUser called 3 times across navigation
```

**Correct (shared data in layout):**

```tsx
// app/dashboard/layout.tsx
import { DashboardNav } from '@/components/dashboard-nav'

export default async function DashboardLayout({
  children,
}: {
  children: React.ReactNode
}) {
  const user = await getCurrentUser()  // Fetched once for all dashboard pages

  return (
    <div className="dashboard">
      <DashboardNav user={user} />
      <main>{children}</main>
    </div>
  )
}

// app/dashboard/settings/page.tsx
export default async function SettingsPage() {
  const user = await getCurrentUser()  // Deduped with layout fetch
  const subscription = await getSubscription(user.id)

  return <SettingsForm user={user} subscription={subscription} />
}
```

**Alternative - React cache for request deduplication:**

```tsx
import { cache } from 'react'

export const getCurrentUser = cache(async () => {
  const session = await getSession()
  return db.user.findUnique({ where: { id: session.userId } })
})
// Same function called multiple times returns cached result within request
```

Reference: [Layouts and Data Fetching](https://nextjs.org/docs/app/building-your-application/routing/layouts-and-templates#layouts)
