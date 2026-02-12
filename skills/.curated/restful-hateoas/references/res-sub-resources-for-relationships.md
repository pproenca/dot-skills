---
title: Express Relationships as Sub-Resources
impact: CRITICAL
impactDescription: prevents client URI construction errors, enables relationship discovery
tags: res, sub-resources, relationships, nesting, hypermedia
---

## Express Relationships as Sub-Resources

Ownership relationships belong in the URI path (`/orders/42/line_items`), not in query parameters (`/line_items?order_id=42`). Sub-resources make the parent-child relationship explicit and discoverable. Combine with hypermedia links so clients navigate from parent to children without constructing URIs.

**Incorrect (flat resources with filter params hide ownership):**

```ruby
# config/routes.rb
Rails.application.routes.draw do
  resources :orders, only: %i[index show]
  resources :line_items, only: %i[index show create]  # flat, relationship via params
end

# app/controllers/line_items_controller.rb
class LineItemsController < ApplicationController
  def index
    line_items = LineItem.where(order_id: params[:order_id])  # relationship buried in query string

    render json: line_items.map { |item|
      { id: item.id, product: item.product_name, quantity: item.quantity }
    }
  end
end
```

**Correct (sub-resources express ownership, hypermedia links enable traversal):**

```ruby
# config/routes.rb
Rails.application.routes.draw do
  resources :orders, only: %i[index show] do
    resources :line_items, only: %i[index create], shallow: true
  end
end

# app/controllers/line_items_controller.rb
class LineItemsController < ApplicationController
  def index
    order = Order.find(params[:order_id])
    line_items = order.line_items

    render json: {
      _embedded: {
        line_items: line_items.map { |item|
          {
            id: item.public_id,
            product: item.product_name,
            quantity: item.quantity,
            _links: {
              self: { href: line_item_path(item) },
              order: { href: order_path(order) }  # navigate back to parent
            }
          }
        }
      },
      _links: {
        self: { href: order_line_items_path(order) },
        order: { href: order_path(order) }
      }
    }
  end
end
```

**Benefits:**
- `POST /orders/42/line_items` makes it obvious the new item belongs to order 42
- Clients discover child resources through `_links` on the parent, no URI templates needed
- Authorization scoping is natural -- accessing line items implies access to the parent order

**When NOT to use:** Use query parameters for cross-cutting filters (`/line_items?min_price=10`) that do not express ownership. Sub-resources are for belongs-to relationships, not arbitrary filtering.
