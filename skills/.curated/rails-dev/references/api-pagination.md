---
title: Always Paginate Collection Endpoints
impact: MEDIUM
impactDescription: prevents response bloat and client timeouts
tags: api, pagination, collections, performance
---

## Always Paginate Collection Endpoints

Returning unbounded collections causes memory spikes, slow responses, and client crashes on large datasets. Always paginate with cursor or offset-based pagination.

**Incorrect (returns all records):**

```ruby
class Api::OrdersController < ApplicationController
  def index
    orders = current_user.orders  # Returns ALL orders
    render json: orders
  end
end
```

**Correct (paginated with metadata):**

```ruby
class Api::OrdersController < ApplicationController
  def index
    orders = current_user.orders
      .order(created_at: :desc)
      .page(params[:page])
      .per(params[:per_page] || 25)

    render json: {
      orders: orders.map { |o| OrderSerializer.new(o).as_json },
      meta: {
        current_page: orders.current_page,
        total_pages: orders.total_pages,
        total_count: orders.total_count
      }
    }
  end
end
```

**Note:** Use cursor-based pagination for real-time feeds to avoid page drift:

```ruby
orders = current_user.orders.where("id < ?", params[:cursor]).limit(25)
```

Reference: [Kaminari Gem](https://github.com/kaminari/kaminari)
