---
title: Model Business Entities, Not Database Tables
impact: CRITICAL
impactDescription: prevents internal coupling from leaking to clients
tags: res, resource-design, domain-modeling, aggregate
---

## Model Business Entities, Not Database Tables

API resources represent business concepts, not ActiveRecord models. Exposing join tables, internal bookkeeping models, or raw database structure forces clients to understand your schema. Aggregate related data into resources that match how consumers think about the domain.

**Incorrect (exposing internal join table as an API resource):**

```ruby
# Leaks schema: clients must know order_products is a join table
resources :orders
resources :products
resources :order_products  # join table exposed as a resource

# app/controllers/order_products_controller.rb
class OrderProductsController < ApplicationController
  def create
    order_product = OrderProduct.create!(
      order_id: params[:order_id],
      product_id: params[:product_id],
      quantity: params[:quantity],
      unit_price: params[:unit_price]  # client must set price -- business logic leak
    )

    render json: order_product, status: :created
  end
end
```

**Correct (aggregate resource models the business concept):**

```ruby
resources :orders do
  resources :line_items, only: %i[index create destroy]  # business concept, not a join table
end

# app/controllers/line_items_controller.rb
class LineItemsController < ApplicationController
  def create
    order = Order.find(params[:order_id])
    line_item = order.add_item(params[:product_id], params[:quantity])  # domain logic stays server-side

    render json: {
      id: line_item.public_id,
      product: line_item.product_name,
      quantity: line_item.quantity,
      unit_price: line_item.unit_price,
      _links: {
        self: { href: line_item_path(line_item) },
        order: { href: order_path(order) }
      }
    }, status: :created
  end
end
```

**Benefits:**
- Clients work with "line items" and "orders" -- concepts they understand
- Server owns pricing, validation, and business rules behind the aggregate boundary
- Schema changes (renaming tables, splitting models) do not break the API contract
