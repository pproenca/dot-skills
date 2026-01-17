---
title: Memoize List Item Components
impact: HIGH
impactDescription: prevents re-render of all items when list data changes
tags: list, memo, renderItem, optimization
---

## Memoize List Item Components

Wrap list item components in `React.memo()` to prevent re-rendering unchanged items when the list data updates. This is essential for smooth scrolling performance.

**Incorrect (all items re-render on any change):**

```typescript
import { FlashList } from '@shopify/flash-list'

function MessageItem({ message, onDelete }) {
  return (
    <View style={styles.messageContainer}>
      <Text style={styles.sender}>{message.sender}</Text>
      <Text style={styles.content}>{message.content}</Text>
      <Text style={styles.time}>{formatTime(message.timestamp)}</Text>
      <IconButton icon="delete" onPress={() => onDelete(message.id)} />
    </View>
  )
}

function MessageList({ messages, onDeleteMessage }) {
  return (
    <FlashList
      data={messages}
      renderItem={({ item }) => (
        <MessageItem message={item} onDelete={onDeleteMessage} />
      )}
      estimatedItemSize={80}
    />
  )
}
// All MessageItems re-render when any message changes
```

**Correct (memoized items only re-render when their props change):**

```typescript
import { memo, useCallback } from 'react'
import { FlashList } from '@shopify/flash-list'

const MessageItem = memo(function MessageItem({ message, onDelete }) {
  return (
    <View style={styles.messageContainer}>
      <Text style={styles.sender}>{message.sender}</Text>
      <Text style={styles.content}>{message.content}</Text>
      <Text style={styles.time}>{formatTime(message.timestamp)}</Text>
      <IconButton icon="delete" onPress={() => onDelete(message.id)} />
    </View>
  )
})

function MessageList({ messages, onDeleteMessage }) {
  const renderItem = useCallback(({ item }) => (
    <MessageItem message={item} onDelete={onDeleteMessage} />
  ), [onDeleteMessage])

  return (
    <FlashList
      data={messages}
      renderItem={renderItem}
      estimatedItemSize={80}
    />
  )
}
// Only changed MessageItems re-render
```

**Custom comparison for complex items:**

```typescript
const MessageItem = memo(
  function MessageItem({ message, onDelete }) {
    // ... component body
  },
  (prevProps, nextProps) => {
    // Only re-render if these specific fields change
    return (
      prevProps.message.id === nextProps.message.id &&
      prevProps.message.content === nextProps.message.content &&
      prevProps.message.isRead === nextProps.message.isRead
    )
  }
)
```

Reference: [React.memo Documentation](https://react.dev/reference/react/memo)
