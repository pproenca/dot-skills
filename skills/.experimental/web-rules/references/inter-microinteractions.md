---
title: Confirm Every Interaction With Visual Feedback Within 100 ms
impact: CRITICAL
impactDescription: Feedback delays > 100 ms feel "broken" (Nielsen's response-time limits); transitions ≥ 400 ms feel laggy; abrupt state changes cause double-clicks in 25%+ of users
tags: inter, microinteractions, feedback, transitions, optimistic-ui, useoptimistic
---

## Confirm Every Interaction With Visual Feedback Within 100 ms

Every click, focus, hover, or form submission must produce a visible change in under 100 ms. For server-bound actions, use React 19's `useOptimistic` to render the expected result immediately; reconcile when the action resolves. Disabled-but-pending submit buttons must show a spinner, never a frozen state. Hover and active states use `transition-colors duration-150`; abrupt changes feel cheap.

**Incorrect (no pending state, button "freezes" while waiting on server):**

```tsx
'use client'
import { useState } from 'react'

function LikeButton({ postId, initialLiked }: { postId: string; initialLiked: boolean }) {
  const [liked, setLiked] = useState(initialLiked)
  return (
    <button
      onClick={async () => {
        await toggleLike(postId) // 400 ms round-trip — UI shows nothing
        setLiked(!liked)
      }}
    >
      <Heart className={liked ? 'fill-rose-500' : ''} />
    </button>
  )
}
```

**Correct (optimistic update + transition + pending indicator):**

```tsx
'use client'
import { useOptimistic, useTransition } from 'react'

function LikeButton({ postId, initialLiked }: { postId: string; initialLiked: boolean }) {
  const [optimisticLiked, setOptimisticLiked] = useOptimistic(initialLiked)
  const [pending, startTransition] = useTransition()

  return (
    <button
      onClick={() => {
        startTransition(async () => {
          setOptimisticLiked(!optimisticLiked) // < 16 ms — next paint
          await toggleLikeAction(postId)
        })
      }}
      className="inline-flex size-11 items-center justify-center rounded-full transition-colors duration-150 hover:bg-rose-50 active:scale-95"
      aria-pressed={optimisticLiked}
      aria-label={optimisticLiked ? 'Unlike' : 'Like'}
    >
      <Heart
        className={`size-5 transition-colors duration-150 ${
          optimisticLiked ? 'fill-rose-500 text-rose-500' : 'text-muted-foreground'
        } ${pending ? 'animate-pulse' : ''}`}
      />
    </button>
  )
}
```

**Form submit pattern:**

```tsx
'use client'
import { useFormStatus } from 'react-dom'

function SubmitButton({ children }: { children: React.ReactNode }) {
  const { pending } = useFormStatus()
  return (
    <Button type="submit" disabled={pending}>
      {pending && <Loader2 className="mr-2 size-4 animate-spin" />}
      {children}
    </Button>
  )
}
```

**Rule:**
- Use `useOptimistic` for any user-initiated mutation that has a predictable outcome
- Use `useFormStatus` to show pending state inside form submit buttons
- Every interactive element has `:hover`, `:focus-visible`, and `:active` styles
- Standard transition: `transition-colors duration-150`; never exceed `duration-300` for state changes
- Respect [acc-reduce-motion](acc-reduce-motion.md) — disable transforms and translations when reduced motion is requested

Reference: [Response Times: The 3 Important Limits — Nielsen Norman Group](https://www.nngroup.com/articles/response-times-3-important-limits/)
