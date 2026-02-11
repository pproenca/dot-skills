---
title: Keep Controllers Thin by Delegating to Models and Services
impact: CRITICAL
impactDescription: reduces controller complexity by 60-80%
tags: ctrl, thin-controllers, service-objects, single-responsibility
---

## Keep Controllers Thin by Delegating to Models and Services

Controllers that contain business logic become untestable and unmaintainable. Delegate domain logic to models or service objects, keeping actions to 5-10 lines.

**Incorrect (business logic in controller):**

```ruby
class OrdersController < ApplicationController
  def create
    @order = Order.new(order_params)
    @order.total = calculate_total(order_params[:items])
    @order.tax = @order.total * tax_rate_for(@order.shipping_address)
    @order.discount = apply_promo_code(params[:promo_code], @order.total)
    @order.final_total = @order.total + @order.tax - @order.discount

    if @order.save
      OrderMailer.confirmation(@order).deliver_later
      InventoryService.reserve_items(@order.items)
      redirect_to @order
    else
      render :new, status: :unprocessable_entity
    end
  end
end
```

**Correct (delegates to service object):**

```ruby
class OrdersController < ApplicationController
  def create
    result = Orders::PlaceOrder.call(
      params: order_params,
      promo_code: params[:promo_code],
      user: current_user
    )

    if result.success?
      redirect_to result.order
    else
      @order = result.order
      render :new, status: :unprocessable_entity
    end
  end
end
```

**Benefits:**
- Controller actions stay under 10 lines
- Business logic is testable without HTTP context
- Service objects are reusable across controllers and jobs

Reference: [Rails Controller Patterns — AppSignal Blog](https://blog.appsignal.com/2021/04/14/ruby-on-rails-controller-patterns-and-anti-patterns.html)
