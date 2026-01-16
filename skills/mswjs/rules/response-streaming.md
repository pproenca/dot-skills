---
title: Mock Streaming Responses with ReadableStream
impact: HIGH
impactDescription: Tests streaming UIs, chat interfaces, and progressive loading
tags: response, streaming, ReadableStream, sse, progressive
---

## Mock Streaming Responses with ReadableStream

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
