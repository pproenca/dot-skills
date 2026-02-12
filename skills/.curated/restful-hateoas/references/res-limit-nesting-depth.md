---
title: Limit Resource Nesting to Two Levels
impact: CRITICAL
impactDescription: reduces URI complexity, enables independent resource evolution
tags: res, nesting, shallow-routes, uri-design
---

## Limit Resource Nesting to Two Levels

Deeply nested URIs like `/customers/5/orders/99/line_items/3` couple resources tightly and force clients to know the full ancestry chain. Limit nesting to two levels (`/customers/5/orders`) and use hypermedia links to connect deeper relationships. This lets each resource evolve its own URI independently.

**Incorrect (3+ levels of nesting couples the entire hierarchy):**

```ruby
# config/routes.rb
Rails.application.routes.draw do
  resources :customers do
    resources :orders do
      resources :line_items do
        resources :adjustments  # /customers/:id/orders/:id/line_items/:id/adjustments
      end
    end
  end
end
```

**Correct (shallow nesting with hypermedia links for traversal):**

```ruby
# config/routes.rb
Rails.application.routes.draw do
  resources :customers do
    resources :orders, shallow: true  # /customers/:id/orders + /orders/:id
  end

  resources :orders, only: [] do
    resources :line_items, shallow: true  # /orders/:id/line_items + /line_items/:id
  end
end

# app/controllers/line_items_controller.rb
class LineItemsController < ApplicationController
  def show
    line_item = LineItem.find(params[:id])

    render json: {
      id: line_item.id,
      quantity: line_item.quantity,
      _links: {
        self: { href: line_item_path(line_item) },
        order: { href: order_path(line_item.order) },  # link replaces deep nesting
        customer: { href: customer_path(line_item.order.customer) }
      }
    }
  end
end
```

**Benefits:**
- `shallow: true` generates collection routes under the parent but member routes at the top level
- Clients follow `_links` to traverse relationships instead of constructing deep URIs
- Resources can be moved, renamed, or restructured without breaking deeply nested paths
