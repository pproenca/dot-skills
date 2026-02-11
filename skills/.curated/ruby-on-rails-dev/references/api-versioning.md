---
title: Version APIs from Day One
impact: MEDIUM
impactDescription: prevents breaking changes for existing clients
tags: api, versioning, backwards-compatibility, routing
---

## Version APIs from Day One

Unversioned APIs force all clients to update simultaneously on breaking changes. Namespace APIs with version prefixes from the start.

**Incorrect (unversioned API):**

```ruby
# config/routes.rb
namespace :api do
  resources :orders
  resources :users
end
```

**Correct (versioned from day one):**

```ruby
# config/routes.rb
namespace :api do
  namespace :v1 do
    resources :orders
    resources :users
  end
end

# app/controllers/api/v1/orders_controller.rb
class Api::V1::OrdersController < Api::BaseController
  def index
    orders = current_user.orders.page(params[:page])
    render json: orders.map { |o| OrderSerializer.new(o).as_json }
  end
end
```

**Benefits:**
- Old clients continue working on v1
- New features ship in v2 without breaking v1
- Deprecation timeline per version

Reference: [Rails Routing — Rails Guides](https://guides.rubyonrails.org/routing.html#controller-namespaces-and-routing)
