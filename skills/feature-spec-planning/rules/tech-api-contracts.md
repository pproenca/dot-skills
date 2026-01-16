---
title: Define API Contracts Before Implementation
impact: MEDIUM
impactDescription: prevents 70% of integration rework
tags: tech, api, contracts, interface
---

## Define API Contracts Before Implementation

Specify API contracts (request/response schemas, error codes, versioning) before coding begins. Vague APIs lead to frontend-backend mismatches, requiring costly iterations.

**Incorrect (vague API description):**

```markdown
## API

The search endpoint accepts a query and returns results.

// Frontend developer asks:
// - What's the URL?
// - GET or POST?
// - What parameters?
// - What does the response look like?
// - What errors can occur?
// Result: Frontend builds assumptions, backend builds differently
```

**Correct (complete API contract):**

```markdown
## API Contract: Product Search

### Endpoint

```http
GET /api/v2/products/search
```

### Authentication
- Required: Yes
- Type: Bearer token (JWT)
- Scopes: `products:read`

### Request

**Query Parameters:**
| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| q | string | Yes | - | Search query (2-100 chars) |
| category | string | No | all | Category filter |
| min_price | number | No | 0 | Minimum price in cents |
| max_price | number | No | null | Maximum price in cents |
| sort | enum | No | relevance | `relevance`, `price_asc`, `price_desc`, `newest` |
| page | integer | No | 1 | Page number (1-1000) |
| per_page | integer | No | 20 | Results per page (1-100) |

**Example Request:**
```bash
curl -X GET "https://api.example.com/api/v2/products/search?q=laptop&category=electronics&sort=price_asc&page=1&per_page=20" \
  -H "Authorization: Bearer eyJhbGc..."
```

### Response

**Success (200 OK):**
```json
{
  "data": {
    "products": [
      {
        "id": "prod_abc123",
        "name": "MacBook Pro 14\"",
        "description": "Apple M3 Pro chip...",
        "price_cents": 199900,
        "currency": "USD",
        "category": "electronics",
        "image_url": "https://cdn.example.com/products/abc123.jpg",
        "in_stock": true,
        "rating": 4.8,
        "review_count": 1247
      }
    ],
    "pagination": {
      "current_page": 1,
      "per_page": 20,
      "total_pages": 15,
      "total_count": 287
    },
    "facets": {
      "categories": [{"name": "electronics", "count": 150}],
      "price_ranges": [{"min": 0, "max": 10000, "count": 45}]
    }
  },
  "meta": {
    "request_id": "req_xyz789",
    "took_ms": 45
  }
}
```

### Error Responses

| Status | Code | Description | Resolution |
|--------|------|-------------|------------|
| 400 | INVALID_QUERY | Query too short/long | Provide 2-100 char query |
| 400 | INVALID_PARAMETER | Parameter validation failed | Check parameter constraints |
| 401 | UNAUTHORIZED | Missing/invalid token | Refresh authentication |
| 429 | RATE_LIMITED | Too many requests | Wait and retry with backoff |
| 500 | INTERNAL_ERROR | Server error | Retry or contact support |

**Error Response Format:**
```json
{
  "error": {
    "code": "INVALID_QUERY",
    "message": "Search query must be between 2 and 100 characters",
    "details": {"provided_length": 1, "min_length": 2}
  },
  "meta": {"request_id": "req_xyz789"}
}
```

### Rate Limits
- Authenticated: 100 requests/minute
- Headers: `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`

### Versioning
- Current: v2
- Deprecation: v1 sunset 2025-06-01
- Breaking changes require major version bump
```

**API contract must include:**
- Endpoint URL and method
- Authentication requirements
- All parameters with types and constraints
- Complete response schemas
- All error codes with resolution steps

Reference: [Microsoft API Guidelines](https://github.com/microsoft/api-guidelines)
