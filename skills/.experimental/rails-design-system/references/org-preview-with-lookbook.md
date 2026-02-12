---
title: Add Lookbook Previews for Every Shared Component
impact: MEDIUM
impactDescription: prevents design drift through living documentation
tags: org, views, components, lookbook, previews, documentation
---

## Add Lookbook Previews for Every Shared Component

Every component in `app/components/` should have a preview class in `test/components/previews/`. Lookbook renders these previews in a browser UI, serving as living documentation that stays in sync with the actual implementation. Without previews, components become invisible to designers and other developers, leading to duplicate implementations and design drift.

**Incorrect (component without preview):**

```ruby
# app/components/alert_component.rb exists
# No preview — team cannot discover or visually verify it
# Result: another developer creates NotificationBannerComponent
# with nearly identical markup because they didn't know AlertComponent existed
```

**Correct (preview with multiple scenarios):**

```ruby
# test/components/previews/alert_component_preview.rb
class AlertComponentPreview < ViewComponent::Preview
  # @label Default Info Alert
  def default
    render(AlertComponent.new(
      type: :info,
      message: "Your profile has been updated successfully."
    ))
  end

  # @label Warning Alert
  def warning
    render(AlertComponent.new(
      type: :warning,
      message: "Your subscription expires in 3 days."
    ))
  end

  # @label Error Alert with Action
  def error_with_action
    render(AlertComponent.new(
      type: :error,
      message: "Payment failed. Please update your billing information.",
      dismissable: true
    )) do |alert|
      alert.with_action do
        helpers.link_to "Update billing", "/billing", class: "alert-link"
      end
    end
  end

  # @label Success Alert (Dismissable)
  def success_dismissable
    render(AlertComponent.new(
      type: :success,
      message: "Order #1234 has been shipped!",
      dismissable: true
    ))
  end
end
```

### Preview with Dynamic Parameters

Lookbook supports dynamic params for interactive exploration:

```ruby
# test/components/previews/button_component_preview.rb
class ButtonComponentPreview < ViewComponent::Preview
  # @param label text "Click me"
  # @param variant select { choices: [primary, secondary, danger, ghost] }
  # @param size select { choices: [sm, md, lg] }
  # @param disabled toggle
  def playground(label: "Click me", variant: :primary, size: :md, disabled: false)
    render(ButtonComponent.new(
      variant: variant.to_sym,
      size: size.to_sym,
      disabled: disabled
    )) { label }
  end
end
```

### Setup

```ruby
# Gemfile
group :development do
  gem "lookbook"
end
```

```ruby
# config/routes.rb (development only)
if Rails.env.development?
  mount Lookbook::Engine, at: "/lookbook"
end
```

Navigate to `http://localhost:3000/lookbook` to browse all component previews. Previews update in real-time as you modify component code.

### Minimum Preview Coverage

Every shared component should have at minimum:
1. **Default** scenario showing the most common usage
2. **Edge case** scenario (empty content, long text, missing optional data)
3. **Variant** scenarios for each visual variant (if applicable)

Reference: [Lookbook](https://lookbook.build/)
