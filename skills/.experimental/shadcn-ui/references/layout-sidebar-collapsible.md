---
title: Configure Sidebar Collapsible Behavior
impact: MEDIUM
impactDescription: controls how sidebar collapses on different screen sizes
tags: layout, sidebar, collapsible, responsive, mobile
---

## Configure Sidebar Collapsible Behavior

Set the `collapsible` prop to control sidebar collapse behavior. The wrong mode creates poor UX on mobile or wastes space on desktop.

**Incorrect (no collapsible configuration):**

```tsx
import { Sidebar } from "@/components/ui/sidebar"

function AppSidebar() {
  return (
    <Sidebar>  {/* No collapsible prop - defaults may not match your needs */}
      <SidebarContent>{/* ... */}</SidebarContent>
    </Sidebar>
  )
}
```

**Correct (explicit collapsible mode):**

```tsx
import { Sidebar } from "@/components/ui/sidebar"

// Icon mode: Collapses to icons only (good for desktop apps)
function AppSidebar() {
  return (
    <Sidebar collapsible="icon">
      <SidebarContent>{/* ... */}</SidebarContent>
    </Sidebar>
  )
}

// Offcanvas mode: Slides in/out (good for mobile-first)
function MobileSidebar() {
  return (
    <Sidebar collapsible="offcanvas">
      <SidebarContent>{/* ... */}</SidebarContent>
    </Sidebar>
  )
}

// None: Never collapses (fixed sidebar)
function FixedSidebar() {
  return (
    <Sidebar collapsible="none">
      <SidebarContent>{/* ... */}</SidebarContent>
    </Sidebar>
  )
}
```

| Mode | Collapsed State | Best For |
|------|-----------------|----------|
| `icon` | Shows icons only | Desktop apps with frequent navigation |
| `offcanvas` | Fully hidden, slides in | Mobile-first, content-heavy apps |
| `none` | Never collapses | Admin panels, always-visible nav |

Reference: [shadcn/ui Sidebar](https://ui.shadcn.com/docs/components/sidebar)
