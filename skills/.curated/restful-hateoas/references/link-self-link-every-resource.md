---
title: Include a Self Link in Every Resource
impact: CRITICAL
impactDescription: enables client caching, bookmarking, and resource identity without URI construction
tags: link, self, hypermedia, hal, identity
---

## Include a Self Link in Every Resource

Every resource representation must include a `self` link pointing to its canonical URI. Without it, clients cannot bookmark, cache, or refer back to a resource they received embedded in another response. The `self` link is the most fundamental hypermedia control -- it establishes resource identity.

**Incorrect (response with no links -- client must reconstruct URIs):**

```ruby
# app/serializers/order_serializer.rb
class OrderSerializer
  def initialize(order)
    @order = order
  end

  def as_json
    {
      id: @order.id,
      total: @order.total.to_f,
      status: @order.status,
      placed_at: @order.created_at.iso8601
    }
    # Client must know "/api/v1/orders/#{id}" to refetch this resource
  end
end
```

**Correct (base serializer adds self link to every resource):**

```ruby
# app/serializers/base_serializer.rb
class BaseSerializer
  def initialize(resource, request: nil)
    @resource = resource
    @request = request
  end

  def as_json
    resource_json.merge(_links: { self: { href: self_href } }.merge(extra_links))
  end

  private

  def resource_json = raise NotImplementedError
  def self_href = raise NotImplementedError
  def extra_links = {}  # override in subclasses to add more links
end

# app/serializers/order_serializer.rb
class OrderSerializer < BaseSerializer
  private

  def resource_json
    {
      id: @resource.id,
      total: @resource.total.to_f,
      status: @resource.status,
      placed_at: @resource.created_at.iso8601
    }
  end

  def self_href = "/api/v1/orders/#{@resource.id}"
end
```

**Benefits:**
- Clients cache and bookmark resources using the `self` link as the cache key
- Embedded resources carry their own identity -- no URI guessing needed
- Every serializer inherits the pattern, ensuring consistency across the entire API

**Reference:** RFC 8288 (Web Linking) defines `self` as a standard relation type. See also `restful-hateoas:link-standard-relation-types`.
