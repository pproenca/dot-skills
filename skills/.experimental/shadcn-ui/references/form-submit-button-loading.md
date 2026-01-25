---
title: Disable Submit Button During Form Submission
impact: MEDIUM-HIGH
impactDescription: prevents duplicate submissions and provides user feedback
tags: form, submit, button, loading, disabled
---

## Disable Submit Button During Form Submission

Disable the submit button and show loading state during form submission. This prevents duplicate submissions and provides visual feedback.

**Incorrect (no loading state):**

```tsx
function ContactForm() {
  const handleSubmit = async (data) => {
    await submitForm(data)  // User can click multiple times
  }

  return (
    <form onSubmit={handleSubmit}>
      {/* Form fields */}
      <Button type="submit">Send Message</Button>
    </form>
  )
}
```

**Correct (loading state with feedback):**

```tsx
import { Spinner } from "@/components/ui/spinner"

function ContactForm() {
  const { handleSubmit, formState: { isSubmitting } } = useForm()

  const onSubmit = async (data) => {
    await submitForm(data)
  }

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      {/* Form fields */}
      <Button type="submit" disabled={isSubmitting}>
        {isSubmitting && <Spinner data-icon="inline-start" />}
        {isSubmitting ? "Sending..." : "Send Message"}
      </Button>
    </form>
  )
}
```

**Alternative (without React Hook Form):**

```tsx
function ContactForm() {
  const [isSubmitting, setIsSubmitting] = useState(false)

  const handleSubmit = async (e) => {
    e.preventDefault()
    setIsSubmitting(true)
    try {
      await submitForm(data)
    } finally {
      setIsSubmitting(false)
    }
  }

  return (
    <form onSubmit={handleSubmit}>
      <Button type="submit" disabled={isSubmitting}>
        {isSubmitting ? "Sending..." : "Send Message"}
      </Button>
    </form>
  )
}
```

Reference: [React Hook Form formState](https://react-hook-form.com/docs/useform/formstate)
