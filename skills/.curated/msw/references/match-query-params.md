---
title: Access Query Parameters from Request URL
impact: MEDIUM-HIGH
impactDescription: Enables filtering, pagination, and search mocking
tags: match, query, search-params, url, filtering
---

## Access Query Parameters from Request URL

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
