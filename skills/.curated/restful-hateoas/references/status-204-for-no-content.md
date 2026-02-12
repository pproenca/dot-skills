---
title: Return 204 No Content for Empty Responses
impact: HIGH
impactDescription: reduces response payload and follows REST semantics for destructive operations
tags: status, 204, no-content, delete, put, patch
---

## Return 204 No Content for Empty Responses

Successful DELETE operations and PUT/PATCH updates that don't need to return a body should respond with 204 No Content. Wrapping an empty success in 200 with `{ success: true }` adds no information -- the status code already communicates success. Returning the deleted resource is misleading because the resource no longer exists.

**Incorrect (returns 200 with artificial wrapper or returns deleted resource):**

```ruby
class Api::V1::OrdersController < ApplicationController
  def destroy
    order = current_user.orders.find(params[:id])
    order.destroy!
    render json: { success: true, message: "Order deleted" }, status: :ok  # useless wrapper
  end

  def update
    order = current_user.orders.find(params[:id])
    order.update!(order_params)
    render json: { success: true, data: OrderSerializer.new(order) }, status: :ok  # wrapper around actual data
  end
end
```

**Correct (204 for DELETE, 200 with body for PUT/PATCH when client needs it):**

```ruby
class Api::V1::OrdersController < ApplicationController
  def destroy
    order = current_user.orders.find(params[:id])
    order.destroy!
    head :no_content  # 204 — resource removed, no body needed
  end

  def update
    order = current_user.orders.find(params[:id])
    order.update!(order_params)
    render json: OrderSerializer.new(order), status: :ok  # 200 — return updated resource with fresh _links
  end
end
```

```http
DELETE /api/v1/orders/ord_abc HTTP/1.1
Authorization: Bearer <token>

HTTP/1.1 204 No Content
```

```http
PUT /api/v1/orders/ord_abc HTTP/1.1
Content-Type: application/json
Authorization: Bearer <token>

{ "total": "149.99" }

HTTP/1.1 200 OK
Content-Type: application/json

{
  "id": "ord_abc",
  "total": "149.99",
  "status": "pending",
  "_links": {
    "self": { "href": "/api/v1/orders/ord_abc" },
    "cancel": { "href": "/api/v1/orders/ord_abc/cancellation", "method": "POST" }
  }
}
```

**Benefits:**
- 204 carries zero body bytes -- faster responses and lower bandwidth
- Clients and intermediaries interpret 204 unambiguously as "success, nothing to parse"
- Returning the updated resource on PUT/PATCH gives clients fresh `_links` reflecting any state changes

**When NOT to use:** If your API contract requires returning the deleted resource for undo functionality, use 200 with the resource body and a `restore` link instead of 204.

**Reference:** RFC 7231 Section 6.3.5 (204 No Content). See also `restful-hateoas:http-delete-is-idempotent`.
