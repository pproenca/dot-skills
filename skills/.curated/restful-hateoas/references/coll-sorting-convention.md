---
title: Support Sorting with a Standardized Sort Parameter
impact: MEDIUM-HIGH
impactDescription: standardized sorting convention reduces client implementation effort across all collection endpoints
tags: coll, sorting, query-params, jsonapi, collections
---

## Support Sorting with a Standardized Sort Parameter

Use a single `sort` query parameter with comma-separated field names and a `-` prefix for descending order (JSON:API convention). Splitting sort field and direction into separate parameters (`sort_by` + `sort_dir`) cannot express multi-column sorts and forces every client to learn your custom parameter names. The `-field` convention is widely adopted, self-documenting, and composable.

**Incorrect (custom sort parameters that cannot express multi-column ordering):**

```ruby
# app/controllers/api/v1/orders_controller.rb
class Api::V1::OrdersController < ApplicationController
  def index
    orders = current_user.orders

    sort_by = params.fetch(:sort_by, "created_at")
    sort_dir = params.fetch(:sort_dir, "desc")  # only one column — cannot sort by status then date
    orders = orders.order(sort_by => sort_dir)

    render json: { orders: orders.map { |o| OrderSerializer.new(o).as_json } }
  end
end
```

**Correct (single `sort` parameter with `-` prefix convention and multi-column support):**

```ruby
# app/controllers/api/v1/orders_controller.rb
class Api::V1::OrdersController < ApplicationController
  SORTABLE_FIELDS = %w[created_at total status customer_id].freeze

  def index
    orders = current_user.orders
    orders = apply_sort(orders)
    orders = paginate(orders)

    render json: {
      _links: {
        self: { href: request.original_url },
        sort: { href: "/api/v1/orders{?sort}", templated: true }  # advertise sortability
      },
      _embedded: { orders: orders.map { |o| OrderSerializer.new(o).as_json } }
    }
  end

  private

  def apply_sort(scope)
    sort_fields = params.fetch(:sort, "-created_at").split(",")

    sort_fields.each do |field|
      direction = field.start_with?("-") ? :desc : :asc  # "-" prefix means descending
      column = field.delete_prefix("-")
      next unless column.in?(SORTABLE_FIELDS)  # whitelist prevents SQL injection
      scope = scope.order(column => direction)
    end

    scope
  end
end
```

```http
GET /api/v1/orders?sort=-created_at,total
  → ORDER BY created_at DESC, total ASC

GET /api/v1/orders?sort=status,-total
  → ORDER BY status ASC, total DESC
```

**Benefits:**
- Multi-column sort in a single parameter: `?sort=-created_at,total` is concise and composable
- The `-` prefix convention is immediately readable without documentation
- Whitelisting `SORTABLE_FIELDS` prevents SQL injection and limits sort to indexed columns
- Templated `_links.sort` href tells clients sorting is available without out-of-band docs

**Reference:** JSON:API Sort specification. See also `restful-hateoas:coll-filtering-via-query-params` for composing sort with filters.
