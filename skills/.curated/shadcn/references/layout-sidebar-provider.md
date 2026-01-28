---
title: Wrap Layout with SidebarProvider
impact: MEDIUM
impactDescription: enables sidebar state management across components
tags: layout, sidebar, provider, context, state
---

## Wrap Layout with SidebarProvider

SidebarProvider must wrap any component that uses sidebar state or controls. Without it, useSidebar hook and SidebarTrigger fail.

**Incorrect (sidebar without provider):**

```tsx
// app/layout.tsx
import { AppSidebar } from "@/components/app-sidebar"
import { SidebarTrigger } from "@/components/ui/sidebar"

export default function Layout({ children }) {
  return (
    <div className="flex">
      <AppSidebar />  {/* Error: useSidebar must be used within SidebarProvider */}
      <main>
        <SidebarTrigger />  {/* Also fails */}
        {children}
      </main>
    </div>
  )
}
```

**Correct (wrapped with provider):**

```tsx
// app/layout.tsx
import { SidebarProvider, SidebarTrigger } from "@/components/ui/sidebar"
import { AppSidebar } from "@/components/app-sidebar"

export default function Layout({ children }) {
  return (
    <SidebarProvider>
      <AppSidebar />
      <main className="flex-1">
        <header className="flex items-center gap-2 p-4">
          <SidebarTrigger />
          <h1>Dashboard</h1>
        </header>
        {children}
      </main>
    </SidebarProvider>
  )
}
```

**Persisting sidebar state:**

```tsx
<SidebarProvider defaultOpen={true}>
  {/* Sidebar starts expanded */}
</SidebarProvider>

// Or with cookies/localStorage
<SidebarProvider defaultOpen={cookies.get("sidebar_open") !== "false"}>
```

Reference: [shadcn/ui Sidebar](https://ui.shadcn.com/docs/components/sidebar)
