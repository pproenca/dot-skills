---
title: Configure Mock Response Delays
impact: MEDIUM
impactDescription: exposes loading state bugs hidden by 0ms response times
tags: mock, delay, latency, testing
---

## Configure Mock Response Delays

Configure appropriate mock delays to simulate real network conditions. Instant responses hide loading state bugs and race conditions.

**Incorrect (no delay or excessive delay):**

```typescript
// orval.config.ts
export default defineConfig({
  api: {
    output: {
      mock: {
        delay: false,  // Instant - hides loading bugs
      },
    },
  },
});
```

**Loading states never visible:**
```typescript
// This bug is invisible with instant mocks
function UserList() {
  const { data, isLoading } = useGetUsers();

  // Bug: returns null instead of loading indicator
  if (!data) return null;  // Should check isLoading

  return <ul>{data.map(u => <li>{u.name}</li>)}</ul>;
}
```

**Correct (realistic delays):**

```typescript
// orval.config.ts
export default defineConfig({
  api: {
    output: {
      mock: {
        delay: 200,  // Fixed 200ms delay
      },
    },
  },
});
```

**Variable delays for realism:**

```typescript
// orval.config.ts
export default defineConfig({
  api: {
    output: {
      mock: {
        delay: () => Math.random() * 500 + 100,  // 100-600ms
      },
    },
  },
});
```

**Per-endpoint delays:**

```typescript
// orval.config.ts
export default defineConfig({
  api: {
    output: {
      mock: {
        delay: 200,
      },
      override: {
        operations: {
          uploadFile: {
            mock: {
              delay: 2000,  // Slow upload simulation
            },
          },
        },
      },
    },
  },
});
```

**In tests, use minimal delays:**
```typescript
// test-setup.ts
const server = setupServer(...handlers);

// Override delay for faster tests
server.use(
  http.get('*', async ({ request }) => {
    // No delay in tests
  })
);
```

Reference: [Orval Mock Delay](https://orval.dev/reference/configuration/output)
