---
title: Return Structured Validation Errors with Field, Code, and Message
impact: MEDIUM
impactDescription: enables field-level client-side error display without string parsing
tags: err, validation, activerecord, 422
---

## Return Structured Validation Errors with Field, Code, and Message

ActiveRecord's `errors.full_messages` returns human-readable strings like "Email can't be blank" -- fine for server logs, useless for client-side form rendering. Clients need to know which field failed, why it failed (as a machine-readable code), and what to display. Returning an array of objects with `field`, `code`, and `message` lets clients map errors directly to form fields.

**Incorrect (returning full_messages -- client cannot map errors to fields):**

```ruby
# app/controllers/api/v1/orders_controller.rb
class Api::V1::OrdersController < ApplicationController
  def create
    order = current_user.orders.build(order_params)

    unless order.save
      render json: { errors: order.errors.full_messages }, status: :unprocessable_entity
      # => { "errors": ["Email can't be blank", "Quantity must be greater than 0"] }
      return
    end

    render json: OrderSerializer.new(order).as_json, status: :created
  end
end
```

**Correct (structured errors with field, code, and message):**

```ruby
# app/controllers/concerns/validation_errors.rb
module ValidationErrors
  extend ActiveSupport::Concern

  private

  def render_validation_errors(record)
    errors = record.errors.map do |error|
      {
        field: error.attribute.to_s.camelize(:lower),  # "email", "shippingAddress"
        code: error.type.to_s,                          # "blank", "too_short", "taken"
        message: error.full_message                     # "Email can't be blank"
      }
    end

    render json: { errors: errors }, status: :unprocessable_entity
  end
end

# app/controllers/api/v1/orders_controller.rb
class Api::V1::OrdersController < ApplicationController
  include ValidationErrors

  def create
    order = current_user.orders.build(order_params)

    unless order.save
      render_validation_errors(order)
      # => { "errors": [{ "field": "email", "code": "blank", "message": "Email can't be blank" }] }
      return
    end

    render json: OrderSerializer.new(order).as_json, status: :created
  end
end
```

**Benefits:**
- Clients render inline errors under each form field using the `field` key
- The `code` key enables programmatic branching (retry on `taken`, highlight on `blank`)
- The `message` key provides a display-ready string, avoiding client-side message construction

**Reference:** See also `restful-hateoas:err-machine-readable-codes` for why codes must be snake_case strings, not integers.
