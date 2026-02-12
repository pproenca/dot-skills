---
title: Include Pagination Links in Both Body and Link Header
impact: MEDIUM-HIGH
impactDescription: enables HTTP-level caching and generic client navigation of paginated resources
tags: coll, pagination, link-header, rfc8288, http-caching
---

## Include Pagination Links in Both Body and Link Header

Pagination links belong in two places: the JSON body (`_links`) for application-level clients and the HTTP `Link` header (RFC 8288) for generic HTTP clients, proxies, and caching layers. The `Link` header is the only pagination signal that HTTP intermediaries can read without parsing your response body -- omitting it means CDNs and prefetch mechanisms cannot discover the next page.

**Incorrect (pagination metadata only in the JSON body):**

```ruby
# app/controllers/api/v1/orders_controller.rb
class Api::V1::OrdersController < ApplicationController
  def index
    orders = paginate(current_user.orders.order(id: :desc))

    render json: {
      _links: { next: { href: "/api/v1/orders?cursor=#{orders.last.id}" } },
      _embedded: { orders: orders.map { |o| OrderSerializer.new(o).as_json } }
    }
    # No Link header — proxies and generic HTTP clients cannot discover pagination
  end
end
```

**Correct (Link header mirrors _links for HTTP-level discoverability):**

```ruby
# app/controllers/api/v1/orders_controller.rb
class Api::V1::OrdersController < ApplicationController
  def index
    orders = paginate(current_user.orders.order(id: :desc))
    links = build_pagination_links(orders)

    response.headers["Link"] = format_link_header(links)  # RFC 8288 Link header

    render json: {
      _links: links,
      _embedded: { orders: orders.map { |o| OrderSerializer.new(o).as_json } }
    }
  end

  private

  def build_pagination_links(orders)
    base = "/api/v1/orders"
    links = { self: { href: request.original_url } }
    links[:next] = { href: "#{base}?cursor=#{orders.last.id}" } if @has_next
    links[:prev] = { href: "#{base}?cursor=#{orders.first.id}&direction=before" } if @has_prev
    links[:first] = { href: base }
    links
  end

  def format_link_header(links)
    links.except(:self).map { |rel, attrs|
      %(<#{attrs[:href]}>; rel="#{rel}")  # <URL>; rel="next"
    }.join(", ")
  end
end
```

```http
HTTP/1.1 200 OK
Link: </api/v1/orders?cursor=ord_42>; rel="next", </api/v1/orders>; rel="first"
Content-Type: application/hal+json

{
  "_links": {
    "self": { "href": "/api/v1/orders?cursor=ord_99" },
    "next": { "href": "/api/v1/orders?cursor=ord_42" },
    "first": { "href": "/api/v1/orders" }
  },
  "_embedded": { "orders": [ ... ] }
}
```

**Benefits:**
- CDNs and HTTP caches can prefetch the next page using the `Link` header without body parsing
- Generic HTTP clients (curl, HTTPie) display pagination rels automatically
- Body `_links` and header `Link` are always in sync -- one source of truth rendered twice

**Reference:** RFC 8288 (Web Linking). See also `restful-hateoas:link-pagination-links` for HAL link structure, `restful-hateoas:coll-cursor-pagination` for cursor implementation.
