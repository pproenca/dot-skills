---
title: Return 405 with Allow Header for Wrong Methods
impact: HIGH
impactDescription: enables client method discovery and differentiates missing resources from unsupported methods
tags: status, 405, allow-header, options, method-discovery
---

## Return 405 with Allow Header for Wrong Methods

When a client sends a request with an HTTP method the resource does not support, return 405 Method Not Allowed with an Allow header listing the supported methods. Returning 404 when the resource exists but the method is wrong misleads clients into thinking the resource does not exist. The Allow header (RFC 9110 Section 10.2.1) is required on 405 responses and enables client method discovery.

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

**Correct (catch-all route returns 405 with Allow header):**

```ruby
# config/routes.rb
Rails.application.routes.draw do
  namespace :api do
    resources :shipments, only: [:show, :update, :destroy]

    # Catch unmatched methods on known resource paths — must come after resource routes
    match "shipments(/:id)", to: "method_not_allowed#reject", via: :all
  end
end

# app/controllers/api/method_not_allowed_controller.rb
class Api::MethodNotAllowedController < Api::BaseController
  RESOURCE_METHODS = {
    "shipments" => { collection: %w[GET HEAD OPTIONS], member: %w[GET HEAD PATCH DELETE OPTIONS] }
  }.freeze

  def reject
    resource = request.path.split("/").third  # e.g., "shipments"
    is_member = params[:id].present?
    methods_config = RESOURCE_METHODS.fetch(resource, {})
    allowed = is_member ? methods_config[:member] : methods_config[:collection]

    response.set_header("Allow", allowed.join(", "))

    render json: {
      type: "https://api.example.com/problems/method-not-allowed",
      title: "Method Not Allowed",
      status: 405,
      detail: "#{request.method} is not supported for #{request.path}",
      _links: { self: { href: request.path } }
    }, status: :method_not_allowed, content_type: "application/problem+json"
  end
end
```

```http
POST /api/shipments HTTP/1.1
Authorization: Bearer <token>

HTTP/1.1 405 Method Not Allowed
Allow: GET, HEAD, OPTIONS
Content-Type: application/problem+json

{
  "type": "https://api.example.com/problems/method-not-allowed",
  "title": "Method Not Allowed",
  "status": 405,
  "detail": "POST is not supported for /api/shipments",
  "_links": {
    "self": { "href": "/api/shipments" }
  }
}
```

**Note:** `rescue_from ActionController::RoutingError` does not work in Rails -- routing errors are raised at the middleware level before controllers are initialized. The catch-all route approach above is the standard workaround.

**Benefits:**
- Clients distinguish "resource does not exist" (404) from "method not supported" (405)
- The Allow header lets clients discover supported methods programmatically
- The catch-all route approach works reliably in all Rails versions
- Error response uses Problem Details (RFC 9457) for consistency

**When NOT to use:** If your API sits behind a gateway that already handles 405 responses and injects Allow headers, avoid duplicating the logic at the application layer.

**Reference:** RFC 9110 Section 15.5.6 (405 Method Not Allowed), Section 10.2.1 (Allow). See also `restful-hateoas:http-get-must-be-safe` for correct method semantics.
