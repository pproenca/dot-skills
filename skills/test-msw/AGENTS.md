# MSW (Mock Service Worker)

**Version 1.0.0**  
mswjs  
January 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive API mocking guide for MSW v2 applications, designed for AI agents and LLMs. Contains 45+ rules across 8 categories, prioritized by impact from critical (setup, handler architecture) to incremental (debugging). Each rule includes detailed explanations, real-world examples comparing incorrect vs. correct implementations, and specific impact metrics to guide automated refactoring and code generation.

---

## Table of Contents

1. [Setup & Initialization](#1-setup-initialization) — **CRITICAL**
   - 1.1 [Commit Worker Script to Version Control](#11-commit-worker-script-to-version-control)
   - 1.2 [Configure Server Lifecycle in Test Setup](#12-configure-server-lifecycle-in-test-setup)
   - 1.3 [Configure TypeScript for MSW v2](#13-configure-typescript-for-msw-v2)
   - 1.4 [Configure Unhandled Request Behavior](#14-configure-unhandled-request-behavior)
   - 1.5 [Require Node.js 18+ for MSW v2](#15-require-nodejs-18-for-msw-v2)
   - 1.6 [Use Correct Entrypoint for Node.js](#16-use-correct-entrypoint-for-nodejs)
2. [Handler Architecture](#2-handler-architecture) — **CRITICAL**
   - 2.1 [Define Happy Path Handlers as Baseline](#21-define-happy-path-handlers-as-baseline)
   - 2.2 [Destructure Resolver Arguments Correctly](#22-destructure-resolver-arguments-correctly)
   - 2.3 [Explicitly Parse Request Bodies](#23-explicitly-parse-request-bodies)
   - 2.4 [Extract Shared Response Logic into Resolvers](#24-extract-shared-response-logic-into-resolvers)
   - 2.5 [Group Handlers by Domain](#25-group-handlers-by-domain)
   - 2.6 [Share Handlers Across Environments](#26-share-handlers-across-environments)
   - 2.7 [Use Absolute URLs in Handlers](#27-use-absolute-urls-in-handlers)
   - 2.8 [Use MSW v2 Response Syntax](#28-use-msw-v2-response-syntax)
3. [Test Integration](#3-test-integration) — **HIGH**
   - 3.1 [Avoid Direct Request Assertions](#31-avoid-direct-request-assertions)
   - 3.2 [Clear Request Library Caches Between Tests](#32-clear-request-library-caches-between-tests)
   - 3.3 [Configure Fake Timers to Preserve queueMicrotask](#33-configure-fake-timers-to-preserve-queuemicrotask)
   - 3.4 [Reset Handlers After Each Test](#34-reset-handlers-after-each-test)
   - 3.5 [Use Async Testing Utilities for Mock Responses](#35-use-async-testing-utilities-for-mock-responses)
   - 3.6 [Use Correct JSDOM Environment for Jest](#36-use-correct-jsdom-environment-for-jest)
   - 3.7 [Use server.boundary() for Concurrent Tests](#37-use-serverboundary-for-concurrent-tests)
4. [Response Patterns](#4-response-patterns) — **HIGH**
   - 4.1 [Add Realistic Response Delays](#41-add-realistic-response-delays)
   - 4.2 [Mock Streaming Responses with ReadableStream](#42-mock-streaming-responses-with-readablestream)
   - 4.3 [Set Response Headers Correctly](#43-set-response-headers-correctly)
   - 4.4 [Simulate Error Responses Correctly](#44-simulate-error-responses-correctly)
   - 4.5 [Use HttpResponse Static Methods](#45-use-httpresponse-static-methods)
   - 4.6 [Use One-Time Handlers for Sequential Scenarios](#46-use-one-time-handlers-for-sequential-scenarios)
5. [Request Matching](#5-request-matching) — **MEDIUM-HIGH**
   - 5.1 [Access Query Parameters from Request URL](#51-access-query-parameters-from-request-url)
   - 5.2 [Match HTTP Methods Explicitly](#52-match-http-methods-explicitly)
   - 5.3 [Order Handlers from Specific to General](#53-order-handlers-from-specific-to-general)
   - 5.4 [Use Custom Predicates for Complex Matching](#54-use-custom-predicates-for-complex-matching)
   - 5.5 [Use URL Path Parameters Correctly](#55-use-url-path-parameters-correctly)
6. [GraphQL Mocking](#6-graphql-mocking) — **MEDIUM**
   - 6.1 [Access GraphQL Variables Correctly](#61-access-graphql-variables-correctly)
   - 6.2 [Handle Batched GraphQL Queries](#62-handle-batched-graphql-queries)
   - 6.3 [Return GraphQL Errors in Correct Format](#63-return-graphql-errors-in-correct-format)
   - 6.4 [Use Operation Name for GraphQL Matching](#64-use-operation-name-for-graphql-matching)
7. [Advanced Patterns](#7-advanced-patterns) — **MEDIUM**
   - 7.1 [Configure MSW for Vitest Browser Mode](#71-configure-msw-for-vitest-browser-mode)
   - 7.2 [Handle Cookies and Authentication](#72-handle-cookies-and-authentication)
   - 7.3 [Implement Dynamic Mock Scenarios](#73-implement-dynamic-mock-scenarios)
   - 7.4 [Mock File Upload Endpoints](#74-mock-file-upload-endpoints)
   - 7.5 [Use bypass() for Passthrough Requests](#75-use-bypass-for-passthrough-requests)
8. [Debugging & Performance](#8-debugging-performance) — **LOW**
   - 8.1 [Know Common MSW Issues and Fixes](#81-know-common-msw-issues-and-fixes)
   - 8.2 [Log Request Details for Debugging](#82-log-request-details-for-debugging)
   - 8.3 [Use Lifecycle Events for Debugging](#83-use-lifecycle-events-for-debugging)
   - 8.4 [Verify Request Interception is Working](#84-verify-request-interception-is-working)

---

## 1. Setup & Initialization

**Impact: CRITICAL**

Worker and server configuration determines all downstream request interception; misconfiguration results in zero mocking capability and silent test failures.

### 1.1 Commit Worker Script to Version Control

**Impact: CRITICAL (Eliminates setup friction for team members; prevents CI failures)**

The `mockServiceWorker.js` file generated by `msw init` should be committed to Git. This ensures team members and CI environments can run browser tests without additional setup commands.

**Incorrect (gitignoring worker script):**

```gitignore
# .gitignore
# This forces every developer to run msw init manually
public/mockServiceWorker.js
```

```bash
# New team member clones repo, runs tests, gets cryptic errors
# because worker script doesn't exist
npm test
# Error: Cannot find mockServiceWorker.js
```

**Correct (commit and auto-update worker script):**

```bash
# Generate worker script with --save flag
npx msw init public/ --save
```

```json
// package.json - auto-updates worker on msw version changes
{
  "msw": {
    "workerDirectory": ["public"]
  }
}
```

```gitignore
# .gitignore - do NOT ignore the worker script
# public/mockServiceWorker.js  <- remove this line
```

**Monorepo configuration:**

```json
// Root package.json for monorepos
{
  "msw": {
    "workerDirectory": [
      "apps/web/public",
      "apps/admin/public"
    ]
  }
}
```

**When NOT to use this pattern:**
- If treating as generated artifact, ensure CI runs `msw init` before tests

Reference: [Managing the Worker](https://mswjs.io/docs/best-practices/managing-the-worker/)

### 1.2 Configure Server Lifecycle in Test Setup

**Impact: CRITICAL (Prevents handler leakage and ensures test isolation; eliminates flaky tests)**

Server lifecycle hooks must be configured in test setup files to ensure proper initialization, cleanup between tests, and graceful shutdown. Missing hooks cause handler pollution and unpredictable test behavior.

**Incorrect (no lifecycle management):**

```typescript
// handlers.test.ts
import { server } from './mocks/node'

// Server never started, handlers never reset
// Tests may pass/fail randomly depending on execution order
it('fetches user', async () => {
  const response = await fetch('/user')
  // This fails silently - no mocking active
})
```

**Correct (proper lifecycle hooks):**

```typescript
// vitest.setup.ts or setupTests.ts
import { beforeAll, afterEach, afterAll } from 'vitest'
import { server } from './mocks/node'

// Start server before all tests
beforeAll(() => server.listen())

// Reset handlers after each test to ensure isolation
afterEach(() => server.resetHandlers())

// Clean shutdown after all tests complete
afterAll(() => server.close())
```

**Jest equivalent:**

```typescript
// setupTests.ts
import { server } from './mocks/node'

beforeAll(() => server.listen())
afterEach(() => server.resetHandlers())
afterAll(() => server.close())
```

**When NOT to use this pattern:**
- Browser-based tests use `worker.start()` and `worker.stop()` instead

Reference: [MSW Quick Start - Test Setup](https://mswjs.io/docs/quick-start)

### 1.3 Configure TypeScript for MSW v2

**Impact: CRITICAL (TypeScript 4.7+ required; incorrect config causes type errors)**

MSW v2 requires TypeScript 4.7+ for proper type inference. Incorrect TypeScript configuration causes confusing type errors and prevents proper handler typing.

**Incorrect (outdated TypeScript or missing config):**

```json
// tsconfig.json - missing moduleResolution
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "ESNext"
    // No moduleResolution - imports fail to resolve
  }
}
```

```typescript
// Type errors due to incorrect resolution
import { http, HttpResponse } from 'msw'
// Error: Cannot find module 'msw' or its corresponding type declarations
```

**Correct (proper TypeScript configuration):**

```json
// tsconfig.json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "ESNext",
    "moduleResolution": "bundler", // or "node16" / "nodenext"
    "esModuleInterop": true,
    "strict": true,
    "skipLibCheck": true
  }
}
```

**Typed handlers with proper inference:**

```typescript
import { http, HttpResponse } from 'msw'

interface User {
  id: string
  name: string
  email: string
}

export const handlers = [
  http.get<never, never, User>('/api/user/:id', ({ params }) => {
    // params.id is typed as string
    return HttpResponse.json({
      id: params.id,
      name: 'John Doe',
      email: 'john@example.com',
    })
  }),
]
```

**When NOT to use this pattern:**
- JavaScript-only projects don't need TypeScript configuration
- Projects using older bundlers may need `moduleResolution: "node"`

Reference: [MSW v2 Migration - TypeScript](https://mswjs.io/docs/migrations/1.x-to-2.x/)

### 1.4 Configure Unhandled Request Behavior

**Impact: CRITICAL (Catches missing handlers immediately; prevents silent test failures)**

Configure `onUnhandledRequest: 'error'` to fail tests when requests lack handlers. This catches missing mocks immediately instead of allowing silent network calls or undefined behavior.

**Incorrect (default silent behavior):**

```typescript
// mocks/node.ts
import { setupServer } from 'msw/node'
import { handlers } from './handlers'

// Default behavior: warns but doesn't fail
// Unhandled requests may hit real APIs or return undefined
export const server = setupServer(...handlers)
```

```typescript
// Test passes despite missing handler - false positive!
it('submits form', async () => {
  await submitForm({ email: 'test@example.com' })
  // POST /submit has no handler but test doesn't fail
  expect(screen.getByText('Success')).toBeInTheDocument()
})
```

**Correct (strict unhandled request handling):**

```typescript
// vitest.setup.ts
import { server } from './mocks/node'

beforeAll(() => {
  server.listen({
    onUnhandledRequest: 'error', // Fail on any unhandled request
  })
})

afterEach(() => server.resetHandlers())
afterAll(() => server.close())
```

**Custom handling for specific URLs:**

```typescript
beforeAll(() => {
  server.listen({
    onUnhandledRequest(request, print) {
      // Allow certain requests through (e.g., static assets)
      if (request.url.includes('/static/')) {
        return
      }
      // Error on all other unhandled requests
      print.error()
    },
  })
})
```

**When NOT to use this pattern:**
- Development environments may prefer `'warn'` for less disruptive feedback
- Integration tests that intentionally hit real endpoints

Reference: [MSW Best Practices - Avoid Request Assertions](https://mswjs.io/docs/best-practices/avoid-request-assertions/)

### 1.5 Require Node.js 18+ for MSW v2

**Impact: CRITICAL (MSW v2 requires Node 18+; older versions cause complete failure)**

MSW v2 sets Node.js 18.0.0 as the minimum supported version. Older versions lack native `fetch` and other required APIs, causing complete mocking failure.

**Incorrect (using unsupported Node version):**

```json
// package.json
{
  "engines": {
    "node": ">=14.0.0"
  }
}
```

```bash
# Node 16 - MSW v2 fails silently or throws cryptic errors
$ node -v
v16.20.0

$ npm test
# ReferenceError: fetch is not defined
# or: Cannot read properties of undefined
```

**Correct (enforce Node 18+ requirement):**

```json
// package.json
{
  "engines": {
    "node": ">=18.0.0"
  }
}
```

```yaml
# .nvmrc
18
```

```yaml
# CI configuration (GitHub Actions)
jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [18, 20, 22]
```

**Verify installation:**

```bash
# Check Node version
node -v  # Should be v18.x.x or higher

# Check MSW version
npm ls msw  # Should be v2.x.x
```

**When NOT to use this pattern:**
- If stuck on Node 16, use MSW v1.x instead (with different API patterns)

Reference: [MSW v2 Migration - Requirements](https://mswjs.io/docs/migrations/1.x-to-2.x/)

### 1.6 Use Correct Entrypoint for Node.js

**Impact: CRITICAL (Zero mocking if wrong entrypoint; 100% test failures)**

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

---

## 2. Handler Architecture

**Impact: CRITICAL**

Handler structure affects maintainability, match reliability, and reusability across environments; poor organization creates N×M complexity as endpoints grow.

### 2.1 Define Happy Path Handlers as Baseline

**Impact: CRITICAL (Establishes reliable baseline; enables clean runtime overrides)**

Define success-state handlers in a central `handlers.ts` file as your baseline. This establishes a reliable foundation that runtime overrides can modify for error scenarios, keeping test-specific edge cases separate from normal behavior.

**Incorrect (mixing success and error states):**

```typescript
// mocks/handlers.ts - cluttered with all scenarios
export const handlers = [
  http.get('/user', () => HttpResponse.json({ name: 'John' })),
  http.get('/user', () => new HttpResponse(null, { status: 401 })),
  http.get('/user', () => new HttpResponse(null, { status: 500 })),
  http.get('/user', () => HttpResponse.error()),
  // Confusing: which handler runs? Last one wins but intent unclear
]
```

**Correct (happy path baseline with runtime overrides):**

```typescript
// mocks/handlers.ts - clean success states only
import { http, HttpResponse } from 'msw'

export const handlers = [
  http.get('/api/user', () => {
    return HttpResponse.json({ id: '1', name: 'John Maverick' })
  }),
  http.post('/api/login', async ({ request }) => {
    const { email } = await request.json()
    return HttpResponse.json({ token: 'mock-jwt-token', email })
  }),
]
```

```typescript
// user.test.ts - override for specific scenarios
import { http, HttpResponse } from 'msw'
import { server } from '../mocks/node'

it('handles authentication error', () => {
  server.use(
    http.get('/api/user', () => {
      return new HttpResponse(null, { status: 401 })
    })
  )
  // Test error handling...
})
```

**When NOT to use this pattern:**
- Single-use test utilities that will never need runtime overrides

Reference: [Structuring Handlers](https://mswjs.io/docs/best-practices/structuring-handlers)

### 2.2 Destructure Resolver Arguments Correctly

**Impact: CRITICAL (Wrong destructuring pattern causes undefined values; silent failures)**

MSW v2 passes a single object argument to resolvers containing `request`, `params`, `cookies`, and other properties. Destructure from this object instead of using multiple arguments.

**Incorrect (v1 multiple arguments pattern):**

```typescript
// MSW v1 pattern - does not work in v2
http.get('/api/user/:id', (req, res, ctx) => {
  const userId = req.params.id  // undefined!
  return res(ctx.json({ id: userId }))
})
```

**Correct (v2 single object argument):**

```typescript
import { http, HttpResponse } from 'msw'

export const handlers = [
  // Destructure from single argument object
  http.get('/api/user/:id', ({ request, params, cookies }) => {
    return HttpResponse.json({
      id: params.id,
      sessionId: cookies.sessionId,
      userAgent: request.headers.get('User-Agent'),
    })
  }),
]
```

**Available resolver properties:**

```typescript
http.post('/api/data', async (info) => {
  // Full request object
  const { request } = info

  // URL path parameters
  const { params } = info  // { id: '123' } for /api/data/:id

  // Parsed cookies from Cookie header
  const { cookies } = info  // { session: 'abc', token: 'xyz' }

  // Request URL as string (not URL object)
  const url = new URL(request.url)

  // Request method
  const method = request.method

  // Request headers
  const authHeader = request.headers.get('Authorization')

  // Request body (must await)
  const body = await request.json()

  return HttpResponse.json({ success: true })
})
```

**Type-safe params:**

```typescript
// Define params type for better type safety
type UserParams = {
  id: string
  orgId: string
}

http.get<UserParams>('/api/org/:orgId/user/:id', ({ params }) => {
  // params.id and params.orgId are typed as string
  return HttpResponse.json({ userId: params.id, orgId: params.orgId })
})
```

**When NOT to use this pattern:**
- This is the only pattern in MSW v2; no alternatives

Reference: [MSW v2 Migration - Resolver Changes](https://mswjs.io/docs/migrations/1.x-to-2.x/)

### 2.3 Explicitly Parse Request Bodies

**Impact: CRITICAL (v2 no longer auto-parses bodies; missing parsing returns undefined)**

MSW v2 does not automatically parse request bodies based on Content-Type. You must explicitly call `.json()`, `.text()`, `.formData()`, or `.arrayBuffer()` on the request object.

**Incorrect (assuming auto-parsed body):**

```typescript
// MSW v1 pattern - body was auto-parsed
http.post('/api/user', ({ request }) => {
  const body = request.body  // undefined in v2!
  return HttpResponse.json({ id: '1', ...body })
})
```

**Correct (explicit body parsing):**

```typescript
import { http, HttpResponse } from 'msw'

export const handlers = [
  // JSON body
  http.post('/api/user', async ({ request }) => {
    const body = await request.json()
    return HttpResponse.json({ id: '1', ...body }, { status: 201 })
  }),

  // Text body
  http.post('/api/text', async ({ request }) => {
    const text = await request.text()
    return HttpResponse.text(`Received: ${text}`)
  }),

  // Form data
  http.post('/api/upload', async ({ request }) => {
    const formData = await request.formData()
    const file = formData.get('file')
    return HttpResponse.json({ filename: file?.name })
  }),

  // ArrayBuffer for binary
  http.post('/api/binary', async ({ request }) => {
    const buffer = await request.arrayBuffer()
    return HttpResponse.json({ bytes: buffer.byteLength })
  }),
]
```

**Typed body parsing:**

```typescript
interface CreateUserRequest {
  name: string
  email: string
}

http.post('/api/user', async ({ request }) => {
  const body = await request.json() as CreateUserRequest
  return HttpResponse.json({
    id: crypto.randomUUID(),
    name: body.name,
    email: body.email,
  })
})
```

**When NOT to use this pattern:**
- GET requests typically don't have bodies and don't need parsing

Reference: [MSW v2 Migration - Request Changes](https://mswjs.io/docs/migrations/1.x-to-2.x/)

### 2.4 Extract Shared Response Logic into Resolvers

**Impact: CRITICAL (Eliminates duplication; ensures consistent mock responses across tests)**

Extract repetitive response logic into reusable resolver functions. This ensures consistency across handlers and reduces maintenance when response shapes change.

**Incorrect (duplicated response logic):**

```typescript
// mocks/handlers.ts
export const handlers = [
  http.get('/api/user/:id', ({ params }) => {
    return HttpResponse.json({
      id: params.id,
      name: 'John',
      email: 'john@example.com',
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    })
  }),
  http.get('/api/users', () => {
    return HttpResponse.json([
      {
        id: '1',
        name: 'John',
        email: 'john@example.com',
        createdAt: new Date().toISOString(),  // Duplicated shape
        updatedAt: new Date().toISOString(),
      },
      // ... more users with same structure
    ])
  }),
]
```

**Correct (shared resolver factories):**

```typescript
// mocks/factories/user.ts
import { faker } from '@faker-js/faker'

export function createMockUser(overrides: Partial<User> = {}): User {
  return {
    id: faker.string.uuid(),
    name: faker.person.fullName(),
    email: faker.internet.email(),
    createdAt: faker.date.past().toISOString(),
    updatedAt: faker.date.recent().toISOString(),
    ...overrides,
  }
}
```

```typescript
// mocks/handlers/user.ts
import { http, HttpResponse } from 'msw'
import { createMockUser } from '../factories/user'

export const userHandlers = [
  http.get('/api/user/:id', ({ params }) => {
    return HttpResponse.json(createMockUser({ id: params.id as string }))
  }),
  http.get('/api/users', () => {
    return HttpResponse.json([
      createMockUser(),
      createMockUser(),
      createMockUser(),
    ])
  }),
]
```

**Higher-order handler for cross-cutting concerns:**

```typescript
// mocks/utils/withAuth.ts
import { HttpResponse } from 'msw'
import type { HttpResponseResolver } from 'msw'

export function withAuth(resolver: HttpResponseResolver): HttpResponseResolver {
  return ({ request, ...rest }) => {
    const authHeader = request.headers.get('Authorization')
    if (!authHeader?.startsWith('Bearer ')) {
      return new HttpResponse(null, { status: 401 })
    }
    return resolver({ request, ...rest })
  }
}
```

**When NOT to use this pattern:**
- One-off handlers for specific test scenarios don't need abstraction

Reference: [Structuring Handlers](https://mswjs.io/docs/best-practices/structuring-handlers)

### 2.5 Group Handlers by Domain

**Impact: CRITICAL (Reduces maintenance overhead; scales to large APIs without N×M complexity)**

Split handlers into separate files organized by domain or feature area. This prevents a single handlers file from becoming unmanageable and enables selective handler composition for different test scenarios.

**Incorrect (monolithic handler file):**

```typescript
// mocks/handlers.ts - 500+ lines, unmaintainable
export const handlers = [
  // User endpoints
  http.get('/api/user', () => { /* ... */ }),
  http.post('/api/user', () => { /* ... */ }),
  http.delete('/api/user/:id', () => { /* ... */ }),
  // Auth endpoints
  http.post('/api/login', () => { /* ... */ }),
  http.post('/api/logout', () => { /* ... */ }),
  // Product endpoints
  http.get('/api/products', () => { /* ... */ }),
  // ... 50 more endpoints mixed together
]
```

**Correct (domain-organized handlers):**

```typescript
// mocks/handlers/user.ts
import { http, HttpResponse } from 'msw'

export const userHandlers = [
  http.get('/api/user', () => {
    return HttpResponse.json({ id: '1', name: 'John' })
  }),
  http.post('/api/user', async ({ request }) => {
    const user = await request.json()
    return HttpResponse.json(user, { status: 201 })
  }),
  http.delete('/api/user/:id', ({ params }) => {
    return new HttpResponse(null, { status: 204 })
  }),
]
```

```typescript
// mocks/handlers/auth.ts
import { http, HttpResponse } from 'msw'

export const authHandlers = [
  http.post('/api/login', async ({ request }) => {
    const { email, password } = await request.json()
    return HttpResponse.json({ token: 'jwt-token' })
  }),
  http.post('/api/logout', () => {
    return new HttpResponse(null, { status: 200 })
  }),
]
```

```typescript
// mocks/handlers/index.ts - compose all handlers
import { userHandlers } from './user'
import { authHandlers } from './auth'
import { productHandlers } from './products'

export const handlers = [
  ...userHandlers,
  ...authHandlers,
  ...productHandlers,
]
```

**When NOT to use this pattern:**
- Small projects with fewer than 10 endpoints may use a single file

Reference: [Structuring Handlers - Group by Domain](https://mswjs.io/docs/best-practices/structuring-handlers)

### 2.6 Share Handlers Across Environments

**Impact: CRITICAL (Single source of truth; eliminates mock drift between dev/test)**

Define handlers once and reuse them across browser (development) and Node.js (testing) environments. This ensures mock behavior is consistent and prevents drift between development and test mocks.

**Incorrect (duplicate handlers per environment):**

```typescript
// mocks/browser-handlers.ts - browser development
export const browserHandlers = [
  http.get('/api/user', () => HttpResponse.json({ name: 'Dev User' })),
]

// mocks/test-handlers.ts - tests (different implementation!)
export const testHandlers = [
  http.get('/api/user', () => HttpResponse.json({ name: 'Test User' })),
]
// Mock behavior differs between environments - bugs hide until production
```

**Correct (shared handlers, environment-specific setup):**

```typescript
// mocks/handlers.ts - single source of truth
import { http, HttpResponse } from 'msw'

export const handlers = [
  http.get('/api/user', () => {
    return HttpResponse.json({ id: '1', name: 'John Maverick' })
  }),
  http.get('/api/posts', () => {
    return HttpResponse.json([
      { id: '1', title: 'First Post' },
      { id: '2', title: 'Second Post' },
    ])
  }),
]
```

```typescript
// mocks/browser.ts - browser setup
import { setupWorker } from 'msw/browser'
import { handlers } from './handlers'

export const worker = setupWorker(...handlers)
```

```typescript
// mocks/node.ts - Node.js setup
import { setupServer } from 'msw/node'
import { handlers } from './handlers'

export const server = setupServer(...handlers)
```

```typescript
// src/index.tsx - conditional browser activation
async function enableMocking() {
  if (process.env.NODE_ENV !== 'development') {
    return
  }
  const { worker } = await import('./mocks/browser')
  return worker.start()
}

enableMocking().then(() => {
  ReactDOM.createRoot(document.getElementById('root')!).render(<App />)
})
```

**When NOT to use this pattern:**
- Environment-specific handlers (e.g., browser-only features) can be added via separate arrays

Reference: [MSW Comparison - Reusability](https://mswjs.io/docs/comparison)

### 2.7 Use Absolute URLs in Handlers

**Impact: CRITICAL (Prevents URL mismatch failures; required for Node.js environments)**

Use absolute URLs or URL patterns in request handlers. Node.js environments require absolute URLs for proper matching, and relative URLs cause silent handler failures.

**Incorrect (relative URLs in Node.js context):**

```typescript
// mocks/handlers.ts
export const handlers = [
  // Relative URL - may not match in Node.js tests
  http.get('/api/user', () => {
    return HttpResponse.json({ name: 'John' })
  }),
]

// Test makes request to full URL
await fetch('http://localhost:3000/api/user')
// Handler doesn't match - request goes unhandled
```

**Correct (absolute URLs or wildcards):**

```typescript
// mocks/handlers.ts
export const handlers = [
  // Absolute URL - matches reliably
  http.get('http://localhost:3000/api/user', () => {
    return HttpResponse.json({ name: 'John' })
  }),
]
```

**Better (wildcard for any origin):**

```typescript
// mocks/handlers.ts
export const handlers = [
  // Wildcard matches any origin - most flexible
  http.get('*/api/user', () => {
    return HttpResponse.json({ name: 'John' })
  }),

  // Or use path patterns that MSW resolves against baseURL
  http.get('/api/user', () => {
    return HttpResponse.json({ name: 'John' })
  }),
]
```

**Environment variable pitfall:**

```typescript
// AVOID: Environment variable not set in tests
const API_URL = process.env.API_URL // undefined in tests!

http.get(`${API_URL}/user`, () => { /* ... */ })
// Results in: http.get('undefined/user', ...) - never matches
```

**When NOT to use this pattern:**
- Browser environments with properly configured base URLs may use relative paths

Reference: [MSW Debugging Runbook](https://mswjs.io/docs/runbook/)

### 2.8 Use MSW v2 Response Syntax

**Impact: CRITICAL (v1 syntax breaks in v2; causes complete handler failure)**

MSW v2 replaces the composition-based `res(ctx.json())` syntax with native `Response` and `HttpResponse`. Using v1 syntax in v2 causes handlers to fail silently.

**Incorrect (v1 composition syntax):**

```typescript
// MSW v1 syntax - does not work in v2
import { rest } from 'msw'

export const handlers = [
  rest.get('/api/user', (req, res, ctx) => {
    return res(
      ctx.status(200),
      ctx.json({ name: 'John' }),
      ctx.delay(100)
    )
  }),
]
```

**Correct (v2 HttpResponse syntax):**

```typescript
// MSW v2 syntax
import { http, HttpResponse, delay } from 'msw'

export const handlers = [
  http.get('/api/user', async () => {
    await delay(100)
    return HttpResponse.json(
      { name: 'John' },
      { status: 200 }
    )
  }),
]
```

**Common v2 response patterns:**

```typescript
import { http, HttpResponse, delay } from 'msw'

export const handlers = [
  // JSON response
  http.get('/api/user', () => {
    return HttpResponse.json({ name: 'John' })
  }),

  // Text response
  http.get('/api/text', () => {
    return HttpResponse.text('Hello, World!')
  }),

  // XML response
  http.get('/api/xml', () => {
    return HttpResponse.xml('<user><name>John</name></user>')
  }),

  // Empty response with status
  http.delete('/api/user/:id', () => {
    return new HttpResponse(null, { status: 204 })
  }),

  // Custom headers
  http.get('/api/data', () => {
    return HttpResponse.json(
      { data: 'value' },
      {
        headers: {
          'X-Custom-Header': 'custom-value',
        },
      }
    )
  }),

  // Network error
  http.get('/api/error', () => {
    return HttpResponse.error()
  }),
]
```

**When NOT to use this pattern:**
- Projects still on MSW v1 should use the v1 syntax until migration

Reference: [MSW v2 Migration Guide](https://mswjs.io/docs/migrations/1.x-to-2.x/)

---

## 3. Test Integration

**Impact: HIGH**

Improper test setup causes flaky tests, isolation failures, handler leakage between tests, and false positives that mask real bugs.

### 3.1 Avoid Direct Request Assertions

**Impact: HIGH (Tests implementation details; breaks on refactors that preserve behavior)**

Do not assert that specific requests were made with specific parameters. This tests implementation details rather than behavior. Instead, assert on your application's reaction to responses.

**Incorrect (asserting request details):**

```typescript
it('sends correct data when creating user', async () => {
  const requestSpy = vi.fn()

  server.use(
    http.post('/api/user', async ({ request }) => {
      requestSpy(await request.json())
      return HttpResponse.json({ id: '1' })
    })
  )

  await createUser({ name: 'John', email: 'john@example.com' })

  // Testing implementation details - what if we add a field?
  expect(requestSpy).toHaveBeenCalledWith({
    name: 'John',
    email: 'john@example.com',
  })
})
```

**Correct (assert behavior through responses):**

```typescript
it('creates user and shows success message', async () => {
  server.use(
    http.post('/api/user', async ({ request }) => {
      const body = await request.json()
      // Validate in handler - returns error if invalid
      if (!body.email) {
        return HttpResponse.json(
          { error: 'Email required' },
          { status: 400 }
        )
      }
      return HttpResponse.json({ id: '1', ...body }, { status: 201 })
    })
  )

  render(<CreateUserForm />)
  await userEvent.type(screen.getByLabelText('Name'), 'John')
  await userEvent.type(screen.getByLabelText('Email'), 'john@example.com')
  await userEvent.click(screen.getByRole('button', { name: 'Create' }))

  // Assert application behavior, not request details
  expect(await screen.findByText('User created!')).toBeInTheDocument()
})
```

**For one-way requests (analytics, logging):**

```typescript
import { server } from './mocks/node'

it('tracks page view', async () => {
  const trackingPromise = new Promise<void>((resolve) => {
    server.events.on('request:end', ({ request }) => {
      if (request.url.includes('/analytics')) {
        resolve()
      }
    })
  })

  render(<HomePage />)

  // Verify the request was made without asserting payload
  await expect(trackingPromise).resolves.toBeUndefined()
})
```

**When NOT to use this pattern:**
- Analytics/telemetry testing may require request payload verification via lifecycle events

Reference: [Avoid Request Assertions](https://mswjs.io/docs/best-practices/avoid-request-assertions/)

### 3.2 Clear Request Library Caches Between Tests

**Impact: HIGH (Prevents stale cached responses; ensures fresh mock data per test)**

Clear data fetching library caches between tests. Libraries like SWR, TanStack Query, and Apollo cache responses, causing tests to receive stale data from previous tests instead of fresh mocked responses.

**Incorrect (cached data leaks between tests):**

```typescript
// test-a.spec.ts
it('displays original user', async () => {
  // Response cached by SWR/React Query
  render(<UserProfile />)
  expect(await screen.findByText('John')).toBeInTheDocument()
})

// test-b.spec.ts
it('displays updated user', async () => {
  server.use(
    http.get('/api/user', () => {
      return HttpResponse.json({ name: 'Jane' })  // Different user
    })
  )
  render(<UserProfile />)
  // FAILS! Cache returns 'John' from previous test
  expect(await screen.findByText('Jane')).toBeInTheDocument()
})
```

**Correct (clear caches in test setup):**

```typescript
// SWR cache clearing
import { cache } from 'swr'

afterEach(() => {
  // Clear SWR cache
  cache.clear()
})
```

```typescript
// TanStack Query cache clearing
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'

const createTestQueryClient = () =>
  new QueryClient({
    defaultOptions: {
      queries: { retry: false, gcTime: 0 },
    },
  })

const renderWithClient = (ui: React.ReactElement) => {
  const testQueryClient = createTestQueryClient()
  return render(
    <QueryClientProvider client={testQueryClient}>{ui}</QueryClientProvider>
  )
}

// Each test gets fresh QueryClient with no cached data
it('displays user', async () => {
  renderWithClient(<UserProfile />)
  expect(await screen.findByText('John')).toBeInTheDocument()
})
```

```typescript
// Apollo Client cache clearing
import { ApolloClient, InMemoryCache } from '@apollo/client'

afterEach(async () => {
  await client.clearStore()
  // or client.resetStore() to refetch active queries
})
```

**When NOT to use this pattern:**
- Tests intentionally verifying cache behavior should not clear caches

Reference: [MSW Debugging Runbook](https://mswjs.io/docs/runbook/)

### 3.3 Configure Fake Timers to Preserve queueMicrotask

**Impact: HIGH (Prevents request body parsing from hanging indefinitely)**

When using fake timers, configure them to not mock `queueMicrotask`. The global `fetch` uses `queueMicrotask` internally for body parsing, and mocking it causes `request.json()` and similar methods to hang forever.

**Incorrect (default fake timers):**

```typescript
// vitest.config.ts or jest.config.js
beforeEach(() => {
  vi.useFakeTimers()  // Mocks ALL timer functions including queueMicrotask
})

// Test hangs indefinitely
it('parses request body', async () => {
  server.use(
    http.post('/api/user', async ({ request }) => {
      const body = await request.json()  // Never resolves!
      return HttpResponse.json(body)
    })
  )

  await fetch('/api/user', {
    method: 'POST',
    body: JSON.stringify({ name: 'John' }),
  })
})
```

**Correct (exclude queueMicrotask from fake timers):**

```typescript
// Vitest
beforeEach(() => {
  vi.useFakeTimers({
    toFake: [
      'setTimeout',
      'setInterval',
      'clearTimeout',
      'clearInterval',
      'setImmediate',
      'clearImmediate',
      'Date',
    ],
    // queueMicrotask is NOT in the list - remains real
  })
})

// Or more explicitly with shouldAdvanceTime
beforeEach(() => {
  vi.useFakeTimers({ shouldAdvanceTime: true })
})
```

```typescript
// Jest
beforeEach(() => {
  jest.useFakeTimers({
    doNotFake: ['queueMicrotask'],  // Explicitly preserve queueMicrotask
  })
})
```

**Alternative - advance timers after async operations:**

```typescript
it('handles delayed response', async () => {
  vi.useFakeTimers()

  const fetchPromise = fetch('/api/user')

  // Advance timers to allow microtasks to process
  await vi.runAllTimersAsync()

  const response = await fetchPromise
  expect(response.ok).toBe(true)

  vi.useRealTimers()
})
```

**When NOT to use this pattern:**
- If not using fake timers, this configuration is unnecessary

Reference: [MSW Debugging Runbook](https://mswjs.io/docs/runbook/)

### 3.4 Reset Handlers After Each Test

**Impact: HIGH (Prevents handler pollution; eliminates test order dependencies)**

Call `server.resetHandlers()` in `afterEach` to remove runtime handlers added during tests. Without reset, handlers from one test can affect subsequent tests, causing mysterious failures that depend on test execution order.

**Incorrect (no handler reset):**

```typescript
// test-a.spec.ts
it('handles server error', () => {
  server.use(
    http.get('/api/user', () => new HttpResponse(null, { status: 500 }))
  )
  // Test passes...
})

// test-b.spec.ts - runs after test-a
it('displays user name', () => {
  // FAILS! Still receiving 500 error from test-a's handler
  render(<UserProfile />)
  expect(screen.getByText('John')).toBeInTheDocument()
})
```

**Correct (reset in afterEach):**

```typescript
// vitest.setup.ts
import { server } from './mocks/node'

beforeAll(() => server.listen())
afterEach(() => server.resetHandlers())  // Clean slate for each test
afterAll(() => server.close())
```

```typescript
// user.test.ts
it('handles server error', () => {
  server.use(
    http.get('/api/user', () => new HttpResponse(null, { status: 500 }))
  )
  render(<UserProfile />)
  expect(screen.getByRole('alert')).toHaveTextContent('Error')
})
// Handler is removed after this test completes

it('displays user name', () => {
  // Uses baseline happy-path handler
  render(<UserProfile />)
  expect(screen.getByText('John')).toBeInTheDocument()
})
```

**When NOT to use this pattern:**
- `server.boundary()` provides automatic isolation for concurrent tests

Reference: [Network Behavior Overrides](https://mswjs.io/docs/best-practices/network-behavior-overrides)

### 3.5 Use Async Testing Utilities for Mock Responses

**Impact: HIGH (Prevents race conditions; ensures responses arrive before assertions)**

Use async testing utilities (`findBy`, `waitFor`) instead of `getBy` or manual `setTimeout` when testing components that make API calls. Mock responses are asynchronous, and synchronous assertions will fail before data arrives.

**Incorrect (synchronous assertions):**

```typescript
it('displays user name', () => {
  render(<UserProfile />)

  // Fails! Response hasn't arrived yet
  expect(screen.getByText('John')).toBeInTheDocument()
})

// Also incorrect - arbitrary timeout
it('displays user name', async () => {
  render(<UserProfile />)

  await new Promise((resolve) => setTimeout(resolve, 100))

  // Flaky - 100ms might not be enough, or wastes time if faster
  expect(screen.getByText('John')).toBeInTheDocument()
})
```

**Correct (async testing utilities):**

```typescript
import { render, screen, waitFor } from '@testing-library/react'

it('displays user name', async () => {
  render(<UserProfile />)

  // findBy* returns a promise that resolves when element appears
  expect(await screen.findByText('John')).toBeInTheDocument()
})

// For non-element assertions, use waitFor
it('updates document title', async () => {
  render(<UserProfile />)

  await waitFor(() => {
    expect(document.title).toBe('John - Profile')
  })
})

// For multiple elements
it('displays user list', async () => {
  render(<UserList />)

  const users = await screen.findAllByRole('listitem')
  expect(users).toHaveLength(3)
})
```

**With loading states:**

```typescript
it('shows loading then content', async () => {
  render(<UserProfile />)

  // Loading state appears immediately
  expect(screen.getByText('Loading...')).toBeInTheDocument()

  // Content replaces loading after response
  expect(await screen.findByText('John')).toBeInTheDocument()
  expect(screen.queryByText('Loading...')).not.toBeInTheDocument()
})
```

**When NOT to use this pattern:**
- Synchronous operations that don't involve API calls can use `getBy`

Reference: [Testing Library Async Methods](https://testing-library.com/docs/dom-testing-library/api-async/)

### 3.6 Use Correct JSDOM Environment for Jest

**Impact: HIGH (Prevents Node.js global conflicts; ensures proper fetch availability)**

Use `jest-fixed-jsdom` instead of `jest-environment-jsdom` when testing with MSW in Jest. Standard JSDOM uses browser export conditions but runs in Node.js, causing conflicts with MSW's entrypoints.

**Incorrect (standard jsdom environment):**

```javascript
// jest.config.js
module.exports = {
  testEnvironment: 'jsdom',  // Uses browser exports incorrectly
}
```

```typescript
// Tests fail with cryptic errors
// TypeError: Cannot read properties of undefined
// or: fetch is not defined
```

**Correct (use jest-fixed-jsdom):**

```bash
npm install -D jest-fixed-jsdom
```

```javascript
// jest.config.js
module.exports = {
  testEnvironment: 'jest-fixed-jsdom',
}
```

**Alternative - migrate to Vitest:**

```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: {
    environment: 'jsdom',  // Vitest handles this correctly
    setupFiles: ['./vitest.setup.ts'],
  },
})
```

**Why this matters:**

JSDOM uses browser export conditions by default, causing packages like MSW to use browser-specific code in a Node.js context. This leads to:
- Missing Node.js globals
- Incorrect module resolution
- Silent failures or cryptic errors

`jest-fixed-jsdom` and Vitest correctly handle the Node.js/browser boundary.

**When NOT to use this pattern:**
- Vitest users don't need this; Vitest handles environments correctly
- Node-only tests (no DOM) should use `testEnvironment: 'node'`

Reference: [MSW v2 Migration - Jest/JSDOM](https://mswjs.io/docs/migrations/1.x-to-2.x/)

### 3.7 Use server.boundary() for Concurrent Tests

**Impact: HIGH (Enables parallel test execution; prevents cross-test handler pollution)**

Wrap concurrent tests in `server.boundary()` to isolate handler overrides. Without boundaries, concurrent tests share handlers, causing race conditions and unpredictable failures.

**Incorrect (concurrent tests without boundaries):**

```typescript
// Tests run in parallel - handlers leak between them
it.concurrent('fetches user', async () => {
  // Uses initial handlers
  const response = await fetch('https://api.example.com/user')
  expect(response.ok).toBe(true)
})

it.concurrent('handles error', async () => {
  server.use(
    http.get('https://api.example.com/user', () => {
      return new HttpResponse(null, { status: 500 })
    })
  )
  // This override might affect the other concurrent test!
  const response = await fetch('https://api.example.com/user')
  expect(response.status).toBe(500)
})
```

**Correct (boundary-isolated concurrent tests):**

```typescript
import { http, HttpResponse } from 'msw'
import { setupServer } from 'msw/node'

const server = setupServer(
  http.get('https://api.example.com/user', () => {
    return HttpResponse.json({ name: 'John' })
  })
)

beforeAll(() => server.listen())
afterAll(() => server.close())

it.concurrent(
  'fetches user',
  server.boundary(async () => {
    const response = await fetch('https://api.example.com/user')
    const user = await response.json()
    expect(user).toEqual({ name: 'John' })
  })
)

it.concurrent(
  'handles server error',
  server.boundary(async () => {
    // Override is scoped to this boundary only
    server.use(
      http.get('https://api.example.com/user', () => {
        return new HttpResponse(null, { status: 500 })
      })
    )
    const response = await fetch('https://api.example.com/user')
    expect(response.status).toBe(500)
  })
)

it.concurrent(
  'handles network error',
  server.boundary(async () => {
    server.use(
      http.get('https://api.example.com/user', () => {
        return HttpResponse.error()
      })
    )
    await expect(fetch('https://api.example.com/user')).rejects.toThrow()
  })
)
```

**When NOT to use this pattern:**
- Sequential tests (non-concurrent) can use standard `afterEach` reset pattern

Reference: [server.boundary() API](https://mswjs.io/docs/api/setup-server/boundary)

---

## 4. Response Patterns

**Impact: HIGH**

Response construction patterns affect type safety, realism, and consistency with production APIs; incorrect responses create false confidence in tests.

### 4.1 Add Realistic Response Delays

**Impact: HIGH (Reveals race conditions; tests loading states; catches timing bugs)**

Use `delay()` to simulate network latency in handlers. This reveals race conditions, tests loading states, and ensures your application handles realistic response timing.

**Incorrect (instant responses hide timing issues):**

```typescript
http.get('/api/user', () => {
  // Instant response - loading states never visible
  // Race conditions in component never triggered
  return HttpResponse.json({ name: 'John' })
})
```

```typescript
// Component test passes but has hidden race condition
it('displays user', async () => {
  render(<UserProfile />)
  // Loading state flashes so briefly it's never testable
  expect(await screen.findByText('John')).toBeInTheDocument()
})
```

**Correct (realistic delays):**

```typescript
import { http, HttpResponse, delay } from 'msw'

export const handlers = [
  http.get('/api/user', async () => {
    // Simulate typical API latency
    await delay(150)
    return HttpResponse.json({ name: 'John' })
  }),
]
```

**Testing loading states:**

```typescript
it('shows loading indicator while fetching', async () => {
  server.use(
    http.get('/api/user', async () => {
      await delay(500)  // Longer delay for visibility
      return HttpResponse.json({ name: 'John' })
    })
  )

  render(<UserProfile />)

  // Loading state is visible during delay
  expect(screen.getByText('Loading...')).toBeInTheDocument()

  // Content appears after delay
  expect(await screen.findByText('John')).toBeInTheDocument()
  expect(screen.queryByText('Loading...')).not.toBeInTheDocument()
})
```

**Global delay for all handlers:**

```typescript
import { http, delay } from 'msw'

export const handlers = [
  // Apply delay to all requests
  http.all('*', async () => {
    await delay(100)
    // No return = continue to next matching handler
  }),

  http.get('/api/user', () => {
    return HttpResponse.json({ name: 'John' })
  }),
]
```

**Delay modes:**

```typescript
// Fixed delay
await delay(200)

// Random delay within range (simulates variable network)
await delay('real')  // Random 100-400ms

// Infinite delay (simulates hung request)
await delay('infinite')
```

**When NOT to use this pattern:**
- Unit tests focused on business logic may skip delays for speed
- CI pipelines may use shorter delays to reduce test duration

Reference: [MSW delay() API](https://mswjs.io/docs/api/delay)

### 4.2 Mock Streaming Responses with ReadableStream

**Impact: HIGH (Tests streaming UIs, chat interfaces, and progressive loading)**

Use `ReadableStream` to mock streaming responses for Server-Sent Events (SSE), chunked transfers, or streaming APIs. This enables testing of real-time features and progressive UI updates.

**Incorrect (returning complete response immediately):**

```typescript
// Chat response arrives all at once - doesn't test streaming UI
http.post('/api/chat', () => {
  return HttpResponse.json({
    message: 'Here is the complete response all at once',
  })
})
```

**Correct (streaming response):**

```typescript
import { http, HttpResponse } from 'msw'

// Text streaming (like AI chat)
http.post('/api/chat', () => {
  const encoder = new TextEncoder()
  const chunks = ['Hello', ' ', 'world', '!']

  const stream = new ReadableStream({
    async start(controller) {
      for (const chunk of chunks) {
        controller.enqueue(encoder.encode(chunk))
        await new Promise((resolve) => setTimeout(resolve, 100))
      }
      controller.close()
    },
  })

  return new HttpResponse(stream, {
    headers: {
      'Content-Type': 'text/plain',
      'Transfer-Encoding': 'chunked',
    },
  })
})
```

**Server-Sent Events (SSE):**

```typescript
http.get('/api/events', () => {
  const encoder = new TextEncoder()
  const events = [
    { id: '1', data: { message: 'First event' } },
    { id: '2', data: { message: 'Second event' } },
    { id: '3', data: { message: 'Third event' } },
  ]

  const stream = new ReadableStream({
    async start(controller) {
      for (const event of events) {
        const sseMessage = `id: ${event.id}\ndata: ${JSON.stringify(event.data)}\n\n`
        controller.enqueue(encoder.encode(sseMessage))
        await new Promise((resolve) => setTimeout(resolve, 200))
      }
      controller.close()
    },
  })

  return new HttpResponse(stream, {
    headers: {
      'Content-Type': 'text/event-stream',
      'Cache-Control': 'no-cache',
      'Connection': 'keep-alive',
    },
  })
})
```

**JSON streaming (newline-delimited):**

```typescript
http.get('/api/stream-json', () => {
  const encoder = new TextEncoder()
  const items = [
    { id: 1, name: 'Item 1' },
    { id: 2, name: 'Item 2' },
    { id: 3, name: 'Item 3' },
  ]

  const stream = new ReadableStream({
    async start(controller) {
      for (const item of items) {
        controller.enqueue(encoder.encode(JSON.stringify(item) + '\n'))
        await new Promise((resolve) => setTimeout(resolve, 100))
      }
      controller.close()
    },
  })

  return new HttpResponse(stream, {
    headers: { 'Content-Type': 'application/x-ndjson' },
  })
})
```

**When NOT to use this pattern:**
- APIs that return complete responses don't need streaming mocks

Reference: [MSW ReadableStream Support](https://mswjs.io/blog/introducing-msw-2.0)

### 4.3 Set Response Headers Correctly

**Impact: HIGH (Ensures CORS, caching, and authentication headers work as expected)**

Set appropriate response headers to simulate real API behavior. Headers like `Set-Cookie`, `Cache-Control`, and CORS headers affect how your application handles responses.

**Incorrect (missing important headers):**

```typescript
http.post('/api/login', () => {
  // Missing Set-Cookie header - authentication won't work
  return HttpResponse.json({ user: { id: '1' } })
})

http.get('/api/data', () => {
  // Missing caching headers - can't test cache behavior
  return HttpResponse.json({ data: 'value' })
})
```

**Correct (explicit headers):**

```typescript
import { http, HttpResponse } from 'msw'

export const handlers = [
  // Authentication with cookies
  http.post('/api/login', () => {
    return HttpResponse.json(
      { user: { id: '1', name: 'John' } },
      {
        headers: {
          'Set-Cookie': 'session=abc123; Path=/; HttpOnly',
        },
      }
    )
  }),

  // Caching headers
  http.get('/api/static-data', () => {
    return HttpResponse.json(
      { version: '1.0' },
      {
        headers: {
          'Cache-Control': 'public, max-age=3600',
          'ETag': '"abc123"',
        },
      }
    )
  }),

  // No-cache for dynamic data
  http.get('/api/user', () => {
    return HttpResponse.json(
      { name: 'John' },
      {
        headers: {
          'Cache-Control': 'no-store',
        },
      }
    )
  }),

  // Pagination headers
  http.get('/api/users', () => {
    return HttpResponse.json(
      [{ id: '1' }, { id: '2' }],
      {
        headers: {
          'X-Total-Count': '100',
          'X-Page': '1',
          'X-Per-Page': '10',
          'Link': '</api/users?page=2>; rel="next"',
        },
      }
    )
  }),

  // Rate limiting headers
  http.get('/api/limited', () => {
    return HttpResponse.json(
      { data: 'value' },
      {
        headers: {
          'X-RateLimit-Limit': '100',
          'X-RateLimit-Remaining': '99',
          'X-RateLimit-Reset': String(Date.now() + 3600000),
        },
      }
    )
  }),
]
```

**Testing rate limit handling:**

```typescript
it('shows rate limit warning when approaching limit', async () => {
  server.use(
    http.get('/api/data', () => {
      return HttpResponse.json(
        { data: 'value' },
        {
          headers: {
            'X-RateLimit-Remaining': '5',
          },
        }
      )
    })
  )

  render(<DataFetcher />)
  expect(await screen.findByText('Rate limit warning')).toBeInTheDocument()
})
```

**When NOT to use this pattern:**
- Tests not concerned with header-specific behavior can omit custom headers

Reference: [MSW HttpResponse Options](https://mswjs.io/docs/api/http-response)

### 4.4 Simulate Error Responses Correctly

**Impact: HIGH (Validates error handling; catches missing error states in UI)**

Use proper HTTP status codes and `HttpResponse.error()` for network errors. Different error types require different handling in your application, and correct simulation ensures your error handling works.

**Incorrect (ambiguous error responses):**

```typescript
// Unclear what type of error this represents
http.get('/api/user', () => {
  return HttpResponse.json({ error: 'Something went wrong' })
})

// Missing status code - defaults to 200!
http.get('/api/user', () => {
  return new HttpResponse('Error occurred')
})
```

**Correct (explicit error types):**

```typescript
import { http, HttpResponse } from 'msw'

// HTTP 4xx - Client errors
http.get('/api/user/:id', () => {
  return HttpResponse.json(
    { error: 'User not found' },
    { status: 404 }
  )
})

http.post('/api/user', () => {
  return HttpResponse.json(
    { error: 'Validation failed', fields: ['email'] },
    { status: 400 }
  )
})

http.get('/api/protected', () => {
  return HttpResponse.json(
    { error: 'Unauthorized' },
    { status: 401 }
  )
})

http.get('/api/admin', () => {
  return HttpResponse.json(
    { error: 'Forbidden' },
    { status: 403 }
  )
})

// HTTP 5xx - Server errors
http.get('/api/user', () => {
  return HttpResponse.json(
    { error: 'Internal server error' },
    { status: 500 }
  )
})

http.get('/api/data', () => {
  return new HttpResponse(null, { status: 503 })  // Service unavailable
})

// Network error (connection failure, DNS failure, etc.)
http.get('/api/user', () => {
  return HttpResponse.error()  // Causes fetch to reject
})
```

**Testing error handling:**

```typescript
it('displays 404 message when user not found', async () => {
  server.use(
    http.get('/api/user/:id', () => {
      return HttpResponse.json(
        { error: 'User not found' },
        { status: 404 }
      )
    })
  )

  render(<UserProfile userId="999" />)
  expect(await screen.findByText('User not found')).toBeInTheDocument()
})

it('handles network failure gracefully', async () => {
  server.use(
    http.get('/api/user', () => {
      return HttpResponse.error()
    })
  )

  render(<UserProfile />)
  expect(await screen.findByText('Network error')).toBeInTheDocument()
})
```

**When NOT to use this pattern:**
- Happy path tests should use success responses

Reference: [MSW HttpResponse API](https://mswjs.io/docs/api/http-response)

### 4.5 Use HttpResponse Static Methods

**Impact: HIGH (Automatic Content-Type headers; cleaner syntax; type safety)**

Use `HttpResponse.json()`, `HttpResponse.text()`, and other static methods instead of manually constructing responses. These methods automatically set correct Content-Type headers and provide cleaner, more readable code.

**Incorrect (manual response construction):**

```typescript
http.get('/api/user', () => {
  // Verbose, easy to forget Content-Type header
  return new Response(
    JSON.stringify({ name: 'John' }),
    {
      status: 200,
      headers: {
        'Content-Type': 'application/json',
      },
    }
  )
})
```

**Correct (HttpResponse static methods):**

```typescript
import { http, HttpResponse } from 'msw'

export const handlers = [
  // JSON - sets Content-Type: application/json automatically
  http.get('/api/user', () => {
    return HttpResponse.json({ name: 'John', email: 'john@example.com' })
  }),

  // JSON with status code
  http.post('/api/user', () => {
    return HttpResponse.json(
      { id: '1', message: 'Created' },
      { status: 201 }
    )
  }),

  // Text - sets Content-Type: text/plain
  http.get('/api/text', () => {
    return HttpResponse.text('Hello, World!')
  }),

  // XML - sets Content-Type: application/xml
  http.get('/api/xml', () => {
    return HttpResponse.xml('<user><name>John</name></user>')
  }),

  // HTML - sets Content-Type: text/html
  http.get('/page', () => {
    return HttpResponse.html('<html><body><h1>Hello</h1></body></html>')
  }),

  // ArrayBuffer for binary data
  http.get('/api/file', () => {
    const buffer = new ArrayBuffer(8)
    return HttpResponse.arrayBuffer(buffer, {
      headers: { 'Content-Type': 'application/octet-stream' },
    })
  }),

  // FormData
  http.get('/api/form', () => {
    const form = new FormData()
    form.append('field', 'value')
    return HttpResponse.formData(form)
  }),
]
```

**When NOT to use this pattern:**
- Custom Content-Types not covered by helpers may need manual `new Response()`

Reference: [MSW HttpResponse API](https://mswjs.io/docs/api/http-response)

### 4.6 Use One-Time Handlers for Sequential Scenarios

**Impact: HIGH (Models realistic multi-step flows; tests retry logic correctly)**

Use the `{ once: true }` option for handlers that should only respond once, then fall back to the next matching handler. This is essential for testing retry logic, sequential API calls, or state changes between requests.

**Incorrect (permanent override prevents testing retries):**

```typescript
it('retries after failure', async () => {
  server.use(
    http.get('/api/user', () => {
      return new HttpResponse(null, { status: 500 })
    })
  )

  render(<UserProfile />)

  // Component retries, but always gets 500 - can't test success after retry
  await userEvent.click(screen.getByRole('button', { name: 'Retry' }))
  // Still failing...
})
```

**Correct (one-time handler for first request):**

```typescript
import { http, HttpResponse } from 'msw'

it('retries after failure and succeeds', async () => {
  server.use(
    http.get(
      '/api/user',
      () => {
        return new HttpResponse(null, { status: 500 })
      },
      { once: true }  // Only affects first request
    )
  )

  render(<UserProfile />)

  // First request fails
  expect(await screen.findByText('Error loading user')).toBeInTheDocument()

  // Retry succeeds (uses baseline happy-path handler)
  await userEvent.click(screen.getByRole('button', { name: 'Retry' }))
  expect(await screen.findByText('John')).toBeInTheDocument()
})
```

**Sequential state changes:**

```typescript
it('shows optimistic update then server response', async () => {
  let callCount = 0

  server.use(
    http.post('/api/like', () => {
      callCount++
      if (callCount === 1) {
        // First call - slow response simulates network
        return HttpResponse.json({ likes: 11 })
      }
      // Subsequent calls
      return HttpResponse.json({ likes: 12 })
    })
  )

  // Test optimistic update behavior
})
```

**Multiple sequential states:**

```typescript
server.use(
  // First request: pending
  http.get('/api/order/:id', () => {
    return HttpResponse.json({ status: 'pending' })
  }, { once: true }),

  // Second request: processing
  http.get('/api/order/:id', () => {
    return HttpResponse.json({ status: 'processing' })
  }, { once: true }),

  // Third+ requests: completed
  http.get('/api/order/:id', () => {
    return HttpResponse.json({ status: 'completed' })
  })
)
```

**When NOT to use this pattern:**
- Single-state tests that don't involve retries or polling

Reference: [Network Behavior Overrides](https://mswjs.io/docs/best-practices/network-behavior-overrides)

---

## 5. Request Matching

**Impact: MEDIUM-HIGH**

Predicate accuracy determines handler activation; subtle URL mismatches cause silent handler failures that are difficult to debug.

### 5.1 Access Query Parameters from Request URL

**Impact: MEDIUM-HIGH (Enables filtering, pagination, and search mocking)**

Parse query parameters from `request.url` using the `URL` constructor. MSW does not automatically parse query strings, so you must extract them manually.

**Incorrect (assuming params includes query string):**

```typescript
http.get('/api/users', ({ params }) => {
  // params does NOT contain query parameters!
  const page = params.page  // undefined
  return HttpResponse.json([])
})
```

**Correct (parse from request.url):**

```typescript
import { http, HttpResponse } from 'msw'

export const handlers = [
  http.get('/api/users', ({ request }) => {
    const url = new URL(request.url)
    const page = url.searchParams.get('page') || '1'
    const limit = url.searchParams.get('limit') || '10'
    const search = url.searchParams.get('search')

    // Mock paginated response
    const pageNum = parseInt(page, 10)
    const limitNum = parseInt(limit, 10)

    return HttpResponse.json({
      data: mockUsers.slice((pageNum - 1) * limitNum, pageNum * limitNum),
      meta: {
        page: pageNum,
        limit: limitNum,
        total: mockUsers.length,
      },
    })
  }),

  // Filtering by query params
  http.get('/api/products', ({ request }) => {
    const url = new URL(request.url)
    const category = url.searchParams.get('category')
    const minPrice = url.searchParams.get('minPrice')
    const maxPrice = url.searchParams.get('maxPrice')

    let products = [...mockProducts]

    if (category) {
      products = products.filter((p) => p.category === category)
    }
    if (minPrice) {
      products = products.filter((p) => p.price >= Number(minPrice))
    }
    if (maxPrice) {
      products = products.filter((p) => p.price <= Number(maxPrice))
    }

    return HttpResponse.json(products)
  }),
]
```

**Multiple values for same parameter:**

```typescript
http.get('/api/items', ({ request }) => {
  const url = new URL(request.url)
  // /api/items?tag=red&tag=blue&tag=green
  const tags = url.searchParams.getAll('tag')  // ['red', 'blue', 'green']

  return HttpResponse.json(
    mockItems.filter((item) => tags.some((tag) => item.tags.includes(tag)))
  )
})
```

**When NOT to use this pattern:**
- Endpoints that don't use query parameters

Reference: [MSW Request Object](https://mswjs.io/docs/api/request)

### 5.2 Match HTTP Methods Explicitly

**Impact: MEDIUM-HIGH (Prevents cross-method interference; models REST APIs correctly)**

Use method-specific handlers (`http.get`, `http.post`, etc.) instead of `http.all`. This prevents a GET handler from accidentally matching POST requests and ensures correct REST API simulation.

**Incorrect (catching unintended methods):**

```typescript
// Matches ALL methods - GET, POST, PUT, DELETE, etc.
http.all('/api/user', () => {
  return HttpResponse.json({ name: 'John' })
})

// POST /api/user also returns user JSON instead of creating
```

**Correct (method-specific handlers):**

```typescript
import { http, HttpResponse } from 'msw'

export const handlers = [
  // GET - retrieve resource
  http.get('/api/user/:id', ({ params }) => {
    return HttpResponse.json({ id: params.id, name: 'John' })
  }),

  // POST - create resource
  http.post('/api/user', async ({ request }) => {
    const body = await request.json()
    return HttpResponse.json(
      { id: crypto.randomUUID(), ...body },
      { status: 201 }
    )
  }),

  // PUT - replace resource
  http.put('/api/user/:id', async ({ params, request }) => {
    const body = await request.json()
    return HttpResponse.json({ id: params.id, ...body })
  }),

  // PATCH - partial update
  http.patch('/api/user/:id', async ({ params, request }) => {
    const updates = await request.json()
    return HttpResponse.json({ id: params.id, name: 'John', ...updates })
  }),

  // DELETE - remove resource
  http.delete('/api/user/:id', () => {
    return new HttpResponse(null, { status: 204 })
  }),

  // HEAD - metadata only
  http.head('/api/user/:id', () => {
    return new HttpResponse(null, {
      headers: { 'X-User-Exists': 'true' },
    })
  }),

  // OPTIONS - CORS preflight
  http.options('/api/*', () => {
    return new HttpResponse(null, {
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE',
      },
    })
  }),
]
```

**When to use http.all:**

```typescript
// Global middleware (logging, delay)
http.all('*', async () => {
  await delay(50)
  // No return - continues to next handler
})

// Catch-all fallback for testing
http.all('/api/*', () => {
  console.warn('Unhandled API request')
  return new HttpResponse(null, { status: 404 })
})
```

**When NOT to use this pattern:**
- Middleware handlers that should apply to all methods can use `http.all`

Reference: [MSW HTTP Handlers](https://mswjs.io/docs/api/http)

### 5.3 Order Handlers from Specific to General

**Impact: MEDIUM-HIGH (Prevents general handlers from shadowing specific ones)**

Place more specific handlers before general ones in the handlers array. MSW matches handlers in order, and the first match wins. A wildcard handler placed first will shadow all subsequent handlers.

**Incorrect (general handler shadows specific):**

```typescript
export const handlers = [
  // Wildcard matches first - specific handlers never reached!
  http.get('/api/*', () => {
    return HttpResponse.json({ fallback: true })
  }),

  // Never matches because /api/* already caught it
  http.get('/api/user/:id', ({ params }) => {
    return HttpResponse.json({ id: params.id, name: 'John' })
  }),
]
```

**Correct (specific before general):**

```typescript
import { http, HttpResponse } from 'msw'

export const handlers = [
  // Most specific handlers first
  http.get('/api/user/:id/settings', ({ params }) => {
    return HttpResponse.json({ userId: params.id, theme: 'dark' })
  }),

  http.get('/api/user/:id', ({ params }) => {
    return HttpResponse.json({ id: params.id, name: 'John' })
  }),

  http.get('/api/users', () => {
    return HttpResponse.json([{ id: '1' }, { id: '2' }])
  }),

  // General fallback last
  http.get('/api/*', () => {
    return HttpResponse.json(
      { error: 'Not found' },
      { status: 404 }
    )
  }),
]
```

**Middleware with passthrough:**

```typescript
export const handlers = [
  // Middleware runs first but doesn't return - passes through
  http.all('*', async () => {
    await delay(50)  // Add delay to all requests
    // No return = continue to next handler
  }),

  // Specific handlers still match
  http.get('/api/user', () => {
    return HttpResponse.json({ name: 'John' })
  }),
]
```

**Runtime handler precedence:**

```typescript
// Initial handlers
const server = setupServer(
  http.get('/api/user', () => HttpResponse.json({ name: 'John' }))
)

// Runtime handlers are PREPENDED (take precedence)
server.use(
  http.get('/api/user', () => HttpResponse.json({ name: 'Jane' }))
)

// Request to /api/user returns { name: 'Jane' }
```

**When NOT to use this pattern:**
- Single handlers don't have ordering concerns

Reference: [MSW Handler Precedence](https://mswjs.io/docs/concepts/request-handler)

### 5.4 Use Custom Predicates for Complex Matching

**Impact: MEDIUM-HIGH (Enables header-based, body-based, and conditional request matching)**

Use a predicate function instead of a URL string for complex matching logic. This enables matching based on headers, request body, cookies, or any combination of request properties.

**Incorrect (multiple handlers for same URL):**

```typescript
// Awkward - two handlers for same URL with different behavior
http.get('/api/data', () => {
  return HttpResponse.json({ public: true })
})

// How to handle authenticated vs unauthenticated?
```

**Correct (predicate-based matching):**

```typescript
import { http, HttpResponse } from 'msw'

export const handlers = [
  // Match based on header presence
  http.get('/api/data', ({ request }) => {
    const authHeader = request.headers.get('Authorization')

    if (authHeader?.startsWith('Bearer ')) {
      return HttpResponse.json({ data: 'authenticated content' })
    }

    return HttpResponse.json(
      { error: 'Unauthorized' },
      { status: 401 }
    )
  }),
]
```

**Predicate function syntax:**

```typescript
// Match by custom criteria
http.all(
  ({ request }) => {
    // Return true to match this request
    return request.url.includes('/api/') &&
           request.headers.get('X-Custom-Header') === 'special'
  },
  () => {
    return HttpResponse.json({ matched: true })
  }
)
```

**Match by request body content:**

```typescript
http.post(
  '/api/action',
  async ({ request }) => {
    const body = await request.clone().json()

    // Different response based on action type
    if (body.action === 'create') {
      return HttpResponse.json({ id: '1', created: true })
    }
    if (body.action === 'delete') {
      return new HttpResponse(null, { status: 204 })
    }

    return HttpResponse.json(
      { error: 'Unknown action' },
      { status: 400 }
    )
  }
)
```

**Match by cookie value:**

```typescript
http.get('/api/user', ({ cookies }) => {
  if (cookies.role === 'admin') {
    return HttpResponse.json({ permissions: ['read', 'write', 'delete'] })
  }
  return HttpResponse.json({ permissions: ['read'] })
})
```

**When NOT to use this pattern:**
- Simple URL-based matching is clearer when sufficient

Reference: [MSW Custom Request Predicate](https://mswjs.io/docs/best-practices/custom-request-predicate)

### 5.5 Use URL Path Parameters Correctly

**Impact: MEDIUM-HIGH (Prevents silent handler mismatches; enables dynamic URL matching)**

Use `:paramName` syntax for dynamic path segments. Parameters are available in the resolver's `params` object. Incorrect patterns cause handlers to never match.

**Incorrect (literal URL instead of pattern):**

```typescript
// Only matches exact string "/api/user/123"
http.get('/api/user/123', () => {
  return HttpResponse.json({ name: 'John' })
})

// Request to /api/user/456 is unhandled
```

**Correct (parameterized URL):**

```typescript
import { http, HttpResponse } from 'msw'

export const handlers = [
  // Matches /api/user/123, /api/user/abc, etc.
  http.get('/api/user/:id', ({ params }) => {
    return HttpResponse.json({ id: params.id, name: 'John' })
  }),

  // Multiple parameters
  http.get('/api/org/:orgId/user/:userId', ({ params }) => {
    return HttpResponse.json({
      orgId: params.orgId,
      userId: params.userId,
    })
  }),

  // Optional parameters (use separate handlers)
  http.get('/api/posts', () => {
    return HttpResponse.json([{ id: '1' }, { id: '2' }])
  }),
  http.get('/api/posts/:postId', ({ params }) => {
    return HttpResponse.json({ id: params.postId })
  }),
]
```

**Wildcard patterns:**

```typescript
// Match any path starting with /api/
http.get('/api/*', () => {
  return HttpResponse.json({ fallback: true })
})

// Match any origin with specific path
http.get('*/api/user', () => {
  return HttpResponse.json({ name: 'John' })
})

// Match all requests of a method
http.get('*', () => {
  return HttpResponse.json({ catchAll: true })
})
```

**Type-safe parameters:**

```typescript
type UserParams = {
  userId: string
}

http.get<UserParams>('/api/user/:userId', ({ params }) => {
  // params.userId is typed as string
  return HttpResponse.json({ id: params.userId })
})
```

**When NOT to use this pattern:**
- Exact URL matching for specific endpoints that never vary

Reference: [MSW Request Matching](https://mswjs.io/docs/http/intercepting-requests)

---

## 6. GraphQL Mocking

**Impact: MEDIUM**

GraphQL-specific patterns for intercepting operations, handling variables, query batching, and error simulation require dedicated approaches.

### 6.1 Access GraphQL Variables Correctly

**Impact: MEDIUM (Enables dynamic mock responses based on query input)**

Access GraphQL variables through the `variables` property in the resolver argument. Use them to return dynamic responses based on query input.

**Incorrect (ignoring variables):**

```typescript
// Returns same user regardless of which ID is requested
graphql.query('GetUser', () => {
  return HttpResponse.json({
    data: {
      user: { id: '1', name: 'John' },
    },
  })
})
```

**Correct (using variables for dynamic responses):**

```typescript
import { graphql, HttpResponse } from 'msw'

// Mock data store
const users = new Map([
  ['1', { id: '1', name: 'John', email: 'john@example.com' }],
  ['2', { id: '2', name: 'Jane', email: 'jane@example.com' }],
])

export const handlers = [
  graphql.query('GetUser', ({ variables }) => {
    const user = users.get(variables.id)

    if (!user) {
      return HttpResponse.json({
        data: null,
        errors: [{ message: 'User not found' }],
      })
    }

    return HttpResponse.json({
      data: { user },
    })
  }),

  // Mutation with input variables
  graphql.mutation('UpdateUser', ({ variables }) => {
    const { id, input } = variables
    const existingUser = users.get(id)

    if (!existingUser) {
      return HttpResponse.json({
        data: null,
        errors: [{ message: 'User not found' }],
      })
    }

    const updatedUser = { ...existingUser, ...input }
    users.set(id, updatedUser)

    return HttpResponse.json({
      data: { updateUser: updatedUser },
    })
  }),

  // Pagination with variables
  graphql.query('GetUsers', ({ variables }) => {
    const { first = 10, after } = variables
    const allUsers = Array.from(users.values())

    let startIndex = 0
    if (after) {
      startIndex = allUsers.findIndex((u) => u.id === after) + 1
    }

    const pageUsers = allUsers.slice(startIndex, startIndex + first)
    const hasNextPage = startIndex + first < allUsers.length

    return HttpResponse.json({
      data: {
        users: {
          edges: pageUsers.map((user) => ({
            node: user,
            cursor: user.id,
          })),
          pageInfo: {
            hasNextPage,
            endCursor: pageUsers[pageUsers.length - 1]?.id,
          },
        },
      },
    })
  }),
]
```

**Type-safe variables:**

```typescript
type GetUserVariables = {
  id: string
}

graphql.query<GetUserVariables>('GetUser', ({ variables }) => {
  // variables.id is typed as string
  return HttpResponse.json({
    data: {
      user: { id: variables.id, name: 'John' },
    },
  })
})
```

**When NOT to use this pattern:**
- Queries without variables don't need variable access

Reference: [MSW GraphQL Intercepting Operations](https://mswjs.io/docs/graphql/intercepting-operations)

### 6.2 Handle Batched GraphQL Queries

**Impact: MEDIUM (Supports Apollo batching; prevents unhandled batch requests)**

Create a custom handler for batched GraphQL queries when using Apollo Client's batch link or similar. Batched requests send multiple operations in a single HTTP request.

**Incorrect (individual handlers don't match batches):**

```typescript
// These won't match a batched request containing both queries
graphql.query('GetUser', () => {
  return HttpResponse.json({ data: { user: { name: 'John' } } })
})

graphql.query('GetPosts', () => {
  return HttpResponse.json({ data: { posts: [] } })
})

// Batched request is unhandled!
```

**Correct (batch handler with individual resolution):**

```typescript
import { http, HttpResponse, getResponse, bypass } from 'msw'

export function batchedGraphQLQuery(url: string, handlers: RequestHandler[]) {
  return http.post(url, async ({ request }) => {
    const requestClone = request.clone()
    const payload = await request.json()

    // Ignore non-batched requests
    if (!Array.isArray(payload)) {
      return
    }

    // Resolve each query in the batch
    const responses = await Promise.all(
      payload.map(async (operation) => {
        const queryRequest = new Request(requestClone.url, {
          method: 'POST',
          headers: requestClone.headers,
          body: JSON.stringify(operation),
        })

        const response = await getResponse(handlers, queryRequest)
        return response || fetch(bypass(queryRequest))
      })
    )

    // Combine responses into batch format
    const results = await Promise.all(
      responses.map((response) => response?.json())
    )

    return HttpResponse.json(results)
  })
}
```

```typescript
// Usage
import { graphql, HttpResponse } from 'msw'
import { batchedGraphQLQuery } from './batchedGraphQLQuery'

const graphqlHandlers = [
  graphql.query('GetUser', () => {
    return HttpResponse.json({
      data: { user: { id: '1', name: 'John' } },
    })
  }),
  graphql.query('GetPosts', () => {
    return HttpResponse.json({
      data: { posts: [{ id: '1', title: 'Post 1' }] },
    })
  }),
]

export const handlers = [
  batchedGraphQLQuery('/graphql', graphqlHandlers),
  ...graphqlHandlers,  // Also handle non-batched requests
]
```

**When NOT to use this pattern:**
- Apps not using query batching don't need batch handlers

Reference: [MSW GraphQL Query Batching](https://mswjs.io/docs/graphql/mocking-responses/query-batching)

### 6.3 Return GraphQL Errors in Correct Format

**Impact: MEDIUM (Ensures GraphQL clients parse errors correctly; tests error handling)**

Return GraphQL errors in the standard `errors` array format. GraphQL errors are different from HTTP errors - they use status 200 with an `errors` field in the response body.

**Incorrect (HTTP-style error response):**

```typescript
// GraphQL clients won't recognize this as a GraphQL error
graphql.query('GetUser', () => {
  return HttpResponse.json(
    { error: 'User not found' },
    { status: 404 }
  )
})
```

**Correct (GraphQL error format):**

```typescript
import { graphql, HttpResponse } from 'msw'

export const handlers = [
  // Single error
  graphql.query('GetUser', () => {
    return HttpResponse.json({
      data: null,
      errors: [
        {
          message: 'User not found',
          extensions: {
            code: 'NOT_FOUND',
          },
        },
      ],
    })
  }),

  // Validation errors with paths
  graphql.mutation('CreateUser', () => {
    return HttpResponse.json({
      data: null,
      errors: [
        {
          message: 'Invalid email format',
          path: ['createUser', 'email'],
          extensions: {
            code: 'VALIDATION_ERROR',
            field: 'email',
          },
        },
        {
          message: 'Name is required',
          path: ['createUser', 'name'],
          extensions: {
            code: 'VALIDATION_ERROR',
            field: 'name',
          },
        },
      ],
    })
  }),

  // Partial success with errors
  graphql.query('GetUsers', () => {
    return HttpResponse.json({
      data: {
        users: [
          { id: '1', name: 'John' },
          null,  // This user failed to load
          { id: '3', name: 'Jane' },
        ],
      },
      errors: [
        {
          message: 'Failed to load user',
          path: ['users', 1],
          extensions: { code: 'INTERNAL_ERROR' },
        },
      ],
    })
  }),

  // Authentication error
  graphql.query('GetPrivateData', () => {
    return HttpResponse.json({
      data: null,
      errors: [
        {
          message: 'Not authenticated',
          extensions: {
            code: 'UNAUTHENTICATED',
          },
        },
      ],
    })
  }),
]
```

**Network-level errors (rare):**

```typescript
// For complete request failures, use HTTP error
graphql.query('GetUser', () => {
  return HttpResponse.error()  // Network failure
})
```

**When NOT to use this pattern:**
- True network failures (DNS, connection) use `HttpResponse.error()`

Reference: [GraphQL Spec - Errors](https://spec.graphql.org/October2021/#sec-Errors)

### 6.4 Use Operation Name for GraphQL Matching

**Impact: MEDIUM (Enables precise operation targeting; prevents query/mutation conflicts)**

Match GraphQL operations by their operation name, not by URL. All GraphQL requests typically go to the same endpoint (`/graphql`), so operation name is the discriminator.

**Incorrect (URL-based matching for GraphQL):**

```typescript
// All GraphQL requests go to /graphql - this catches everything!
http.post('/graphql', () => {
  return HttpResponse.json({ data: { user: { name: 'John' } } })
})
```

**Correct (operation-based matching):**

```typescript
import { graphql, HttpResponse } from 'msw'

export const handlers = [
  // Match query by operation name
  graphql.query('GetUser', () => {
    return HttpResponse.json({
      data: {
        user: {
          id: '1',
          name: 'John',
          email: 'john@example.com',
        },
      },
    })
  }),

  // Match mutation by operation name
  graphql.mutation('CreateUser', async ({ variables }) => {
    return HttpResponse.json({
      data: {
        createUser: {
          id: crypto.randomUUID(),
          name: variables.name,
          email: variables.email,
        },
      },
    })
  }),

  // Separate handlers for different queries
  graphql.query('GetUsers', () => {
    return HttpResponse.json({
      data: {
        users: [
          { id: '1', name: 'John' },
          { id: '2', name: 'Jane' },
        ],
      },
    })
  }),
]
```

**Access operation variables:**

```typescript
graphql.query('GetUser', ({ variables }) => {
  // variables matches your GraphQL query variables
  return HttpResponse.json({
    data: {
      user: {
        id: variables.id,
        name: 'John',
      },
    },
  })
})

// Query from client:
// query GetUser($id: ID!) { user(id: $id) { id name } }
// variables: { id: "123" }
```

**Custom GraphQL endpoint:**

```typescript
// If your GraphQL endpoint isn't /graphql
graphql.link('https://api.example.com/gql').query('GetUser', () => {
  return HttpResponse.json({
    data: { user: { name: 'John' } },
  })
})
```

**When NOT to use this pattern:**
- REST APIs should use `http.*` handlers, not GraphQL handlers

Reference: [MSW GraphQL API](https://mswjs.io/docs/api/graphql)

---

## 7. Advanced Patterns

**Impact: MEDIUM**

Complex scenarios including request bypass, passthrough, cookies, authentication, streaming, and WebSocket mocking for comprehensive API simulation.

### 7.1 Configure MSW for Vitest Browser Mode

**Impact: MEDIUM (Enables browser-environment testing with proper worker setup)**

Extend Vitest's test context to include the MSW worker when testing in browser mode. This ensures proper worker lifecycle management per test.

**Incorrect (global worker without test context):**

```typescript
// Worker state leaks between tests
import { worker } from './mocks/browser'

beforeAll(() => worker.start())
afterAll(() => worker.stop())

// Tests can't override handlers safely
```

**Correct (extended test context):**

```typescript
// test-extend.ts
import { test as testBase } from 'vitest'
import { worker } from './mocks/browser'

export const test = testBase.extend({
  worker: [
    async ({}, use) => {
      // Start worker before test
      await worker.start({
        onUnhandledRequest: 'error',
      })

      // Provide worker to test
      await use(worker)

      // Reset handlers after test
      worker.resetHandlers()
    },
    {
      auto: true,  // Automatically available to all tests
    },
  ],
})

export { expect } from 'vitest'
```

```typescript
// user.test.ts
import { http, HttpResponse } from 'msw'
import { test, expect } from './test-extend'
import { Dashboard } from './components/Dashboard'

test('displays user data', async ({ worker }) => {
  // Worker is automatically started
  render(<Dashboard />)
  expect(await screen.findByText('John')).toBeInTheDocument()
})

test('handles error state', async ({ worker }) => {
  // Override handlers for this test
  worker.use(
    http.get('/api/user', () => {
      return new HttpResponse(null, { status: 500 })
    })
  )

  render(<Dashboard />)
  expect(await screen.findByText('Error loading')).toBeInTheDocument()
})
```

**Vitest config for browser mode:**

```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: {
    browser: {
      enabled: true,
      name: 'chromium',
      provider: 'playwright',
    },
    setupFiles: ['./vitest.setup.ts'],
  },
})
```

**When NOT to use this pattern:**
- Node.js tests should use `setupServer` instead

Reference: [MSW Vitest Browser Mode](https://mswjs.io/docs/recipes/vitest-browser-mode)

### 7.2 Handle Cookies and Authentication

**Impact: MEDIUM (Enables session-based auth testing; validates auth flows)**

Access cookies from the `cookies` object in resolvers and set cookies via response headers. This enables testing of session-based authentication flows.

**Incorrect (ignoring authentication state):**

```typescript
// Always returns user regardless of auth state
http.get('/api/user', () => {
  return HttpResponse.json({ name: 'John' })
})
```

**Correct (cookie-based auth handling):**

```typescript
import { http, HttpResponse } from 'msw'

export const handlers = [
  // Login sets session cookie
  http.post('/api/login', async ({ request }) => {
    const { email, password } = await request.json()

    if (email === 'john@example.com' && password === 'password') {
      return HttpResponse.json(
        { user: { id: '1', email } },
        {
          headers: {
            'Set-Cookie': 'session=abc123; Path=/; HttpOnly; SameSite=Strict',
          },
        }
      )
    }

    return HttpResponse.json(
      { error: 'Invalid credentials' },
      { status: 401 }
    )
  }),

  // Protected endpoint checks cookie
  http.get('/api/user', ({ cookies }) => {
    if (!cookies.session) {
      return HttpResponse.json(
        { error: 'Not authenticated' },
        { status: 401 }
      )
    }

    // In real app, validate session token
    return HttpResponse.json({
      id: '1',
      name: 'John',
      email: 'john@example.com',
    })
  }),

  // Logout clears cookie
  http.post('/api/logout', () => {
    return new HttpResponse(null, {
      status: 200,
      headers: {
        'Set-Cookie': 'session=; Path=/; Expires=Thu, 01 Jan 1970 00:00:00 GMT',
      },
    })
  }),
]
```

**Bearer token authentication:**

```typescript
http.get('/api/protected', ({ request }) => {
  const authHeader = request.headers.get('Authorization')

  if (!authHeader?.startsWith('Bearer ')) {
    return HttpResponse.json(
      { error: 'Missing token' },
      { status: 401 }
    )
  }

  const token = authHeader.slice(7)

  // Validate token (simplified)
  if (token === 'valid-token') {
    return HttpResponse.json({ data: 'protected content' })
  }

  return HttpResponse.json(
    { error: 'Invalid token' },
    { status: 403 }
  )
})
```

**Multiple cookies:**

```typescript
http.get('/api/preferences', ({ cookies }) => {
  return HttpResponse.json({
    theme: cookies.theme || 'light',
    language: cookies.lang || 'en',
    userId: cookies.session ? '1' : null,
  })
})
```

**When NOT to use this pattern:**
- Public endpoints that don't require authentication

Reference: [MSW Cookies](https://mswjs.io/docs/concepts/request-handler#cookies)

### 7.3 Implement Dynamic Mock Scenarios

**Impact: MEDIUM (Enables runtime mock state changes; supports complex test flows)**

Use module-level state or scenario flags to switch between different mock behaviors at runtime. This enables testing different application states without restarting tests.

**Incorrect (static handlers for all scenarios):**

```typescript
// Can't test different user states without test setup changes
http.get('/api/user', () => {
  return HttpResponse.json({ name: 'John', plan: 'free' })
})
```

**Correct (dynamic scenario switching):**

```typescript
import { http, HttpResponse } from 'msw'

// Scenario state
type Scenario = 'default' | 'premium' | 'expired' | 'error'
let currentScenario: Scenario = 'default'

// Export function to change scenario
export function setScenario(scenario: Scenario) {
  currentScenario = scenario
}

export const handlers = [
  http.get('/api/user', () => {
    switch (currentScenario) {
      case 'premium':
        return HttpResponse.json({
          name: 'John',
          plan: 'premium',
          features: ['feature1', 'feature2', 'feature3'],
        })

      case 'expired':
        return HttpResponse.json({
          name: 'John',
          plan: 'expired',
          features: [],
          message: 'Please renew your subscription',
        })

      case 'error':
        return HttpResponse.json(
          { error: 'Service unavailable' },
          { status: 503 }
        )

      default:
        return HttpResponse.json({
          name: 'John',
          plan: 'free',
          features: ['feature1'],
        })
    }
  }),
]
```

**Usage in tests:**

```typescript
import { setScenario } from '../mocks/handlers'

describe('Subscription', () => {
  afterEach(() => {
    setScenario('default')  // Reset after each test
  })

  it('shows premium features for premium users', async () => {
    setScenario('premium')
    render(<Dashboard />)
    expect(await screen.findByText('Premium Features')).toBeInTheDocument()
  })

  it('shows renewal prompt for expired users', async () => {
    setScenario('expired')
    render(<Dashboard />)
    expect(await screen.findByText('Please renew')).toBeInTheDocument()
  })
})
```

**URL-based scenarios (for development):**

```typescript
http.get('/api/user', ({ request }) => {
  const url = new URL(request.url)
  const scenario = url.searchParams.get('_scenario')

  if (scenario === 'error') {
    return new HttpResponse(null, { status: 500 })
  }

  return HttpResponse.json({ name: 'John' })
})

// In browser: /dashboard?_scenario=error
```

**When NOT to use this pattern:**
- Simple tests with single states don't need scenario complexity

Reference: [Dynamic Mock Scenarios](https://mswjs.io/docs/best-practices/dynamic-mock-scenarios)

### 7.4 Mock File Upload Endpoints

**Impact: MEDIUM (Tests file upload forms and progress indicators)**

Parse `FormData` from requests to mock file upload endpoints. Access uploaded files and other form fields through the standard `FormData` API.

**Incorrect (ignoring multipart data):**

```typescript
// Can't access uploaded file
http.post('/api/upload', () => {
  return HttpResponse.json({ success: true })
})
```

**Correct (parsing FormData):**

```typescript
import { http, HttpResponse, delay } from 'msw'

export const handlers = [
  // Single file upload
  http.post('/api/upload', async ({ request }) => {
    const formData = await request.formData()
    const file = formData.get('file') as File

    if (!file) {
      return HttpResponse.json(
        { error: 'No file provided' },
        { status: 400 }
      )
    }

    // Simulate upload delay based on file size
    await delay(Math.min(file.size / 1000, 2000))

    return HttpResponse.json({
      id: crypto.randomUUID(),
      filename: file.name,
      size: file.size,
      mimeType: file.type,
      url: `https://cdn.example.com/uploads/${file.name}`,
    })
  }),

  // Multiple files
  http.post('/api/upload-multiple', async ({ request }) => {
    const formData = await request.formData()
    const files = formData.getAll('files') as File[]

    const results = files.map((file) => ({
      id: crypto.randomUUID(),
      filename: file.name,
      size: file.size,
    }))

    return HttpResponse.json({ files: results })
  }),

  // File with additional form fields
  http.post('/api/profile/avatar', async ({ request }) => {
    const formData = await request.formData()
    const avatar = formData.get('avatar') as File
    const userId = formData.get('userId') as string

    if (!avatar || !userId) {
      return HttpResponse.json(
        { error: 'Missing required fields' },
        { status: 400 }
      )
    }

    return HttpResponse.json({
      userId,
      avatarUrl: `https://cdn.example.com/avatars/${userId}/${avatar.name}`,
    })
  }),
]
```

**Validating file types:**

```typescript
http.post('/api/upload/image', async ({ request }) => {
  const formData = await request.formData()
  const file = formData.get('image') as File

  const allowedTypes = ['image/jpeg', 'image/png', 'image/gif']

  if (!allowedTypes.includes(file.type)) {
    return HttpResponse.json(
      { error: 'Invalid file type. Allowed: JPEG, PNG, GIF' },
      { status: 415 }
    )
  }

  return HttpResponse.json({ success: true, url: '/uploaded.jpg' })
})
```

**When NOT to use this pattern:**
- JSON-only APIs don't need FormData parsing

Reference: [MSW Request FormData](https://mswjs.io/docs/api/request)

### 7.5 Use bypass() for Passthrough Requests

**Impact: MEDIUM (Enables mixing real and mocked APIs; supports hybrid testing)**

Use `bypass()` to mark requests that should skip MSW interception and hit the real server. This enables hybrid scenarios where some APIs are mocked and others are real.

**Incorrect (request creates infinite loop):**

```typescript
// Making a fetch inside a handler without bypass creates infinite recursion
http.get('/api/user', async () => {
  // This request is intercepted by this same handler!
  const realResponse = await fetch('/api/user')  // Infinite loop
  return realResponse
})
```

**Correct (bypass MSW interception):**

```typescript
import { http, HttpResponse, bypass } from 'msw'

export const handlers = [
  // Proxy to real API and modify response
  http.get('/api/user', async ({ request }) => {
    // bypass() marks the request to skip MSW
    const realResponse = await fetch(bypass(request))
    const realData = await realResponse.json()

    // Augment real data with mock data
    return HttpResponse.json({
      ...realData,
      mockField: 'added by MSW',
    })
  }),

  // Conditional passthrough
  http.get('/api/data', async ({ request }) => {
    const url = new URL(request.url)

    // Only mock in test environment
    if (url.searchParams.get('mock') !== 'true') {
      return fetch(bypass(request))
    }

    return HttpResponse.json({ mocked: true })
  }),
]
```

**Using passthrough() for unconditional passthrough:**

```typescript
import { http, passthrough } from 'msw'

export const handlers = [
  // Always pass through to real API
  http.get('/api/analytics/*', () => {
    return passthrough()
  }),

  // Pass through external APIs
  http.all('https://external-service.com/*', () => {
    return passthrough()
  }),
]
```

**Difference between bypass and passthrough:**
- `bypass(request)`: Use inside a handler to make a real request
- `passthrough()`: Return from handler to let the original request through

**When NOT to use this pattern:**
- Fully mocked environments should avoid real API calls

Reference: [MSW bypass API](https://mswjs.io/docs/api/bypass)

---

## 8. Debugging & Performance

**Impact: LOW**

Observability tools, lifecycle events, and troubleshooting patterns for diagnosing MSW configuration issues during development.

### 8.1 Know Common MSW Issues and Fixes

**Impact: LOW (Quick reference for frequent problems; reduces debugging time)**

Reference this checklist when MSW behaves unexpectedly. Most issues fall into a few common categories that have well-known solutions.

**Incorrect (handler not matching due to relative URL):**

```typescript
// Node.js environment - handler never matches
import { http, HttpResponse } from 'msw'

export const handlers = [
  // Relative URL doesn't match absolute request URLs
  http.get('/api/user', () => {
    return HttpResponse.json({ name: 'John' })
  }),
]

// When fetch('http://localhost:3000/api/user') is called,
// the handler doesn't match because '/api/user' !== 'http://localhost:3000/api/user'
```

**Correct (handler matches with wildcard):**

```typescript
// Node.js environment - handler matches any origin
import { http, HttpResponse } from 'msw'

export const handlers = [
  // Wildcard matches any origin prefix
  http.get('*/api/user', () => {
    return HttpResponse.json({ name: 'John' })
  }),
]

// Now fetch('http://localhost:3000/api/user') matches correctly
```

## Common Issues Quick Reference

**Issue: "fetch is not defined"**
- Fix: Upgrade Node.js to 18+ (native fetch support)

**Issue: Body parsing hangs with fake timers**
```typescript
// Fix: Exclude queueMicrotask from fake timers
vi.useFakeTimers({
  toFake: ['setTimeout', 'setInterval', 'Date'],
  // queueMicrotask NOT faked
})
```

**Issue: Stale responses from cache**
```typescript
// Fix: Clear request library cache between tests
afterEach(() => {
  cache.clear()  // SWR
  queryClient.clear()  // TanStack Query
})
```

**Issue: MSW v1 code in v2 project**
```typescript
// v2 correct syntax:
http.get('/api/user', () => {
  return HttpResponse.json({ name: 'John' })
})
```

**When NOT to use this pattern:**
- Reference only; not all issues apply to every project

Reference: [MSW Debugging Runbook](https://mswjs.io/docs/runbook/)

### 8.2 Log Request Details for Debugging

**Impact: LOW (Provides detailed request inspection; identifies payload issues)**

Create a debugging middleware handler to log full request details. This helps identify issues with request payloads, headers, and authentication.

**Incorrect (no request visibility):**

```typescript
// Can't see what's being sent to handlers
http.post('/api/user', async ({ request }) => {
  const body = await request.json()
  // body is unexpected - but why?
  return HttpResponse.json({ error: 'Invalid data' }, { status: 400 })
})
```

**Correct (detailed request logging):**

```typescript
import { http, HttpResponse } from 'msw'

// Debug middleware - add as first handler
const debugHandler = http.all('*', async ({ request }) => {
  const url = new URL(request.url)
  const clone = request.clone()

  console.group(`[MSW] ${request.method} ${url.pathname}`)
  console.log('Full URL:', request.url)
  console.log('Headers:', Object.fromEntries(request.headers.entries()))

  // Log body for non-GET requests
  if (request.method !== 'GET' && request.method !== 'HEAD') {
    const contentType = request.headers.get('Content-Type')

    if (contentType?.includes('application/json')) {
      console.log('Body (JSON):', await clone.json())
    } else if (contentType?.includes('multipart/form-data')) {
      const formData = await clone.formData()
      console.log('Body (FormData):', Object.fromEntries(formData.entries()))
    } else {
      console.log('Body (Text):', await clone.text())
    }
  }

  console.groupEnd()

  // Don't return - let next handler process the request
})

export const handlers = [
  debugHandler,  // Must be first
  // ... other handlers
]
```

**Conditional debug mode:**

```typescript
const DEBUG = process.env.DEBUG_MSW === 'true'

export const handlers = [
  ...(DEBUG ? [debugHandler] : []),
  // ... other handlers
]
```

**Response logging:**

```typescript
// Log responses using lifecycle events
server.events.on('request:end', async ({ request, response }) => {
  if (!response) return

  const clone = response.clone()
  const contentType = response.headers.get('Content-Type')

  console.log(`[MSW Response] ${request.method} ${request.url}`)
  console.log('Status:', response.status)

  if (contentType?.includes('application/json')) {
    console.log('Body:', await clone.json())
  }
})
```

**Development browser logging:**

```typescript
// mocks/browser.ts
import { setupWorker } from 'msw/browser'
import { handlers } from './handlers'

export const worker = setupWorker(...handlers)

// Enable detailed logging in development
if (process.env.NODE_ENV === 'development') {
  worker.start({
    onUnhandledRequest: 'warn',
  })
}
```

**When NOT to use this pattern:**
- Remove debug logging before committing/production
- CI should use minimal logging for cleaner output

Reference: [MSW Lifecycle Events](https://mswjs.io/docs/api/life-cycle-events)

### 8.3 Use Lifecycle Events for Debugging

**Impact: LOW (Provides visibility into request interception; aids troubleshooting)**

Subscribe to lifecycle events to observe request interception, matching, and responses. This is invaluable for debugging why handlers aren't matching or responses aren't arriving.

**Incorrect (guessing why requests fail):**

```typescript
// No visibility into what MSW is doing
const server = setupServer(...handlers)
server.listen()

// Tests fail mysteriously - is the handler matching? Is the response correct?
```

**Correct (lifecycle event logging):**

```typescript
import { setupServer } from 'msw/node'
import { handlers } from './handlers'

const server = setupServer(...handlers)

// Log all intercepted requests
server.events.on('request:start', ({ request }) => {
  console.log('MSW intercepted:', request.method, request.url)
})

// Log when a handler matches
server.events.on('request:match', ({ request }) => {
  console.log('MSW matched:', request.method, request.url)
})

// Log completed responses
server.events.on('request:end', ({ request, response }) => {
  console.log(
    'MSW responded:',
    request.method,
    request.url,
    '→',
    response.status
  )
})

// Log unhandled requests
server.events.on('request:unhandled', ({ request }) => {
  console.warn('MSW unhandled:', request.method, request.url)
})
```

**Conditional logging:**

```typescript
// Only log in debug mode
if (process.env.DEBUG_MSW) {
  server.events.on('request:start', ({ request }) => {
    console.log('[MSW]', request.method, request.url)
  })
}
```

**Event types:**
- `request:start` - Request intercepted by MSW
- `request:match` - Handler found for request
- `request:unhandled` - No handler matched
- `request:end` - Response sent (mocked or passthrough)
- `response:mocked` - Mocked response sent
- `response:bypass` - Request passed through to network

**Cleanup:**

```typescript
// Remove event listeners when done
const unsubscribe = server.events.on('request:start', handler)
unsubscribe()  // Remove listener
```

**When NOT to use this pattern:**
- Production builds should not include debug logging
- CI environments may want minimal logging for cleaner output

Reference: [MSW Lifecycle Events](https://mswjs.io/docs/api/life-cycle-events)

### 8.4 Verify Request Interception is Working

**Impact: LOW (Confirms MSW is active; identifies setup failures early)**

Add a verification step to confirm MSW is intercepting requests. This catches configuration issues before they cause mysterious test failures.

**Incorrect (assuming MSW is working):**

```typescript
// No verification - tests fail with confusing errors
beforeAll(() => server.listen())

it('fetches user', async () => {
  // If MSW isn't working, this hits real API or fails silently
  const response = await fetch('/api/user')
})
```

**Correct (verify interception):**

```typescript
import { setupServer } from 'msw/node'
import { handlers } from './handlers'

const server = setupServer(...handlers)

beforeAll(() => {
  server.listen()

  // Verify MSW is intercepting
  server.events.on('request:start', ({ request }) => {
    console.log('✓ MSW intercepted:', request.method, request.url)
  })
})

// Or create a verification test
describe('MSW Setup', () => {
  it('intercepts requests', async () => {
    let intercepted = false

    server.events.on('request:start', () => {
      intercepted = true
    })

    await fetch('/api/health')

    expect(intercepted).toBe(true)
  })
})
```

**Debugging checklist when handlers don't match:**

```typescript
// Step 1: Verify interception is happening
server.events.on('request:start', ({ request }) => {
  console.log('Intercepted URL:', request.url)  // Check if URL is absolute
  console.log('Intercepted method:', request.method)
})

// Step 2: Add console.log inside handler
http.get('/api/user', () => {
  console.log('Handler matched!')  // If this doesn't log, handler isn't matching
  return HttpResponse.json({ name: 'John' })
})

// Step 3: Check handler URL vs request URL
// Common issues:
// - Handler: '/api/user' but request goes to 'http://localhost:3000/api/user'
// - Environment variable in URL is undefined
// - Typo in URL path
```

**Browser verification:**

```typescript
// In browser console
const { worker } = await import('./mocks/browser')
await worker.start()

// Check if worker script is accessible
fetch('/mockServiceWorker.js')
  .then((r) => r.ok ? 'Worker script found' : 'Worker script missing')
  .then(console.log)
```

**When NOT to use this pattern:**
- Stable test suites don't need verification in every run

Reference: [MSW Debugging Runbook](https://mswjs.io/docs/runbook/)

---

## References

1. [https://mswjs.io/docs/](https://mswjs.io/docs/)
2. [https://mswjs.io/docs/best-practices/](https://mswjs.io/docs/best-practices/)
3. [https://mswjs.io/docs/migrations/1.x-to-2.x/](https://mswjs.io/docs/migrations/1.x-to-2.x/)
4. [https://mswjs.io/docs/runbook/](https://mswjs.io/docs/runbook/)
5. [https://github.com/mswjs/msw](https://github.com/mswjs/msw)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |