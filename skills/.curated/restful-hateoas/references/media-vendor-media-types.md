---
title: Use Vendor Media Types for API Versioning
impact: HIGH
impactDescription: enables API versioning without URI changes, keeping resource URIs stable across versions
tags: media, vendor-type, versioning, accept, mime-type
---

## Use Vendor Media Types for API Versioning

Vendor media types (`application/vnd.myapp.v2+json`) encode the API version in the Accept header instead of the URI. This is the pure REST approach -- a resource's URI identifies the resource, not its representation version. URL versioning (`/api/v1/orders`, `/api/v2/orders`) creates parallel URI spaces for the same resource, breaks bookmarks, invalidates caches, and forces clients to update every hardcoded URL on version bumps.

**Incorrect (URL-based versioning -- every URI changes on version bump):**

```ruby
# config/routes.rb
namespace :api do
  namespace :v1 do
    resources :orders, only: [:show]  # /api/v1/orders/:id
  end
  namespace :v2 do
    resources :orders, only: [:show]  # /api/v2/orders/:id -- same resource, different URI
  end
end

# Two controllers, two route sets, duplicated logic for the same resource
```

**Correct (vendor media type in Accept header -- URI stays the same):**

```ruby
# config/routes.rb
namespace :api do
  resources :orders, only: [:show]  # /api/orders/:id -- one URI per resource, always
end

# app/controllers/concerns/vendor_media_type.rb
module VendorMediaType
  extend ActiveSupport::Concern

  included do
    before_action :parse_api_version
  end

  private

  def parse_api_version
    accept = request.headers["Accept"] || ""
    if accept.match?(/application\/vnd\.myapp\.v(\d+)\+json/)
      @api_version = accept.match(/v(\d+)/)[1].to_i
    else
      @api_version = 1  # default version
    end
  end
end

# app/controllers/api/orders_controller.rb
class Api::OrdersController < ApplicationController
  include VendorMediaType

  def show
    order = Order.find(params[:id])
    serializer = @api_version >= 2 ? V2::OrderSerializer : V1::OrderSerializer
    render json: serializer.new(order).as_json,
           content_type: "application/vnd.myapp.v#{@api_version}+json"
  end
end
```

```http
# Client requesting v2 representation
GET /api/orders/42 HTTP/1.1
Accept: application/vnd.myapp.v2+json

HTTP/1.1 200 OK
Content-Type: application/vnd.myapp.v2+json
```

**Benefits:**
- Resource URIs remain stable forever -- bookmarks and caches survive version changes
- Adding v3 requires a new serializer, not new routes or controllers
- Clients opt into new versions explicitly by changing the Accept header
- HATEOAS links in responses always point to stable URIs

**When NOT to use:**
- Public APIs where developer experience demands simple URL-based versioning (GitHub-style)
- When your API gateway does not support routing on Accept headers

**Reference:** RFC 6838 Section 3.2 (Vendor Media Types). See also `restful-hateoas:media-accept-header-negotiation` for the negotiation mechanism.
