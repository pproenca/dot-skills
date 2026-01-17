---
title: Use Zod for Schema Validation
impact: HIGH
impactDescription: eliminates runtime type errors with full TS inference
tags: form, zod, validation, typescript, schema
---

## Use Zod for Schema Validation

Define form schemas with Zod for type-safe validation. Zod integrates with React Hook Form via `@hookform/resolvers` and provides TypeScript type inference.

**Incorrect (manual validation without schema):**

```tsx
function RegistrationForm() {
  const form = useForm()

  const onSubmit = (data: any) => {
    // Manual validation - no type safety
    if (!data.email || !data.email.includes("@")) {
      form.setError("email", { message: "Invalid email" })
      return
    }
    if (!data.age || data.age < 18) {
      form.setError("age", { message: "Must be 18 or older" })
      return
    }
    // data is typed as 'any' - no autocomplete
  }

  return <form onSubmit={form.handleSubmit(onSubmit)}>{/* ... */}</form>
}
```

**Correct (Zod schema with type inference):**

```tsx
import { z } from "zod"
import { zodResolver } from "@hookform/resolvers/zod"

const registrationSchema = z.object({
  email: z.string().email("Please enter a valid email"),
  username: z
    .string()
    .min(3, "Username must be at least 3 characters")
    .max(20, "Username must be at most 20 characters")
    .regex(/^[a-zA-Z0-9_]+$/, "Only letters, numbers, and underscores"),
  age: z.coerce
    .number()
    .min(18, "You must be at least 18 years old")
    .max(120, "Please enter a valid age"),
  website: z.string().url("Please enter a valid URL").optional().or(z.literal("")),
})

type RegistrationFormValues = z.infer<typeof registrationSchema>
// TypeScript knows: { email: string; username: string; age: number; website?: string }

function RegistrationForm() {
  const form = useForm<RegistrationFormValues>({
    resolver: zodResolver(registrationSchema),
    defaultValues: {
      email: "",
      username: "",
      age: undefined,
      website: "",
    },
  })

  const onSubmit = (data: RegistrationFormValues) => {
    // data is fully typed with validation passed
    console.log(data.email) // TypeScript knows this is a valid email string
  }

  return <Form {...form}>{/* ... */}</Form>
}
```

**Common Zod patterns:**
- `z.coerce.number()` - Converts string input to number
- `.optional().or(z.literal(""))` - Allow empty string for optional fields
- `.refine()` - Custom validation logic
- `.transform()` - Transform values after validation

Reference: [Zod Documentation](https://zod.dev/)
