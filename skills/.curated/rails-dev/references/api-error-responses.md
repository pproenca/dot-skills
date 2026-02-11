---
title: Return Structured Error Responses
impact: MEDIUM
impactDescription: enables client-side error handling without string parsing
tags: api, errors, json, error-handling
---

## Return Structured Error Responses

Returning plain text errors or inconsistent JSON formats forces clients to parse strings. Use a consistent error envelope.

**Incorrect (inconsistent error formats):**

```ruby
class Api::OrdersController < ApplicationController
  def create
    order = Order.new(order_params)
    if order.save
      render json: order
    else
      render json: order.errors.full_messages, status: :unprocessable_entity
    end
  end

  def show
    order = Order.find(params[:id])
    render json: order
  rescue ActiveRecord::RecordNotFound
    render json: "Not found", status: :not_found  # Plain string
  end
end
```

**Correct (consistent error envelope):**

```ruby
class Api::OrdersController < Api::BaseController
  def create
    order = Order.new(order_params)
    if order.save
      render json: OrderSerializer.new(order).as_json, status: :created
    else
      render json: {
        error: "validation_failed",
        message: "Order could not be created",
        details: order.errors.messages
      }, status: :unprocessable_entity
    end
  end
end

# app/controllers/api/base_controller.rb
class Api::BaseController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound do |e|
    render json: {
      error: "not_found",
      message: "#{e.model} not found"
    }, status: :not_found
  end
end
```
