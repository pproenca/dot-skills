---
title: Expose Available Actions as Links
impact: CRITICAL
impactDescription: moves business logic from client to server, eliminates client-side state machines
tags: link, affordances, actions, state-transitions, hateoas
---

## Expose Available Actions as Links

The presence or absence of action links communicates which state transitions are currently allowed. If an order can be cancelled, include a `cancel` link. If it has already shipped, omit the link. This moves business rule enforcement from the client to the server -- clients never need to check status fields to decide what buttons to show.

**Incorrect (client checks status and hardcodes which actions are allowed):**

```ruby
# app/serializers/order_serializer.rb
class OrderSerializer < BaseSerializer
  private

  def resource_json
    {
      id: @resource.id,
      total: @resource.total.to_f,
      status: @resource.status  # client reads this to decide: "if pending, show cancel button"
    }
  end

  def self_href = "/api/v1/orders/#{@resource.id}"

  # No action links -- client must duplicate business rules
end
```

**Correct (server conditionally includes action links based on resource state):**

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
    links = {}
    if @resource.cancellable?  # business rule lives in the model
      links[:cancel] = { href: "/api/v1/orders/#{@resource.id}/cancellation", method: "POST" }
    end
    if @resource.shippable?
      links[:ship] = { href: "/api/v1/orders/#{@resource.id}/shipment", method: "POST" }
    end
    if @resource.payable?
      links[:pay] = { href: "/api/v1/orders/#{@resource.id}/payment", method: "POST" }
    end
    links
  end
end
```

**Benefits:**
- Adding a new action (e.g., `refund`) requires zero client changes -- the link just appears
- Business rules change in one place (the model), not across every client
- UI can render buttons based on link presence: `show_button(:cancel) if links[:cancel]`

**Note:** The `method` property on link objects is not part of the base HAL specification. It is a widely adopted pragmatic extension. For strict HAL compliance, use [HAL-FORMS](http://rwcbook.com/hal-forms/) (`_templates`) to express available methods per link.

**When NOT to use:**
- For read-only resources with no state transitions, action links add no value

**Reference:** This is the core of HATEOAS -- Hypermedia as the Engine of Application State. See also `restful-hateoas:res-noun-based-uris` for modelling actions as sub-resource nouns.
