---
title: Scope Queries to Current User for Authorization
impact: HIGH
impactDescription: "prevents IDOR attacks (OWASP A01: Broken Access Control)"
tags: sec, idor, authorization, scoping, query-scoping
---

## Scope Queries to Current User for Authorization

Using `find(params[:id])` without scoping allows users to access any record by guessing IDs. Scope queries through the current user's associations.

**Incorrect (unscoped find exposes all records):**

```ruby
class OrdersController < ApplicationController
  def show
    @order = Order.find(params[:id])  # Any user can view any order by ID
  end

  def update
    @order = Order.find(params[:id])  # Any user can update any order
    @order.update(order_params)
  end
end
```

**Correct (scoped through current user):**

```ruby
class OrdersController < ApplicationController
  def show
    @order = current_user.orders.find(params[:id])
  end

  def update
    @order = current_user.orders.find(params[:id])
    @order.update(order_params)
  end
end
```

Reference: [OWASP Rails Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Ruby_on_Rails_Cheat_Sheet.html)
