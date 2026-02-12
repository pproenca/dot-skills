---
title: Build Status Helpers That Return Styled Fragments
impact: MEDIUM
impactDescription: reduces status badge markup from 3-5 lines to 1 helper call
tags: helper, badges, status, patterns
---

## Build Status Helpers That Return Styled Fragments

When status-to-color mappings are scattered across views, a design change (e.g., "warning badges should be amber, not yellow") requires a find-and-replace across dozens of files. Centralizing these mappings in helpers means one change propagates everywhere. The helper owns the mapping from domain value to visual presentation.

**Incorrect (conditionals and style mappings duplicated across views):**

```erb
<%# app/views/orders/index.html.erb %>
<% @orders.each do |order| %>
  <% if order.status == "pending" %>
    <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-yellow-100 text-yellow-800">Pending</span>
  <% elsif order.status == "shipped" %>
    <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800">Shipped</span>
  <% elsif order.status == "delivered" %>
    <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">Delivered</span>
  <% elsif order.status == "cancelled" %>
    <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-red-100 text-red-800">Cancelled</span>
  <% end %>
<% end %>

<%# app/views/admin/orders/show.html.erb — same mapping, slightly different classes %>
```

**Correct (helper with a status map hash):**

```ruby
# app/helpers/orders_helper.rb
module OrdersHelper
  ORDER_STATUS_STYLES = {
    "pending"   => { bg: "bg-yellow-100", text: "text-yellow-800", label: "Pending" },
    "confirmed" => { bg: "bg-blue-100",   text: "text-blue-800",   label: "Confirmed" },
    "shipped"   => { bg: "bg-indigo-100", text: "text-indigo-800", label: "Shipped" },
    "delivered" => { bg: "bg-green-100",  text: "text-green-800",  label: "Delivered" },
    "cancelled" => { bg: "bg-red-100",    text: "text-red-800",    label: "Cancelled" },
    "refunded"  => { bg: "bg-gray-100",   text: "text-gray-800",   label: "Refunded" }
  }.freeze

  def order_status_badge(status)
    config = ORDER_STATUS_STYLES.fetch(status.to_s) do
      { bg: "bg-gray-100", text: "text-gray-800", label: status.to_s.titleize }
    end

    tag.span(
      config[:label],
      class: class_names(
        "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium",
        config[:bg],
        config[:text]
      )
    )
  end
end
```

```erb
<%# Usage — one call, always consistent %>
<%= order_status_badge(order.status) %>
```

Apply the same pattern for other domain-specific badges:

```ruby
# app/helpers/users_helper.rb
module UsersHelper
  ROLE_STYLES = {
    "admin"     => { bg: "bg-purple-100", text: "text-purple-800" },
    "editor"    => { bg: "bg-blue-100",   text: "text-blue-800" },
    "viewer"    => { bg: "bg-gray-100",   text: "text-gray-800" }
  }.freeze

  def role_badge(user)
    config = ROLE_STYLES.fetch(user.role, ROLE_STYLES["viewer"])

    tag.span(
      user.role.titleize,
      class: class_names(
        "inline-flex items-center px-2 py-0.5 rounded text-xs font-medium",
        config[:bg],
        config[:text]
      )
    )
  end
end
```

```ruby
# app/helpers/tasks_helper.rb
module TasksHelper
  def priority_indicator(task)
    color = case task.priority
            when "critical" then "text-red-600"
            when "high"     then "text-orange-500"
            when "medium"   then "text-yellow-500"
            when "low"      then "text-gray-400"
            end

    tag.span(class: "inline-flex items-center gap-1 text-sm") do
      icon("flag", size: :sm, class: color) +
        tag.span(task.priority.titleize)
    end
  end
end
```

Reference: [Rails Action View Helpers](https://guides.rubyonrails.org/action_view_helpers.html)
