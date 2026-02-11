---
title: Move Display Logic to Helpers or Presenters
impact: MEDIUM
impactDescription: eliminates scattered conditionals across templates
tags: view, helpers, presenters, separation-of-concerns
---

## Move Display Logic to Helpers or Presenters

Complex conditionals in ERB templates create unreadable views and resist testing. Extract display logic into helpers or presenter objects.

**Incorrect (complex logic in template):**

```erb
<div class="user-badge">
  <% if @user.admin? %>
    <span class="badge badge-admin">Admin</span>
  <% elsif @user.moderator? %>
    <span class="badge badge-mod">Moderator</span>
  <% elsif @user.premium? %>
    <span class="badge badge-premium">Premium</span>
  <% else %>
    <span class="badge badge-member">Member</span>
  <% end %>
  <span class="name"><%= @user.first_name %> <%= @user.last_name %></span>
  <span class="joined"><%= time_ago_in_words(@user.created_at) %> ago</span>
</div>
```

**Correct (helper method):**

```ruby
# app/helpers/users_helper.rb
module UsersHelper
  def user_badge(user)
    role = if user.admin? then "admin"
           elsif user.moderator? then "mod"
           elsif user.premium? then "premium"
           else "member"
           end

    tag.span(role.titleize, class: "badge badge-#{role}")
  end
end
```

```erb
<div class="user-badge">
  <%= user_badge(@user) %>
  <span class="name"><%= @user.first_name %> <%= @user.last_name %></span>
  <span class="joined"><%= time_ago_in_words(@user.created_at) %> ago</span>
</div>
```

Reference: [Action View Helpers — Rails Guides](https://guides.rubyonrails.org/action_view_helpers.html)
