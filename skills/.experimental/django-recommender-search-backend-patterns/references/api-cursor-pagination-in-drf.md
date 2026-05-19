---
title: Return Cursor-Based Pagination from DRF
impact: MEDIUM
impactDescription: prevents page-skip bugs as data shifts
tags: api, drf, pagination, cursor, response-shape
---

## Return Cursor-Based Pagination from DRF

DRF's default `PageNumberPagination` (`?page=2&size=20`) returns the same items shifted around as data changes between requests — the user sees duplicates and missing items on infinite scroll. `CursorPagination` solves this by encoding the position with the last item's sort key, returning an opaque cursor the client passes back.

For recommendation feeds, search results, and any list that changes between page fetches (which is most lists), use cursor pagination. The response shape is stable, future-proof, and aligns with how the OpenSearch backend already paginates (`search_after`, see [[search-use-search-after-not-from]]).

**Incorrect (page-number pagination with shifting data):**

```python
# views.py
from rest_framework.pagination import PageNumberPagination

class StandardPageNumberPagination(PageNumberPagination):
    page_size = 20
    max_page_size = 100

class RecommendationsList(ListAPIView):
    pagination_class = StandardPageNumberPagination
# Response:
# {
#   "count": 1037,
#   "next": "https://api.example.com/recommendations?page=3",
#   "previous": "...page=1",
#   "results": [...]
# }
# Problem: new items inserted between page 1 and page 2 → user sees duplicates
```

**Correct (cursor pagination — stable across writes):**

```python
from rest_framework.pagination import CursorPagination

class RecommendationsCursorPagination(CursorPagination):
    page_size = 20
    max_page_size = 100
    ordering = "-created_at"     # tiebreaker — see [[search-stable-tiebreaker-sort]]
    cursor_query_param = "cursor"

class RecommendationsList(ListAPIView):
    pagination_class = RecommendationsCursorPagination
    queryset = Recommendation.objects.all()
# Response:
# {
#   "next": "https://api.example.com/recommendations?cursor=cD0yMDI2LTA1LTE5",
#   "previous": null,
#   "results": [...]
# }
# Opaque cursor; stable across inserts; no skipping/duplicating
```

**For OpenSearch-backed endpoints (search_after under the hood):**

DRF's `CursorPagination` is for queryset-based endpoints. For OpenSearch-backed endpoints, build a custom paginator that wraps `search_after`:

```python
import base64
import json
from rest_framework.pagination import BasePagination
from rest_framework.response import Response

class OpenSearchCursorPagination(BasePagination):
    """Opaque cursor pagination backed by OpenSearch search_after."""
    page_size = 20
    max_page_size = 100

    def paginate(self, query_fn, request, view=None):
        """Call this from your view; query_fn accepts (cursor, size) → (items, next_cursor_sort_values)."""
        size = self._get_size(request)
        cursor = self._decode(request.query_params.get("cursor"))
        items, next_sort = query_fn(cursor=cursor, size=size)
        self._next_cursor = self._encode(next_sort) if next_sort else None
        self._items = items
        self._request = request
        return items

    def get_paginated_response(self, data):
        next_url = self._build_next_url() if self._next_cursor else None
        return Response({
            "items": data,
            "next": next_url,
            "page_size": len(data),
        })

    def _get_size(self, request) -> int:
        size = request.query_params.get("size")
        try:
            size = int(size) if size else self.page_size
        except ValueError:
            size = self.page_size
        return min(max(1, size), self.max_page_size)

    def _encode(self, sort_values) -> str:
        return base64.urlsafe_b64encode(
            json.dumps(sort_values).encode()
        ).decode().rstrip("=")

    def _decode(self, cursor: str | None):
        if not cursor:
            return None
        try:
            padded = cursor + "=" * (-len(cursor) % 4)
            return json.loads(base64.urlsafe_b64decode(padded))
        except (ValueError, json.JSONDecodeError):
            return None  # malformed cursor → start over

    def _build_next_url(self) -> str:
        from urllib.parse import urlencode, urlparse, urlunparse, parse_qs
        parts = urlparse(self._request.build_absolute_uri())
        qs = parse_qs(parts.query)
        qs["cursor"] = [self._next_cursor]
        return urlunparse(parts._replace(query=urlencode(qs, doseq=True)))
```

**Usage in the view:**

```python
class SearchView(APIView):
    pagination_class = OpenSearchCursorPagination

    def get(self, request):
        paginator = self.pagination_class()
        items = paginator.paginate(
            query_fn=lambda cursor, size: search_opensearch(
                query=request.query_params["q"], cursor=cursor, size=size,
            ),
            request=request, view=self,
        )
        return paginator.get_paginated_response([self._serialize(i) for i in items])
```

**Response shape consistency across endpoints:**

Use the same envelope across the API so clients don't branch:

```python
# Standard response shape for all paginated endpoints
{
    "items": [...],
    "next": "...?cursor=abc",   # or null on last page
    "page_size": 20,
}

# For homepage feeds with multiple sections
{
    "sections": [
        {"name": "for_you", "items": [...], "next": "...?cursor=..."},
        {"name": "trending", "items": [...], "next": "...?cursor=..."},
    ]
}
```

**Don't expose total counts on cursor-paginated endpoints:**

Counting all matches is expensive (OpenSearch needs to count every shard; SQL needs a full count query). Cursor pagination doesn't need totals — the existence of `next` tells the client there's more. Drop the `count` field from response.

If users *really* need a total ("Showing X of Y results"), make it a separate endpoint that's cached aggressively or returns an approximate count (`total_approximate: true`).

**Encode cursors opaquely:**

```python
# ❌ Exposing sort fields lets clients fabricate cursors and skip security checks
?cursor=created_at:2026-05-19,id:abc123

# ✅ Opaque base64-encoded JSON — clients can only echo it back
?cursor=eyJzb3J0IjpbIjIwMjYtMDUtMTkiLCJhYmMxMjMiXX0
```

**Sign cursors if they carry sensitive sort values:**

```python
import hmac, hashlib

def sign_cursor(sort_values, secret: bytes) -> str:
    payload = json.dumps(sort_values).encode()
    sig = hmac.new(secret, payload, hashlib.sha256).digest()[:8]
    return base64.urlsafe_b64encode(payload + b"|" + sig).decode().rstrip("=")
```

This prevents clients from constructing arbitrary cursors to scan data they shouldn't see.

**Symptom of bad pagination:**
- "User reports seeing the same item on consecutive pages" — page-number pagination + writes
- "Search page 100 returns 500" — `from + size > 10000`
- "Total count query takes 5 seconds" — exposing `count` on every page

Reference: [DRF — Pagination](https://www.django-rest-framework.org/api-guide/pagination/) | [Use The Index, Luke — Pagination](https://use-the-index-luke.com/sql/partial-results/fetch-next-page)
