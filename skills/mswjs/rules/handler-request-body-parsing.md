---
title: Explicitly Parse Request Bodies
impact: CRITICAL
impactDescription: v2 no longer auto-parses bodies; missing parsing returns undefined
tags: handler, request, body, parsing, json
---

## Explicitly Parse Request Bodies

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
