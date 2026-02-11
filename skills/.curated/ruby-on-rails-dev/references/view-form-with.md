---
title: Use form_with Instead of form_tag or form_for
impact: MEDIUM
impactDescription: consistent form API with automatic CSRF and Turbo integration
tags: view, forms, form-with, helpers
---

## Use form_with Instead of form_tag or form_for

`form_tag` and `form_for` still work but are superseded by `form_with` since Rails 5.1. `form_with` unifies both APIs, includes CSRF protection, and integrates with Turbo by default.

**Incorrect (legacy form helpers):**

```erb
<%= form_for @order do |f| %>
  <%= f.text_field :shipping_address %>
  <%= f.submit %>
<% end %>

<%= form_tag search_path, method: :get do %>
  <%= text_field_tag :query %>
  <%= submit_tag "Search" %>
<% end %>
```

**Correct (unified form_with):**

```erb
<%= form_with model: @order do |f| %>
  <%= f.text_field :shipping_address %>
  <%= f.submit %>
<% end %>

<%= form_with url: search_path, method: :get do |f| %>
  <%= f.text_field :query %>
  <%= f.submit "Search" %>
<% end %>
```

Reference: [Form Helpers — Rails Guides](https://guides.rubyonrails.org/form_helpers.html)
