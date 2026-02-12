---
title: Prove Patterns in Production Before Extraction
impact: CRITICAL
impactDescription: prevents speculative design system work
tags: decide, extraction, production-first, pragmatism
---

## Prove Patterns in Production Before Extraction

Speculative design system work produces components nobody uses and abstractions that fit imagined requirements instead of real ones. Build the feature with inline HTML first. Ship it. Let the pattern survive 2-3 sprints of real usage and appear in multiple places. Only then extract it into a shared partial or component. Rails itself was extracted from Basecamp after proving concepts in production -- apply the same discipline to your design system.

**Incorrect (designing a modal library before any modal exists):**

```ruby
# app/components/modal_component.rb
# Sprint 1: Built before any feature needs a modal
class ModalComponent < ViewComponent::Base
  renders_one :header
  renders_one :body
  renders_one :footer

  def initialize(size: :md, dismissable: true, backdrop: :default, position: :center)
    @size = size
    @dismissable = dismissable
    @backdrop = backdrop
    @position = position
  end

  # 80 lines of logic for variants nobody has requested yet
end
```

**Correct (inline first, extract after proven production use):**

```erb
<%# Sprint 1: app/views/projects/show.html.erb — first modal, inline %>
<div data-controller="modal" class="relative z-50" role="dialog" aria-modal="true">
  <div class="fixed inset-0 bg-gray-500/75"></div>
  <div class="fixed inset-0 flex items-center justify-center p-4">
    <div class="w-full max-w-lg rounded-xl bg-white p-6 shadow-xl">
      <h3 class="text-lg font-semibold text-gray-900">Delete Project</h3>
      <p class="mt-2 text-sm text-gray-500">This action cannot be undone.</p>
      <div class="mt-4 flex justify-end gap-3">
        <button data-action="modal#close" class="rounded-md px-3 py-2 text-sm text-gray-700">Cancel</button>
        <%= button_to "Delete", project_path(@project), method: :delete,
              class: "rounded-md bg-red-600 px-3 py-2 text-sm text-white" %>
      </div>
    </div>
  </div>
</div>

<%# Sprint 3: Third modal appears in app/views/members/index.html.erb %>
<%# Pattern is proven — NOW extract to app/views/shared/_modal.html.erb %>
<%= render "shared/modal", title: "Remove Member" do %>
  <p class="text-sm text-gray-500">Remove <%= member.name %> from this team?</p>
<% end %>
```

**When NOT to use this pattern:** Infrastructure-level patterns like form builders, flash message rendering, and design tokens should be extracted upfront because they affect every page from the start. If you know from prior projects that you will need a certain pattern (e.g., you are rebuilding an existing app), you can extract early based on that proven history.

Reference: [DHH — The Rails Doctrine: Extract patterns from proven production work](https://rubyonrails.org/doctrine#extract)
