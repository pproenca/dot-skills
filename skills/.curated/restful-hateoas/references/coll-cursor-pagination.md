---
title: Use Cursor-Based Pagination Instead of Offset
impact: MEDIUM-HIGH
impactDescription: constant-time indexed lookup vs O(n) offset scanning, prevents page drift on inserts/deletes
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

**Correct (cursor pagination with composite cursor and hypermedia links):**

```ruby
# app/controllers/api/v1/orders_controller.rb
class Api::V1::OrdersController < ApplicationController
  PER_PAGE = 25

  def index
    orders = current_user.orders.order(created_at: :desc, id: :desc)

    if params[:cursor].present?
      ts, id = decode_cursor(params[:cursor])
      orders = orders.where("(created_at, id) < (?, ?)", ts, id)  # composite cursor — works with any public ID scheme
    end

    orders = orders.limit(PER_PAGE + 1)  # fetch one extra to detect next page

    has_next = orders.size > PER_PAGE
    orders = orders.first(PER_PAGE)

    render json: {
      _links: pagination_links(orders, has_next),
      _embedded: { orders: orders.map { |o| OrderSerializer.new(o).as_json } }
    }
  end

  private

  def encode_cursor(record)
    Base64.urlsafe_encode64("#{record.created_at.iso8601(6)}:#{record.id}", padding: false)
  end

  def decode_cursor(cursor)
    ts_str, id_str = Base64.urlsafe_decode64(cursor).split(":", 2)
    [Time.iso8601(ts_str), id_str.to_i]
  end

  def pagination_links(orders, has_next)
    base = "/api/v1/orders"
    links = { self: { href: request.original_url } }
    links[:next] = { href: "#{base}?cursor=#{encode_cursor(orders.last)}" } if has_next
    links[:first] = { href: base }
    links
  end
end
```

**Benefits:**
- Pagination cost is constant regardless of how deep into the collection the client navigates (uses indexed lookup, not sequential scan)
- No page drift -- inserting or deleting records does not shift the cursor position
- The `_links.next` href is opaque to clients, so you can change cursor encoding without breaking consumers
- Composite cursor (`created_at:id`) works with any public identifier scheme, including UUIDs

**When NOT to use:**
- Admin dashboards requiring "jump to page N" navigation need offset pagination alongside cursor links. Consider offering both: cursor links in `_links` and page metadata in a `meta` object.

**Reference:** See also `restful-hateoas:link-pagination-links` for hypermedia pagination link structure, `restful-hateoas:coll-link-header-pagination` for HTTP Link headers.
