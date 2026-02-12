---
title: Scope Helpers to Domain Modules, Not ApplicationHelper
impact: MEDIUM
impactDescription: prevents ApplicationHelper from becoming a dumping ground
tags: helper, organization, modules, conventions
---

## Scope Helpers to Domain Modules, Not ApplicationHelper

ApplicationHelper is the junk drawer of Rails apps. Without discipline, it grows to 300+ lines covering users, orders, products, and settings. Domain-scoped helpers are easier to find, test, and maintain. Rails auto-includes the helper module matching the current controller, so `UsersHelper` methods are available in all user views automatically.

**Incorrect (everything dumped into ApplicationHelper):**

```ruby
# app/helpers/application_helper.rb — 250 lines and growing
module ApplicationHelper
  def user_avatar(user, size: :md) ... end
  def role_badge(user) ... end
  def user_initials(user) ... end
  def order_status_badge(status) ... end
  def order_total(order) ... end
  def format_price(amount, currency: "USD") ... end
  def product_availability(product) ... end
  def product_image_url(product) ... end
  def setting_label(key) ... end
  def icon(name, **options) ... end
  def flash_class(type) ... end
  def page_title(title = nil) ... end
  def time_ago_in_words_short(time) ... end
  # ... 30 more methods
end
```

**Correct (domain helpers in resource-specific modules):**

```ruby
# app/helpers/application_helper.rb — only truly global helpers (< 30 lines)
module ApplicationHelper
  def icon(name, size: :md, **options) ... end
  def flash_class(type) ... end
  def page_title(title = nil)
    if title
      content_for(:page_title, title)
    else
      content_for?(:page_title) ? "#{content_for(:page_title)} | MyApp" : "MyApp"
    end
  end
end
```

```ruby
# app/helpers/users_helper.rb — user-specific presentation logic
module UsersHelper
  def user_avatar(user, size: :md) ... end
  def role_badge(user) ... end
  def user_initials(user) ... end
end
```

```ruby
# app/helpers/orders_helper.rb — order-specific presentation logic
module OrdersHelper
  def order_status_badge(status) ... end
  def order_total(order) ... end
  def format_price(amount, currency: "USD") ... end
end
```

```ruby
# app/helpers/products_helper.rb — product-specific presentation logic
module ProductsHelper
  def product_availability(product) ... end
  def product_image_url(product, variant: :thumb) ... end
end
```

Rails auto-includes helpers based on controller name. For `OrdersController`, `OrdersHelper` is available in all its views. If you need a helper from another module in a view, you have two options:

```ruby
# Option 1: Include explicitly in the controller
class AdminDashboardController < ApplicationController
  helper OrdersHelper
  helper UsersHelper
end

# Option 2: Include all helpers (Rails default, but consider opting out)
# config/application.rb
config.action_controller.include_all_helpers = true  # default
```

A good rule of thumb: if a helper method references a specific model (User, Order, Product), it belongs in that model's helper module. If it is truly model-agnostic (icon rendering, flash styling, page titles), it belongs in ApplicationHelper.

Reference: [Rails Action View Helpers](https://guides.rubyonrails.org/action_view_helpers.html)
