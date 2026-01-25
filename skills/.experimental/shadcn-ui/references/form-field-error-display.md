---
title: Display Field Errors with FieldError Component
impact: MEDIUM-HIGH
impactDescription: consistent error styling and accessibility attributes
tags: form, field, error, validation, display
---

## Display Field Errors with FieldError Component

Use the FieldError component for consistent error message styling and automatic ARIA association. Raw text spans lack proper accessibility attributes.

**Incorrect (raw error text):**

```tsx
function EmailField({ error }) {
  return (
    <div>
      <label>Email</label>
      <Input type="email" />
      {error && (
        <span className="text-red-500 text-sm">{error}</span>
      )}
      {/* Not associated with input via aria-describedby */}
    </div>
  )
}
```

**Correct (FieldError component):**

```tsx
import { Field, FieldLabel, FieldError } from "@/components/ui/field"
import { Input } from "@/components/ui/input"

function EmailField({ error }) {
  const hasError = !!error

  return (
    <Field data-invalid={hasError}>
      <FieldLabel htmlFor="email">Email</FieldLabel>
      <Input
        id="email"
        type="email"
        aria-invalid={hasError}
        aria-describedby={hasError ? "email-error" : undefined}
      />
      {hasError && <FieldError id="email-error">{error}</FieldError>}
    </Field>
  )
}
```

**With React Hook Form Controller:**

```tsx
<Controller
  name="email"
  control={control}
  render={({ field, fieldState }) => (
    <Field data-invalid={fieldState.invalid}>
      <FieldLabel>Email</FieldLabel>
      <Input {...field} aria-invalid={fieldState.invalid} />
      {fieldState.invalid && (
        <FieldError>{fieldState.error?.message}</FieldError>
      )}
    </Field>
  )}
/>
```

Reference: [shadcn/ui Field](https://ui.shadcn.com/docs/components/field)
