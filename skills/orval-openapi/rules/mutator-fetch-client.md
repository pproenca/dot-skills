---
title: Use Fetch Mutator for Smaller Bundle Size
impact: MEDIUM-HIGH
impactDescription: eliminates axios dependency, 10-20KB bundle savings
tags: mutator, fetch, bundle, native
---

## Use Fetch Mutator for Smaller Bundle Size

Use native fetch instead of Axios when you don't need Axios-specific features. This eliminates a dependency and reduces bundle size.

**Incorrect (Axios for simple use case):**

```typescript
// mutator.ts
import Axios, { AxiosRequestConfig } from 'axios';  // +15KB

export const AXIOS_INSTANCE = Axios.create({
  baseURL: import.meta.env.VITE_API_URL,
});

export const customInstance = <T>(config: AxiosRequestConfig): Promise<T> => {
  return AXIOS_INSTANCE(config).then(({ data }) => data);
};
```

**Correct (native fetch):**

```typescript
// mutator.ts
const BASE_URL = import.meta.env.VITE_API_URL;

interface RequestConfig {
  url: string;
  method: 'GET' | 'POST' | 'PUT' | 'DELETE' | 'PATCH';
  params?: Record<string, string>;
  data?: unknown;
  headers?: Record<string, string>;
  signal?: AbortSignal;
}

export const customFetch = async <T>(config: RequestConfig): Promise<T> => {
  const { url, method, params, data, headers, signal } = config;

  const queryString = params
    ? `?${new URLSearchParams(params).toString()}`
    : '';

  const token = localStorage.getItem('accessToken');

  const response = await fetch(`${BASE_URL}${url}${queryString}`, {
    method,
    headers: {
      'Content-Type': 'application/json',
      ...(token && { Authorization: `Bearer ${token}` }),
      ...headers,
    },
    ...(data && { body: JSON.stringify(data) }),
    signal,
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new FetchError(response.status, error);
  }

  return response.json();
};

export class FetchError extends Error {
  constructor(public status: number, public data: unknown) {
    super(`HTTP ${status}`);
  }
}

export type ErrorType<E> = FetchError & { data: E };
```

**When to use Axios instead:**
- Need request/response interceptors with complex chaining
- Need upload progress tracking
- Need automatic request cancellation on unmount

Reference: [Orval Fetch Client](https://orval.dev/guides/fetch-client)
