---
title: Return 406 Not Acceptable for Unsupported Media Types
impact: HIGH
impactDescription: prevents silent format mismatches, helps clients discover supported representations
tags: media, 406, not-acceptable, error-handling, content-negotiation
---

## Return 406 Not Acceptable for Unsupported Media Types

When a client sends an Accept header the server cannot satisfy, the correct response is 406 Not Acceptable. Silently falling back to JSON hides the mismatch -- the client thinks it got the format it asked for, parses it wrong, and breaks in subtle ways. A clear 406 with a list of supported types lets clients self-correct immediately.

**Incorrect (unknown Accept header silently defaults to JSON):**

```ruby
# app/controllers/api/orders_controller.rb
class Api::OrdersController < ApplicationController
  def show
    order = Order.find(params[:id])
    render json: OrderSerializer.new(order).as_json  # always JSON, even if client asked for XML
  end
end
```

```http
GET /api/orders/42 HTTP/1.1
Accept: application/xml

HTTP/1.1 200 OK
Content-Type: application/json

{"id":42,"total":99.95}
```

**Correct (return 406 with supported media types):**

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::API
  rescue_from ActionController::UnknownFormat, with: :not_acceptable

  private

  def not_acceptable
    render json: {
      error: "Not Acceptable",
      message: "The requested media type is not supported.",
      supported_media_types: [
        "application/json",
        "application/hal+json",
        "application/vnd.api+json"
      ]
    }, status: :not_acceptable, content_type: "application/json"
  end
end

# app/controllers/api/orders_controller.rb
class Api::OrdersController < ApplicationController
  def show
    order = Order.find(params[:id])

    respond_to do |format|
      format.json { render json: OrderSerializer.new(order).as_json }
      format.hal  { render json: HalOrderSerializer.new(order).as_json, content_type: "application/hal+json" }
      # Any other Accept value raises ActionController::UnknownFormat → 406
    end
  end
end
```

```http
GET /api/orders/42 HTTP/1.1
Accept: application/xml

HTTP/1.1 406 Not Acceptable
Content-Type: application/json

{
  "error": "Not Acceptable",
  "message": "The requested media type is not supported.",
  "supported_media_types": [
    "application/json",
    "application/hal+json",
    "application/vnd.api+json"
  ]
}
```

**Benefits:**
- Clients discover exactly which media types are available without consulting docs
- No silent mismatches where a client parses the wrong format and fails downstream
- API gateways and monitoring dashboards can track 406s to spot misconfigured clients

**Reference:** RFC 7231 Section 6.5.6 (406 Not Acceptable). See also `restful-hateoas:media-accept-header-negotiation` for registering the MIME types that `respond_to` matches against.
