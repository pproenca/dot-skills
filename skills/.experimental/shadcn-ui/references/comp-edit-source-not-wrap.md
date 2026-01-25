---
title: Edit Component Source Instead of Wrapping
impact: CRITICAL
impactDescription: avoids wrapper component proliferation and style override complexity
tags: comp, customization, source-editing, wrapper, composition
---

## Edit Component Source Instead of Wrapping

shadcn/ui components are meant to be modified directly. Wrapping creates unnecessary abstraction layers and makes styling harder to maintain.

**Incorrect (wrapper component with overrides):**

```typescript
// components/custom-button.tsx
import { Button } from "@/components/ui/button"

export function CustomButton({ className, ...props }) {
  return (
    <Button
      className={`rounded-full font-bold ${className}`}  // Overrides may conflict
      {...props}
    />
  )
}
// Now you have two button components to maintain
```

**Correct (edit the source directly):**

```typescript
// components/ui/button.tsx
const buttonVariants = cva(
  "inline-flex items-center justify-center rounded-full font-bold ...",
  //                                    ^^^^^^^^^^^^^ ^^^^^^^^^ edited directly
  {
    variants: {
      variant: {
        default: "bg-primary text-primary-foreground hover:bg-primary/90",
        // Add your custom variants here
        brand: "bg-brand-500 text-white hover:bg-brand-600",
      },
    },
  }
)
```

**When wrappers ARE appropriate:**
- Adding business logic (e.g., analytics tracking)
- Providing default props for a specific context
- Combining multiple shadcn/ui components

Reference: [shadcn/ui Philosophy](https://ui.shadcn.com/docs)
