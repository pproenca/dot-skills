---
title: Extract Logic to Helpers Not Partials
impact: MEDIUM
impactDescription: eliminates partials with minimal HTML, keeps view logic testable
tags: view, helpers, partials, extraction
---

## Extract Logic to Helpers Not Partials

When a partial contains mostly conditional logic and minimal HTML markup, extract it into a helper method or a model method instead. DHH: "Smells like there's no markup here -- this should be a method on the model." Partials carry rendering overhead and create file indirection for what is essentially a method call. Helpers take explicit parameters, never rely on instance variables, and are straightforward to unit test.

**Incorrect (logic-heavy partial with minimal markup):**

```ruby
# app/views/cards/_status_badge.html.erb — 90% logic, 10% markup
<% if card.archived? %>
  <span class="badge badge-muted">Archived</span>
<% elsif card.due_date&.past? %>
  <span class="badge badge-danger">Overdue</span>
<% elsif card.due_date&.today? %>
  <span class="badge badge-warning">Due Today</span>
<% elsif card.due_date && card.due_date < 3.days.from_now %>
  <span class="badge badge-info">Due Soon</span>
<% elsif card.completed? %>
  <span class="badge badge-success">Complete</span>
<% end %>

# app/views/cards/_card.html.erb — rendering a partial for a single <span>
<div class="card">
  <h3><%= card.title %></h3>
  <%= render "cards/status_badge", card: card %>
</div>
```

**Correct (helper method with explicit parameters):**

```ruby
# app/helpers/cards_helper.rb
module CardsHelper
  def card_status_badge(card)
    label, style = card_status(card)
    return unless label
    tag.span label, class: "badge badge-#{style}"
  end
  private
  def card_status(card)
    if card.archived?
      ["Archived", "muted"]
    elsif card.overdue?
      ["Overdue", "danger"]
    elsif card.due_today?
      ["Due Today", "warning"]
    elsif card.due_soon?
      ["Due Soon", "info"]
    elsif card.completed?
      ["Complete", "success"]
    end
  end
end

# app/models/card.rb
class Card < ApplicationRecord
  def overdue?
    due_date&.past? && !completed?
  end
  def due_today?
    due_date&.today?
  end
  def due_soon?
    due_date.present? && due_date.between?(Date.tomorrow, 3.days.from_now.to_date)
  end
end

# app/views/cards/_card.html.erb
<div class="card">
  <h3><%= card.title %></h3>
  <%= card_status_badge(card) %>
</div>

# test/helpers/cards_helper_test.rb
class CardsHelperTest < ActionView::TestCase
  test "returns overdue badge for past-due card" do
    card = cards(:overdue)
    assert_match "Overdue", card_status_badge(card)
    assert_match "badge-danger", card_status_badge(card)
  end
end
```

**When NOT to use:** If the partial contains substantial HTML structure (forms, multi-element layouts, nested components), keep it as a partial. The guideline targets partials that are essentially Ruby logic wrapped in a single tag.

Reference: DHH's code review patterns
