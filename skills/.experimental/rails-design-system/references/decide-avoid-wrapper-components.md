---
title: Avoid Wrapper Components That Add No Logic
impact: HIGH
impactDescription: reduces indirection and codebase size
tags: decide, components, indirection, tailwind
---

## Avoid Wrapper Components That Add No Logic

A component that only wraps a CSS class around its content adds a file, a class definition, and a layer of indirection for zero functional value. With Tailwind, the utility classes already serve as a declarative API for styling. Creating `CardComponent`, `ContainerComponent`, or `SectionComponent` just to apply CSS classes trades one line of HTML for an entire Ruby class and template pair.

**Incorrect (wrapper component that only adds CSS classes):**

```ruby
# app/components/card_component.rb — adds nothing but indirection
class CardComponent < ViewComponent::Base
  def initialize(padding: 4)
    @padding = padding
  end

  def call
    content_tag :div, content, class: "rounded-lg border border-gray-200 p-#{@padding} shadow-sm"
  end
end
```

```erb
<%# Usage — now you need to look up CardComponent to understand what it renders %>
<%= render CardComponent.new(padding: 6) do %>
  <h3 class="text-lg font-semibold"><%= @project.name %></h3>
  <p class="text-sm text-gray-500"><%= @project.description %></p>
<% end %>
```

**Correct (Tailwind classes directly in ERB):**

```erb
<%# app/views/projects/_card.html.erb — clear, no indirection %>
<div class="rounded-lg border border-gray-200 p-6 shadow-sm">
  <h3 class="text-lg font-semibold text-gray-900"><%= project.name %></h3>
  <p class="mt-1 text-sm text-gray-500"><%= truncate(project.description, length: 120) %></p>
  <div class="mt-3 flex items-center gap-2">
    <%= status_badge(project.status) %>
    <span class="text-xs text-gray-400"><%= time_ago_in_words(project.updated_at) %> ago</span>
  </div>
</div>
```

**When NOT to use this pattern:** Wrap in a component when it adds real logic beyond CSS -- conditional rendering based on user permissions, data transformation, multiple named slots for different content areas, or Stimulus controller wiring. For example, a `NotificationComponent` that selects icon, color scheme, and dismiss behavior based on a severity level earns its abstraction.

Reference: [ViewComponent Documentation — When to use components](https://viewcomponent.org/)
