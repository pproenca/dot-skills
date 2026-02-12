---
title: Link to Related Resources Instead of Exposing Foreign Keys
impact: CRITICAL
impactDescription: decouples clients from URI structure, enables independent server evolution
tags: link, related, foreign-key, decoupling, navigation
---

## Link to Related Resources Instead of Exposing Foreign Keys

Include links to related resources instead of just exposing foreign key IDs. When clients receive `customer_id: 7`, they must know how to build `/api/v1/customers/7` -- coupling them to your URI structure. Links let clients follow relationships without knowing URL patterns.

**Incorrect (foreign key IDs require client-side URI construction):**

```ruby
# app/serializers/order_serializer.rb
class OrderSerializer
  def initialize(order)
    @order = order
  end

  def as_json
    {
      id: @order.id,
      customer_id: @order.customer_id,   # client must know the customers URL pattern
      shipment_id: @order.shipment_id,   # client must know the shipments URL pattern
      total: @order.total.to_f,
      status: @order.status
    }
  end
end
```

**Correct (links to related resources decouple clients from URI patterns):**

```ruby
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

  def self_href = "/api/v1/orders/#{@resource.id}"

  def extra_links
    links = { customer: { href: "/api/v1/customers/#{@resource.customer_id}" } }
    if @resource.shipment_id
      links[:shipment] = { href: "/api/v1/shipments/#{@resource.shipment_id}" }
    end
    links[:line_items] = { href: "/api/v1/orders/#{@resource.id}/line_items" }
    links
  end
end
```

**Benefits:**
- Server can rename `/customers` to `/accounts` without breaking clients -- just update the link
- Clients discover relationships by following links, not by memorizing URI templates
- Optional associations (like `shipment`) are simply absent rather than `null` IDs

**When NOT to use:**
- If clients always need the related data in the same request, embed it in `_embedded` (see `restful-hateoas:link-embedded-vs-linked`)

**Reference:** See also `restful-hateoas:link-standard-relation-types` for choosing correct `rel` names.
