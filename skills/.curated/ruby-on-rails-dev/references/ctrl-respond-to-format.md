---
title: Use respond_to for Multi-Format Responses
impact: HIGH
impactDescription: single action serves HTML, JSON, CSV without duplication
tags: ctrl, respond-to, formats, api, content-negotiation
---

## Use respond_to for Multi-Format Responses

Separate endpoints for HTML and JSON responses duplicate query logic. Use `respond_to` to serve multiple formats from one action.

**Incorrect (duplicate controllers for HTML and JSON):**

```ruby
# app/controllers/orders_controller.rb
class OrdersController < ApplicationController
  def index
    @orders = current_user.orders.recent
  end
end

# app/controllers/api/orders_controller.rb
class Api::OrdersController < ApplicationController
  def index
    orders = current_user.orders.recent  # Duplicated query
    render json: orders
  end
end
```

**Correct (single action, multiple formats):**

```ruby
class OrdersController < ApplicationController
  def index
    @orders = current_user.orders.includes(:items).recent

    respond_to do |format|
      format.html
      format.json { render json: @orders }
      format.csv { send_data @orders.to_csv, filename: "orders.csv" }
    end
  end
end
```

**When NOT to use this pattern:**
- For external APIs — use dedicated `Api::V1::` controllers with versioning and serializers
- When HTML and JSON responses need significantly different query logic or authorization

Reference: [Layouts and Rendering — Rails Guides](https://guides.rubyonrails.org/layouts_and_rendering.html)
