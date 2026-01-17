---
title: Handle Async Validation with Debouncing
impact: HIGH
impactDescription: prevents excessive API calls during validation
tags: form, async, validation, debounce, api
---

## Handle Async Validation with Debouncing

When validating against an API (username availability, email uniqueness), debounce the validation to prevent excessive network requests.

**Incorrect (API call on every keystroke):**

```tsx
const schema = z.object({
  username: z.string().min(3).refine(
    async (username) => {
      // Called on EVERY keystroke - floods server
      const response = await fetch(`/api/check-username?u=${username}`)
      return response.ok
    },
    { message: "Username already taken" }
  ),
})

function UsernameForm() {
  const form = useForm({
    resolver: zodResolver(schema),
    mode: "onChange", // Triggers validation constantly
  })

  return <Form {...form}>{/* ... */}</Form>
}
```

**Correct (debounced async validation):**

```tsx
import { useDebouncedCallback } from "use-debounce"

const baseSchema = z.object({
  username: z.string().min(3, "Username must be at least 3 characters"),
})

type FormValues = z.infer<typeof baseSchema>

function UsernameForm() {
  const [usernameError, setUsernameError] = useState<string | null>(null)
  const [isChecking, setIsChecking] = useState(false)

  const form = useForm<FormValues>({
    resolver: zodResolver(baseSchema),
    mode: "onBlur",
  })

  const checkUsername = useDebouncedCallback(async (username: string) => {
    if (username.length < 3) return

    setIsChecking(true)
    try {
      const response = await fetch(`/api/check-username?u=${username}`)
      if (!response.ok) {
        setUsernameError("Username already taken")
        form.setError("username", { message: "Username already taken" })
      } else {
        setUsernameError(null)
      }
    } finally {
      setIsChecking(false)
    }
  }, 500) // 500ms debounce

  return (
    <Form {...form}>
      <FormField
        control={form.control}
        name="username"
        render={({ field }) => (
          <FormItem>
            <FormLabel>Username</FormLabel>
            <FormControl>
              <div className="relative">
                <Input
                  {...field}
                  onChange={(e) => {
                    field.onChange(e)
                    checkUsername(e.target.value)
                  }}
                />
                {isChecking && (
                  <Loader2 className="absolute right-3 top-3 h-4 w-4 animate-spin" />
                )}
              </div>
            </FormControl>
            <FormMessage />
          </FormItem>
        )}
      />
    </Form>
  )
}
```

Reference: [use-debounce](https://github.com/xnimorz/use-debounce)
