---
title: Handle race conditions in effect-based fetching
impact: HIGH
impactDescription: Effects can run multiple times; fetch logic must handle races between old and new requests
tags: [effect, fetching, race-conditions, async, cleanup]
---

# Handle Race Conditions in Effect-Based Fetching

When fetching data in Effects, handle the case where a new fetch starts before the old one finishes. The old response should be ignored.

## Why This Matters

Race conditions cause:
- Wrong data displayed (old request resolves last)
- State updates after unmount (memory leaks)
- Flickering between old and new data
- Subtle, hard-to-reproduce bugs

## The Race Condition

```tsx
// BUG: Race condition without handling
function Profile({ userId }: { userId: string }) {
  const [user, setUser] = useState<User | null>(null);

  useEffect(() => {
    fetchUser(userId).then(setUser);
    // If userId changes while fetching:
    // 1. Start fetch for "alice"
    // 2. userId changes to "bob"
    // 3. Start fetch for "bob"
    // 4. "bob" response arrives first → setUser(bob)
    // 5. "alice" response arrives → setUser(alice) ← BUG!
  }, [userId]);

  return <div>{user?.name}</div>;
}
```

## Solution 1: Cancelled Flag

```tsx
function Profile({ userId }: { userId: string }) {
  const [user, setUser] = useState<User | null>(null);

  useEffect(() => {
    let cancelled = false;

    async function fetchData() {
      const data = await fetchUser(userId);

      // Only update if this effect is still current
      if (!cancelled) {
        setUser(data);
      }
    }

    fetchData();

    return () => {
      cancelled = true;  // Mark as stale on cleanup
    };
  }, [userId]);

  return <div>{user?.name}</div>;
}
```

## Solution 2: AbortController

```tsx
function Profile({ userId }: { userId: string }) {
  const [user, setUser] = useState<User | null>(null);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    const controller = new AbortController();

    async function fetchData() {
      try {
        const response = await fetch(`/api/users/${userId}`, {
          signal: controller.signal,
        });
        const data = await response.json();
        setUser(data);
      } catch (e) {
        if (e.name !== 'AbortError') {
          setError(e);
        }
        // AbortError is expected when we cancel - don't set error
      }
    }

    fetchData();

    return () => {
      controller.abort();  // Cancel the request
    };
  }, [userId]);

  if (error) return <div>Error: {error.message}</div>;
  return <div>{user?.name}</div>;
}
```

## Complete Example with Loading State

```tsx
function SearchResults({ query }: { query: string }) {
  const [results, setResults] = useState<Result[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    if (!query) {
      setResults([]);
      return;
    }

    let cancelled = false;
    const controller = new AbortController();

    async function search() {
      setIsLoading(true);
      setError(null);

      try {
        const response = await fetch(`/api/search?q=${query}`, {
          signal: controller.signal,
        });
        const data = await response.json();

        if (!cancelled) {
          setResults(data.results);
        }
      } catch (e) {
        if (!cancelled && e.name !== 'AbortError') {
          setError(e);
        }
      } finally {
        if (!cancelled) {
          setIsLoading(false);
        }
      }
    }

    search();

    return () => {
      cancelled = true;
      controller.abort();
    };
  }, [query]);

  if (isLoading) return <Spinner />;
  if (error) return <ErrorMessage error={error} />;
  return <ResultsList results={results} />;
}
```

## Better: Use a Data Fetching Library

```tsx
// Libraries like React Query, SWR, RTK Query handle this automatically

// With React Query:
function Profile({ userId }: { userId: string }) {
  const { data: user, isLoading, error } = useQuery({
    queryKey: ['user', userId],
    queryFn: () => fetchUser(userId),
  });

  if (isLoading) return <Spinner />;
  if (error) return <Error error={error} />;
  return <div>{user.name}</div>;
}

// Benefits:
// - No race conditions
// - Automatic caching
// - Deduplication
// - Refetching on focus
// - Loading/error states
```

## Why Effects for Fetching is Suboptimal

```tsx
// Effect-based fetching has issues:
// 1. No caching (every mount re-fetches)
// 2. Race conditions require manual handling
// 3. No deduplication
// 4. Server components can't use them
// 5. Waterfalls (child fetches after parent)

// Consider:
// - Data fetching libraries (React Query, SWR)
// - Framework solutions (Next.js, Remix loaders)
// - Server Components (React 18+)
```

## If You Must Use Effects

```tsx
// Custom hook to encapsulate the pattern
function useFetch<T>(url: string) {
  const [data, setData] = useState<T | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    let cancelled = false;
    const controller = new AbortController();

    setIsLoading(true);

    fetch(url, { signal: controller.signal })
      .then(res => res.json())
      .then(data => {
        if (!cancelled) {
          setData(data);
          setError(null);
        }
      })
      .catch(err => {
        if (!cancelled && err.name !== 'AbortError') {
          setError(err);
        }
      })
      .finally(() => {
        if (!cancelled) {
          setIsLoading(false);
        }
      });

    return () => {
      cancelled = true;
      controller.abort();
    };
  }, [url]);

  return { data, isLoading, error };
}
```

## Key Principle

Every async operation in an Effect must account for the Effect being re-run before it completes. Use a cancelled flag or AbortController to ignore stale responses.
