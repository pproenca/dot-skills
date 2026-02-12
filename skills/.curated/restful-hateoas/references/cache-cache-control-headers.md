---
title: Set Explicit Cache-Control Headers for API Responses
impact: MEDIUM
impactDescription: enables CDN and proxy caching for public resources, controls client-side cache lifetimes
tags: cache, cache-control, cdn, headers
---

## Set Explicit Cache-Control Headers for API Responses

Without explicit `Cache-Control` headers, caching behavior is undefined -- browsers, CDNs, and proxies apply their own heuristics, which may cache private data publicly or never cache publicly shareable data. Setting `private, max-age=60` for user-specific responses prevents proxy caching of personal data. Setting `public, max-age=3600` for shared resources (product catalogs, categories) offloads traffic to CDN edge nodes.

**Incorrect (no Cache-Control headers -- caching behavior left to browser defaults):**

```ruby
# app/controllers/api/v1/orders_controller.rb
class Api::V1::OrdersController < ApplicationController
  def show
    order = current_user.orders.find(params[:id])

    render json: OrderSerializer.new(order).as_json
    # No Cache-Control header -- CDN might cache this user's order for everyone
  end

  def categories
    categories = Category.active.ordered

    render json: categories.map { |c| CategorySerializer.new(c).as_json }
    # No Cache-Control header -- CDN cannot cache this even though it's public
  end
end
```

**Correct (explicit Cache-Control per endpoint based on data sensitivity):**

```ruby
# app/controllers/api/v1/orders_controller.rb
class Api::V1::OrdersController < ApplicationController
  def show
    order = current_user.orders.find(params[:id])

    if stale?(etag: order)
      expires_in 1.minute, public: false  # private, max-age=60 — user-specific
      render json: OrderSerializer.new(order).as_json
    end
  end
end

# app/controllers/api/v1/categories_controller.rb
class Api::V1::CategoriesController < ApplicationController
  def index
    categories = Category.active.ordered

    expires_in 1.hour, public: true  # public, max-age=3600 — CDN-cacheable
    render json: categories.map { |c| CategorySerializer.new(c).as_json }
  end
end

# app/controllers/api/v1/shipments_controller.rb
class Api::V1::ShipmentsController < ApplicationController
  def show
    shipment = Shipment.find(params[:id])

    response.headers["Cache-Control"] = "no-store"  # real-time tracking, never cache
    render json: ShipmentSerializer.new(shipment).as_json
  end
end
```

**Benefits:**
- Public resources served from CDN edge nodes reduce origin load and improve latency globally
- Private data is explicitly excluded from shared caches, preventing cross-user data leaks
- `no-store` for real-time resources ensures clients always get fresh data

**When NOT to use:** Do not set `public` on any response that varies by `Authorization` header without also setting a `Vary: Authorization` header. See `restful-hateoas:cache-vary-header`.

**Reference:** RFC 9111 (HTTP Caching). See also `restful-hateoas:cache-etag-conditional-get` for combining Cache-Control with conditional requests.
