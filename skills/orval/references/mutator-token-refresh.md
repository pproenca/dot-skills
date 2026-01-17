---
title: Handle Token Refresh in Mutator
impact: HIGH
impactDescription: prevents 401 cascades, automatic retry on token expiry
tags: mutator, authentication, refresh, jwt
---

## Handle Token Refresh in Mutator

Implement token refresh logic in your mutator's interceptors. This handles expired tokens transparently without requiring retry logic in every component.

**Incorrect (no refresh handling):**

```typescript
// mutator.ts
AXIOS_INSTANCE.interceptors.request.use((config) => {
  const token = localStorage.getItem('accessToken');
  config.headers.Authorization = `Bearer ${token}`;
  return config;
});
// 401 errors bubble up to every component
```

**Correct (automatic token refresh):**

```typescript
// mutator.ts
import Axios, { AxiosError, AxiosRequestConfig } from 'axios';

let isRefreshing = false;
let failedQueue: Array<{ resolve: (t: string) => void; reject: (e: Error) => void }> = [];

const processQueue = (error: Error | null, token: string | null) => {
  failedQueue.forEach((p) => error ? p.reject(error) : p.resolve(token!));
  failedQueue = [];
};

export const AXIOS_INSTANCE = Axios.create({ baseURL: import.meta.env.VITE_API_URL });

AXIOS_INSTANCE.interceptors.response.use(
  (response) => response,
  async (error: AxiosError) => {
    const originalRequest = error.config as AxiosRequestConfig & { _retry?: boolean };

    if (error.response?.status === 401 && !originalRequest._retry) {
      if (isRefreshing) {
        return new Promise((resolve, reject) => {
          failedQueue.push({ resolve, reject });
        }).then((token) => {
          originalRequest.headers!.Authorization = `Bearer ${token}`;
          return AXIOS_INSTANCE(originalRequest);
        });
      }

      originalRequest._retry = true;
      isRefreshing = true;

      try {
        const { data } = await Axios.post('/auth/refresh', {
          refreshToken: localStorage.getItem('refreshToken'),
        });
        localStorage.setItem('accessToken', data.accessToken);
        processQueue(null, data.accessToken);
        originalRequest.headers!.Authorization = `Bearer ${data.accessToken}`;
        return AXIOS_INSTANCE(originalRequest);
      } catch (refreshError) {
        processQueue(refreshError as Error, null);
        localStorage.clear();
        window.location.href = '/login';
        return Promise.reject(refreshError);
      } finally {
        isRefreshing = false;
      }
    }
    return Promise.reject(error);
  }
);

export const customInstance = <T>(config: AxiosRequestConfig): Promise<T> => {
  return AXIOS_INSTANCE(config).then(({ data }) => data);
};
```

Reference: [Axios Interceptors](https://axios-http.com/docs/interceptors)
