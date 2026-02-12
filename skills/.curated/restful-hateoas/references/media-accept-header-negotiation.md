---
title: Respect the Accept Header for Content Negotiation
impact: HIGH
impactDescription: enables multiple client types (web, mobile, third-party) from a single API without separate endpoints
tags: media, accept, content-negotiation, mime-type, hal, json-api
---

## Respect the Accept Header for Content Negotiation

The Accept header is the HTTP mechanism for clients to declare which representation they want. By registering custom MIME types and using `respond_to`, a single controller action can serve plain JSON, HAL+JSON, and JSON:API -- all from the same URI. Without this, you end up with parallel endpoints (`/api/orders.json`, `/api/orders.hal`) or, worse, every client gets the same format whether they can parse it or not.

**Incorrect (ignoring Accept header -- all clients get the same JSON regardless):**

```ruby
# app/controllers/api/orders_controller.rb
class Api::OrdersController < ApplicationController
  def show
    order = Order.find(params[:id])
    render json: OrderSerializer.new(order).as_json  # always plain JSON, Accept header ignored
  end
end
```

**Correct (register MIME types and negotiate based on Accept header):**

```ruby
# config/initializers/mime_types.rb
Mime::Type.register "application/hal+json", :hal
Mime::Type.register "application/vnd.api+json", :jsonapi

# app/controllers/api/orders_controller.rb
class Api::OrdersController < ApplicationController
  def show
    order = Order.find(params[:id])

    respond_to do |format|
      format.json   { render json: OrderSerializer.new(order).as_json }
      format.hal    { render json: HalOrderSerializer.new(order).as_json, content_type: "application/hal+json" }
      format.jsonapi { render json: JsonApiOrderSerializer.new(order).as_json, content_type: "application/vnd.api+json" }
    end
  end
end
```

```http
# Client requesting HAL
GET /api/orders/42 HTTP/1.1
Accept: application/hal+json

HTTP/1.1 200 OK
Content-Type: application/hal+json
```

**Benefits:**
- One URI, multiple representations -- no endpoint duplication
- Adding a new format (e.g., JSON:API) requires zero route changes
- Clients opt into richer hypermedia formats at their own pace

**When NOT to use:**
- Internal microservices where every consumer is under your control and a single format suffices

**Reference:** RFC 7231 Section 5.3.2 (Accept header). See also `restful-hateoas:media-content-type-in-responses` for setting the correct Content-Type on the way out.
