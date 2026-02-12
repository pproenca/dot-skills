---
title: Use Idempotency Keys for Safe POST Retries
impact: CRITICAL
impactDescription: prevents duplicate resource creation on network retries, essential for payment and financial operations
tags: http, idempotency, post, retry, header
---

## Use Idempotency Keys for Safe POST Retries

POST is not idempotent by design -- retrying a POST can create duplicate resources. In payment, order, and transfer scenarios, duplicates mean real money lost. An `Idempotency-Key` header (proposed standard) lets clients attach a unique key to POST requests. If the server sees the same key twice, it returns the original response instead of creating a duplicate.

**Incorrect (retrying POST creates duplicate orders):**

```ruby
class Api::OrdersController < ApplicationController
  def create
    order = current_user.orders.build(order_params)

    if order.save
      render json: OrderSerializer.new(order), status: :created, location: api_order_url(order)
    else
      render json: { errors: order.errors }, status: :unprocessable_entity
    end
    # Client timeout → retry → second order created with same items
  end
end
```

**Correct (idempotency key prevents duplicate creation on retry):**

```ruby
# app/controllers/concerns/idempotent.rb
module Idempotent
  extend ActiveSupport::Concern

  private

  def ensure_idempotency_key!
    key = request.headers["Idempotency-Key"]
    return render_missing_key unless key

    cached = IdempotencyCache.find_by(key: key, user: current_user)
    if cached
      response.headers["Idempotency-Key"] = key
      render json: cached.response_body, status: cached.response_status
      return false
    end

    true
  end

  def store_idempotency_response(key, status:, body:)
    IdempotencyCache.create!(
      key: key, user: current_user,
      response_status: status, response_body: body,
      expires_at: 24.hours.from_now
    )
  end

  def render_missing_key
    render json: {
      type: "https://api.example.com/problems/missing-idempotency-key",
      title: "Missing Idempotency-Key",
      status: 400,
      detail: "POST requests require an Idempotency-Key header for safe retries"
    }, status: :bad_request, content_type: "application/problem+json"
  end
end

# app/controllers/api/orders_controller.rb
class Api::OrdersController < ApplicationController
  include Idempotent

  def create
    return unless ensure_idempotency_key!

    key = request.headers["Idempotency-Key"]
    order = current_user.orders.build(order_params)

    if order.save
      body = OrderSerializer.new(order).as_json
      store_idempotency_response(key, status: 201, body: body)
      response.headers["Idempotency-Key"] = key
      render json: body, status: :created, location: api_order_url(order)
    else
      render json: { errors: order.errors }, status: :unprocessable_entity
    end
  end
end
```

```http
POST /api/orders HTTP/1.1
Content-Type: application/json
Idempotency-Key: ord_req_a1b2c3d4
Authorization: Bearer <token>

{ "items": [{ "product_id": "prod_42", "quantity": 2 }] }

HTTP/1.1 201 Created
Idempotency-Key: ord_req_a1b2c3d4
Location: https://api.example.com/api/orders/ord_9f2a

# Retry with same key → returns cached 201, no duplicate created
```

**Benefits:**
- Network retries never create duplicate resources -- the same key always returns the same response
- Client libraries can safely retry on timeout without application-level deduplication
- The 24-hour expiry prevents unbounded cache growth while covering typical retry windows

**When NOT to use:** GET, PUT, and DELETE are already idempotent by HTTP semantics. Only POST needs idempotency keys. For PATCH with merge semantics, idempotency keys are optional but useful for non-idempotent patches.

**Reference:** IETF draft-ietf-httpapi-idempotency-key-header (Idempotency-Key HTTP Header Field). See also `restful-hateoas:http-post-for-creation` for POST creation semantics.
