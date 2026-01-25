---
title: Use asChild for Custom Element Rendering
impact: CRITICAL
impactDescription: enables button styling on links without wrapper elements
tags: comp, asChild, slot, radix, composition, link
---

## Use asChild for Custom Element Rendering

The `asChild` prop renders component styles on a child element instead of the default element. Use this to apply button styles to links or custom elements.

**Incorrect (button wrapping link):**

```tsx
import { Button } from "@/components/ui/button"
import Link from "next/link"

function NavButton() {
  return (
    <Button>
      <Link href="/dashboard">Dashboard</Link>
    </Button>
  )
  // Renders: <button><a>Dashboard</a></button>
  // Problem: Nested interactive elements, accessibility violation
}
```

**Correct (asChild with link):**

```tsx
import { Button } from "@/components/ui/button"
import Link from "next/link"

function NavButton() {
  return (
    <Button asChild>
      <Link href="/dashboard">Dashboard</Link>
    </Button>
  )
  // Renders: <a class="button-styles">Dashboard</a>
  // Button styles applied directly to the link
}
```

**Works with any element:**

```tsx
// Apply button styles to a div (rare but valid)
<Button asChild>
  <div role="button" tabIndex={0}>Custom Element</div>
</Button>
```

Reference: [Radix UI Slot](https://www.radix-ui.com/primitives/docs/utilities/slot)
