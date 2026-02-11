---
title: Handle Errors with rescue_from in Controllers
impact: HIGH
impactDescription: eliminates scattered begin/rescue blocks across actions
tags: ctrl, error-handling, rescue-from, exceptions
---

## Handle Errors with rescue_from in Controllers

Scattering `begin/rescue` blocks in individual actions creates inconsistent error responses. Use `rescue_from` to handle errors uniformly.

**Incorrect (rescue in every action):**

```ruby
class OrdersController < ApplicationController
  def show
    @order = Order.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to orders_path, alert: "Order not found"
  end

  def update
    @order = Order.find(params[:id])
    @order.update!(order_params)
  rescue ActiveRecord::RecordNotFound
    redirect_to orders_path, alert: "Order not found"
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:alert] = e.message
    render :edit, status: :unprocessable_entity
  end
end
```

**Correct (centralized error handling):**

```ruby
class OrdersController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid

  def show
    @order = Order.find(params[:id])
  end

  def update
    @order = Order.find(params[:id])
    @order.update!(order_params)
    redirect_to @order
  end

  private

  def record_not_found
    redirect_to orders_path, alert: "Order not found"
  end

  def record_invalid(exception)
    flash.now[:alert] = exception.message
    render :edit, status: :unprocessable_entity
  end
end
```

Reference: [Action Controller Overview — Rails Guides](https://guides.rubyonrails.org/action_controller_overview.html#rescue-from)
