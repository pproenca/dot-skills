---
title: Clean Up Supabase Realtime Subscriptions in the `useEffect` Return
impact: MEDIUM-HIGH
impactDescription: prevents memory leaks and duplicate event handlers per dep change
tags: client, supabase, realtime, useeffect, cleanup
---

## Clean Up Supabase Realtime Subscriptions in the `useEffect` Return

`client.channel(...).subscribe()` opens a long-lived WebSocket-like connection. Without unsubscribing in the effect's cleanup function, every dep change leaves an orphaned channel: handlers fire multiple times per event, the connection count climbs (Supabase Realtime has per-project limits), and unmounting the component does nothing. The pattern: subscribe in the effect body, return `() => subscription.unsubscribe()`.

**Incorrect (no cleanup — channels leak on every dep change):**

```tsx
'use client';
export function NotificationsLive({ accountIds }: { accountIds: string[] }) {
  const client = useSupabase();
  const [latest, setLatest] = useState<Notification | null>(null);

  useEffect(() => {
    const channel = client.channel('notifications');
    channel
      .on('postgres_changes',
        { event: 'INSERT', schema: 'public', table: 'notifications',
          filter: `account_id=in.(${accountIds.join(', ')})` },
        (payload) => setLatest(payload.new as Notification),
      )
      .subscribe();
    // No return → no cleanup.
    // accountIds changes → new channel opened on top of the old one.
    // Each INSERT now triggers 2, 3, N handlers.
    // Component unmounts → channel stays open until GC, possibly forever.
  }, [accountIds]);

  return latest && <Toast>{latest.body}</Toast>;
}
```

**Correct (the shipped pattern — explicit cleanup):**

```tsx
// packages/features/notifications/src/hooks/use-notifications-stream.ts
'use client';
import { useEffect } from 'react';
import { useSupabase } from '@kit/supabase/hooks/use-supabase';

export function useNotificationsStream({
  onNotifications,
  accountIds,
  enabled,
}: {
  onNotifications: (notifications: Notification[]) => void;
  accountIds: string[];
  enabled: boolean;
}) {
  const client = useSupabase();

  useEffect(() => {
    if (!enabled) return;

    const channel = client.channel('notifications-channel');
    const subscription = channel
      .on(
        'postgres_changes',
        {
          event: 'INSERT',
          schema: 'public',
          filter: `account_id=in.(${accountIds.join(', ')})`,
          table: 'notifications',
        },
        (payload) => {
          onNotifications([payload.new as Notification]);
        },
      )
      .subscribe();

    return () => {
      // Cleanup: fires on unmount AND before re-running the effect.
      void subscription?.unsubscribe();
    };
  }, [client, onNotifications, accountIds, enabled]);
}
```

**`removeChannel` vs `unsubscribe`:** for a single channel, `subscription.unsubscribe()` is sufficient. If you held multiple channels by name, use `client.removeChannel(channel)` for each. Don't use `client.removeAllChannels()` — that breaks unrelated subscriptions in the same client.

**Stable callback references.** If `onNotifications` is recreated every render, the effect re-runs every render — open, close, open, close on every keypress. Wrap it in `useCallback` at the call site, or use a `useRef` for handlers that don't need to be reactive:

```ts
// In the consumer:
const onNotifications = useCallback((newOnes: Notification[]) => {
  setNotifications((prev) => [...newOnes, ...prev]);
}, []);

useNotificationsStream({ onNotifications, accountIds, enabled: true });
```

**Filter strings depend on `accountIds`.** Joining the array on every render creates a new string; if `accountIds` is the dep, fine — the effect re-runs only on actual list changes. If you pass the joined string as a dep, the same trap applies.

**Conditional subscription with `enabled`.** Putting the `if (!enabled) return;` *inside* the effect (rather than guarding the hook call) keeps the hook unconditional — Rules of Hooks require it. The cleanup still runs on `enabled` flipping false.

**Don't subscribe inside the component body.** Subscribing on every render (outside `useEffect`) creates a new channel every render and never cleans up. Subscriptions always belong in `useEffect`.

**Watch for channel name reuse.** `client.channel('notifications')` returns the same channel object for the same name across the app. If two components both call `.channel('notifications')` and only one unsubscribes, the other one's handlers stop firing because the channel was torn down. Use unique names per consumer (`'notifications-' + componentId`) when channels aren't intentionally shared.

Reference: [Supabase Realtime docs](https://supabase.com/docs/guides/realtime/postgres-changes)
