---
title: Add useOptimistic for Instant Mutation Feedback
impact: HIGH
impactDescription: 0ms perceived latency for mutations, automatic rollback on failure
tags: migrate, useOptimistic, optimistic-ui, latency
---

## Add useOptimistic for Instant Mutation Feedback

Waiting for a server response before updating the UI creates perceptible latency on every user action. `useOptimistic` immediately reflects the expected state while the mutation runs in the background, rolling back automatically if the server rejects the change.

**Incorrect (UI waits for server response before reflecting the toggle):**

```tsx
"use client";

import { useState } from "react";

export function BookmarkList({ bookmarks }: { bookmarks: Bookmark[] }) {
  const [items, setItems] = useState(bookmarks);
  const [pendingId, setPendingId] = useState<string | null>(null);

  async function handleToggle(bookmarkId: string) {
    setPendingId(bookmarkId);
    try {
      // User sees no change until this resolves — 200-800ms delay
      const updated = await toggleBookmark(bookmarkId);
      setItems((prev) =>
        prev.map((bm) => (bm.id === bookmarkId ? updated : bm))
      );
    } catch {
      // No rollback needed since UI never changed, but user waited for nothing
    } finally {
      setPendingId(null);
    }
  }

  return (
    <ul>
      {items.map((bookmark) => (
        <li key={bookmark.id}>
          <span>{bookmark.title}</span>
          <button
            onClick={() => handleToggle(bookmark.id)}
            disabled={pendingId === bookmark.id}
          >
            {pendingId === bookmark.id
              ? "Saving..."
              : bookmark.isSaved ? "Unsave" : "Save"}
          </button>
        </li>
      ))}
    </ul>
  );
}
```

**Correct (useOptimistic provides instant feedback, rolls back on failure):**

```tsx
// app/actions/bookmarks.ts
"use server";

export async function toggleBookmarkAction(bookmarkId: string) {
  return await toggleBookmark(bookmarkId);
}

// components/BookmarkList.tsx
"use client";

import { useOptimistic, useTransition } from "react";
import { toggleBookmarkAction } from "@/app/actions/bookmarks";

export function BookmarkList({ bookmarks }: { bookmarks: Bookmark[] }) {
  const [isPending, startTransition] = useTransition();
  const [optimisticBookmarks, toggleOptimistic] = useOptimistic(
    bookmarks,
    (current, toggledId: string) =>
      current.map((bm) =>
        bm.id === toggledId ? { ...bm, isSaved: !bm.isSaved } : bm
      )
  );

  function handleToggle(bookmarkId: string) {
    startTransition(async () => {
      toggleOptimistic(bookmarkId); // Instant UI update — 0ms perceived latency
      await toggleBookmarkAction(bookmarkId);
    });
  }

  return (
    <ul>
      {optimisticBookmarks.map((bookmark) => (
        <li key={bookmark.id}>
          <span>{bookmark.title}</span>
          <button onClick={() => handleToggle(bookmark.id)}>
            {bookmark.isSaved ? "Unsave" : "Save"}
          </button>
        </li>
      ))}
    </ul>
  );
}
```

Reference: [useOptimistic](https://react.dev/reference/react/useOptimistic)
