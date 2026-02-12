---
title: Extract After Three Uses, Not Before
impact: CRITICAL
impactDescription: prevents premature abstractions by requiring 3+ proven uses before extraction
tags: decide, extraction, rule-of-three, abstraction
---

## Extract After Three Uses, Not Before

Premature extraction is the most common design system mistake in Rails. Creating a partial, component, or helper before a pattern has proven itself leads to wrong abstractions that are harder to change than inline duplication. Wait until you see the same pattern in 3+ places before extracting -- the third occurrence reveals which parts truly vary and which are stable.

**Incorrect (extracting after first use):**

```ruby
# app/components/button_component.rb
# Created after writing ONE button in ONE view
class ButtonComponent < ViewComponent::Base
  def initialize(label:, variant: :primary, size: :md, icon: nil, disabled: false)
    @label = label
    @variant = variant
    @size = size
    @icon = icon
    @disabled = disabled
  end
end
```

```erb
<%# app/components/button_component.html.erb %>
<button class="btn btn-<%= @variant %> btn-<%= @size %> <%= 'btn-disabled' if @disabled %>">
  <%= render_icon(@icon) if @icon %>
  <%= @label %>
</button>
```

**Correct (inline first, extract after three proven uses):**

```erb
<%# app/views/projects/show.html.erb — first use, inline is fine %>
<button class="rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white hover:bg-indigo-500">
  Save Project
</button>

<%# app/views/tasks/new.html.erb — second use, still inline %>
<button class="rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white hover:bg-indigo-500">
  Create Task
</button>

<%# app/views/comments/_form.html.erb — third use: NOW extract %>
<%# Pattern is proven. Extract to app/views/shared/_button.html.erb %>
<%= render "shared/button", label: "Post Comment" %>
```

**When NOT to use this pattern:** Design tokens and custom form builders are exceptions -- extract these upfront because they enforce consistency from day one. A `FormBuilder` that standardizes labels, error messages, and help text across every form is worth the early investment. Similarly, Tailwind `@theme` tokens for colors, spacing, and typography should be defined before any UI work begins.

Reference: [Sandi Metz — The Wrong Abstraction](https://sandimetz.com/blog/2016/1/20/the-wrong-abstraction)
