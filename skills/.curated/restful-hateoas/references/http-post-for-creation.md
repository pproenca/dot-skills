---
title: Return 201 Created with Location Header from POST
impact: CRITICAL
impactDescription: enables client discovery of newly created resource URIs
tags: http, post, create, location-header, status-codes
---

## Return 201 Created with Location Header from POST

POST creates a new subordinate resource and the server assigns its URI. Returning 200 with just the body forces clients to guess or parse the new resource's URL. The Location header (RFC 7231 Section 7.1.2) is the standard mechanism for the server to tell the client where the new resource lives, enabling hypermedia-driven navigation.

**Incorrect (returns 200, no Location header):**

```ruby
class OrdersController < ApplicationController
  def create
    order = current_user.orders.build(order_params)

    if order.save
      render json: OrderSerializer.new(order), status: :ok  # 200 — client has no URI for the new resource
    else
      render json: { errors: order.errors }, status: :unprocessable_entity
    end
  end
end
```

**Correct (returns 201 with Location header):**

```ruby
class OrdersController < ApplicationController
  def create
    order = current_user.orders.build(order_params)

    if order.save
      render json: OrderSerializer.new(order),
             status: :created,                                  # 201 — resource was created
             location: api_v1_order_url(order)                  # Location header points to the new resource
    else
      render json: { errors: order.errors }, status: :unprocessable_entity
    end
  end
end
```

```http
HTTP/1.1 201 Created
Location: https://api.example.com/api/v1/orders/ord_9f2a
Content-Type: application/json

{
  "id": "ord_9f2a",
  "total": "129.99",
  "status": "pending",
  "_links": {
    "self": { "href": "/api/v1/orders/ord_9f2a" },
    "customer": { "href": "/api/v1/customers/cust_7" }
  }
}
```

**Benefits:**
- Clients follow the Location header to GET the new resource -- no URL construction needed
- Intermediaries and monitoring tools detect creation events via 201 status
- The server assigns the URI, not the client -- POST to a collection, server responds with Location

**When NOT to use:** POST for non-creation actions (triggering exports, sending emails) should return 200 or 202 instead. See `restful-hateoas:status-202-for-async` for long-running operations.

**Reference:** RFC 7231 Section 6.3.2 (201 Created). See also `restful-hateoas:status-201-with-location` for the status code and header mechanics.
