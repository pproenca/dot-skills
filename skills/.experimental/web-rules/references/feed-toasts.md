---
title: Use Toasts Only for Confirmations of Non-Blocking Actions
impact: HIGH
impactDescription: Toasts shown for blocking errors are missed by ~30% of users (NN/g); over-use of toasts produces "notification blindness" and reduces effectiveness by 50%+
tags: feed, toasts, sonner, notifications, aria-live, non-blocking
---

## Use Toasts Only for Confirmations of Non-Blocking Actions

Toasts (transient banners) are for *confirmations of completed actions the user just initiated* — "Project saved", "Invite sent", "Copied to clipboard". They are not for: validation errors (render inline), blocking failures (show in the page), or important alerts the user must read (use a dialog). Use `sonner` — it ships proper ARIA live regions and supports rich, action-bearing toasts.

**Incorrect (toasts used for blocking errors, validation, and important alerts):**

```tsx
'use client'
import { toast } from 'sonner'

function PaymentForm() {
  return (
    <form action={async (formData) => {
      const result = await pay(formData)
      if (!result.ok) {
        toast.error('Payment failed') // blocking error hidden in toast that auto-dismisses
        return
      }
      toast.success('Done')
    }}>
      ...
    </form>
  )
}

// Toasting validation errors instead of rendering them inline
if (email === '') toast.error('Email is required')
```

**Correct (toasts for completed non-blocking actions only; blocking errors rendered in-page):**

```tsx
// app/layout.tsx — Toaster mounted once at the root
import { Toaster } from 'sonner'

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>
        {children}
        <Toaster position="bottom-right" richColors />
      </body>
    </html>
  )
}

// Non-blocking confirmation — toast is appropriate
'use client'
import { toast } from 'sonner'

export function CopyLinkButton({ url }: { url: string }) {
  return (
    <Button
      variant="ghost"
      size="sm"
      onClick={async () => {
        await navigator.clipboard.writeText(url)
        toast.success('Link copied')
      }}
    >
      <Link2 className="mr-2 size-4" /> Copy link
    </Button>
  )
}

// Toast with an Undo action — pair with optimistic UI
import { toast } from 'sonner'
import { archiveAction, unarchiveAction } from './actions'

async function onArchive(id: string) {
  await archiveAction(id)
  toast.success('Project archived', {
    action: { label: 'Undo', onClick: () => unarchiveAction(id) },
    duration: 6000,
  })
}

// Blocking failure → render in the page, not as a toast
{state.error && (
  <div role="alert" className="rounded-md border border-destructive/30 bg-destructive/5 p-3 text-sm text-destructive">
    {state.error}
  </div>
)}
```

**Rule:**
- Toasts: completed non-blocking actions only — saves, copies, sends, archives
- Validation errors: inline with the field, `role="alert"`
- Blocking failures: in-page alert region or full error state
- Toast duration ≥ 4 s for read-only confirmations; ≥ 6 s when paired with an Undo action
- Maximum one toast on screen at a time — `sonner` queues by default
- Always-on dark/light theming via `<Toaster richColors />` — never use raw red/green outside the design tokens

Reference: [sonner docs](https://sonner.emilkowal.ski/) · [Toast — ARIA Authoring Practices](https://www.w3.org/WAI/ARIA/apg/patterns/alert/)
