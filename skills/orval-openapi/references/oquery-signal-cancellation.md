---
title: Pass AbortSignal for Request Cancellation
impact: MEDIUM-HIGH
impactDescription: prevents memory leaks and wasted bandwidth on unmount
tags: oquery, react-query, signal, cancellation
---

## Pass AbortSignal for Request Cancellation

Ensure your mutator passes the AbortSignal to enable automatic request cancellation. Without it, abandoned requests continue running after component unmount.

**Incorrect (signal ignored):**

```typescript
// mutator.ts
export const customInstance = <T>(config: AxiosRequestConfig): Promise<T> => {
  // Signal not passed - requests can't be cancelled
  return axios({
    url: config.url,
    method: config.method,
    data: config.data,
  }).then(({ data }) => data);
};
```

**Problem:** User navigates away, but request continues, wastes bandwidth, may update unmounted component state.

**Correct (signal forwarded):**

```typescript
// mutator.ts
import Axios, { AxiosRequestConfig } from 'axios';

export const customInstance = <T>(config: AxiosRequestConfig): Promise<T> => {
  return Axios({
    ...config,
    signal: config.signal,  // Forward the AbortSignal
  }).then(({ data }) => data);
};
```

**For fetch-based mutator:**

```typescript
// mutator.ts
interface RequestConfig {
  url: string;
  method: string;
  data?: unknown;
  signal?: AbortSignal;  // Include signal in config type
}

export const customFetch = async <T>(config: RequestConfig): Promise<T> => {
  const response = await fetch(config.url, {
    method: config.method,
    body: config.data ? JSON.stringify(config.data) : undefined,
    signal: config.signal,  // Forward to fetch
  });

  return response.json();
};
```

**React Query automatically cancels on:**
- Component unmount
- Query key change
- Manual `queryClient.cancelQueries()`

Reference: [TanStack Query Cancellation](https://tanstack.com/query/latest/docs/framework/react/guides/query-cancellation)
