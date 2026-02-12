---
title: Use Hypermedia Links for Pagination
impact: CRITICAL
impactDescription: enables cursor-based pagination migration without breaking clients
tags: link, pagination, next, prev, cursor, collections
---

## Use Hypermedia Links for Pagination

Collection responses must include `next`, `prev`, `first`, and `last` links for pagination. When clients follow links instead of constructing page URLs, you can migrate from offset to cursor-based pagination without breaking a single client -- the link structure stays the same, only the `href` value changes.

**Incorrect (pagination metadata forces clients to build URLs):**

```ruby
# app/serializers/order_collection_serializer.rb
class OrderCollectionSerializer
  def initialize(orders)
    @orders = orders
  end

  def as_json
    {
      orders: @orders.map { |o| OrderSerializer.new(o).as_json },
      meta: {
        page: @orders.current_page,
        per_page: 25,
        total_pages: @orders.total_pages
      }
      # Client must build: "/orders?page=#{meta[:page] + 1}" -- coupled to URL scheme
    }
  end
end
```

**Correct (pagination links -- clients follow hrefs without URL construction):**

```ruby
# app/serializers/order_collection_serializer.rb
class OrderCollectionSerializer
  def initialize(orders, base_path:)
    @orders = orders
    @base_path = base_path
  end

  def as_json
    {
      _links: pagination_links,
      _embedded: {
        orders: @orders.map { |o| OrderSerializer.new(o).as_json }
      },
      total_count: @orders.total_count
    }
  end

  private

  def pagination_links
    links = { self: { href: "#{@base_path}?cursor=#{@orders.first&.id}" } }
    if @orders.length == 25  # more pages available
      links[:next] = { href: "#{@base_path}?cursor=#{@orders.last.id}&direction=after" }
    end
    if @cursor.present?  # cursor param indicates a previous page exists
      links[:prev] = { href: "#{@base_path}?cursor=#{@orders.first.id}&direction=before" }
    end
    links
  end
end
```

**Benefits:**
- Switching from `?page=3` to `?cursor=abc123` requires zero client changes
- Clients use `response._links.next.href` consistently -- no URL construction
- Absent `next` link signals "last page" without a separate boolean field

**When NOT to use:**
- Internal admin tools where page-number jumping is a core UX requirement may still benefit from exposing page metadata alongside links

**Reference:** See also `rails-dev:api-pagination` for server-side pagination setup, and `restful-hateoas:link-standard-relation-types` for IANA `next`/`prev`/`first`/`last` rels.
