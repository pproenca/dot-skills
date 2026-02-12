---
title: Return 409 Conflict for State Conflicts
impact: HIGH
impactDescription: distinguishes validation errors from state conflicts, enables client recovery
tags: status, 409, conflict, state-transition, error-handling
---

## Return 409 Conflict for State Conflicts

When a request conflicts with the current state of a resource -- such as cancelling an already-shipped order or approving an already-rejected application -- return 409 Conflict instead of 422 or 400. A 422 means the payload is syntactically valid but semantically wrong (validation error). A 409 means the request would have been valid but the resource has already moved to a state that makes the operation impossible. Including `_links` in the 409 body lets the client discover what actions are still available.

**Incorrect (returns 422 for a state conflict):**

```ruby
class Api::V1::Orders::CancellationsController < ApplicationController
  def create
    order = current_user.orders.find(params[:order_id])

    unless order.cancellable?
      render json: { errors: ["Order cannot be cancelled"] }, status: :unprocessable_entity  # 422 — misleading
      return
    end

    order.cancel!
    head :no_content
  end
end
```

**Correct (returns 409 with conflict explanation and recovery links):**

```ruby
class Api::V1::Orders::CancellationsController < ApplicationController
  def create
    order = current_user.orders.find(params[:order_id])

    unless order.cancellable?
      render json: {
        error: "conflict",
        message: "Order #{order.id} is #{order.status} and cannot be cancelled",
        _links: {
          self: { href: "/api/v1/orders/#{order.id}" },                     # GET current state
          shipment: { href: "/api/v1/orders/#{order.id}/shipment" }          # the state that caused the conflict
        }
      }, status: :conflict  # 409 — state conflict, not a validation error
      return
    end

    order.cancel!
    head :no_content
  end
end
```

```http
POST /api/v1/orders/ord_abc/cancellation HTTP/1.1
Authorization: Bearer <token>

HTTP/1.1 409 Conflict
Content-Type: application/json

{
  "error": "conflict",
  "message": "Order ord_abc is shipped and cannot be cancelled",
  "_links": {
    "self": { "href": "/api/v1/orders/ord_abc" },
    "shipment": { "href": "/api/v1/orders/ord_abc/shipment" }
  }
}
```

**Benefits:**
- Clients distinguish between "fix your input" (422) and "resource state changed" (409)
- Recovery links in the 409 body guide the client to the current resource state
- Monitoring dashboards can alert on 409 spikes as an indicator of race conditions or stale UI state

**When NOT to use:** Use 422 for payload validation errors (missing required fields, invalid formats). Use 412 Precondition Failed when the conflict is detected via conditional headers (If-Match / If-Unmodified-Since).

**Reference:** RFC 9110 Section 15.5.10 (409 Conflict). See also `restful-hateoas:link-action-affordances` for exposing allowed state transitions.
