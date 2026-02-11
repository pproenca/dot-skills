---
title: Extract Complex Queries into Query Objects
impact: MEDIUM-HIGH
impactDescription: reduces model complexity by 30-50%, enables isolated testing
tags: model, query-objects, poro, complex-queries
---

## Extract Complex Queries into Query Objects

Multi-join queries with conditional logic bloat models and resist testing. Query objects encapsulate complex queries in dedicated classes.

**Incorrect (complex query in model):**

```ruby
class Order < ApplicationRecord
  def self.dashboard_summary(user, start_date, end_date)
    joins(:items, :payments)
      .where(user_id: user.id)
      .where(placed_at: start_date..end_date)
      .where(payments: { status: "completed" })
      .group(:status)
      .select("orders.status, COUNT(*) as order_count, SUM(payments.amount) as total_revenue")
      .having("SUM(payments.amount) > ?", 0)
  end
end
```

**Correct (query object):**

```ruby
# app/queries/order_dashboard_query.rb
class OrderDashboardQuery
  def initialize(user:, start_date:, end_date:)
    @user = user
    @start_date = start_date
    @end_date = end_date
  end

  def call
    Order
      .joins(:items, :payments)
      .where(user_id: @user.id)
      .where(placed_at: @start_date..@end_date)
      .where(payments: { status: "completed" })
      .group(:status)
      .select("orders.status, COUNT(*) as order_count, SUM(payments.amount) as total_revenue")
      .having("SUM(payments.amount) > ?", 0)
  end
end

# Usage
OrderDashboardQuery.new(user: current_user, start_date: 30.days.ago, end_date: Time.current).call
```

**Benefits:**
- Testable with focused specs
- Reusable across controllers and reports
- Keeps model file under 200 lines
