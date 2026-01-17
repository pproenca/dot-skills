---
title: Prefetch Dependent Data in queryFn
impact: HIGH
impactDescription: parallelizes dependent data fetching
tags: prefetch, queryFn, parallel, dependent
---

## Prefetch Dependent Data in queryFn

When you know what data will be needed based on a response, start prefetching within the queryFn itself. This runs prefetches in parallel with the primary fetch.

**Incorrect (sequential dependent fetches):**

```typescript
function Feed() {
  const { data: feed } = useQuery({
    queryKey: ['feed'],
    queryFn: getFeed,
  })

  // Graph queries only start AFTER feed renders
  return (
    <div>
      {feed?.map(item =>
        item.type === 'GRAPH'
          ? <GraphWidget id={item.id} key={item.id} />
          : <TextWidget item={item} key={item.id} />
      )}
    </div>
  )
}

function GraphWidget({ id }: { id: string }) {
  const { data } = useQuery({
    queryKey: ['graph', id],
    queryFn: () => getGraphData(id),
  })
  // Started after feed loaded - waterfall!
}
```

**Correct (prefetch in queryFn):**

```typescript
function Feed() {
  const queryClient = useQueryClient()

  const { data: feed } = useQuery({
    queryKey: ['feed'],
    queryFn: async () => {
      const feed = await getFeed()

      // Prefetch graph data for all graph items in parallel
      feed
        .filter(item => item.type === 'GRAPH')
        .forEach(item => {
          queryClient.prefetchQuery({
            queryKey: ['graph', item.id],
            queryFn: () => getGraphData(item.id),
          })
        })

      return feed
    },
  })

  return (
    <div>
      {feed?.map(item =>
        item.type === 'GRAPH'
          ? <GraphWidget id={item.id} key={item.id} /> // Cache already warm!
          : <TextWidget item={item} key={item.id} />
      )}
    </div>
  )
}
```

**Timeline improvement:**
```
Before: Feed (100ms) → then Graph1 + Graph2 + Graph3 (150ms each) = 550ms
After:  Feed (100ms) + Graphs prefetching in parallel = 150ms total
```
