---
title: Scope Your Design System to Actual Needs
impact: HIGH
impactDescription: prevents over-engineering the system itself
tags: decide, scope, pragmatism, architecture
---

## Scope Your Design System to Actual Needs

A Rails design system is not a React component library. Over-scoping is the second most common failure mode after premature extraction. You need a small, focused toolkit: design tokens, a custom form builder, 5-10 shared partials or components, a handful of Stimulus controllers, and naming conventions. You do not need Storybook, a component API layer, a token management pipeline, or a separate design system application.

**Incorrect (over-engineered design system scope):**

```ruby
# 50+ components built before any feature uses them
# app/components/
#   accordion_component.rb
#   alert_component.rb
#   avatar_component.rb
#   badge_component.rb
#   breadcrumb_component.rb
#   button_component.rb       (3 variants nobody requested)
#   card_component.rb
#   carousel_component.rb     (no carousel in any design)
#   checkbox_component.rb
#   ... 40 more files

# config/design_system.yml — token management pipeline
design_tokens:
  pipeline: figma -> style-dictionary -> tailwind -> rails
  sync_interval: daily
  approval_workflow: true

# Gemfile — heavyweight dependencies for "just in case"
gem "lookbook"
gem "view_component"
gem "view_component-storybook"   # Storybook bridge
gem "primer_view_components"      # GitHub's component library
```

**Correct (just enough for a production Rails app):**

```css
/* app/assets/stylesheets/application.tailwind.css */
/* Design tokens via Tailwind @theme — single source of truth */
@theme {
  --color-primary-500: #4f46e5;
  --color-primary-600: #4338ca;
  --color-danger-500: #ef4444;
  --color-success-500: #22c55e;
  --radius-default: 0.5rem;
  --radius-full: 9999px;
}
```

```ruby
# app/form_builders/application_form_builder.rb
# Custom FormBuilder — consistent labels, errors, help text everywhere
class ApplicationFormBuilder < ActionView::Helpers::FormBuilder
  def text_field(method, options = {})
    field_wrapper(method, options) { super(method, options.merge(class: field_classes(method))) }
  end

  private

  def field_wrapper(method, options, &block)
    @template.tag.div(class: "mb-4") do
      label(method, class: "block text-sm font-medium text-gray-700") +
        yield +
        error_message(method)
    end
  end
end
```

```erb
<%# 6-8 proven partials — each extracted after 3+ uses %>
<%# app/views/shared/_modal.html.erb %>
<%# app/views/shared/_flash.html.erb %>
<%# app/views/shared/_empty_state.html.erb %>
<%# app/views/shared/_pagination.html.erb %>
<%# app/views/shared/_dropdown_menu.html.erb %>
<%# app/views/shared/_page_header.html.erb %>
```

**When NOT to use this pattern:** Large organizations with multiple Rails applications sharing a UI (e.g., a main app, an admin panel, and a marketing site) may benefit from a shared component gem or engine. In that case, the overhead of a more structured design system is justified by cross-application consistency. Even then, extract from one proven app first rather than designing in the abstract.

Reference: [DHH -- The Rails Doctrine](https://rubyonrails.org/doctrine)
