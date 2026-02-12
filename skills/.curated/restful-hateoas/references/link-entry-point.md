---
title: Provide a Root API Entry Point
impact: CRITICAL
impactDescription: enables API discovery without external documentation, the homepage of your API
tags: link, entry-point, root, discovery, navigation
---

## Provide a Root API Entry Point

Provide a root endpoint (e.g., `GET /api`) that returns links to all top-level resources. This is the "homepage" of your API -- clients start here and discover the entire API through link traversal. Without a root, clients must know every resource URI upfront from out-of-band documentation.

**Incorrect (no root endpoint -- clients must hardcode all resource URIs):**

```ruby
# config/routes.rb
namespace :api do
  resources :orders
  resources :customers
  resources :products
  resources :shipments
  # No root route -- clients need a README to discover these
end
```

**Correct (root controller returns a link map to all resources):**

```ruby
# config/routes.rb
namespace :api do
  root "root#index"  # GET /api
  resources :orders
  resources :customers
  resources :products
  resources :shipments
end

# app/controllers/api/root_controller.rb
class Api::RootController < Api::BaseController
  def index
    render json: {
      _links: {
        self: { href: "/api" },
        orders: { href: "/api/orders", title: "Customer orders" },
        customers: { href: "/api/customers", title: "Customer accounts" },
        products: { href: "/api/products", title: "Product catalogue" },
        shipments: { href: "/api/shipments", title: "Shipment tracking" }
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
    _links: {
      self: { href: "/api" },
      orders: { href: "/api/orders" },
      customers: { href: "/api/customers" },
      "https://api.example.com/rels/search": {
        href: "/api/search{?q}",  # URI template (RFC 6570)
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
