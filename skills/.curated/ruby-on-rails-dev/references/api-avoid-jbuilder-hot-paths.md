---
title: Avoid Jbuilder on High-Traffic Endpoints
impact: MEDIUM
impactDescription: 2-5× faster JSON generation with plain serializers
tags: api, jbuilder, serialization, performance
---

## Avoid Jbuilder on High-Traffic Endpoints

Jbuilder creates a new template context per render, adding 2-5ms overhead per response. For high-traffic APIs, use plain Ruby serializers.

**Incorrect (Jbuilder template):**

```ruby
# app/views/api/orders/index.json.jbuilder
json.orders @orders do |order|
  json.id order.id
  json.total order.total.to_f
  json.status order.status
  json.items order.items do |item|
    json.id item.id
    json.name item.product.name
  end
end
```

**Correct (plain Ruby serializer):**

```ruby
class Api::OrdersController < Api::BaseController
  def index
    orders = current_user.orders.includes(items: :product).page(params[:page])
    render json: { orders: orders.map { |o| OrderSerializer.new(o).as_json } }
  end
end
```

**When NOT to use this pattern:**
- Low-traffic internal admin endpoints where development speed matters more
- Prototyping and MVPs

Reference: [Jbuilder Gem](https://github.com/rails/jbuilder)
