---
title: Support Filtering via Typed Query Parameters
impact: MEDIUM-HIGH
impactDescription: enables precise client-side filtering without ambiguous server-side search parsing
tags: coll, filtering, query-params, collections, api-design
---

## Support Filtering via Typed Query Parameters

Collection endpoints should support filtering through explicit, typed query parameters -- one per filterable field. A single `search` parameter forces the server to parse a freeform string and guess intent, producing inconsistent results and making the API impossible to document precisely. Typed parameters like `status=shipped&created_after=2024-01-01` are self-documenting, cacheable, and composable.

**Incorrect (single search parameter requires server-side parsing guesswork):**

```ruby
# app/controllers/api/v1/orders_controller.rb
class Api::V1::OrdersController < ApplicationController
  def index
    orders = current_user.orders

    if params[:search].present?
      # Parsing "shipped 2024" — is "2024" a year? An order number? Ambiguous.
      terms = params[:search].split(/\s+/)
      terms.each do |term|
        orders = orders.where("status LIKE ? OR notes LIKE ?", "%#{term}%", "%#{term}%")
      end
    end

    render json: { orders: orders.map { |o| OrderSerializer.new(o).as_json } }
  end
end
```

**Correct (typed, composable query parameters with discoverable filter links):**

```ruby
# app/controllers/api/v1/orders_controller.rb
class Api::V1::OrdersController < ApplicationController
  ALLOWED_FILTERS = %w[status created_after created_before customer_id min_total].freeze

  def index
    orders = current_user.orders.order(id: :desc)
    orders = apply_filters(orders)
    orders = paginate(orders)

    render json: {
      _links: collection_links,
      _embedded: { orders: orders.map { |o| OrderSerializer.new(o).as_json } }
    }
  end

  private

  def apply_filters(scope)
    scope = scope.where(status: params[:status]) if params[:status].present?
    scope = scope.where("created_at >= ?", Date.parse(params[:created_after])) if params[:created_after].present?
    scope = scope.where("created_at <= ?", Date.parse(params[:created_before])) if params[:created_before].present?
    scope = scope.where(customer_id: params[:customer_id]) if params[:customer_id].present?
    scope = scope.where("total >= ?", params[:min_total].to_d) if params[:min_total].present?
    scope
  end

  def collection_links
    {
      self: { href: request.original_url },
      filters: { href: "/api/v1/orders{?status,created_after,created_before,customer_id,min_total}", templated: true }
    }
  end
end
```

**Benefits:**
- Each filter maps to a single database condition -- no ambiguous string parsing
- Templated `_links.filters` href advertises available filters (RFC 6570 URI Templates)
- Filters compose: `?status=shipped&min_total=100` is a precise intersection, not a fuzzy search
- Cached responses are keyed by exact query string -- `?status=shipped` and `?status=pending` cache independently

**When NOT to use:**
- Full-text search across multiple fields is a separate concern -- expose it as a dedicated `/search` endpoint or a `q` parameter alongside field filters.

**Reference:** RFC 6570 (URI Template) for templated link relations. See also `restful-hateoas:coll-sorting-convention` for sorting alongside filters.
