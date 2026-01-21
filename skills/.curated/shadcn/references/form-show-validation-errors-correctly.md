---
title: Show Validation Errors at Appropriate Times
impact: HIGH
impactDescription: improves user experience and reduces frustration
tags: form, validation, errors, ux, timing
---

## Show Validation Errors at Appropriate Times

Show validation errors on blur or submit, not on every keystroke. Immediate validation frustrates users typing valid input.

**Incorrect (errors shown while typing):**

```tsx
const form = useForm<FormValues>({
  resolver: zodResolver(schema),
  mode: "onChange", // Validates on every keystroke
})

// User types "t" - sees "Email must be valid" immediately
// User types "te" - still sees error
// User types "test@" - still sees error
// Frustrating experience during normal typing
```

**Correct (errors shown on blur or submit):**

```tsx
const form = useForm<FormValues>({
  resolver: zodResolver(schema),
  mode: "onBlur", // Validates when field loses focus
  reValidateMode: "onChange", // Re-validates on change after first error
})

// User types entire email without interruption
// Error only shown when they leave the field
// Once error shown, it updates as they fix it
```

**Alternative (validate on submit only):**

```tsx
const form = useForm<FormValues>({
  resolver: zodResolver(schema),
  mode: "onSubmit", // Only validates on form submission
})

// Good for short forms where user submits quickly
// Shows all errors at once after submit attempt
```

**Validation mode guidelines:**
- `onBlur` - Recommended for most forms
- `onChange` - Only for real-time feedback (passwords)
- `onSubmit` - Short forms or wizards
- `reValidateMode: "onChange"` - Always pair with onBlur for instant feedback during correction

Reference: [React Hook Form Validation](https://react-hook-form.com/docs/useform#mode)
