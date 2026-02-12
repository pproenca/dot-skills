---
title: Use HEAD for Metadata Without Transferring the Body
impact: HIGH
impactDescription: eliminates body transfer for existence and metadata checks
tags: http, head, metadata, caching, bandwidth
---

## Use HEAD for Metadata Without Transferring the Body

HEAD returns the same headers as GET but with no response body. Using GET and discarding the body to check whether a resource exists wastes bandwidth, server CPU serializing the response, and database I/O loading the full record. Rails supports HEAD on all GET routes by default, but controller actions must avoid rendering side effects that assume a body will be sent.

**Incorrect (using GET and discarding the body to check existence):**

```ruby
# Client-side code checking if an order exists
class OrderCheckService
  def exists?(order_id)
    response = connection.get("/api/v1/orders/#{order_id}")  # transfers full JSON body
    response.status == 200
  rescue Faraday::ResourceNotFound
    false
  end
end

# Controller renders full serialization even for existence checks
class OrdersController < ApplicationController
  def show
    order = Order.includes(:line_items, :customer).find(params[:id])  # eager loads everything
    render json: OrderSerializer.new(order, include: [:line_items, :customer])
  end
end
```

**Correct (HEAD for metadata, controller handles HEAD efficiently):**

```ruby
# Client-side code using HEAD for existence check
class OrderCheckService
  def exists?(order_id)
    response = connection.head("/api/v1/orders/#{order_id}")  # no body transferred
    response.status == 200
  rescue Faraday::ResourceNotFound
    false
  end
end

# Controller responds to HEAD without serializing the body
class OrdersController < ApplicationController
  def show
    order = Order.find_by(id: params[:id])
    return head :not_found unless order

    if request.head?
      response.headers["X-Order-Status"] = order.status
      response.headers["Last-Modified"] = order.updated_at.httpdate
      head :ok  # headers only, no serialization cost
    else
      render json: OrderSerializer.new(order, include: [:line_items, :customer])
    end
  end
end
```

```http
HEAD /api/v1/orders/42 HTTP/1.1

HTTP/1.1 200 OK
Last-Modified: Thu, 12 Feb 2026 10:30:00 GMT
ETag: "a1b2c3d4"
X-Order-Status: shipped
Content-Length: 1847
```

**Benefits:**
- Zero bytes transferred for existence checks -- savings scale with resource size
- `Last-Modified` and `ETag` headers enable conditional GET with `If-None-Match`
- `Content-Length` header lets clients allocate buffers before downloading
- Rails routes HEAD to the same action as GET by default -- no extra route needed

**Reference:** RFC 9110 Section 9.3.2 (HEAD)
