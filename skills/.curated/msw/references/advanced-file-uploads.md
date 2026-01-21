---
title: Mock File Upload Endpoints
impact: MEDIUM
impactDescription: Tests file upload forms and progress indicators
tags: advanced, upload, file, formdata, multipart
---

## Mock File Upload Endpoints

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
