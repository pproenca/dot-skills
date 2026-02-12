---
title: Use Machine-Readable Error Codes Instead of Messages
impact: MEDIUM
impactDescription: eliminates fragile string matching, survives i18n translation and message rewording
tags: err, error-codes, i18n, machine-readable
---

## Use Machine-Readable Error Codes Instead of Messages

Human-readable error messages change: copywriters reword them, i18n translates them, typo fixes alter them. Any client that branches on `error.message.include?("already shipped")` breaks silently when the message becomes "has already been dispatched". Machine-readable codes (`snake_case` strings) are stable contracts -- messages are for display, codes are for logic.

**Incorrect (client branches on message strings -- breaks on any wording change):**

```ruby
# app/controllers/api/v1/orders_controller.rb
class Api::V1::OrdersController < ApplicationController
  def cancel
    order = current_user.orders.find(params[:id])

    unless order.cancellable?
      render json: {
        message: "This order has already been shipped and cannot be cancelled"
        # client does: if error["message"].include?("shipped") -- fragile
      }, status: :conflict
      return
    end

    order.cancel!
    head :no_content
  end
end
```

**Correct (stable code for logic, localizable message for display):**

```ruby
# app/controllers/api/v1/orders_controller.rb
class Api::V1::OrdersController < ApplicationController
  def cancel
    order = current_user.orders.find(params[:id])

    unless order.cancellable?
      render json: {
        code: "order_already_shipped",                                  # stable, machine-readable
        message: I18n.t("errors.order_already_shipped", id: order.id), # display-only, translatable
        _links: { self: { href: "/api/v1/orders/#{order.id}" } }
      }, status: :conflict
      return
    end

    order.cancel!
    head :no_content
  end
end

# config/locales/en.yml
# en:
#   errors:
#     order_already_shipped: "Order %{id} has already been shipped and cannot be cancelled"
```

**Benefits:**
- Client logic matches on `code` (`case error.code; when "order_already_shipped"`) -- immune to rewording
- Messages can be freely translated, rewritten, or A/B tested without breaking clients
- Error codes serve as stable documentation anchors and monitoring labels

**When NOT to use:** For validation errors, use the `code` field from `err-validation-errors` (ActiveRecord error types like `blank`, `taken`). This rule applies to business-logic errors where you define custom codes.

**Reference:** See also `restful-hateoas:err-problem-details` for wrapping codes in RFC 9457 Problem Details format.
