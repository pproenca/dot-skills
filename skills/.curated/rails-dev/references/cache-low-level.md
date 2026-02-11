---
title: Use Rails.cache.fetch for Computed Data
impact: HIGH
impactDescription: eliminates redundant computation on repeated requests
tags: cache, low-level, rails-cache, fetch, memoization
---

## Use Rails.cache.fetch for Computed Data

Recomputing expensive aggregations on every request wastes CPU and database resources. Use `Rails.cache.fetch` with an expiry to cache results.

**Incorrect (recomputes on every request):**

```ruby
class DashboardController < ApplicationController
  def show
    @total_revenue = Order.completed.sum(:total)  # Full table scan every time
    @top_products = Product.top_sellers(limit: 10)  # Expensive aggregation
    @user_growth = User.monthly_growth_rate  # Reads entire users table
  end
end
```

**Correct (cached with expiry):**

```ruby
class DashboardController < ApplicationController
  def show
    @total_revenue = Rails.cache.fetch("dashboard/revenue", expires_in: 15.minutes) do
      Order.completed.sum(:total)
    end

    @top_products = Rails.cache.fetch("dashboard/top_products", expires_in: 1.hour) do
      Product.top_sellers(limit: 10).to_a
    end

    @user_growth = Rails.cache.fetch("dashboard/user_growth", expires_in: 1.day) do
      User.monthly_growth_rate
    end
  end
end
```

**Benefits:**
- Automatic cache miss handling (computes and stores on first call)
- Configurable TTL per data freshness requirements
- Works with any cache store (Redis, Memcached, memory)

Reference: [Caching with Rails — Rails Guides](https://guides.rubyonrails.org/caching_with_rails.html#low-level-caching)
