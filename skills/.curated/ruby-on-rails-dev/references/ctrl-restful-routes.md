---
title: Follow RESTful Routing Conventions
impact: CRITICAL
impactDescription: eliminates custom route proliferation
tags: ctrl, restful, routing, conventions, resources
---

## Follow RESTful Routing Conventions

Custom routes outside REST conventions create inconsistent APIs and force developers to learn bespoke URL patterns. Map actions to standard CRUD operations.

**Incorrect (custom non-RESTful routes):**

```ruby
# config/routes.rb
get "/orders/search", to: "orders#search"
post "/orders/mark_shipped", to: "orders#mark_shipped"
get "/orders/export_csv", to: "orders#export_csv"
post "/orders/bulk_delete", to: "orders#bulk_delete"
```

**Correct (RESTful resources with member/collection routes):**

```ruby
# config/routes.rb
resources :orders do
  collection do
    get :search
  end
  member do
    patch :ship
  end
end

resources :orders, only: [] do
  resource :export, only: :show, module: :orders
  resource :bulk_deletion, only: :create, module: :orders
end
```

**Benefits:**
- Predictable URL patterns for every resource
- Separate controllers for distinct responsibilities
- Standard HTTP verbs map to standard actions

Reference: [Rails Routing — Rails Guides](https://guides.rubyonrails.org/routing.html)
