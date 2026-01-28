---
title: Fetch Independent Data in Parallel
impact: HIGH
impactDescription: N× faster when N requests are parallelized
tags: data, parallel, Promise.all, waterfalls, network
---

## Fetch Independent Data in Parallel

Sequential fetches multiply latency. When requests don't depend on each other, execute them concurrently.

**Incorrect (sequential fetches):**

```tsx
function ProfileScreen() {
  const [user, setUser] = useState(null)
  const [posts, setPosts] = useState(null)
  const [followers, setFollowers] = useState(null)

  useEffect(() => {
    async function loadData() {
      const userData = await fetchUser()        // 200ms
      const postsData = await fetchPosts()      // 300ms
      const followersData = await fetchFollowers() // 150ms
      // Total: 650ms (sequential)

      setUser(userData)
      setPosts(postsData)
      setFollowers(followersData)
    }
    loadData()
  }, [])

  // ...
}
```

**Correct (parallel fetches):**

```tsx
function ProfileScreen() {
  const [data, setData] = useState(null)

  useEffect(() => {
    async function loadData() {
      const [user, posts, followers] = await Promise.all([
        fetchUser(),      // 200ms
        fetchPosts(),     // 300ms  (runs simultaneously)
        fetchFollowers()  // 150ms  (runs simultaneously)
      ])
      // Total: 300ms (max of all three)

      setData({ user, posts, followers })
    }
    loadData()
  }, [])

  // ...
}
```

**With TanStack Query (automatic parallelization):**

```tsx
function ProfileScreen({ userId }) {
  // These run in parallel automatically
  const userQuery = useQuery(['user', userId], () => fetchUser(userId))
  const postsQuery = useQuery(['posts', userId], () => fetchPosts(userId))
  const followersQuery = useQuery(['followers', userId], () => fetchFollowers(userId))

  const isLoading = userQuery.isLoading || postsQuery.isLoading || followersQuery.isLoading

  if (isLoading) return <Spinner />

  return (
    <View>
      <UserHeader user={userQuery.data} />
      <PostList posts={postsQuery.data} />
      <FollowerCount count={followersQuery.data.length} />
    </View>
  )
}
```

**useQueries for dynamic parallel queries:**

```tsx
function MultiProductScreen({ productIds }) {
  const results = useQueries({
    queries: productIds.map(id => ({
      queryKey: ['product', id],
      queryFn: () => fetchProduct(id),
    }))
  })

  const isLoading = results.some(r => r.isLoading)
  const products = results.map(r => r.data).filter(Boolean)

  // ...
}
```

**When sequential is necessary:**

```tsx
// When request B depends on response A
async function loadDependentData() {
  const user = await fetchUser()  // Need user.id first
  const [posts, settings] = await Promise.all([
    fetchPosts(user.id),     // Parallel after user
    fetchSettings(user.id)   // Parallel after user
  ])
}
```

**Error handling with Promise.allSettled:**

```tsx
const results = await Promise.allSettled([
  fetchUser(),
  fetchPosts(),
  fetchFollowers()
])

const user = results[0].status === 'fulfilled' ? results[0].value : null
const posts = results[1].status === 'fulfilled' ? results[1].value : []
// App continues even if some requests fail
```

Reference: [TanStack Query Parallel Queries](https://tanstack.com/query/latest/docs/react/guides/parallel-queries)
