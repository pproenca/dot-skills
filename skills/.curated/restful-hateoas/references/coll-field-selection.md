---
title: Support Sparse Fieldsets via a Fields Parameter
impact: MEDIUM-HIGH
impactDescription: 2-10x payload reduction for clients that only need a subset of resource fields
tags: coll, fields, sparse-fieldsets, performance, payload
---

## Support Sparse Fieldsets via a Fields Parameter

Collection endpoints should support a `fields` query parameter that limits which fields are returned. Mobile clients listing orders need `id`, `status`, and `total` -- not the full 30-field representation with nested addresses and line items. Without field selection, every client pays the serialization and transfer cost of the largest consumer's needs.

**Incorrect (always returns all fields regardless of client needs):**

```ruby
# app/controllers/api/v1/orders_controller.rb
class Api::V1::OrdersController < ApplicationController
  def index
    orders = paginate(current_user.orders.order(id: :desc))

    render json: {
      _embedded: { orders: orders.map { |o| OrderSerializer.new(o).as_json } }
    }
    # Every response includes all 30 fields — mobile clients transfer 10x more data than needed
  end
end

# app/serializers/order_serializer.rb
class OrderSerializer < BaseSerializer
  private

  def resource_json
    {
      id: @resource.id, status: @resource.status, total: @resource.total.to_f,
      currency: @resource.currency, notes: @resource.notes,
      shipping_address: @resource.shipping_address, billing_address: @resource.billing_address,
      line_items: @resource.line_items.map { |li| LineItemSerializer.new(li).as_json }
    }
  end
end
```

**Correct (fields parameter filters both SELECT and serializer output):**

```ruby
# app/controllers/api/v1/orders_controller.rb
class Api::V1::OrdersController < ApplicationController
  def index
    requested_fields = parse_fields(params[:fields])
    orders = current_user.orders.order(id: :desc)
    orders = orders.select(requested_fields & Order.column_names) if requested_fields  # narrow SELECT
    orders = paginate(orders)

    render json: {
      _links: {
        self: { href: request.original_url },
        fields: { href: "/api/v1/orders{?fields}", templated: true }
      },
      _embedded: {
        orders: orders.map { |o| OrderSerializer.new(o, fields: requested_fields).as_json }
      }
    }
  end

  private

  def parse_fields(fields_param)
    return nil if fields_param.blank?
    fields_param.split(",").map(&:strip)  # "id,status,total" → ["id", "status", "total"]
  end
end

# app/serializers/order_serializer.rb
class OrderSerializer < BaseSerializer
  ALLOWED_FIELDS = %w[id status total currency notes shipping_address billing_address].freeze

  def initialize(resource, fields: nil, **opts)
    super(resource, **opts)
    @fields = fields&.intersection(ALLOWED_FIELDS) || ALLOWED_FIELDS  # whitelist only
  end

  private

  def resource_json
    all_fields = {
      id: @resource.id, status: @resource.status, total: @resource.total.to_f,
      currency: @resource.currency, notes: @resource.notes,
      shipping_address: @resource.shipping_address, billing_address: @resource.billing_address
    }
    all_fields.slice(*@fields.map(&:to_sym))  # return only requested fields
  end
end
```

```http
GET /api/v1/orders?fields=id,status,total
→ { "_embedded": { "orders": [{ "id": "ord_1", "status": "shipped", "total": 129.99, "_links": { "self": { "href": "/api/v1/orders/ord_1" } } }] } }
```

**Benefits:**
- Mobile list views request only `id,status,total` -- payload drops from ~2KB to ~200 bytes per item
- Database SELECT is narrowed, avoiding loading text columns and associations the client does not need
- `_links.self` is always included regardless of field selection, preserving hypermedia navigability
- Templated `_links.fields` href advertises sparse fieldset support

**When NOT to use:**
- Single-resource GET endpoints (`/orders/123`) should default to full representation. Field selection is most valuable on collection endpoints with many items.

**Reference:** JSON:API Sparse Fieldsets specification. See also `restful-hateoas:coll-filtering-via-query-params` for combining field selection with filters.
