---
title: Mutations whose UI outcome is predictable apply optimistically with `useOptimistic` — automatic rollback on server failure
impact: MEDIUM
impactDescription: 0ms perceived latency for high-frequency actions (likes, toggles, add-to-cart); automatic revert on failure with no manual snapshot/restore
tags: action, optimistic-ui, useOptimistic, instant-feedback
---

## Mutations whose UI outcome is predictable apply optimistically with `useOptimistic` — automatic rollback on server failure

**Pattern intent:** "click → wait 200-500ms → see result" feels sluggish. For high-frequency UI actions (likes, toggles, follow, add-to-cart) where the new state is deterministic, apply the change immediately and let `useOptimistic` revert if the server rejects.

### Shapes to recognize

- A `'Like'` button that calls a Server Action and `await`s before updating UI — the heart icon flashes ~300ms after the click.
- A toggle that shows a spinner during submission — the spinner is the only feedback for an instant operation.
- A "favorite" button storing state in `useState`, manually mutating on click, manually rolling back in `catch` — handles the case but inconsistent across the app.
- A shopping-cart "add" button that disables itself for ~500ms post-click — uses `useTransition` for pending state but doesn't update the cart count optimistically.
- A workaround using SWR's `mutate(...)` with optimistic data — works in client-data-fetching contexts; `useOptimistic` is the React-native equivalent that pairs cleanly with Server Actions.

The canonical resolution: `const [optimistic, addOptimistic] = useOptimistic(real, reducer)`. Call `addOptimistic(value)` inside the form action *before* `await`-ing the server call. React reverts automatically when the action settles, regardless of outcome.

**Incorrect (waiting for server response):**

```typescript
'use client'

import { useState } from 'react'

export function LikeButton({ postId, initialLikes }: { postId: string; initialLikes: number }) {
  const [likes, setLikes] = useState(initialLikes)
  const [isLiking, setIsLiking] = useState(false)

  async function handleLike() {
    setIsLiking(true)
    const newLikes = await likePost(postId)  // Wait for server
    setLikes(newLikes)
    setIsLiking(false)
  }

  return (
    <button onClick={handleLike} disabled={isLiking}>
      {likes} {isLiking ? '...' : '❤️'}
    </button>
  )
}
// 200-500ms delay before UI updates
```

**Correct (optimistic update):**

```typescript
'use client'

import { useOptimistic } from 'react'
import { likePost } from './actions'

export function LikeButton({ postId, initialLikes }: { postId: string; initialLikes: number }) {
  const [optimisticLikes, addOptimisticLike] = useOptimistic(
    initialLikes,
    (state, _) => state + 1
  )

  async function handleLike() {
    addOptimisticLike(null)  // Instant UI update
    await likePost(postId)   // Server update in background
    // If fails, React reverts automatically
  }

  return (
    <form action={handleLike}>
      <button type="submit">
        {optimisticLikes} ❤️
      </button>
    </form>
  )
}
// Instant feedback, reverts on failure
```

**When to use:**
- Like/vote buttons
- Adding items to cart
- Toggling favorites
- Any action where instant feedback improves UX
