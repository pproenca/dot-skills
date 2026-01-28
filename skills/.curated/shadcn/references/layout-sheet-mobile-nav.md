---
title: Use Sheet for Mobile Navigation Overlay
impact: MEDIUM
impactDescription: proper mobile navigation with slide-in behavior
tags: layout, sheet, mobile, navigation, responsive
---

## Use Sheet for Mobile Navigation Overlay

Use Sheet component for mobile navigation that slides in from the edge. Dialog-based mobile menus feel awkward and don't match mobile UX patterns.

**Incorrect (Dialog for mobile nav):**

```tsx
import { Dialog, DialogContent, DialogTrigger } from "@/components/ui/dialog"

function MobileNav() {
  return (
    <Dialog>
      <DialogTrigger asChild>
        <Button variant="ghost" size="icon" className="md:hidden">
          <Menu />
        </Button>
      </DialogTrigger>
      <DialogContent>
        <nav>{/* Navigation items */}</nav>
      </DialogContent>
    </Dialog>
  )
  // Dialog centers on screen, doesn't feel like mobile nav
}
```

**Correct (Sheet with side positioning):**

```tsx
import { Sheet, SheetContent, SheetHeader, SheetTitle, SheetTrigger } from "@/components/ui/sheet"
import { Menu } from "lucide-react"

function MobileNav() {
  return (
    <Sheet>
      <SheetTrigger asChild>
        <Button variant="ghost" size="icon" className="md:hidden">
          <Menu className="h-5 w-5" />
          <span className="sr-only">Toggle menu</span>
        </Button>
      </SheetTrigger>
      <SheetContent side="left" className="w-[300px]">
        <SheetHeader>
          <SheetTitle>Navigation</SheetTitle>
        </SheetHeader>
        <nav className="flex flex-col gap-4 py-4">
          <a href="/dashboard" className="text-lg font-medium">Dashboard</a>
          <a href="/settings" className="text-lg font-medium">Settings</a>
          <a href="/help" className="text-lg font-medium">Help</a>
        </nav>
      </SheetContent>
    </Sheet>
  )
}
```

**Sheet sides:**
- `left`: Standard mobile nav (slides from left edge)
- `right`: Settings/filters panel
- `top`: Notifications, search
- `bottom`: Action sheets, mobile modals

Reference: [shadcn/ui Sheet](https://ui.shadcn.com/docs/components/sheet)
