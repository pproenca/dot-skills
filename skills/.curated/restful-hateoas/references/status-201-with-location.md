---
title: Return 201 Created with Location Header
impact: HIGH
impactDescription: enables client redirection to new resource, follows HTTP creation semantics
tags: status, 201, location-header, create, hateoas
---

## Return 201 Created with Location Header

The 201 status code combined with the Location header is the server's mechanism for telling clients where a newly created resource lives. The Location header carries the canonical URI; the body carries the representation with `_links`. Returning 200 after creation hides the creation event from intermediaries and leaves clients without a standard way to discover the new resource's URI.

**Incorrect (returns 200 with no Location header):**

```ruby
class Api::V1::OrdersController < ApplicationController
  def create
    order = current_user.orders.build(order_params)

    if order.save
      render json: OrderSerializer.new(order), status: :ok  # 200 — client cannot discover the new resource URI
    else
      render json: { errors: order.errors }, status: :unprocessable_entity
    end
  end
end
```

```http
HTTP/1.1 200 OK
Content-Type: application/json

{
  "id": "ord_abc",
  "total": "129.99",
  "status": "pending"
}
```

**Correct (returns 201 Created with Location header and _links):**

```ruby
class Api::V1::OrdersController < ApplicationController
  def create
    order = current_user.orders.build(order_params)

    if order.save
      render json: OrderSerializer.new(order),
             status: :created,                          # 201 — resource was created
             location: api_v1_order_url(order)           # Location header points to the new resource
    else
      render json: { errors: order.errors }, status: :unprocessable_entity
    end
  end
end
```

```http
HTTP/1.1 201 Created
Location: https://api.example.com/api/v1/orders/ord_abc
Content-Type: application/json

{
  "id": "ord_abc",
  "total": "129.99",
  "status": "pending",
  "_links": {
    "self": { "href": "/api/v1/orders/ord_abc" },
    "customer": { "href": "/api/v1/customers/cust_7" },
    "cancel": { "href": "/api/v1/orders/ord_abc/cancellation", "method": "POST" }
  }
}
```

**Benefits:**
- Clients follow the Location header to GET the new resource -- no URL construction needed
- Intermediaries and monitoring tools detect creation events via 201 status
- Combined with `_links` in the body, the client gets both the canonical URI and available next actions in one response

**When NOT to use:** Batch creation endpoints that create multiple resources may return 200 with a collection body instead, since Location can only hold a single URI.

**Reference:** RFC 7231 Section 6.3.2 (201 Created). See also `restful-hateoas:http-post-for-creation`, `restful-hateoas:link-self-link-every-resource`.
