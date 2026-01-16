---
title: Enable Streaming SSR with Suspense
impact: MEDIUM
impactDescription: 200-400ms faster TTFB, progressive content delivery
tags: render, streaming, ssr, suspense, performance
---

## Enable Streaming SSR with Suspense

React 19 streams HTML progressively with Suspense. Content inside Suspense boundaries streams as it becomes available, reducing Time to First Byte and improving perceived performance.

**Incorrect (all-or-nothing SSR):**

```tsx
// Everything must complete before any HTML is sent
export default async function Page() {
  const user = await fetchUser()
  const posts = await fetchPosts()
  const recommendations = await fetchRecommendations()  // Slow!

  return (
    <div>
      <Header user={user} />
      <PostFeed posts={posts} />
      <Recommendations items={recommendations} />
    </div>
  )
}
// Client waits for slowest fetch before seeing anything
```

**Correct (progressive streaming):**

```tsx
export default function Page() {
  return (
    <div>
      <Suspense fallback={<HeaderSkeleton />}>
        <Header />
      </Suspense>

      <Suspense fallback={<FeedSkeleton />}>
        <PostFeed />
      </Suspense>

      <Suspense fallback={<RecommendationsSkeleton />}>
        <Recommendations />  {/* Streams when ready */}
      </Suspense>
    </div>
  )
}

async function Header() {
  const user = await fetchUser()
  return <header>{user.name}</header>
}

async function PostFeed() {
  const posts = await fetchPosts()
  return <div>{posts.map(p => <Post key={p.id} post={p} />)}</div>
}

async function Recommendations() {
  const items = await fetchRecommendations()
  return <aside>{items.map(i => <Rec key={i.id} item={i} />)}</aside>
}
// Fast sections appear immediately, slow sections stream in
```

**Benefits:**
- First content visible faster (lower TTFB)
- Progressive hydration as content arrives
- Slow data doesn't block fast content

Reference: [Streaming SSR](https://react.dev/reference/react-dom/server/renderToReadableStream)
