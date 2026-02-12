---
title: Use Plural Nouns for Collection URIs
impact: CRITICAL
impactDescription: prevents URI inconsistency across endpoints, matches Rails conventions
tags: res, uri-design, plural, collections
---

## Use Plural Nouns for Collection URIs

Collections must use plural nouns (`/orders`, `/customers`) so that the collection URI and individual resource URI form a natural hierarchy: `GET /orders` lists all, `GET /orders/5` fetches one. Mixing singular and plural creates ambiguity about which URI returns a collection versus a single resource.

**Incorrect (inconsistent singular/plural URIs):**

```ruby
# config/routes.rb
Rails.application.routes.draw do
  resource :order       # /order  -- singular, no index route
  resources :customers  # /customers -- plural

  get "/user/:id", to: "users#show"          # singular noun
  get "/user/:id/setting", to: "settings#show"  # singular nested
end
```

**Correct (consistent plural collection URIs):**

```ruby
# config/routes.rb
Rails.application.routes.draw do
  resources :orders     # GET /orders, GET /orders/:id, POST /orders ...
  resources :customers  # GET /customers, GET /customers/:id ...

  resources :users, only: %i[show] do
    resources :settings, only: %i[index show update]  # /users/:id/settings
  end
end
```

**Benefits:**
- `GET /orders` always returns a collection; `GET /orders/:id` always returns one resource
- Rails `resources` generates plural routes by default -- fighting the convention costs effort
- Clients can predict URI patterns without consulting documentation

**When NOT to use:** Use `resource` (singular) only for true singletons scoped to the current user, such as `/profile` or `/session`, where there is exactly one resource per authenticated context.
