---
title: Batch Related API Calls
impact: MEDIUM
impactDescription: reduces N requests to 1
tags: async, batching, api, network
---

## Batch Related API Calls

Making individual API calls for each item creates N network requests. Batch items into a single call when your API supports it to dramatically reduce latency.

**Incorrect (N requests for N items):**

```typescript
// screens/FriendsActivity.tsx
export function FriendsActivity({ friendIds }: Props) {
  const [activities, setActivities] = useState<Activity[]>([]);

  useEffect(() => {
    async function loadActivities() {
      // 10 friends = 10 API calls = 10 round trips
      const results = await Promise.all(
        friendIds.map((id) => fetchActivity(id))
      );
      setActivities(results.flat());
    }
    loadActivities();
  }, [friendIds]);

  return <ActivityFeed activities={activities} />;
}
// 10 requests × 100ms each = 1000ms (even with parallelization)
```

**Correct (1 batched request):**

```typescript
// screens/FriendsActivity.tsx
export function FriendsActivity({ friendIds }: Props) {
  const [activities, setActivities] = useState<Activity[]>([]);

  useEffect(() => {
    async function loadActivities() {
      // Single API call with all IDs
      const results = await fetchActivities(friendIds);
      setActivities(results);
    }
    loadActivities();
  }, [friendIds]);

  return <ActivityFeed activities={activities} />;
}
// 1 request × 150ms = 150ms (85% faster)
```

**API design pattern:**

```typescript
// Instead of: GET /activity/:userId (called N times)
// Use: POST /activities/batch with { userIds: string[] }
```

**Client-side batching:** Libraries like `dataloader` can automatically batch calls within a time window.

Reference: [DataLoader](https://github.com/graphql/dataloader)
