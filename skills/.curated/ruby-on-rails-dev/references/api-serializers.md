---
title: Use Serializers for Consistent JSON Responses
impact: MEDIUM
impactDescription: eliminates ad-hoc JSON construction across controllers
tags: api, serializers, json, consistency
---

## Use Serializers for Consistent JSON Responses

Building JSON inline with `render json:` and `as_json` scatters response structure across controllers. Serializers centralize the API contract.

**Incorrect (ad-hoc JSON in controller):**

```ruby
class Api::OrdersController < ApplicationController
  def show
    order = Order.find(params[:id])
    render json: {
      id: order.id,
      total: order.total.to_f,
      status: order.status,
      items: order.items.map { |item|
        { id: item.id, name: item.product.name, quantity: item.quantity }
      },
      customer: { id: order.user.id, name: order.user.name }
    }
  end
end
```

**Correct (dedicated serializer):**

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
      items: @order.items.map { |item| ItemSerializer.new(item).as_json },
      customer: UserSerializer.new(@order.user).as_json
    }
  end
end

# Controller
class Api::OrdersController < ApplicationController
  def show
    order = Order.includes(:items, :user).find(params[:id])
    render json: OrderSerializer.new(order).as_json
  end
end
```

Reference: [Rendering JSON — Rails Guides](https://guides.rubyonrails.org/layouts_and_rendering.html)
