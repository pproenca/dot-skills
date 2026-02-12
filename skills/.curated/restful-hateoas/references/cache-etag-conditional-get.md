---
title: Use ETags with stale? for Conditional GET Requests
impact: MEDIUM
impactDescription: skips serialization and body transfer on 304, reduces response size to zero bytes
tags: cache, etag, conditional-get, stale
---

## Use ETags with stale? for Conditional GET Requests

Without conditional GET, the server serializes and transmits the full response body on every request even when the client already has an identical copy. Rails' `stale?` compares the resource's ETag against the client's `If-None-Match` header and returns 304 Not Modified when they match -- skipping serialization, JSON generation, and body transmission entirely. This is HTTP's built-in caching mechanism, and it costs one line of code.

**Incorrect (always serializing and returning 200 even when content is unchanged):**

```ruby
# app/controllers/api/v1/orders_controller.rb
class Api::V1::OrdersController < ApplicationController
  def show
    order = current_user.orders.find(params[:id])

    render json: OrderSerializer.new(order).as_json  # serializes every time, even if nothing changed
  end
end
```

**Correct (stale? returns 304 automatically, skipping serialization on cache hit):**

```ruby
# app/controllers/api/v1/orders_controller.rb
class Api::V1::OrdersController < ApplicationController
  def show
    order = current_user.orders.includes(:line_items).find(params[:id])

    if stale?(etag: order)  # compares ETag with If-None-Match, returns 304 on match
      render json: OrderSerializer.new(order).as_json
    end
  end

  def index
    orders = current_user.orders.order(updated_at: :desc).limit(25)

    if stale?(etag: orders)  # works with collections too
      render json: orders.map { |o| OrderSerializer.new(o).as_json }
    end
  end
end
```

```http
# First request -- full response with ETag
GET /api/v1/orders/42 HTTP/1.1
Authorization: Bearer <token>

HTTP/1.1 200 OK
ETag: "a1b2c3d4"
Content-Type: application/json
# ... full body ...

# Second request -- client sends ETag back
GET /api/v1/orders/42 HTTP/1.1
If-None-Match: "a1b2c3d4"

HTTP/1.1 304 Not Modified
# no body, no serialization cost
```

**Benefits:**
- Zero serialization cost on cache hits -- the response body is never generated
- Works with Rails' built-in `stale?` out of the box, no external caching layer needed
- Clients receive the ETag automatically in the response headers

**Reference:** RFC 9110 Section 13.1 (Conditional Requests). See also `rails-dev:cache-conditional-get` for deeper Rails integration, and `restful-hateoas:cache-last-modified` for time-based conditional requests.
