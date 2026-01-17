---
title: Enable Infinite Queries for Paginated Endpoints
impact: MEDIUM-HIGH
impactDescription: eliminates manual page state management and data accumulation logic
tags: oquery, react-query, infinite, pagination
---

## Enable Infinite Queries for Paginated Endpoints

Enable infinite query generation for paginated endpoints. Manual pagination with regular queries leads to complex state management and poor UX.

**Incorrect (manual pagination):**

```typescript
// orval.config.ts - only useQuery enabled
export default defineConfig({
  api: {
    output: {
      client: 'react-query',
    },
  },
});
```

**Manual pagination state:**
```typescript
const [page, setPage] = useState(1);
const { data } = useGetUsers({ page, limit: 20 });
const [allUsers, setAllUsers] = useState<User[]>([]);

useEffect(() => {
  if (data) {
    setAllUsers(prev => [...prev, ...data.users]);  // Manual accumulation
  }
}, [data]);

const loadMore = () => setPage(p => p + 1);
```

**Correct (infinite queries enabled):**

```typescript
// orval.config.ts
export default defineConfig({
  api: {
    output: {
      client: 'react-query',
      override: {
        query: {
          useQuery: true,
          useInfinite: true,
          useInfiniteQueryParam: 'page',  // Which param controls pagination
        },
      },
    },
  },
});
```

**Clean infinite scroll:**
```typescript
const {
  data,
  fetchNextPage,
  hasNextPage,
  isFetchingNextPage,
} = useGetUsersInfinite({ limit: 20 });

// All pages automatically accumulated
const allUsers = data?.pages.flatMap(page => page.users) ?? [];

return (
  <div>
    {allUsers.map(user => <UserCard key={user.id} user={user} />)}
    {hasNextPage && (
      <button onClick={() => fetchNextPage()} disabled={isFetchingNextPage}>
        {isFetchingNextPage ? 'Loading...' : 'Load More'}
      </button>
    )}
  </div>
);
```

Reference: [TanStack Infinite Queries](https://tanstack.com/query/latest/docs/framework/react/guides/infinite-queries)
