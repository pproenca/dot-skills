---
title: Compose Components, Never Inherit Them
impact: HIGH
impactDescription: prevents template resolution confusion and fragile hierarchies
tags: comp, views, components, viewcomponent, composition, inheritance
---

## Compose Components, Never Inherit Them

Having one component inherit from another leads to template resolution confusion and fragile hierarchies. ViewComponent resolves templates by class name, so a subclass either needs its own template (duplicating the parent's markup) or relies on the parent's template (which cannot be overridden cleanly). Use composition instead: render one component inside another.

**Incorrect (component inheritance):**

```ruby
# app/components/card_component.rb
class CardComponent < ViewComponent::Base
  def initialize(title:)
    @title = title
  end
end

# app/components/admin_card_component.rb
class AdminCardComponent < CardComponent
  def initialize(title:, user:)
    super(title: title)
    @user = user
  end

  # Which template is used? CardComponent's? AdminCardComponent's?
  # If AdminCardComponent has no template, it uses CardComponent's,
  # but then you can't add admin-specific markup.
  # If it has its own template, you're duplicating the card structure.
end
```

**Correct (composition):**

```ruby
# app/components/card_component.rb
class CardComponent < ViewComponent::Base
  renders_one :badge
  renders_one :header
  renders_one :footer

  def initialize(title:, variant: :default)
    @title = title
    @variant = variant
  end
end

# app/components/admin_badge_component.rb
class AdminBadgeComponent < ViewComponent::Base
  def initialize(user:)
    @user = user
  end

  def role_label
    @user.role.titleize
  end
end
```

```erb
<%# app/components/card_component.html.erb %>
<div class="card card-<%= @variant %>">
  <div class="card-header">
    <h3><%= @title %></h3>
    <% if badge? %>
      <%= badge %>
    <% end %>
  </div>
  <div class="card-body">
    <%= content %>
  </div>
  <% if footer? %>
    <div class="card-footer"><%= footer %></div>
  <% end %>
</div>
```

```erb
<%# Usage — compose AdminBadge into Card %>
<%= render(CardComponent.new(title: "User Management", variant: :elevated)) do |card| %>
  <% card.with_badge do %>
    <%= render(AdminBadgeComponent.new(user: current_user)) %>
  <% end %>

  <% card.with_footer do %>
    <%= link_to "Manage Users", admin_users_path, class: "btn btn-primary" %>
  <% end %>

  <p>Active users: <%= @active_count %></p>
<% end %>
```

### Why Composition Wins

| Concern | Inheritance | Composition |
|---|---|---|
| Template resolution | Ambiguous — which class owns the template? | Clear — each component owns its own template |
| Adding new variants | Requires new subclass per variant | Pass data or nest components |
| Testing | Must test parent and child separately | Each component tests in isolation |
| Refactoring parent | Breaks all children | No coupling — children are callers, not subclasses |

The only acceptable inheritance is from `ViewComponent::Base` itself (or `ApplicationComponent` as a thin base class for shared configuration like default options).

Reference: [ViewComponent Composition](https://viewcomponent.org/guide/templates.html)
