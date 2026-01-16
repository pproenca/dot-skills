---
title: Enable Headers in Generated Functions
impact: HIGH
impactDescription: enables custom headers per request without mutator hacks
tags: output, headers, authorization, customization
---

## Enable Headers in Generated Functions

Enable the `headers` option when you need to pass custom headers per request. Without it, all header customization must go through a global mutator.

**Incorrect (headers disabled):**

```typescript
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    output: {
      target: 'src/api',
      // headers not enabled - can't pass per-request headers
    },
  },
});
```

**No way to pass request-specific headers:**
```typescript
// Can't add custom header for this specific call
const { data } = useGetUserDocuments(userId);
```

**Correct (headers enabled):**

```typescript
import { defineConfig } from 'orval';

export default defineConfig({
  api: {
    output: {
      target: 'src/api',
      headers: true,
    },
  },
});
```

**Generated functions accept headers:**
```typescript
// Pass custom headers per request
const { data } = useGetUserDocuments(userId, {
  headers: {
    'X-Custom-Header': 'value',
    'Accept-Language': userLocale,
  },
});
```

**Use cases:**
- Per-request authorization tokens
- Content negotiation headers
- Correlation IDs for tracing
- Feature flags via headers

**When NOT to use this pattern:**
- All headers are global (use mutator instead)
- API doesn't require per-request header customization

Reference: [Orval headers Option](https://orval.dev/reference/configuration/output)
