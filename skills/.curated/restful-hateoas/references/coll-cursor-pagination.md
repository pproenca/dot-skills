---
title: Use Cursor-Based Pagination Instead of Offset
impact: MEDIUM-HIGH
impactDescription: O(1) pagination performance vs O(n) offset scanning, prevents page drift on inserts/deletes
tags: coll, pagination, cursor, performance, collections
---

## Use Cursor-Based Pagination Instead of Offset

Offset-based pagination (`page=5&per_page=25`) breaks when records are inserted or deleted between requests -- rows shift positions and clients see duplicates or miss records entirely (page drift). At scale, `OFFSET 10000` forces the database to scan and discard 10,000 rows before returning results, degrading to O(n). Cursor-based pagination uses a stable pointer (the last seen ID) and performs a constant-time indexed lookup.

**Incorrect (offset pagination drifts on inserts and degrades at scale):**

```ruby
# app/controllers/api/v1/orders_controller.rb
class Api::V1::OrdersController < ApplicationController
  def index
    page = params.fetch(:page, 1).to_i
    per_page = params.fetch(:per_page, 25).to_i

    orders = current_user.orders
      .order(id: :desc)
      .offset((page - 1) * per_page)  # OFFSET 10000 scans 10000 rows
      .limit(per_page)

    render json: {
      orders: orders.map { |o| OrderSerializer.new(o).as_json },
      meta: { page: page, per_page: per_page, total_pages: (current_user.orders.count / per_page.to_f).ceil }
    }
  end
end
```

**Correct (cursor pagination with indexed lookup and hypermedia links):**

```ruby
# app/controllers/api/v1/orders_controller.rb
class Api::V1::OrdersController < ApplicationController
  PER_PAGE = 25

  def index
    orders = current_user.orders.order(id: :desc)
    orders = orders.where("id < ?", decode_cursor(params[:cursor])) if params[:cursor].present?
    orders = orders.limit(PER_PAGE + 1)  # fetch one extra to detect next page

    has_next = orders.size > PER_PAGE
    orders = orders.first(PER_PAGE)

    render json: {
      _links: pagination_links(orders, has_next),
      _embedded: { orders: orders.map { |o| OrderSerializer.new(o).as_json } }
    }
  end

  private

  def encode_cursor(id) = Base64.urlsafe_encode64(id.to_s, padding: false)
  def decode_cursor(cursor) = Base64.urlsafe_decode64(cursor)

  def pagination_links(orders, has_next)
    base = "/api/v1/orders"
    links = { self: { href: request.original_url } }
    links[:next] = { href: "#{base}?cursor=#{encode_cursor(orders.last.id)}" } if has_next
    links[:first] = { href: base }
    links
  end
end
```

**Benefits:**
- Pagination cost is O(1) regardless of how deep into the collection the client navigates
- No page drift -- inserting or deleting records does not shift the cursor position
- The `_links.next` href is opaque to clients, so you can change cursor encoding without breaking consumers

**When NOT to use:**
- Admin dashboards requiring "jump to page N" navigation need offset pagination alongside cursor links. Consider offering both: cursor links in `_links` and page metadata in a `meta` object.

**Reference:** See also `restful-hateoas:link-pagination-links` for hypermedia pagination link structure, `restful-hateoas:coll-link-header-pagination` for HTTP Link headers.
