---
title: Subscribe with subscriptionOptions on the new client
tags: client, subscriptions, tanstack-query
---

## Subscribe with subscriptionOptions on the new client

The remembered shape for consuming a subscription is `trpc.chat.onMessage.useSubscription({ roomId }, { onData })` — a hook hanging off the procedure, the way `createTRPCReact` exposed it. That hook does not exist on the `@trpc/tanstack-react-query` proxy, which returns option factories rather than hooks, so a component written the old way fails on a codebase that migrated cleanly everywhere else. It is the easiest of the client flips to miss, because subscriptions are usually a handful of call sites next to hundreds of queries: the migration reads as done, and the one realtime component breaks at runtime in whatever view happens to mount it.

The proxy supplies the options and `useSubscription` — imported from `@trpc/tanstack-react-query`, not read off the proxy — consumes them, exactly as `queryOptions()` pairs with `useQuery` and `mutationOptions()` with `useMutation`.

```tsx
// components/chat-room.tsx
import { useState } from 'react';
import { useSubscription } from '@trpc/tanstack-react-query';
import { useTRPC } from '~/trpc/react';
import type { ChatMessage } from '~/server/routers/chat';

export function ChatRoom({ roomId }: { roomId: string }) {
  const trpc = useTRPC();
  const [messages, setMessages] = useState<ChatMessage[]>([]);

  const { status } = useSubscription(
    trpc.chat.onMessage.subscriptionOptions(
      { roomId },
      {
        onData: (message) => {
          setMessages((current) => [...current, message]);
        },
        onError: (error) => {
          console.error('chat stream dropped', error);
        },
      },
    ),
  );

  return (
    <div>
      {status === 'connecting' && <ConnectingBanner />}
      <MessageList messages={messages} />
    </div>
  );
}
```

The input goes in the first argument and the handlers in the second, which is the same split as the old hook — the diff is where the call happens, not what you pass it. `useSubscription` returns connection state (`status`, `error`, `reset`) rather than accumulated data, so the component still owns the buffer.

Reference: [tRPC — TanStack React Query usage: subscriptions](https://trpc.io/docs/client/tanstack-react-query/usage)
