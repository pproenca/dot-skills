---
title: Include Recovery Links in Error Responses
impact: MEDIUM
impactDescription: enables client-driven error recovery through hypermedia instead of hardcoded fallback logic
tags: err, links, hateoas, recovery
---

## Include Recovery Links in Error Responses

An error response without links is a dead end -- the client knows something went wrong but has no machine-readable way to recover. Adding `_links` to error bodies turns errors into navigable resources. A 409 Conflict should link to the conflicting resource's current state. A 401 Unauthorized should link to the authentication endpoint. A 403 Forbidden can link to a permissions request flow.

**Incorrect (error with no links -- client must hardcode recovery paths):**

```ruby
# app/controllers/api/v1/orders_controller.rb
class Api::V1::OrdersController < ApplicationController
  def update
    order = current_user.orders.find(params[:id])

    unless order.editable?
      render json: {
        error: "conflict",
        message: "Order #{order.id} has already been shipped"
      }, status: :conflict  # client gets a message but no way to discover next steps
      return
    end

    order.update!(order_params)
    render json: OrderSerializer.new(order).as_json
  end
end
```

**Correct (error response includes recovery links):**

```ruby
# app/controllers/api/v1/orders_controller.rb
class Api::V1::OrdersController < ApplicationController
  def update
    order = current_user.orders.find(params[:id])

    unless order.editable?
      render json: {
        error: "conflict",
        message: "Order #{order.id} has already been shipped",
        _links: {
          current_state: { href: "/api/v1/orders/#{order.id}", title: "View current order" },
          shipment: { href: "/api/v1/orders/#{order.id}/shipment", title: "Track shipment" },
          support: { href: "/api/v1/support/tickets", title: "Request order change" }
        }
      }, status: :conflict
      return
    end

    order.update!(order_params)
    render json: OrderSerializer.new(order).as_json
  end
end

# app/controllers/concerns/authentication.rb -- 401 with auth link
module Authentication
  def render_unauthorized
    render json: {
      error: "unauthorized",
      message: "Authentication required",
      _links: {
        authenticate: { href: "/api/v1/oauth/authorize", title: "Begin authentication" }
      }
    }, status: :unauthorized
  end
end
```

**Benefits:**
- Clients follow links to recover from errors without hardcoding fallback URIs
- Server-side changes to recovery flows (new support ticket endpoint) propagate automatically through links
- Error responses become first-class hypermedia resources, consistent with the rest of the API

**Reference:** See also `restful-hateoas:status-409-for-conflicts` for when to use 409 vs 422, and `restful-hateoas:link-action-affordances` for embedding available actions.
