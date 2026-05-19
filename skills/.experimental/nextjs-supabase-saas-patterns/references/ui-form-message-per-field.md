---
title: Include `FormMessage` for Every Field
impact: MEDIUM
impactDescription: prevents silent validation failures and unreadable error states
tags: ui, form, validation, error-display, accessibility
---

## Include `FormMessage` for Every Field

`FormMessage` from `@kit/ui/form` renders the field-level error message returned by the resolver — usually the translated string from the Zod error. Without it, the field gets a red ring but the user has no way to know *why* — was it too short, wrong format, already taken? Validation that doesn't surface is validation that doesn't help.

**Incorrect (no FormMessage — user sees red, has no clue why):**

```tsx
<FormField
  control={form.control}
  name="email"
  render={({ field }) => (
    <FormItem>
      <FormLabel>Email</FormLabel>
      <FormControl>
        <Input {...field} />
      </FormControl>
      {/* No FormMessage. Submit fails silently — input goes red, no message. */}
    </FormItem>
  )}
/>
```

**Correct (every field has FormMessage):**

```tsx
import {
  Form,
  FormField,
  FormItem,
  FormLabel,
  FormControl,
  FormMessage,
} from '@kit/ui/form';

<FormField
  control={form.control}
  name="email"
  render={({ field }) => (
    <FormItem>
      <FormLabel>
        <Trans i18nKey="auth.email" />
      </FormLabel>
      <FormControl>
        <Input type="email" data-test="email-input" {...field} />
      </FormControl>
      <FormMessage />
    </FormItem>
  )}
/>
```

**Error sources `FormMessage` shows:**

1. Zod resolver's field error (`form.formState.errors.email.message`).
2. Manually set errors via `form.setError('email', { message: '...' })`.
3. Server-action errors mapped back to the field via `result.validationErrors`.

**Translation-aware error messages:**

```ts
// schema:
export const SignInSchema = z.object({
  email: z.string().email('auth.errors.invalidEmail'),    // i18n key as message.
  password: z.string().min(8, 'auth.errors.passwordTooShort'),
});

// FormMessage automatically passes the message through Trans:
<FormMessage />
// Renders the translated string for 'auth.errors.invalidEmail'.
```

**Custom display when needed:** `FormMessage` accepts children that override the default. Use this sparingly — usually for inline help text that combines the error with a hint:

```tsx
<FormMessage>
  {form.formState.errors.password?.message ? (
    <Trans i18nKey={form.formState.errors.password.message} />
  ) : (
    <span className="text-muted-foreground">
      <Trans i18nKey="auth.passwordHint" />
    </span>
  )}
</FormMessage>
```

**Accessibility wins:** `FormMessage` is wired to the input via `aria-describedby` and `aria-invalid` — screen readers announce the error when focus enters the field. Without it, your form is inaccessible to screen-reader users.

**Empty FormMessage when no error:** the component returns `null` when there's no error, so it doesn't add layout shift. Some teams add `min-h-[1.25rem]` to keep the row height stable; the kit's components handle this in the wrapper styles.

**Surface server errors meaningfully.** When the action returns `{ error: true, message: 'teams.duplicateSlugError' }`, map it to the right field:

```ts
const { execute } = useAction(createTeamAccountAction, {
  onError: ({ error }) => {
    if (error.serverError === 'teams.duplicateSlugError') {
      form.setError('slug', { message: 'teams.duplicateSlugError' });
      // FormMessage on the slug field renders the translated error.
    }
  },
});
```

**Don't replace FormMessage with a generic toast for field errors.** Toasts don't tell the user *which* field — and on a form with five red fields, the toast disappears before the user can read them all.

Reference: [shadcn/ui Form components](https://ui.shadcn.com/docs/components/form)
