---
title: Extend Variants with Class Variance Authority
impact: CRITICAL
impactDescription: maintains type safety and design consistency
tags: arch, cva, variants, class-variance-authority, typescript
---

## Extend Variants with Class Variance Authority

When adding new variants to shadcn/ui components, extend the existing CVA configuration rather than using conditional className logic. This maintains type safety and design system consistency.

**Incorrect (inline conditional classes):**

```tsx
function StatusBadge({ status }: { status: string }) {
  return (
    <Badge
      className={
        status === "success"
          ? "bg-green-500"
          : status === "warning"
            ? "bg-yellow-500"
            : status === "error"
              ? "bg-red-500"
              : ""
      }
    >
      {status}
    </Badge>
  )
}
// No type safety, classes can conflict with base Badge styles
```

**Correct (extended CVA configuration):**

```tsx
import { cva, type VariantProps } from "class-variance-authority"

const statusBadgeVariants = cva(
  "inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-semibold",
  {
    variants: {
      status: {
        success: "bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-300",
        warning: "bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-300",
        error: "bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-300",
        info: "bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-300",
      },
    },
    defaultVariants: {
      status: "info",
    },
  }
)

interface StatusBadgeProps extends VariantProps<typeof statusBadgeVariants> {
  children: React.ReactNode
}

function StatusBadge({ status, children }: StatusBadgeProps) {
  return <span className={statusBadgeVariants({ status })}>{children}</span>
}
// Type-safe: status prop is typed as "success" | "warning" | "error" | "info"
```

Reference: [Class Variance Authority](https://cva.style/docs)
