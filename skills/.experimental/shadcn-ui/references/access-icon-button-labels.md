---
title: Add Accessible Labels to Icon-Only Buttons
impact: HIGH
impactDescription: required for screen reader users to understand button purpose
tags: access, button, icon, sr-only, aria-label
---

## Add Accessible Labels to Icon-Only Buttons

Icon-only buttons must have accessible text. Without it, screen readers announce "button" with no indication of purpose.

**Incorrect (icon button without label):**

```tsx
import { X } from "lucide-react"
import { Button } from "@/components/ui/button"

function CloseButton({ onClick }) {
  return (
    <Button variant="ghost" size="icon" onClick={onClick}>
      <X className="h-4 w-4" />
    </Button>
  )
  // Screen reader: "button" - no context
}
```

**Correct (sr-only text):**

```tsx
import { X } from "lucide-react"
import { Button } from "@/components/ui/button"

function CloseButton({ onClick }) {
  return (
    <Button variant="ghost" size="icon" onClick={onClick}>
      <X className="h-4 w-4" />
      <span className="sr-only">Close</span>
    </Button>
  )
  // Screen reader: "Close, button"
}
```

**Alternative (aria-label):**

```tsx
<Button variant="ghost" size="icon" onClick={onClick} aria-label="Close">
  <X className="h-4 w-4" />
</Button>
```

**sr-only vs aria-label:**
- `sr-only`: Visible to screen readers, can be translated
- `aria-label`: Overrides all content, not translatable by default

Prefer `<span className="sr-only">` for better internationalization support.

Reference: [WAI-ARIA Button Pattern](https://www.w3.org/WAI/ARIA/apg/patterns/button/)
