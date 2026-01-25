---
title: Use CVA for Component Variants
impact: CRITICAL
impactDescription: type-safe variants with automatic class merging
tags: comp, cva, class-variance-authority, variants, typescript
---

## Use CVA for Component Variants

class-variance-authority (CVA) creates type-safe variant props. Manual conditional classes are error-prone and lack TypeScript support.

**Incorrect (manual conditional classes):**

```tsx
interface ButtonProps {
  variant?: "default" | "destructive" | "outline"
  size?: "sm" | "md" | "lg"
}

function Button({ variant = "default", size = "md", className }: ButtonProps) {
  const variantClasses = {
    default: "bg-primary text-primary-foreground",
    destructive: "bg-destructive text-destructive-foreground",
    outline: "border border-input bg-background",
  }
  const sizeClasses = {
    sm: "h-8 px-3 text-sm",
    md: "h-10 px-4",
    lg: "h-12 px-6 text-lg",
  }

  return (
    <button className={`${variantClasses[variant]} ${sizeClasses[size]} ${className}`}>
      {/* className may override unintentionally */}
    </button>
  )
}
```

**Correct (CVA with type inference):**

```tsx
import { cva, type VariantProps } from "class-variance-authority"
import { cn } from "@/lib/utils"

const buttonVariants = cva(
  "inline-flex items-center justify-center rounded-md font-medium transition-colors",
  {
    variants: {
      variant: {
        default: "bg-primary text-primary-foreground hover:bg-primary/90",
        destructive: "bg-destructive text-destructive-foreground hover:bg-destructive/90",
        outline: "border border-input bg-background hover:bg-accent",
      },
      size: {
        sm: "h-8 px-3 text-sm",
        default: "h-10 px-4",
        lg: "h-12 px-6 text-lg",
      },
    },
    defaultVariants: {
      variant: "default",
      size: "default",
    },
  }
)

interface ButtonProps extends VariantProps<typeof buttonVariants> {}

function Button({ variant, size, className, ...props }: ButtonProps) {
  return <button className={cn(buttonVariants({ variant, size }), className)} {...props} />
}
```

`VariantProps` automatically infers types from the CVA definition.

Reference: [class-variance-authority](https://cva.style/docs)
