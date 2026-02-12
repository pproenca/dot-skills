---
title: Leverage HATEOAS to Eliminate URL Versioning
impact: LOW-MEDIUM
impactDescription: eliminates version-specific code paths and duplicated controllers, reduces long-term maintenance burden
tags: evolve, hateoas, versioning, links
---

## Leverage HATEOAS to Eliminate URL Versioning

URL versioning (`/api/v1/`, `/api/v2/`) forces servers to maintain parallel controller hierarchies and clients to hardcode version-specific base URLs. When clients follow links from API responses instead of constructing URIs, the server can change URI structure, add new resources, and restructure relationships without breaking consumers. The server controls the URI space; clients just follow `_links`. This is the fundamental promise of hypermedia: the server-side is free to evolve because clients do not embed knowledge of URI patterns.

**Incorrect (URL versioning with duplicated controllers and hardcoded client URIs):**

```ruby
# config/routes.rb
namespace :api do
  namespace :v1 do
    resources :orders                        # /api/v1/orders
    resources :customers                     # /api/v1/customers
  end
  namespace :v2 do
    resources :orders                        # /api/v2/orders — duplicated logic
    resources :customers                     # /api/v2/customers — duplicated logic
  end
end

# Client hardcodes:
# BASE_URL = "https://api.example.com/api/v2"
# order_url = "#{BASE_URL}/orders/#{order_id}"  # breaks if v3 changes the path
```

**Correct (single API with evolving link structure -- clients follow _links):**

```ruby
# config/routes.rb
namespace :api do
  resources :orders do
    resource :shipment, only: :show
    resources :line_items, only: :index
  end
  resources :customers, only: %i[show index]
end

# app/serializers/order_serializer.rb
class OrderSerializer < BaseSerializer
  private

  def resource_json
    {
      id: @resource.id,
      total: @resource.total.to_f,
      status: @resource.status
    }
  end

  def self_href = "/api/orders/#{@resource.id}"

  def extra_links
    links = {}
    links[:customer] = { href: "/api/customers/#{@resource.customer_id}" }
    links[:shipment] = { href: "/api/orders/#{@resource.id}/shipment" } if @resource.shipped?
    links[:line_items] = { href: "/api/orders/#{@resource.id}/line_items" }
    links
  end
end

# Client follows links:
# order = fetch(entry_point["_links"]["orders"]["href"])
# shipment = fetch(order["_links"]["shipment"]["href"])  # URI is opaque to client
```

**Benefits:**
- One set of controllers and serializers instead of duplicated version namespaces
- Server can restructure URIs (e.g., moving shipments to a separate service) by changing links -- clients follow automatically
- New capabilities are exposed by adding new `_links` entries, not new API versions

**When NOT to use:** If your API consumers cannot follow links (e.g., hardcoded integrations that refuse to change), URL versioning may still be necessary as a pragmatic fallback. Consider offering both: stable links for hypermedia-capable clients and versioned URLs for legacy consumers.

**Reference:** See also `rails-dev:api-versioning` for URL versioning patterns when they are needed, and `restful-hateoas:link-entry-point` for the API root that bootstraps link discovery.
