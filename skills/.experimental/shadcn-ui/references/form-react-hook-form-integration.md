---
title: Integrate React Hook Form with Field Components
impact: MEDIUM-HIGH
impactDescription: type-safe forms with automatic validation and error display
tags: form, react-hook-form, validation, zod, integration
---

## Integrate React Hook Form with Field Components

Use React Hook Form with shadcn/ui Field components for type-safe validation and consistent error display. Manual form state management is error-prone.

**Incorrect (manual form state):**

```tsx
import { useState } from "react"
import { Input } from "@/components/ui/input"

function LoginForm() {
  const [email, setEmail] = useState("")
  const [errors, setErrors] = useState({})

  const handleSubmit = (e) => {
    e.preventDefault()
    if (!email.includes("@")) {
      setErrors({ email: "Invalid email" })  // Manual validation
      return
    }
    // Submit
  }

  return (
    <form onSubmit={handleSubmit}>
      <Input value={email} onChange={(e) => setEmail(e.target.value)} />
      {errors.email && <span>{errors.email}</span>}
    </form>
  )
}
```

**Correct (React Hook Form with Zod):**

```tsx
import { useForm } from "react-hook-form"
import { zodResolver } from "@hookform/resolvers/zod"
import { z } from "zod"
import { Field, FieldLabel, FieldError } from "@/components/ui/field"
import { Input } from "@/components/ui/input"

const schema = z.object({
  email: z.string().email("Enter a valid email address"),
  password: z.string().min(8, "Password must be at least 8 characters"),
})

type FormData = z.infer<typeof schema>

function LoginForm() {
  const { register, handleSubmit, formState: { errors } } = useForm<FormData>({
    resolver: zodResolver(schema),
  })

  const onSubmit = (data: FormData) => {
    // Type-safe data
  }

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <Field data-invalid={!!errors.email}>
        <FieldLabel htmlFor="email">Email</FieldLabel>
        <Input id="email" {...register("email")} aria-invalid={!!errors.email} />
        {errors.email && <FieldError>{errors.email.message}</FieldError>}
      </Field>
    </form>
  )
}
```

Reference: [shadcn/ui Forms](https://ui.shadcn.com/docs/components/form)
