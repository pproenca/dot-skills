---
title: Use Interceptors for Cross-Cutting Concerns
impact: HIGH
impactDescription: centralizes logging, retry logic, and request timing
tags: mutator, interceptors, logging, retry
---

## Use Interceptors for Cross-Cutting Concerns

Configure Axios interceptors in your mutator for cross-cutting concerns like logging, retry logic, and request timing. This keeps generated code clean while adding observability.

**Incorrect (no interceptors):**

```typescript
// mutator.ts
export const customInstance = <T>(config: AxiosRequestConfig): Promise<T> => {
  console.log('Request:', config.url);  // Logging in wrong place
  const start = Date.now();
  return axios(config)
    .then(({ data }) => {
      console.log('Response time:', Date.now() - start);
      return data;
    });
};
```

**Correct (interceptors for observability):**

```typescript
// mutator.ts
import Axios, { AxiosRequestConfig, AxiosResponse, AxiosError } from 'axios';

export const AXIOS_INSTANCE = Axios.create({
  baseURL: import.meta.env.VITE_API_URL,
});

// Request interceptor - logging and timing
AXIOS_INSTANCE.interceptors.request.use((config) => {
  config.metadata = { startTime: Date.now() };

  if (import.meta.env.DEV) {
    console.log(`[API] ${config.method?.toUpperCase()} ${config.url}`);
  }

  return config;
});

// Response interceptor - timing and error normalization
AXIOS_INSTANCE.interceptors.response.use(
  (response: AxiosResponse) => {
    const duration = Date.now() - response.config.metadata.startTime;

    if (import.meta.env.DEV) {
      console.log(`[API] ${response.status} in ${duration}ms`);
    }

    return response;
  },
  (error: AxiosError) => {
    const duration = Date.now() - error.config?.metadata?.startTime;
    console.error(`[API] Error after ${duration}ms:`, error.message);

    return Promise.reject(error);
  }
);

export const customInstance = <T>(config: AxiosRequestConfig): Promise<T> => {
  return AXIOS_INSTANCE(config).then(({ data }) => data);
};

export type ErrorType<E> = AxiosError<E>;
```

**Benefits:**
- Clean separation of concerns
- Consistent logging across all requests
- Easy to add metrics/tracing

Reference: [Axios Interceptors](https://axios-http.com/docs/interceptors)
