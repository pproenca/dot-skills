---
title: Use Slots for Markup, Arguments for Data
impact: HIGH
impactDescription: clarifies the component API and prevents html_safe misuse
tags: comp, views, components, viewcomponent, slots, api-design
---

## Use Slots for Markup, Arguments for Data

If a consumer needs to pass HTML or markup into a component, use a slot. If they pass a string, boolean, number, or object, use a constructor argument. This distinction prevents callers from building HTML strings and marking them `html_safe`, which is error-prone and bypasses Rails' XSS protection.

**Incorrect (passing markup as string arguments):**

```ruby
# app/components/card_component.rb
class CardComponent < ViewComponent::Base
  def initialize(title:, footer_html: nil)
    @title = title
    @footer_html = footer_html
  end
end
```

```erb
<%# Caller must build HTML strings — fragile and unsafe %>
<%= render(CardComponent.new(
  title: "Settings",
  footer_html: "<button class='btn btn-primary'>Save</button>".html_safe
)) %>
```

**Correct (slots for markup, arguments for data):**

```ruby
# app/components/card_component.rb
class CardComponent < ViewComponent::Base
  renders_one :header
  renders_one :footer
  renders_many :actions

  def initialize(title:, variant: :default)
    @title = title
    @variant = variant
  end

  def variant_class
    case @variant
    when :elevated then "card-elevated shadow-lg"
    when :outlined then "card-outlined border"
    else "card-default"
    end
  end
end
```

```erb
<%# app/components/card_component.html.erb %>
<div class="card <%= variant_class %>">
  <div class="card-header">
    <% if header? %>
      <%= header %>
    <% else %>
      <h3 class="card-title"><%= @title %></h3>
    <% end %>
  </div>
  <div class="card-body">
    <%= content %>
  </div>
  <% if footer? %>
    <div class="card-footer">
      <%= footer %>
    </div>
  <% end %>
</div>
```

```erb
<%# Usage — callers write real ERB, not HTML strings %>
<%= render(CardComponent.new(title: "User Settings", variant: :elevated)) do |card| %>
  <% card.with_footer do %>
    <%= link_to "Cancel", settings_path, class: "btn btn-secondary" %>
    <%= button_tag "Save Changes", class: "btn btn-primary",
                   data: { action: "submit" } %>
  <% end %>

  <div class="form-group">
    <%= label_tag :name, "Display Name" %>
    <%= text_field_tag :name, @user.name, class: "form-control" %>
  </div>
<% end %>
```

### renders_one vs renders_many

```ruby
class NavigationComponent < ViewComponent::Base
  renders_one :brand     # single slot: logo/brand area
  renders_many :items    # multi slot: nav items

  def initialize(sticky: false)
    @sticky = sticky
  end
end
```

```erb
<%= render(NavigationComponent.new(sticky: true)) do |nav| %>
  <% nav.with_brand do %>
    <%= image_tag "logo.svg", alt: "AppName", class: "h-8" %>
  <% end %>

  <% nav.with_item do %>
    <%= link_to "Dashboard", dashboard_path %>
  <% end %>
  <% nav.with_item do %>
    <%= link_to "Settings", settings_path %>
  <% end %>
<% end %>
```

Reference: [ViewComponent Slots](https://viewcomponent.org/guide/slots.html)
