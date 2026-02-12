---
title: Return 405 with Allow Header for Wrong Methods
impact: HIGH
impactDescription: enables client method discovery and differentiates missing resources from unsupported methods
tags: status, 405, allow-header, options, method-discovery
---

## Return 405 with Allow Header for Wrong Methods

When a client sends a request with an HTTP method the resource does not support, return 405 Method Not Allowed with an Allow header listing the supported methods. Returning 404 when the resource exists but the method is wrong misleads clients into thinking the resource does not exist. The Allow header (RFC 7231 Section 7.4.1) is required on 405 responses and enables client method discovery.

**Incorrect (returns 404 when the resource exists but the method is wrong):**

```ruby
# config/routes.rb
Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :shipments, only: [:show, :update, :destroy]  # no :create — POST returns 404 by default
    end
  end
end
```

```http
POST /api/v1/shipments HTTP/1.1

HTTP/1.1 404 Not Found
```

**Correct (returns 405 with Allow header and supports OPTIONS):**

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::API
  rescue_from ActionController::RoutingError, with: :method_not_allowed

  private

  def method_not_allowed
    allowed = allowed_methods_for(request.path)
    response.set_header("Allow", allowed.join(", "))  # required by RFC 7231

    render json: {
      error: "method_not_allowed",
      message: "#{request.method} is not supported for #{request.path}",
      allowed_methods: allowed,
      _links: { self: { href: request.path } }
    }, status: :method_not_allowed  # 405
  end

  def allowed_methods_for(path)
    Rails.application.routes.routes
         .select { |r| r.path.match?(path) }
         .map { |r| r.verb.upcase }
         .uniq
  end
end

# config/routes.rb
Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :shipments, only: [:show, :update, :destroy]

      # Explicit OPTIONS support for method discovery
      match "shipments(/:id)", to: "shipments#options", via: :options
    end
  end
end

# app/controllers/api/v1/shipments_controller.rb
class Api::V1::ShipmentsController < ApplicationController
  def options
    response.set_header("Allow", "GET, PATCH, DELETE, OPTIONS")
    head :no_content
  end
end
```

```http
POST /api/v1/shipments HTTP/1.1
Authorization: Bearer <token>

HTTP/1.1 405 Method Not Allowed
Allow: GET, PATCH, DELETE, OPTIONS
Content-Type: application/json

{
  "error": "method_not_allowed",
  "message": "POST is not supported for /api/v1/shipments",
  "allowed_methods": ["GET", "PATCH", "DELETE", "OPTIONS"],
  "_links": {
    "self": { "href": "/api/v1/shipments" }
  }
}
```

```http
OPTIONS /api/v1/shipments/shp_42 HTTP/1.1

HTTP/1.1 204 No Content
Allow: GET, PATCH, DELETE, OPTIONS
```

**Benefits:**
- Clients distinguish "resource does not exist" (404) from "method not supported" (405)
- The Allow header lets clients discover supported methods programmatically
- OPTIONS support enables pre-flight checks and API exploration without trial-and-error
- CORS pre-flight requests rely on OPTIONS -- supporting it is essential for browser clients

**When NOT to use:** If your API sits behind a gateway that already handles 405 responses and injects Allow headers, avoid duplicating the logic at the application layer.

**Reference:** RFC 7231 Section 6.5.5 (405 Method Not Allowed), Section 7.4.1 (Allow). See also `restful-hateoas:http-get-must-be-safe` for correct method semantics.
