---
title: Wrap Checkbox with Label for Click Target
impact: HIGH
impactDescription: expands clickable area and provides screen reader context
tags: ally, checkbox, label, form, click-target
---

## Wrap Checkbox with Label for Click Target

Checkboxes should be wrapped with or associated to labels. This expands the click target and ensures screen readers announce the label with the checkbox.

**Incorrect (checkbox without label association):**

```tsx
import { Checkbox } from "@/components/ui/checkbox"

function TermsCheckbox() {
  return (
    <div className="flex items-center gap-2">
      <Checkbox id="terms" />
      <span>I agree to the terms</span>  {/* Not a label */}
    </div>
  )
  // Clicking text doesn't toggle checkbox
  // Screen reader: "checkbox, unchecked" - no context
}
```

**Correct (label with htmlFor):**

```tsx
import { Checkbox } from "@/components/ui/checkbox"
import { Label } from "@/components/ui/label"

function TermsCheckbox() {
  return (
    <div className="flex items-center gap-2">
      <Checkbox id="terms" />
      <Label htmlFor="terms">I agree to the terms and conditions</Label>
    </div>
  )
  // Clicking label toggles checkbox
  // Screen reader: "I agree to the terms and conditions, checkbox, unchecked"
}
```

**Alternative (wrapping label):**

```tsx
<Label className="flex items-center gap-2">
  <Checkbox />
  <span>I agree to the terms</span>
</Label>
```

Reference: [shadcn/ui Checkbox](https://ui.shadcn.com/docs/components/checkbox)
