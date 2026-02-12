---
title: Set Last-Modified Header for Time-Based Cache Validation
impact: MEDIUM
impactDescription: enables time-based cache validation without comparing full bodies or computing hashes
tags: cache, last-modified, fresh-when, conditional
---

## Set Last-Modified Header for Time-Based Cache Validation

ETags work by comparing opaque tokens, but sometimes time-based validation is simpler and sufficient. Setting `Last-Modified` via `fresh_when` lets clients send `If-Modified-Since` on subsequent requests. If the resource hasn't changed since that timestamp, Rails returns 304 Not Modified without touching the serializer. This is especially useful for resources with a reliable `updated_at` column and no need for content-based hashing.

**Incorrect (no Last-Modified header -- clients must re-fetch the full body every time):**

```ruby
# app/controllers/api/v1/customers_controller.rb
class Api::V1::CustomersController < ApplicationController
  def show
    customer = Customer.find(params[:id])

    render json: CustomerSerializer.new(customer).as_json  # no cache headers at all
  end
end
```

**Correct (fresh_when sets Last-Modified and handles If-Modified-Since automatically):**

```ruby
# app/controllers/api/v1/customers_controller.rb
class Api::V1::CustomersController < ApplicationController
  def show
    customer = Customer.find(params[:id])

    if stale?(last_modified: customer.updated_at)  # sets Last-Modified, checks If-Modified-Since
      render json: CustomerSerializer.new(customer).as_json
    end
  end

  def index
    customers = Customer.order(updated_at: :desc).limit(50)
    latest = customers.maximum(:updated_at)

    if stale?(last_modified: latest)  # use the most recent timestamp for collections
      render json: customers.map { |c| CustomerSerializer.new(c).as_json }
    end
  end
end
```

```http
# First request
GET /api/v1/customers/7 HTTP/1.1

HTTP/1.1 200 OK
Last-Modified: Thu, 12 Jun 2025 14:30:00 GMT
# ... full body ...

# Second request with timestamp
GET /api/v1/customers/7 HTTP/1.1
If-Modified-Since: Thu, 12 Jun 2025 14:30:00 GMT

HTTP/1.1 304 Not Modified
```

**Alternative:** Combine both ETag and Last-Modified for strongest caching. Use `stale?(etag: customer, last_modified: customer.updated_at)` to support both validation mechanisms simultaneously.

**Benefits:**
- No hash computation required -- just a timestamp comparison
- Works well with CDN and proxy caches that understand `Last-Modified`
- `stale?` handles both setting the header and checking the conditional in one call

**Reference:** RFC 9110 Section 8.8.2 (Last-Modified). See also `restful-hateoas:cache-etag-conditional-get` for content-based validation.
