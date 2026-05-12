---
title: Every Route Segment Has `error.tsx` With a Try-Again Action
impact: HIGH
impactDescription: Without an `error.tsx`, runtime errors trip the global error UI and lose all state; users abandon flows at 60-80% rate when an error has no recovery action
tags: feed, error-states, error-tsx, error-boundary, recovery
---

## Every Route Segment Has `error.tsx` With a Try-Again Action

Each route segment that fetches data or runs Server Actions must include an `error.tsx`. The component receives `error` and `reset`; render a short human explanation plus a `Try again` button that calls `reset()`. For Server Action errors, return structured error state from the action and render inline near the field. Never display a raw stack trace to end users.

**Incorrect (no error boundary; raw error message; no recovery path):**

```tsx
// app/projects/page.tsx
export default async function Projects() {
  const projects = await getProjects() // throws if API is down
  // No error.tsx — Next.js falls back to the global error page and nukes the layout
  return <ProjectList projects={projects} />
}
```

**Correct (route-level error boundary + Try-Again, action-level structured errors):**

```tsx
// app/projects/error.tsx
'use client'
import { AlertCircle } from 'lucide-react'
import { useEffect } from 'react'

export default function ProjectsError({
  error,
  reset,
}: {
  error: Error & { digest?: string }
  reset: () => void
}) {
  useEffect(() => {
    // Log to your observability tool (Sentry, Datadog, etc.) — include digest
    console.error('Projects error', error)
  }, [error])

  return (
    <div role="alert" className="mx-auto max-w-md text-center p-12 space-y-4">
      <AlertCircle className="mx-auto size-10 text-destructive" aria-hidden="true" />
      <h2 className="text-lg font-semibold">We couldn't load your projects</h2>
      <p className="text-sm text-muted-foreground">
        This is usually temporary. Try again — if it keeps happening, contact support.
      </p>
      <Button onClick={reset} className="mt-2">Try again</Button>
      {error.digest && (
        <p className="text-xs text-muted-foreground">Reference: {error.digest}</p>
      )}
    </div>
  )
}
```

**Server Action error pattern (validation + recoverable failures):**

```tsx
// app/projects/actions.ts
'use server'
import { z } from 'zod'

const schema = z.object({ name: z.string().min(1, 'Name is required') })

export async function createProject(_prev: unknown, formData: FormData) {
  const parsed = schema.safeParse(Object.fromEntries(formData))
  if (!parsed.success) return { ok: false, fieldErrors: parsed.error.flatten().fieldErrors }
  try {
    await db.project.create({ data: parsed.data })
    revalidateTag('projects')
    return { ok: true }
  } catch (e) {
    return { ok: false, formError: 'Something went wrong. Please try again.' }
  }
}

// app/projects/new-project-form.tsx
'use client'
import { useActionState } from 'react'
export function NewProjectForm() {
  const [state, action, pending] = useActionState(createProject, { ok: false })
  return (
    <form action={action} className="space-y-2">
      <input name="name" required aria-invalid={!!state.fieldErrors?.name} />
      {state.fieldErrors?.name && (
        <p role="alert" className="text-sm text-destructive">{state.fieldErrors.name[0]}</p>
      )}
      {state.formError && (
        <p role="alert" className="text-sm text-destructive">{state.formError}</p>
      )}
      <Button type="submit" disabled={pending}>{pending ? 'Creating…' : 'Create'}</Button>
    </form>
  )
}
```

**Rule:**
- Every route segment that fetches data has an `error.tsx` (Client Component, marked `'use client'`)
- The error component shows: a human message, a `Try again` button calling `reset()`, and the `error.digest` for support
- Server Actions return structured error state (`{ ok, fieldErrors, formError }`) — never throw uncaught
- Validation errors render inline with `role="alert"` and `aria-invalid`
- Log to your observability tool from within `error.tsx`'s `useEffect` — include user/session context

Reference: [Error handling — Next.js 16](https://nextjs.org/docs/app/building-your-application/routing/error-handling)
