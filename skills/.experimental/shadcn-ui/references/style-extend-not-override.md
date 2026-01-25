---
title: Extend Variants Instead of Overriding Base Styles
impact: HIGH
impactDescription: preserves default behavior while adding customization
tags: style, cva, variants, customization, extension
---

## Extend Variants Instead of Overriding Base Styles

Add new variants to CVA definitions instead of modifying base classes. This preserves default component behavior while adding customization.

**Incorrect (modifying base styles):**

```tsx
// components/ui/button.tsx
const buttonVariants = cva(
  "inline-flex items-center justify-center rounded-full", // Changed from rounded-md
  {
    variants: {
      variant: {
        default: "bg-brand-500 text-white", // Changed from bg-primary
        // All existing code now broken
      },
    },
  }
)
```

**Correct (extending with new variants):**

```tsx
// components/ui/button.tsx
const buttonVariants = cva(
  "inline-flex items-center justify-center rounded-md font-medium transition-colors",
  {
    variants: {
      variant: {
        default: "bg-primary text-primary-foreground hover:bg-primary/90",
        destructive: "bg-destructive text-destructive-foreground",
        outline: "border border-input bg-background hover:bg-accent",
        // Add new variants without changing existing ones
        brand: "bg-brand-500 text-white hover:bg-brand-600",
        success: "bg-green-600 text-white hover:bg-green-700",
      },
      shape: {
        default: "",
        pill: "rounded-full",
        square: "rounded-none",
      },
    },
    defaultVariants: {
      variant: "default",
      shape: "default",
    },
  }
)
```

**Usage:**

```tsx
<Button variant="brand" shape="pill">Custom Button</Button>
<Button variant="default">Still works as before</Button>
```

Reference: [class-variance-authority](https://cva.style/docs)
