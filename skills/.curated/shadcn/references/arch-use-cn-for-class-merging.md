---
title: Use cn() for Safe Class Merging
impact: CRITICAL
impactDescription: prevents Tailwind class conflicts
tags: arch, cn, tailwind-merge, className, utilities
---

## Use cn() for Safe Class Merging

Always use the `cn()` utility (which wraps `clsx` and `tailwind-merge`) when combining classes. Direct string concatenation causes Tailwind class conflicts where later classes don't override earlier ones.

**Incorrect (string concatenation causes conflicts):**

```tsx
interface CardProps {
  className?: string
  variant?: "default" | "highlighted"
}

function Card({ className, variant }: CardProps) {
  const baseClasses = "rounded-lg border bg-card p-6"
  const variantClasses = variant === "highlighted" ? "bg-primary" : ""

  return (
    <div className={`${baseClasses} ${variantClasses} ${className}`}>
      {/* bg-card and bg-primary both in class string - unpredictable result */}
    </div>
  )
}
```

**Correct (cn() handles conflicts intelligently):**

```tsx
import { cn } from "@/lib/utils"

interface CardProps {
  className?: string
  variant?: "default" | "highlighted"
}

function Card({ className, variant }: CardProps) {
  return (
    <div
      className={cn(
        "rounded-lg border bg-card p-6",
        variant === "highlighted" && "bg-primary text-primary-foreground",
        className
      )}
    >
      {/* tailwind-merge ensures bg-primary overrides bg-card */}
    </div>
  )
}
```

**How cn() works:**
1. `clsx` handles conditional classes and arrays
2. `tailwind-merge` resolves conflicts (last wins for same property)
3. User's `className` prop always takes precedence (passed last)

Reference: [shadcn/ui Utilities](https://ui.shadcn.com/docs/installation/manual)
