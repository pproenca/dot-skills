---
title: Use Correct Entrypoint for Node.js
impact: CRITICAL
impactDescription: Zero mocking if wrong entrypoint; 100% test failures
tags: setup, entrypoint, node, server, msw-node
---

## Use Correct Entrypoint for Node.js

MSW v2 separates browser and Node.js entrypoints. Using the wrong import causes complete mocking failure with no interception occurring.

**Incorrect (importing from wrong path):**

```typescript
// This imports browser code into Node.js - mocking silently fails
import { setupServer } from 'msw'
import { setupWorker } from 'msw'

const server = setupServer(...handlers)
```

**Correct (using msw/node entrypoint):**

```typescript
// Node.js environments (tests, SSR) use msw/node
import { setupServer } from 'msw/node'
import { handlers } from './handlers'

export const server = setupServer(...handlers)
```

**Browser environments use msw/browser:**

```typescript
// Browser environments use msw/browser
import { setupWorker } from 'msw/browser'
import { handlers } from './handlers'

export const worker = setupWorker(...handlers)
```

**When NOT to use this pattern:**
- Never deviate from this pattern; entrypoint selection is binary based on environment

Reference: [MSW Node.js Integration](https://mswjs.io/docs/integrations/node)
