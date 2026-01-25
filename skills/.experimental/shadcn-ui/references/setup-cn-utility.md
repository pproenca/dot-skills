---
title: Create the cn Utility Before Using Components
impact: CRITICAL
impactDescription: required by every shadcn/ui component for class merging
tags: setup, cn, clsx, tailwind-merge, utility, className
---

## Create the cn Utility Before Using Components

Every shadcn/ui component uses the `cn` utility to merge Tailwind classes. Missing this utility causes runtime errors in all components.

**Incorrect (missing cn utility):**

```typescript
// components/ui/button.tsx
import { cn } from "@/lib/utils"
// Error: Cannot find module '@/lib/utils'

export function Button({ className, ...props }) {
  return (
    <button className={cn("px-4 py-2", className)} {...props} />
  )
}
```

**Correct (cn utility defined):**

```typescript
// lib/utils.ts
import { clsx, type ClassValue } from "clsx"
import { twMerge } from "tailwind-merge"

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}
```

**Why both libraries:**
- `clsx` handles conditional classes: `cn("base", isActive && "active")`
- `tailwind-merge` resolves conflicts: `cn("px-2", "px-4")` returns `"px-4"`

Reference: [shadcn/ui Manual Installation](https://ui.shadcn.com/docs/installation/manual)
