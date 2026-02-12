---
title: Include Vary Header When Responses Differ by Request Headers
impact: MEDIUM
impactDescription: prevents cache poisoning across different content types, users, and locales
tags: cache, vary, content-negotiation, caching
---

## Include Vary Header When Responses Differ by Request Headers

When the same URL produces different responses based on request headers (e.g., `Accept` for content negotiation, `Authorization` for user-specific data, `Accept-Language` for locale), caches must know which headers affect the response. Without a `Vary` header, a CDN might cache the HAL+JSON response and serve it to a client requesting JSON:API, or cache one user's order list and serve it to another. The `Vary` header tells caches to store separate entries per unique combination of the listed headers.

**Incorrect (same URL serves different formats without Vary -- cache serves wrong representation):**

```ruby
# app/controllers/api/v1/orders_controller.rb
class Api::V1::OrdersController < ApplicationController
  def show
    order = current_user.orders.find(params[:id])

    respond_to do |format|
      format.json { render json: OrderSerializer.new(order).as_json }
      format.hal  { render json: HalOrderSerializer.new(order).as_json, content_type: "application/hal+json" }
    end
    # No Vary header -- CDN caches the first format and serves it to all clients
  end
end
```

**Correct (Vary header ensures caches store separate entries per Accept and Authorization):**

```ruby
# app/controllers/concerns/vary_headers.rb
module VaryHeaders
  extend ActiveSupport::Concern

  included do
    before_action :set_vary_headers
  end

  private

  def set_vary_headers
    response.headers["Vary"] = "Accept, Authorization"
  end
end

# app/controllers/api/v1/orders_controller.rb
class Api::V1::OrdersController < ApplicationController
  include VaryHeaders

  def show
    order = current_user.orders.find(params[:id])

    respond_to do |format|
      format.json { render json: OrderSerializer.new(order).as_json }
      format.hal  { render json: HalOrderSerializer.new(order).as_json, content_type: "application/hal+json" }
    end
    # Vary: Accept, Authorization -- CDN stores separate entries per format and user
  end
end
```

```http
GET /api/v1/orders/42 HTTP/1.1
Accept: application/hal+json
Authorization: Bearer user_a_token

HTTP/1.1 200 OK
Content-Type: application/hal+json
Vary: Accept, Authorization
Cache-Control: private, max-age=60
```

**Benefits:**
- CDNs and proxies store and serve the correct representation per client request
- Prevents one user's cached response from leaking to another user
- Works with all standard HTTP caches -- no custom cache key configuration needed

**When NOT to use:** If your API serves only one format and does not vary by any request header, omit `Vary` to maximize cache hit rates. Adding unnecessary `Vary` headers fragments the cache.

**Reference:** RFC 7231 Section 7.1.4 (Vary). See also `restful-hateoas:media-accept-header-negotiation` for content negotiation and `restful-hateoas:cache-cache-control-headers` for Cache-Control directives.
