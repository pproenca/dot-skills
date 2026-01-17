---
title: Use Optimistic Updates for Instant Feedback
impact: MEDIUM
impactDescription: instant UI response, better perceived performance
tags: action, optimistic, useOptimistic, mutation
---

## Use Optimistic Updates for Instant Feedback

Use `useOptimistic` to update UI immediately before the server confirms. If the action fails, React reverts to the previous state.

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
