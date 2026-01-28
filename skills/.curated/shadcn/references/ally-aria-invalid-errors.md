---
title: Use aria-invalid for Form Error States
impact: HIGH
impactDescription: announces validation errors to screen readers
tags: ally, form, aria-invalid, validation, error
---

## Use aria-invalid for Form Error States

Set `aria-invalid={true}` on inputs with validation errors. This announces the error state to screen readers and triggers error styling.

**Incorrect (visual-only error indication):**

```tsx
import { Input } from "@/components/ui/input"

function EmailInput({ error }) {
  return (
    <div>
      <Input
        type="email"
        className={error ? "border-red-500" : ""}
      />
      {error && <span className="text-red-500">{error}</span>}
    </div>
  )
  // Screen reader: Cannot detect error state
}
```

**Correct (aria-invalid with error message):**

```tsx
import { Field, FieldLabel, FieldError } from "@/components/ui/field"
import { Input } from "@/components/ui/input"

function EmailInput({ error }) {
  return (
    <Field data-invalid={!!error}>
      <FieldLabel htmlFor="email">Email</FieldLabel>
      <Input
        id="email"
        type="email"
        aria-invalid={!!error}
        aria-describedby={error ? "email-error" : undefined}
      />
      {error && <FieldError id="email-error">{error}</FieldError>}
    </Field>
  )
  // Screen reader: "Email, invalid entry, Enter a valid email address"
}
```

**With React Hook Form:**

```tsx
<Input
  {...field}
  aria-invalid={fieldState.invalid}
/>
{fieldState.invalid && (
  <FieldError>{fieldState.error?.message}</FieldError>
)}
```

Reference: [shadcn/ui Forms](https://ui.shadcn.com/docs/components/form)
