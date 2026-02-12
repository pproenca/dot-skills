---
title: Consider Phlex for Single-File Component Simplicity
impact: MEDIUM-HIGH
impactDescription: reduces file count by 50% per component
tags: comp, views, components, phlex, viewcomponent, comparison
---

## Consider Phlex for Single-File Component Simplicity

Phlex components are single Ruby files with no separate template. For teams that prefer Ruby over ERB, Phlex reduces the files-per-component tax from 2+ (class + template + optional sidecar assets) to 1. This makes small, frequently used components less painful to create and maintain, which encourages extraction.

**Incorrect (ViewComponent requires 2+ files per component):**

```ruby
# app/components/status_badge_component.rb
class StatusBadgeComponent < ViewComponent::Base
  COLORS = {
    active: "bg-green-100 text-green-800",
    pending: "bg-yellow-100 text-yellow-800",
    inactive: "bg-gray-100 text-gray-600",
    suspended: "bg-red-100 text-red-800"
  }.freeze

  def initialize(status:)
    @status = status.to_sym
  end

  def color_classes
    COLORS.fetch(@status, COLORS[:inactive])
  end

  def label
    @status.to_s.titleize
  end
end
```

```erb
<%# app/components/status_badge_component.html.erb %>
<span class="inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium <%= color_classes %>">
  <%= label %>
</span>
```

**Correct (Phlex collapses into a single file):**

```ruby
# app/components/status_badge.rb
class StatusBadge < Phlex::HTML
  COLORS = {
    active: "bg-green-100 text-green-800",
    pending: "bg-yellow-100 text-yellow-800",
    inactive: "bg-gray-100 text-gray-600",
    suspended: "bg-red-100 text-red-800"
  }.freeze

  def initialize(status:)
    @status = status.to_sym
  end

  def view_template
    span(
      class: "inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium #{color_classes}"
    ) { label_text }
  end

  private

  def color_classes
    COLORS.fetch(@status, COLORS[:inactive])
  end

  def label_text
    @status.to_s.titleize
  end
end
```

```erb
<%# Usage in ERB %>
<%= render StatusBadge.new(status: user.status) %>
```

### Phlex with Slots

```ruby
# app/components/card.rb
class Card < Phlex::HTML
  def initialize(title:, variant: :default)
    @title = title
    @variant = variant
  end

  def view_template(&block)
    div(class: "card card-#{@variant}") do
      div(class: "card-header") { h3 { @title } }
      div(class: "card-body", &block)
    end
  end
end
```

### When to Choose Each

| Criterion | ViewComponent | Phlex |
|---|---|---|
| Team prefers ERB templates | Better fit | Unfamiliar syntax |
| Many small UI components | File overhead adds up | Single-file wins |
| Need Lookbook previews | First-class support | Supported via adapter |
| Performance-sensitive rendering | Good | Faster (no template compilation) |
| Existing large ViewComponent library | Keep it | Migration cost |
| New project, Ruby-fluent team | Either works | Consider strongly |

Both are production-grade. Choose based on team preference and existing investment. Do not mix both in the same project unless migrating.

Reference: [Phlex Documentation](https://www.phlex.fun/)
