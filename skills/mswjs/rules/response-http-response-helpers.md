---
title: Use HttpResponse Static Methods
impact: HIGH
impactDescription: Automatic Content-Type headers; cleaner syntax; type safety
tags: response, HttpResponse, json, text, xml, helpers
---

## Use HttpResponse Static Methods

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
