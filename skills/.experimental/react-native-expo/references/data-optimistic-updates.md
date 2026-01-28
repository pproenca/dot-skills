---
title: Use Optimistic Updates for Instant Feedback
impact: MEDIUM-HIGH
impactDescription: 200-500ms perceived latency reduction
tags: data, optimistic, mutations, react-query, ux
---

## Use Optimistic Updates for Instant Feedback

Update UI immediately on user action, then sync with server. Revert if the server request fails.

**Incorrect (wait for server response):**

```tsx
function LikeButton({ postId, initialLikes }) {
  const [likes, setLikes] = useState(initialLikes)
  const [isLiking, setIsLiking] = useState(false)

  const handleLike = async () => {
    setIsLiking(true)
    try {
      const response = await likePost(postId)  // 200-500ms wait
      setLikes(response.likes)
    } finally {
      setIsLiking(false)
    }
  }

  return (
    <TouchableOpacity onPress={handleLike} disabled={isLiking}>
      <Text>{likes} likes</Text>
      {isLiking && <Spinner />}
    </TouchableOpacity>
  )
}
// User sees delay, button feels unresponsive
```

**Correct (optimistic update):**

```tsx
function LikeButton({ postId, initialLikes }) {
  const [likes, setLikes] = useState(initialLikes)

  const handleLike = async () => {
    // Optimistic: update immediately
    const previousLikes = likes
    setLikes(likes + 1)

    try {
      await likePost(postId)
    } catch (error) {
      // Revert on failure
      setLikes(previousLikes)
      Alert.alert('Failed to like post')
    }
  }

  return (
    <TouchableOpacity onPress={handleLike}>
      <Text>{likes} likes</Text>
    </TouchableOpacity>
  )
}
// Instant feedback, revert only on error
```

**With TanStack Query mutations:**

```tsx
function LikeButton({ postId }) {
  const queryClient = useQueryClient()

  const { mutate: like } = useMutation({
    mutationFn: () => likePost(postId),

    onMutate: async () => {
      // Cancel outgoing refetches
      await queryClient.cancelQueries(['post', postId])

      // Snapshot previous value
      const previousPost = queryClient.getQueryData(['post', postId])

      // Optimistically update
      queryClient.setQueryData(['post', postId], old => ({
        ...old,
        likes: old.likes + 1,
        isLiked: true,
      }))

      return { previousPost }
    },

    onError: (err, variables, context) => {
      // Revert on error
      queryClient.setQueryData(['post', postId], context.previousPost)
    },

    onSettled: () => {
      // Always refetch after error or success
      queryClient.invalidateQueries(['post', postId])
    },
  })

  return (
    <TouchableOpacity onPress={() => like()}>
      <Text>Like</Text>
    </TouchableOpacity>
  )
}
```

**Optimistic list updates:**

```tsx
function TodoList() {
  const queryClient = useQueryClient()

  const { mutate: addTodo } = useMutation({
    mutationFn: createTodo,

    onMutate: async (newTodo) => {
      await queryClient.cancelQueries(['todos'])
      const previousTodos = queryClient.getQueryData(['todos'])

      // Add optimistic todo with temporary ID
      queryClient.setQueryData(['todos'], old => [
        ...old,
        { ...newTodo, id: 'temp-' + Date.now(), isPending: true }
      ])

      return { previousTodos }
    },

    onError: (err, newTodo, context) => {
      queryClient.setQueryData(['todos'], context.previousTodos)
    },

    onSuccess: (result, variables, context) => {
      // Replace temp item with real data
      queryClient.setQueryData(['todos'], old =>
        old.map(todo =>
          todo.id.startsWith('temp-') ? result : todo
        )
      )
    },
  })

  // ...
}
```

**When NOT to use optimistic updates:**
- Financial transactions
- Irreversible actions
- Actions requiring server validation
- When error recovery is complex

Reference: [TanStack Query Optimistic Updates](https://tanstack.com/query/latest/docs/react/guides/optimistic-updates)
