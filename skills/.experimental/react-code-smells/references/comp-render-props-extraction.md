---
title: Extract Shared Logic with Render Props or Hooks
impact: CRITICAL
impactDescription: enables reuse across 3-10 components, reduces duplication by 60%
tags: comp, render-props, hooks, composition, code-reuse
---

## Extract Shared Logic with Render Props or Hooks

Duplicated logic across components signals a missing abstraction. Extract to a custom hook (preferred) or render prop pattern.

**Code Smell Indicators:**
- Copy-pasted useEffect logic across components
- Same state + handlers duplicated in siblings
- "This looks like that other component"
- Changes require updating multiple files identically

**Incorrect (duplicated fetch logic):**

```tsx
function UserProfile({ userId }) {
  const [user, setUser] = useState(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  useEffect(() => {
    setLoading(true)
    fetchUser(userId)
      .then(setUser)
      .catch(setError)
      .finally(() => setLoading(false))
  }, [userId])

  if (loading) return <Spinner />
  if (error) return <Error error={error} />
  return <Profile user={user} />
}

function UserPosts({ userId }) {
  const [posts, setPosts] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  useEffect(() => {
    setLoading(true)
    fetchPosts(userId)
      .then(setPosts)
      .catch(setError)
      .finally(() => setLoading(false))
  }, [userId])

  if (loading) return <Spinner />
  if (error) return <Error error={error} />
  return <PostList posts={posts} />
}
```

**Correct (extracted to custom hook):**

```tsx
function useFetch<T>(fetcher: () => Promise<T>, deps: unknown[]) {
  const [data, setData] = useState<T | null>(null)
  const [status, setStatus] = useState<'loading' | 'success' | 'error'>('loading')
  const [error, setError] = useState<Error | null>(null)

  useEffect(() => {
    setStatus('loading')
    fetcher()
      .then(result => {
        setData(result)
        setStatus('success')
      })
      .catch(err => {
        setError(err)
        setStatus('error')
      })
  }, deps)

  return { data, status, error }
}

function UserProfile({ userId }) {
  const { data: user, status, error } = useFetch(
    () => fetchUser(userId),
    [userId]
  )

  if (status === 'loading') return <Spinner />
  if (status === 'error') return <Error error={error} />
  return <Profile user={user} />
}

function UserPosts({ userId }) {
  const { data: posts, status, error } = useFetch(
    () => fetchPosts(userId),
    [userId]
  )

  if (status === 'loading') return <Spinner />
  if (status === 'error') return <Error error={error} />
  return <PostList posts={posts} />
}
```

**When to use render props instead:**

```tsx
// Render props give more control over rendering
function FetchData({ fetcher, deps, children }) {
  const { data, status, error } = useFetch(fetcher, deps)
  return children({ data, status, error })
}

// Consumer controls all rendering
<FetchData fetcher={() => fetchUser(id)} deps={[id]}>
  {({ data, status, error }) => (
    status === 'loading' ? <CustomSpinner /> :
    status === 'error' ? <CustomError>{error.message}</CustomError> :
    <CustomProfile user={data} />
  )}
</FetchData>
```

**Choose hooks when:**
- Logic is reused, but rendering varies
- You want composable building blocks
- TypeScript inference is important

**Choose render props when:**
- You want to share behavior AND rendering
- The abstraction owns the render tree structure
- You're building a headless component library

Reference: [Reusing Logic with Custom Hooks](https://react.dev/learn/reusing-logic-with-custom-hooks)
