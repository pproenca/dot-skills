---
title: Use Problem Details (RFC 9457) for Error Responses
impact: MEDIUM
impactDescription: machine-readable errors enable client automation and eliminate ad-hoc error parsing
tags: err, rfc-9457, problem-details, error-handling
---

## Use Problem Details (RFC 9457) for Error Responses

Errors are resources too. Without a standard error format, every API invents its own shape (`{ error: "..." }`, `{ message: "..." }`, `{ errors: [...] }`) and every client must write custom parsing logic for each one. RFC 9457 (Problem Details for HTTP APIs) defines a machine-readable format with `type`, `title`, `status`, `detail`, and `instance` fields that clients can handle generically.

**Incorrect (ad-hoc error format -- every endpoint returns a different shape):**

```ruby
# app/controllers/api/v1/orders_controller.rb
class Api::V1::OrdersController < ApplicationController
  def show
    order = current_user.orders.find_by(id: params[:id])

    unless order
      render json: { error: "not found" }, status: :not_found  # no structure, no type URI
      return
    end

    render json: OrderSerializer.new(order).as_json
  end
end
```

**Correct (RFC 9457 Problem Details with consistent structure):**

```ruby
# app/controllers/concerns/problem_details.rb
module ProblemDetails
  extend ActiveSupport::Concern

  private

  def render_problem(type:, title:, status:, detail:, extras: {})
    render json: {
      type: "https://api.example.com/problems/#{type}",
      title: title,
      status: status,
      detail: detail,
      instance: request.original_url
    }.merge(extras), status: status, content_type: "application/problem+json"
  end
end

# app/controllers/api/v1/orders_controller.rb
class Api::V1::OrdersController < ApplicationController
  include ProblemDetails

  def show
    order = current_user.orders.find_by(id: params[:id])

    unless order
      render_problem(
        type: "order-not-found",
        title: "Order Not Found",
        status: 404,
        detail: "No order with id #{params[:id]} exists for this account"
      )
      return
    end

    render json: OrderSerializer.new(order).as_json
  end
end
```

**Benefits:**
- Clients parse every error with a single handler -- no endpoint-specific error shapes
- The `type` URI serves as both a machine-readable code and a link to human documentation
- The `instance` field identifies the exact request that failed, simplifying debugging and support tickets

**Reference:** RFC 9457 (Problem Details for HTTP APIs). See also `restful-hateoas:err-error-links` for adding recovery links to error responses.
