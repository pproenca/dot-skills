---
title: Apply optimistic updates for user actions
impact: MEDIUM
impactDescription: eliminates round-trip latency on user actions
tags: motion, optimistic-ui, responsiveness, feedback
---

## Apply optimistic updates for user actions

When a user taps Save or Like, native apps reflect the change instantly and reconcile with the server in the background — the interface never makes the user wait on the network to see their own action. Disabling the control and showing a spinner until the request returns makes the app feel sluggish on anything but a fast connection. Update local state immediately, then roll back if the request fails.

**Incorrect (block the UI on the network round-trip):**

```tsx
async function onToggleSave(trail: Trail) {
  setSaving(true); // spinner until the server responds — feels slow
  await api.saveTrail(trail.id);
  setSaved(true);
  setSaving(false);
}
```

**Correct (optimistic update with rollback):**

```tsx
async function onToggleSave(trail: Trail) {
  setSaved(true); // reflect the tap immediately
  try {
    await api.saveTrail(trail.id);
  } catch {
    setSaved(false); // reconcile by rolling back on failure
    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Error);
  }
}
```

**When NOT to use this pattern:**

- Irreversible or high-stakes actions (payments, deletions with no undo) — there, confirm and show real progress instead.

Reference: [TanStack Query — Optimistic Updates](https://tanstack.com/query/latest/docs/framework/react/guides/optimistic-updates)
