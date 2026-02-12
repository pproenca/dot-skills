---
title: Choose Between Embedding and Linking Related Resources
impact: CRITICAL
impactDescription: balances response size vs request count, reduces payload by only including links for optional associations
tags: link, embedded, hal, payload, performance, chatty
---

## Choose Between Embedding and Linking Related Resources

Decide between embedding related resources inline (`_embedded`) and linking to them (`_links`). Embedding always-needed data saves round trips; linking optional data keeps payloads small. The best APIs do both -- embed core associations and link to the rest, optionally letting clients request embedding via a query parameter.

**Incorrect (always embedding all associations -- bloated responses):**

```ruby
# app/serializers/order_serializer.rb
class OrderSerializer < BaseSerializer
  private

  def resource_json
    {
      id: @resource.id,
      total: @resource.total.to_f,
      status: @resource.status,
      customer: CustomerSerializer.new(@resource.customer).as_json,
      line_items: @resource.line_items.map { |li| LineItemSerializer.new(li).as_json },
      shipment: @resource.shipment ? ShipmentSerializer.new(@resource.shipment).as_json : nil,
      payments: @resource.payments.map { |p| PaymentSerializer.new(p).as_json },
      audit_log: @resource.audit_entries.map { |e| AuditSerializer.new(e).as_json }
    }
    # Every response includes everything -- 5-10KB per order even for a list view
  end
end
```

**Correct (embed core data, link optional data, support client-requested embedding):**

```ruby
# app/serializers/order_serializer.rb
class OrderSerializer < BaseSerializer
  def initialize(resource, request: nil, embed: [])
    super(resource, request: request)
    @embed = Array(embed)  # e.g., ["customer", "line_items"]
  end

  private

  def resource_json
    json = { id: @resource.id, total: @resource.total.to_f, status: @resource.status }
    json[:_embedded] = embedded_resources if embedded_resources.any?
    json
  end

  def self_href = "/api/v1/orders/#{@resource.id}"

  def extra_links
    {
      customer: { href: "/api/v1/customers/#{@resource.customer_id}" },
      line_items: { href: "/api/v1/orders/#{@resource.id}/line_items" },
      shipment: (@resource.shipment_id &&
        { href: "/api/v1/shipments/#{@resource.shipment_id}" }),
      payments: { href: "/api/v1/orders/#{@resource.id}/payments" }
    }.compact
  end

  def embedded_resources
    embeds = {}
    if @embed.include?("customer")
      embeds[:customer] = CustomerSerializer.new(@resource.customer).as_json
    end
    if @embed.include?("line_items")
      embeds[:line_items] = @resource.line_items.map { |li| LineItemSerializer.new(li).as_json }
    end
    embeds
  end
end

# Controller parses ?embed= query parameter
# GET /api/v1/orders/42?embed=customer,line_items
class Api::V1::OrdersController < Api::V1::BaseController
  def show
    order = Order.includes(*embed_associations).find(params[:id])
    render json: OrderSerializer.new(order, embed: embed_params).as_json
  end

  private

  def embed_params = params.fetch(:embed, "").split(",")

  def embed_associations
    allowed = { "customer" => :customer, "line_items" => :line_items }
    embed_params.filter_map { |e| allowed[e] }  # whitelist to prevent arbitrary includes
  end
end
```

**Benefits:**
- Default responses stay small -- only links, no embedded payloads
- Clients that need related data request it explicitly via `?embed=`
- Server eager-loads only requested associations, avoiding N+1 queries

**When NOT to use:**
- If a related resource is always needed in every client (e.g., order always needs line_items for display), embed it by default instead of requiring the `?embed=` parameter

**Reference:** HAL specification defines `_embedded` for inline resource representations. See also `restful-hateoas:link-related-resource-links`.
