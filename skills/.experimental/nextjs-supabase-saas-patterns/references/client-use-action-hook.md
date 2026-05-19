---
title: Call Server Actions with `useAction` from `next-safe-action/hooks`
impact: MEDIUM-HIGH
impactDescription: prevents per-form reimplementation of loading/error/typing
tags: client, server-action, useaction, next-safe-action
---

## Call Server Actions with `useAction` from `next-safe-action/hooks`

`useAction(action)` returns `{ execute, executeAsync, isPending, result, ... }` — `execute` is typed by the action's Zod schema (wrong input shape fails to compile), `isPending` tracks the request, `result` holds `.data` on success and `.serverError` on failure, and `onSuccess`/`onError` callbacks let you toast or navigate. Calling actions with raw `fetch` (or even `startTransition` around the bare function) loses every guarantee — types, loading state, error envelopes, and the standardised result shape.

**Incorrect (raw fetch / bare action call — reimplementing everything):**

```tsx
'use client';
export function ContactForm() {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const onSubmit = async (data: ContactInput) => {
    setLoading(true);
    setError(null);
    try {
      // Direct call to a 'use server' function: bypasses safe-action's pipeline.
      // No client-side validation, no typed result envelope, easy to misuse.
      const res = await sendContactEmail(data);
      if (!res?.ok) setError('Failed');
    } catch (e) {
      setError('Failed');
    } finally {
      setLoading(false);
    }
  };
  // Now do this for every form. Each one with subtly different error handling.
}
```

**Correct (the shipped pattern — `useAction` provides all of it):**

```tsx
// app/[locale]/(marketing)/contact/_components/contact-form.tsx
'use client';

import { useAction } from 'next-safe-action/hooks';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';

import { ContactEmailSchema } from '../_lib/contact-email.schema';
import { sendContactEmail } from '../_lib/server/server-actions';

export function ContactForm() {
  const [state, setState] = useState({ success: false, error: false });

  const { execute, isPending } = useAction(sendContactEmail, {
    onSuccess: () => setState({ success: true, error: false }),
    onError: () => setState({ error: true, success: false }),
  });

  const form = useForm({
    resolver: zodResolver(ContactEmailSchema),
    defaultValues: { name: '', email: '', message: '', captchaToken: '' },
  });

  return (
    <Form {...form}>
      <form
        onSubmit={form.handleSubmit((data) => execute(data))}
      >
        {/* fields with FormMessage */}
        <Button type="submit" disabled={isPending}>
          {isPending ? <Spinner /> : <Trans i18nKey="contact.submit" />}
        </Button>
      </form>
    </Form>
  );
}
```

**Why `execute` and not `executeAsync`:**

| `execute(input)` | Fires the action. Doesn't return a promise you await. Use with `onSuccess`/`onError`. |
| `executeAsync(input)` | Returns a promise. Use when you need to `await` (e.g., to chain actions or use the result inline). |

For form submissions, `execute` + callbacks is the idiomatic pattern. For "do A, then do B with A's result," `executeAsync`.

**`isPending` for the button state:**

```tsx
<Button type="submit" disabled={isPending}>
  {isPending ? <Spinner /> : 'Submit'}
</Button>
```

Don't toggle a local `useState` for this — `isPending` is already correctly debounced and tracks the safe-action lifecycle.

**`result.serverError` for displaying failures:**

```tsx
const { execute, result } = useAction(action, {
  onError: ({ error }) => {
    if (error.serverError) toast.error(error.serverError);
    if (error.validationErrors) /* field-level errors */;
  },
});

// Or render inline:
{result?.serverError && <Alert variant="destructive">{result.serverError}</Alert>}
```

**Typed input — no `as any` needed:**

```ts
// The action defines: .inputSchema(ContactEmailSchema)
// execute is typed as: (input: z.input<typeof ContactEmailSchema>) => void
execute({ name: 'Pedro', email: 'p@p.com', message: '...', captchaToken: '...' });
//        ^^^^^^^^^^^^^^^ wrong type here is a compile error
```

**Form-level integration:** use `form.handleSubmit((data) => execute(data))`. The Zod schema is the same on both sides (see the schema-separate-file rule), so the data is already validated by RHF when it reaches `execute`.

**One `useAction` per action.** Resist the urge to wrap multiple actions in one hook — the `isPending` state would be ambiguous. One hook per mutation is the clean shape.

**Optimistic updates:** combine with React Query's `useMutation` cache-update pattern, OR use safe-action v8+'s `optimisticData` parameter:

```ts
const { execute } = useAction(toggleStarAction, {
  optimisticData: (input) => ({ starred: input.value }),
});
```

Reference: [next-safe-action `useAction`](https://next-safe-action.dev/docs/execute-actions/hooks/useaction)
