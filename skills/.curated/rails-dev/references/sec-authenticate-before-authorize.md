---
title: Authenticate Before Authorize on Every Request
impact: HIGH
impactDescription: "prevents unauthorized access (OWASP A01: Broken Access Control)"
tags: sec, authentication, authorization, before-action
---

## Authenticate Before Authorize on Every Request

Missing authentication on a single action exposes data. Use `before_action` in ApplicationController and skip explicitly for public endpoints.

**Incorrect (authentication per controller):**

```ruby
class OrdersController < ApplicationController
  def index
    @orders = current_user.orders  # current_user might be nil
  end

  def show
    @order = Order.find(params[:id])  # No auth check, anyone can view
  end
end
```

**Correct (default authentication with explicit skips):**

```ruby
class ApplicationController < ActionController::Base
  before_action :authenticate_user!
end

class OrdersController < ApplicationController
  before_action :authorize_order_access, only: [:show, :edit, :update]

  def show
    @order = current_user.orders.find(params[:id])
  end

  private

  def authorize_order_access
    @order = current_user.orders.find_by(id: params[:id])
    head :not_found unless @order
  end
end

class PublicPagesController < ApplicationController
  skip_before_action :authenticate_user!
end
```

Reference: [Securing Rails Applications — Rails Guides](https://guides.rubyonrails.org/security.html)
