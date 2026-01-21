---
title: Avoid !important Overrides
impact: HIGH
impactDescription: maintains style specificity and component customization
tags: style, important, specificity, tailwind, overrides
---

## Avoid !important Overrides

Never use `!important` to override shadcn/ui styles. It breaks the cascade and prevents component consumers from customizing styles.

**Incorrect (using !important):**

```tsx
function BrandButton({ children }: { children: React.ReactNode }) {
  return (
    <Button className="!bg-brand-500 !text-white !hover:bg-brand-600">
      {/* !important prevents any further customization */}
      {children}
    </Button>
  )
}

// Consumer cannot override
function Page() {
  return (
    <BrandButton className="bg-red-500">
      {/* bg-red-500 ignored due to !important */}
      Click me
    </BrandButton>
  )
}
```

**Correct (proper specificity with cn()):**

```tsx
import { cn } from "@/lib/utils"

function BrandButton({
  className,
  children,
}: {
  className?: string
  children: React.ReactNode
}) {
  return (
    <Button
      className={cn(
        "bg-brand-500 text-white hover:bg-brand-600",
        className
      )}
    >
      {/* User className passed last, can override defaults */}
      {children}
    </Button>
  )
}

// Consumer can customize
function Page() {
  return (
    <BrandButton className="bg-red-500 hover:bg-red-600">
      {/* Works - className overrides defaults via cn() */}
      Click me
    </BrandButton>
  )
}
```

**If styles aren't applying:**
1. Check class order in `cn()` - later classes win
2. Verify Tailwind config includes your custom colors
3. Use browser DevTools to inspect computed styles

Reference: [Tailwind Important Modifier](https://tailwindcss.com/docs/configuration#important-modifier)
