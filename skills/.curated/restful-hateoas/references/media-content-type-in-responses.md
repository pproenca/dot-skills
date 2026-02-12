---
title: Set the Correct Content-Type in Every Response
impact: HIGH
impactDescription: enables clients to parse responses correctly, prevents silent media type mismatch
tags: media, content-type, response-headers, hal, json
---

## Set the Correct Content-Type in Every Response

The Content-Type header tells the client how to parse the response body. If you serve HAL-formatted JSON but label it `application/json`, clients that understand HAL will not activate their link-following logic, and generic JSON clients will stumble over `_links` and `_embedded` keys they did not expect. The Content-Type must match the actual media type being served -- anything else is a lie that breaks client automation.

**Incorrect (HAL body with wrong Content-Type -- client cannot distinguish format):**

```ruby
# app/controllers/api/orders_controller.rb
class Api::OrdersController < ApplicationController
  def show
    order = Order.find(params[:id])
    payload = {
      id: order.id,
      total: order.total.to_f,
      _links: { self: { href: "/api/orders/#{order.id}" } }
    }
    render json: payload  # Content-Type defaults to application/json -- wrong for HAL
  end
end
```

```http
HTTP/1.1 200 OK
Content-Type: application/json

{"id":42,"total":99.95,"_links":{"self":{"href":"/api/orders/42"}}}
```

**Correct (Content-Type matches the actual media type):**

```ruby
# app/controllers/api/orders_controller.rb
class Api::OrdersController < ApplicationController
  def show
    order = Order.find(params[:id])
    payload = {
      id: order.id,
      total: order.total.to_f,
      _links: { self: { href: "/api/orders/#{order.id}" } }
    }
    render json: payload, content_type: "application/hal+json"  # matches the HAL structure
  end
end
```

```http
HTTP/1.1 200 OK
Content-Type: application/hal+json

{"id":42,"total":99.95,"_links":{"self":{"href":"/api/orders/42"}}}
```

**Alternative:**

```ruby
# app/controllers/concerns/hal_response.rb — extract into a concern for consistency
module HalResponse
  extend ActiveSupport::Concern

  private

  def render_hal(payload, status: :ok)
    render json: payload, content_type: "application/hal+json", status: status
  end
end
```

**Benefits:**
- HAL-aware clients (e.g., HAL Browser, Spring HATEOAS) activate link parsing automatically
- Content-Type-based routing in API gateways and proxies works correctly
- Clients can reliably switch parsing strategy based on the Content-Type header

**Reference:** RFC 9110 Section 8.3 (Content-Type). See also `restful-hateoas:media-accept-header-negotiation` for negotiating which format to serve.
