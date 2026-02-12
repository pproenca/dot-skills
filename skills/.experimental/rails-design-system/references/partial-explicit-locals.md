---
title: Always Pass Explicit Locals to Partials
impact: HIGH
impactDescription: prevents hidden dependencies and stale data bugs
tags: partial, views, partials, locals, strict-locals
---

## Always Pass Explicit Locals to Partials

Never rely on instance variables (`@user`) inside partials. Pass everything as local variables so the partial's contract is explicit and it can be reused across different controllers without hidden coupling. When a partial silently depends on an instance variable, renaming or removing that variable in one controller breaks rendering in another with no compile-time warning.

**Incorrect (partial relies on instance variable):**

```erb
<%# app/views/users/_user_card.html.erb %>
<div class="user-card">
  <h3><%= @user.display_name %></h3>
  <p><%= @user.email %></p>
</div>

<%# app/views/users/show.html.erb %>
<%= render "user_card" %>
```

**Correct (explicit local variables):**

```erb
<%# app/views/users/_user_card.html.erb %>
<%# locals: (user:) %>
<div class="user-card">
  <h3><%= user.display_name %></h3>
  <p><%= user.email %></p>
</div>

<%# app/views/users/show.html.erb %>
<%= render "user_card", user: @user %>
```

### Rails 7.1+ Strict Locals

The `locals:` strict comment enforces the contract at render time. If a caller omits a required local, Rails raises an `ActionView::Template::Error` immediately rather than failing with a confusing `nil` reference deep in the template.

```erb
<%# locals: (user:, show_actions: true) %>
<div class="user-card">
  <h3><%= user.display_name %></h3>
  <% if show_actions %>
    <%= link_to "Edit", edit_user_path(user), class: "btn btn-sm" %>
  <% end %>
</div>
```

Optional locals use Ruby's default argument syntax. This gives callers a clear API: required arguments must be provided, optional ones have sensible defaults.

Reference: [Rails Strict Locals](https://edgeguides.rubyonrails.org/action_view_overview.html#strict-locals)
