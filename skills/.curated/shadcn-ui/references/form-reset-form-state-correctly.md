---
title: Reset Form State Correctly After Submission
impact: HIGH
impactDescription: prevents stale data and submission errors
tags: form, reset, state, react-hook-form, submission
---

## Reset Form State Correctly After Submission

After successful form submission, reset the form state to prevent stale data, duplicate submissions, and confusion about form status.

**Incorrect (form not reset after submission):**

```tsx
function ContactForm() {
  const form = useForm<ContactFormValues>({
    resolver: zodResolver(contactSchema),
  })

  const onSubmit = async (data: ContactFormValues) => {
    await submitContact(data)
    toast.success("Message sent!")
    // Form still shows old data
    // User might accidentally resubmit
  }

  return <Form {...form}>{/* ... */}</Form>
}
```

**Correct (form reset with proper state management):**

```tsx
function ContactForm() {
  const form = useForm<ContactFormValues>({
    resolver: zodResolver(contactSchema),
    defaultValues: {
      name: "",
      email: "",
      message: "",
    },
  })

  const onSubmit = async (data: ContactFormValues) => {
    try {
      await submitContact(data)
      toast.success("Message sent!")
      form.reset() // Resets to defaultValues and clears errors
    } catch (error) {
      toast.error("Failed to send message")
      // Keep form data so user can retry
    }
  }

  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)}>
        {/* Form fields */}
        <Button type="submit" disabled={form.formState.isSubmitting}>
          {form.formState.isSubmitting ? "Sending..." : "Send Message"}
        </Button>
      </form>
    </Form>
  )
}
```

**Reset patterns:**
- `form.reset()` - Reset to defaultValues
- `form.reset(newValues)` - Reset to specific values
- `form.resetField("email")` - Reset single field
- `form.clearErrors()` - Clear errors without resetting values

**For edit forms (reset to fetched data):**

```tsx
const { data: user } = useQuery(["user", userId], fetchUser)

const form = useForm<UserFormValues>({
  resolver: zodResolver(userSchema),
})

useEffect(() => {
  if (user) {
    form.reset(user) // Reset to fetched data when available
  }
}, [user, form])
```

Reference: [React Hook Form reset](https://react-hook-form.com/docs/useform/reset)
