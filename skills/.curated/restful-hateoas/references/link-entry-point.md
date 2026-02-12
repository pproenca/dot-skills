---
title: Provide a Root API Entry Point
impact: CRITICAL
impactDescription: enables API discovery without external documentation, the homepage of your API
tags: link, entry-point, root, discovery, navigation
---

## Provide a Root API Entry Point

Provide a root endpoint (e.g., `GET /api/v1`) that returns links to all top-level resources. This is the "homepage" of your API -- clients start here and discover the entire API through link traversal. Without a root, clients must know every resource URI upfront from out-of-band documentation.

**Incorrect (no root endpoint -- clients must hardcode all resource URIs):**

```ruby
# config/routes.rb
namespace :api do
  namespace :v1 do
    resources :orders
    resources :customers
    resources :products
    resources :shipments
    # No root route -- clients need a README to discover these
  end
end
```

**Correct (root controller returns a link map to all resources):**

```ruby
# config/routes.rb
namespace :api do
  namespace :v1 do
    root "root#index"  # GET /api/v1
    resources :orders
    resources :customers
    resources :products
    resources :shipments
  end
end

# app/controllers/api/v1/root_controller.rb
class Api::V1::RootController < Api::V1::BaseController
  def index
    render json: {
      _links: {
        self: { href: "/api/v1" },
        orders: { href: "/api/v1/orders", title: "Customer orders" },
        customers: { href: "/api/v1/customers", title: "Customer accounts" },
        products: { href: "/api/v1/products", title: "Product catalogue" },
        shipments: { href: "/api/v1/shipments", title: "Shipment tracking" }
      }
    }
  end
end
```

**Alternative (include API metadata alongside links):**

```ruby
def index
  render json: {
    api: "Example Store API",
    version: "v1",
    _links: {
      self: { href: "/api/v1" },
      orders: { href: "/api/v1/orders" },
      customers: { href: "/api/v1/customers" },
      "https://api.example.com/rels/search": {
        href: "/api/v1/search{?q}",  # URI template (RFC 6570)
        templated: true
      }
    }
  }
end
```

**Benefits:**
- New resources are discoverable the moment you add them to the root
- Clients need exactly one bookmark: the root URI
- API documentation becomes a supplement, not a prerequisite

**Reference:** Roy Fielding's thesis, Section 5.2.1 -- "A REST API should be entered with no prior knowledge beyond the initial URI." See also `restful-hateoas:link-standard-relation-types`.
