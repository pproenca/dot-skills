---
title: Export Custom Error Types from Mutator
impact: HIGH
impactDescription: enables type-safe error handling in hooks
tags: mutator, errors, types, axios
---

## Export Custom Error Types from Mutator

Export `ErrorType` from your mutator to enable type-safe error handling. Without it, caught errors are typed as `unknown`, requiring unsafe type assertions.

**Incorrect (no error type export):**

```typescript
// mutator.ts
export const customInstance = <T>(config: AxiosRequestConfig): Promise<T> => {
  return axios(config).then(({ data }) => data);
};
// No ErrorType export
```

**Error handling is untyped:**
```typescript
const { error } = useCreateUser();

if (error) {
  // error is unknown - no type safety
  console.log(error.response?.data?.message);  // TypeScript error
}
```

**Correct (with error type export):**

```typescript
// mutator.ts
import Axios, { AxiosError, AxiosRequestConfig } from 'axios';

export const customInstance = <T>(config: AxiosRequestConfig): Promise<T> => {
  return Axios(config).then(({ data }) => data);
};

// Export error type for generated hooks
export type ErrorType<E> = AxiosError<E>;
```

**Type-safe error handling:**
```typescript
interface ApiError {
  message: string;
  code: string;
  errors?: Record<string, string[]>;
}

const { error } = useCreateUser<ApiError>();

if (error) {
  // error is AxiosError<ApiError> - fully typed
  const message = error.response?.data?.message;
  const fieldErrors = error.response?.data?.errors;
}
```

**For fetch-based clients:**

```typescript
// mutator.ts
export type ErrorType<E> = Error & { data?: E; status?: number };

export const customFetch = async <T>(config: RequestConfig): Promise<T> => {
  const response = await fetch(config.url, config);

  if (!response.ok) {
    const error = new Error('Request failed') as ErrorType<unknown>;
    error.data = await response.json();
    error.status = response.status;
    throw error;
  }

  return response.json();
};
```

Reference: [Orval Error Types](https://orval.dev/guides/custom-axios)
