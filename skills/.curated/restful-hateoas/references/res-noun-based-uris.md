---
title: Use Noun-Based URIs, Not Verbs
impact: CRITICAL
impactDescription: eliminates custom route proliferation, lets HTTP methods convey action semantics
tags: res, uri-design, nouns, http-methods
---

## Use Noun-Based URIs, Not Verbs

URIs identify resources, not operations. Actions are expressed through HTTP methods (GET, POST, PUT, DELETE), not through verb segments in the path. Verb-based routes create an ever-growing list of custom endpoints that duplicate what standard CRUD already provides.

**Incorrect (verb-based routes duplicate HTTP method semantics):**

```ruby
# config/routes.rb
Rails.application.routes.draw do
  post "/orders/create", to: "orders#create"
  put "/orders/update/:id", to: "orders#update"
  post "/users/:id/activate", to: "users#activate"  # verb in URI
  post "/users/:id/deactivate", to: "users#deactivate"
  get "/reports/generate", to: "reports#generate"
end
```

**Correct (nouns as resources, HTTP methods as verbs):**

```ruby
# config/routes.rb
Rails.application.routes.draw do
  resources :orders, only: %i[index show create update destroy]

  resources :users, only: %i[show update] do
    resource :activation, only: %i[create destroy]  # sub-resource noun for state change
  end

  resources :reports, only: %i[create show]  # POST creates, GET retrieves
end
```

**Benefits:**
- Standard CRUD routes need no documentation -- the HTTP method is the verb
- Sub-resources like `/users/5/activation` model state transitions as nouns
- Clients and intermediaries can rely on method semantics for caching and retries

**Reference:** See also `rails-dev:ctrl-restful-routes` for controller-level conventions.
