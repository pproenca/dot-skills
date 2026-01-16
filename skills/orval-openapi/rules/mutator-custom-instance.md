---
title: Use Custom Mutator for HTTP Client Configuration
impact: HIGH
impactDescription: centralizes auth, error handling, and cross-cutting concerns
tags: mutator, axios, fetch, authentication
---

## Use Custom Mutator for HTTP Client Configuration

Create a custom mutator to centralize HTTP client configuration. This is where authentication, error handling, base URLs, and request/response transformations belong.

**Incorrect (no mutator, scattered configuration):**

```typescript
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    output: {
      target: 'src/api',
      // No mutator - auth must be added to every call
    },
  },
});
```

**Auth scattered across components:**
```typescript
const { data } = useGetUser(userId, {
  headers: { Authorization: `Bearer ${token}` },  // Repeated everywhere
});
```

**Correct (centralized mutator):**

```typescript
// orval.config.ts
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    output: {
      target: 'src/api',
      override: {
        mutator: {
          path: './src/api/mutator.ts',
          name: 'customInstance',
        },
      },
    },
  },
});
```

```typescript
// src/api/mutator.ts
import Axios, { AxiosRequestConfig, AxiosError } from 'axios';

export const AXIOS_INSTANCE = Axios.create({
  baseURL: import.meta.env.VITE_API_URL,
});

AXIOS_INSTANCE.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

export const customInstance = <T>(config: AxiosRequestConfig): Promise<T> => {
  return AXIOS_INSTANCE(config).then(({ data }) => data);
};

export type ErrorType<E> = AxiosError<E>;
```

**Clean component usage:**
```typescript
// Auth automatically included
const { data } = useGetUser(userId);
```

Reference: [Orval Custom Axios](https://orval.dev/guides/custom-axios)
