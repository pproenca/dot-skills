---
title: Limit List Data in Memory
impact: MEDIUM
impactDescription: prevents out-of-memory crashes
tags: mem, lists, pagination, windowing
---

## Limit List Data in Memory

Storing thousands of items in state consumes significant memory. Implement pagination or windowing to keep only visible data plus a buffer in memory.

**Incorrect (loading all data into memory):**

```typescript
// screens/MessageHistory.tsx
export function MessageHistory({ conversationId }: Props) {
  const [messages, setMessages] = useState<Message[]>([]);

  useEffect(() => {
    // Loads ALL messages - could be 10,000+ items
    fetchAllMessages(conversationId).then(setMessages);
  }, [conversationId]);

  return (
    <FlashList
      data={messages}  // 10,000 items in memory
      renderItem={({ item }) => <MessageBubble message={item} />}
      estimatedItemSize={80}
    />
  );
}
// Memory grows unbounded, crashes on low-end devices
```

**Correct (paginated with cleanup):**

```typescript
// screens/MessageHistory.tsx
const PAGE_SIZE = 50;

export function MessageHistory({ conversationId }: Props) {
  const [messages, setMessages] = useState<Message[]>([]);
  const [cursor, setCursor] = useState<string | null>(null);

  const loadMore = useCallback(async () => {
    const newMessages = await fetchMessages(conversationId, cursor, PAGE_SIZE);
    setMessages((prev) => {
      const combined = [...prev, ...newMessages];
      // Keep max 200 messages in memory
      return combined.slice(-200);
    });
    setCursor(newMessages[newMessages.length - 1]?.id ?? null);
  }, [conversationId, cursor]);

  return (
    <FlashList
      data={messages}
      renderItem={({ item }) => <MessageBubble message={item} />}
      onEndReached={loadMore}
      estimatedItemSize={80}
    />
  );
}
// Memory capped at ~200 items, older items garbage collected
```

**For infinite lists:** Consider using a library like `react-query` with `useInfiniteQuery` that handles pagination automatically.

Reference: [FlatList Performance](https://reactnative.dev/docs/optimizing-flatlist-configuration)
