---
title: Use Components Only When Partials Fall Short
impact: HIGH
impactDescription: prevents unnecessary framework adoption and file overhead
tags: comp, views, components, viewcomponent, partials, decision
---

## Use Components Only When Partials Fall Short

Upgrade from a partial to a ViewComponent or Phlex component when you hit one of four concrete thresholds. Components add file overhead (class + template + test + preview), so they must earn their existence. Most Rails views work perfectly with well-structured partials. Reserve components for genuinely complex UI elements.

**Incorrect (over-engineered component):**

```ruby
# app/components/alert_component.rb
# This is a 2-file component for what should be a 3-line partial
class AlertComponent < ViewComponent::Base
  def initialize(type:, message:)
    @type = type
    @message = message
  end
end
```

```erb
<%# app/components/alert_component.html.erb %>
<div class="alert alert-<%= @type %>" role="alert">
  <%= @message %>
</div>
```

A partial handles this with zero overhead:

```erb
<%# app/views/shared/_alert.html.erb %>
<%# locals: (type:, message:) %>
<div class="alert alert-<%= type %>" role="alert">
  <%= message %>
</div>
```

**Correct (component that earns its weight):**

```ruby
# app/components/modal_component.rb
class ModalComponent < ViewComponent::Base
  renders_one :header
  renders_one :body
  renders_one :footer

  def initialize(size: :md, dismissable: true)
    @size = size
    @dismissable = dismissable
  end

  def size_class
    case @size
    when :sm then "modal-sm"
    when :lg then "modal-lg"
    when :xl then "modal-xl"
    else "modal-md"
    end
  end
end
```

```erb
<%# Usage — multiple slots, conditional logic, reusable across the app %>
<%= render(ModalComponent.new(size: :lg)) do |modal| %>
  <% modal.with_header do %>
    <h2>Confirm Cancellation</h2>
  <% end %>
  <% modal.with_body do %>
    <p>This will cancel the subscription immediately. Unused time will not be refunded.</p>
  <% end %>
  <% modal.with_footer do %>
    <%= button_tag "Keep Subscription", class: "btn btn-secondary", data: { action: "modal#close" } %>
    <%= button_to "Cancel Subscription", cancel_subscription_path, method: :patch, class: "btn btn-danger" %>
  <% end %>
<% end %>
```

### Decision Checklist: When to Use a Component

| Criterion | Partial | Component |
|---|---|---|
| Simple markup with data locals | Yes | Overkill |
| Unit testing view logic in isolation | Awkward | Built-in |
| Multiple named content slots | `content_for` hacks | `renders_one` / `renders_many` |
| 3+ conditional rendering branches | Gets messy | Clean with Ruby methods |
| Preview/documentation system (Lookbook) | Not supported | First-class support |
| Used in 5+ places with strict API contract | Fragile | Enforced via initializer |

If a partial meets none of these criteria, keep it as a partial.

Reference: [ViewComponent Documentation](https://viewcomponent.org/)
