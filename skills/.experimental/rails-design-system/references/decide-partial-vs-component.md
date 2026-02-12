---
title: Use Partials by Default, Components When Earned
impact: CRITICAL
impactDescription: prevents unnecessary framework overhead
tags: decide, partials, view-component, phlex, extraction
---

## Use Partials by Default, Components When Earned

ERB partials handle 80% of view reuse in Rails with zero additional dependencies. Reaching for ViewComponent or Phlex before a partial has proven insufficient adds framework overhead, extra files, and a steeper learning curve for the team. Upgrade to a component only when a partial can no longer serve the need.

**Incorrect (component for a simple, single-context card):**

```ruby
# app/components/project_card_component.rb
# Used in exactly ONE view — projects/index
class ProjectCardComponent < ViewComponent::Base
  def initialize(project:)
    @project = project
  end
end
```

```erb
<%# app/components/project_card_component.html.erb %>
<div class="rounded-lg border border-gray-200 p-4 shadow-sm">
  <h3 class="text-lg font-semibold text-gray-900"><%= @project.name %></h3>
  <p class="mt-1 text-sm text-gray-500"><%= truncate(@project.description, length: 120) %></p>
  <span class="mt-2 inline-block text-xs text-gray-400"><%= time_ago_in_words(@project.updated_at) %> ago</span>
</div>
```

**Correct (start with a partial, upgrade when complexity demands it):**

```erb
<%# app/views/projects/_card.html.erb — simple partial with explicit locals %>
<div class="rounded-lg border border-gray-200 p-4 shadow-sm">
  <h3 class="text-lg font-semibold text-gray-900"><%= project.name %></h3>
  <p class="mt-1 text-sm text-gray-500"><%= truncate(project.description, length: 120) %></p>
  <span class="mt-2 inline-block text-xs text-gray-400"><%= time_ago_in_words(project.updated_at) %> ago</span>
</div>

<%# Usage — clean collection rendering %>
<%= render partial: "projects/card", collection: @projects, as: :project %>
```

```ruby
# LATER: upgrade to component when you need slots for multiple content areas,
# isolated unit tests, or the card is used in 5+ unrelated views with variants.

# app/components/card_component.rb
class CardComponent < ViewComponent::Base
  renders_one :header
  renders_one :footer
  renders_one :actions

  def initialize(variant: :default)
    @variant = variant
  end
end
```

**When NOT to use this pattern:** If the element requires isolated unit testing (e.g., complex conditional rendering based on permissions), multiple named content slots, or is a cross-cutting pattern used in 3+ unrelated contexts (dashboards, emails, PDFs), skip the partial phase and go directly to a component. Form builders are also better served by a dedicated `ActionView::Helpers::FormBuilder` subclass than by partials.

Reference: [DHH on ViewComponent — Basecamp/Hey approach](https://discuss.rubyonrails.org/t/do-basecamp-hey-use-viewcomponents/83270/9)
