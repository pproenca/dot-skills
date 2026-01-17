---
title: Isolate Component Variants from Base Styles
impact: CRITICAL
impactDescription: prevents style bleeding and maintains component reusability
tags: arch, variants, isolation, cva, separation-of-concerns
---

## Isolate Component Variants from Base Styles

Keep variant-specific styles separate from base component styles. Mixing them creates tightly coupled components that are difficult to extend or override.

**Incorrect (base and variant styles mixed):**

```tsx
function AlertBanner({
  type,
  children,
}: {
  type: "info" | "success" | "error"
  children: React.ReactNode
}) {
  return (
    <div
      className={`rounded-lg p-4 ${
        type === "info"
          ? "border-blue-200 bg-blue-50 text-blue-800"
          : type === "success"
            ? "border-green-200 bg-green-50 text-green-800"
            : "border-red-200 bg-red-50 text-red-800"
      }`}
    >
      {/* Border style missing from base, must be repeated in each variant */}
      {children}
    </div>
  )
}
```

**Correct (separated base and variant definitions):**

```tsx
import { cva, type VariantProps } from "class-variance-authority"
import { cn } from "@/lib/utils"

const alertVariants = cva(
  // Base styles applied to all variants
  "rounded-lg border p-4",
  {
    variants: {
      type: {
        // Only color-related styles in variants
        info: "border-blue-200 bg-blue-50 text-blue-800",
        success: "border-green-200 bg-green-50 text-green-800",
        error: "border-red-200 bg-red-50 text-red-800",
      },
    },
    defaultVariants: {
      type: "info",
    },
  }
)

interface AlertBannerProps
  extends React.HTMLAttributes<HTMLDivElement>,
    VariantProps<typeof alertVariants> {}

function AlertBanner({ type, className, children, ...props }: AlertBannerProps) {
  return (
    <div className={cn(alertVariants({ type }), className)} {...props}>
      {children}
    </div>
  )
}
// Base styles (rounded-lg, border, p-4) guaranteed on all variants
```

**Benefits:**
- Base styles guaranteed on all variants
- Easy to add new variants without duplicating structure
- Clear separation enables easier maintenance

Reference: [CVA Documentation](https://cva.style/docs/getting-started/variants)
