---
title: Render Optimistic UI for Appointment and Note Writes
impact: MEDIUM
impactDescription: maintains responsiveness while a write syncs to the server
tags: domain, optimistic-ui, mutations, offline
---

## Render Optimistic UI for Appointment and Note Writes

Awaiting the server before reflecting a change leaves the clinician staring at a spinner for the length of a round-trip — painful on a weak clinic connection. Applying the change to the local cache immediately and reconciling when the request settles keeps the UI responsive, with a rollback if the write fails.

**Incorrect (await the server before showing the change):**

```typescript
async function onConfirm(id: string) {
  setLoading(true)
  await api.confirmAppointment(id) // UI is frozen behind a spinner for the whole round-trip
  setLoading(false)
  refetch()
}
// On a slow connection the screen shows a spinner for seconds after each tap.
```

**Correct (optimistic update with rollback):**

```typescript
const mutation = useMutation({
  mutationFn: (id: string) => api.confirmAppointment(id),
  onMutate: async (id) => {
    await queryClient.cancelQueries({ queryKey: ['appointments'] })
    const previous = queryClient.getQueryData(['appointments'])
    queryClient.setQueryData(['appointments'], (list) => markConfirmed(list, id)) // instant
    return { previous }
  },
  onError: (_err, _id, ctx) => queryClient.setQueryData(['appointments'], ctx?.previous),
})
// The status flips immediately; a failed sync rolls back to the previous state.
```

Reference: [TanStack Query optimistic updates](https://tanstack.com/query/latest/docs/framework/react/guides/optimistic-updates)
