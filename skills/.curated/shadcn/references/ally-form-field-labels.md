---
title: Associate Labels with Form Controls
impact: HIGH
impactDescription: enables screen reader announcements and click-to-focus
tags: ally, form, label, input, accessibility
---

## Associate Labels with Form Controls

Every form input must have an associated label using the `htmlFor` attribute or wrapping. Placeholder text alone is not accessible.

**Incorrect (placeholder without label):**

```tsx
import { Input } from "@/components/ui/input"

function SearchForm() {
  return (
    <form>
      <Input placeholder="Enter email address" type="email" />
      {/* Screen reader: "Edit text" - no context */}
      {/* Placeholder disappears when typing */}
    </form>
  )
}
```

**Correct (Field component with label):**

```tsx
import { Field, FieldLabel } from "@/components/ui/field"
import { Input } from "@/components/ui/input"

function SearchForm() {
  return (
    <form>
      <Field>
        <FieldLabel htmlFor="email">Email Address</FieldLabel>
        <Input id="email" type="email" placeholder="you@example.com" />
      </Field>
    </form>
  )
  // Screen reader: "Email Address, edit text"
}
```

**Alternative (Label component):**

```tsx
import { Label } from "@/components/ui/label"
import { Input } from "@/components/ui/input"

function SearchForm() {
  return (
    <form>
      <div className="grid gap-2">
        <Label htmlFor="email">Email Address</Label>
        <Input id="email" type="email" />
      </div>
    </form>
  )
}
```

**For icon-only inputs (visually hidden label):**

```tsx
<Label htmlFor="search" className="sr-only">Search</Label>
<Input id="search" placeholder="Search..." />
```

Reference: [WAI-ARIA Forms](https://www.w3.org/WAI/tutorials/forms/labels/)
