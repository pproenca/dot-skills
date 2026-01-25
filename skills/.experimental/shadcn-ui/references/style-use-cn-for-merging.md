---
title: Use cn() for All Class Merging
impact: HIGH
impactDescription: prevents Tailwind class conflicts and enables conditional styling
tags: style, cn, tailwind-merge, className, utility
---

## Use cn() for All Class Merging

Always use the `cn()` utility when combining classes. Template literals and array joins cause Tailwind class conflicts where later classes don't override earlier ones.

**Incorrect (template literal concatenation):**

```tsx
function Card({ className, highlighted }) {
  return (
    <div className={`p-4 bg-card ${highlighted ? "bg-yellow-100" : ""} ${className}`}>
      {/* bg-yellow-100 may not override bg-card due to CSS specificity */}
    </div>
  )
}

// Usage
<Card className="p-8" highlighted />
// Result: "p-4 bg-card bg-yellow-100 p-8"
// p-4 and p-8 both in class string - unpredictable behavior
```

**Correct (cn utility):**

```tsx
import { cn } from "@/lib/utils"

function Card({ className, highlighted }) {
  return (
    <div className={cn(
      "p-4 bg-card",
      highlighted && "bg-yellow-100",
      className
    )}>
      {/* tailwind-merge resolves conflicts correctly */}
    </div>
  )
}

// Usage
<Card className="p-8" highlighted />
// Result: "bg-yellow-100 p-8"
// p-4 removed, bg-card removed - proper overrides
```

**cn() handles:**
- Tailwind class conflicts (`p-4` vs `p-8`)
- Conditional classes (`highlighted && "..."`)
- Falsy value filtering (`undefined`, `false`, `null`)

Reference: [tailwind-merge](https://github.com/dcastil/tailwind-merge)
