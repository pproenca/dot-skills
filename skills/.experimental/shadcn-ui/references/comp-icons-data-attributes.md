---
title: Use data-icon Attributes for Icon Spacing
impact: HIGH
impactDescription: consistent icon alignment without manual margin classes
tags: comp, icons, lucide, data-attributes, spacing
---

## Use data-icon Attributes for Icon Spacing

shadcn/ui buttons use `data-icon` attributes for consistent icon spacing. Manual margin classes create inconsistent alignment across the codebase.

**Incorrect (manual margin classes):**

```tsx
import { Mail } from "lucide-react"
import { Button } from "@/components/ui/button"

function SendButton() {
  return (
    <Button>
      <Mail className="mr-2 h-4 w-4" />  {/* Manual margin */}
      Send Email
    </Button>
  )
}

function SaveButton() {
  return (
    <Button>
      Save
      <Check className="ml-2 h-4 w-4" />  {/* Different margin direction */}
    </Button>
  )
}
// Inconsistent: some use mr-2, some ml-2, some forget sizing
```

**Correct (data-icon attributes):**

```tsx
import { Mail, Check } from "lucide-react"
import { Button } from "@/components/ui/button"

function SendButton() {
  return (
    <Button>
      <Mail data-icon="inline-start" />
      Send Email
    </Button>
  )
}

function SaveButton() {
  return (
    <Button>
      Save
      <Check data-icon="inline-end" />
    </Button>
  )
}
```

**Loading state with spinner:**

```tsx
import { Spinner } from "@/components/ui/spinner"

function SubmitButton({ isLoading }) {
  return (
    <Button disabled={isLoading}>
      {isLoading && <Spinner data-icon="inline-start" />}
      {isLoading ? "Saving..." : "Save"}
    </Button>
  )
}
```

Reference: [shadcn/ui Button](https://ui.shadcn.com/docs/components/button)
