---
title: Use yield Blocks for Partial Customization Points
impact: MEDIUM-HIGH
impactDescription: enables flexible partials without component frameworks
tags: partial, views, yield, blocks, layout-partials
---

## Use yield Blocks for Partial Customization Points

Pass blocks to partials for customizable regions. This gives partial-level "slots" without needing ViewComponent or Phlex. When a partial needs to render caller-provided markup in specific places, `render layout:` with `yield` is the idiomatic Rails approach. This prevents creating multiple near-identical partial variants that differ only in one section.

**Incorrect (multiple partial variants):**

```erb
<%# app/views/shared/_card_with_footer.html.erb %>
<div class="card">
  <div class="card-body"><%= body %></div>
  <div class="card-footer">
    <%= link_to "Save", "#", class: "btn btn-primary" %>
  </div>
</div>

<%# app/views/shared/_card_with_delete_footer.html.erb %>
<div class="card">
  <div class="card-body"><%= body %></div>
  <div class="card-footer">
    <%= button_to "Delete", "#", method: :delete, class: "btn btn-danger" %>
  </div>
</div>
```

**Correct (yield block for customizable footer):**

```erb
<%# app/views/shared/_card.html.erb %>
<%# locals: (title:) %>
<div class="card">
  <div class="card-header">
    <h3 class="card-title"><%= title %></h3>
  </div>
  <div class="card-body">
    <%= yield %>
  </div>
</div>
```

```erb
<%# Usage in a view %>
<%= render layout: "shared/card", locals: { title: "User Profile" } do %>
  <p><%= @user.display_name %></p>
  <p><%= @user.email %></p>
<% end %>
```

### Multiple Yield Points with Content For

For partials that need more than one customizable region, combine `yield` with `content_for`:

```erb
<%# app/views/shared/_modal.html.erb %>
<%# locals: (title:, size: "md") %>
<div class="modal modal-<%= size %>">
  <div class="modal-header">
    <h2><%= title %></h2>
  </div>
  <div class="modal-body">
    <%= yield %>
  </div>
  <% if content_for?(:modal_footer) %>
    <div class="modal-footer">
      <%= yield :modal_footer %>
    </div>
  <% end %>
</div>
```

```erb
<%# Usage with both body and footer %>
<% content_for :modal_footer do %>
  <%= button_tag "Cancel", class: "btn btn-secondary", data: { action: "modal#close" } %>
  <%= button_tag "Confirm", class: "btn btn-primary", data: { action: "modal#confirm" } %>
<% end %>

<%= render layout: "shared/modal", locals: { title: "Confirm Deletion" } do %>
  <p>Are you sure you want to delete this item? This action cannot be undone.</p>
<% end %>
```

When yield blocks grow to need 3+ customizable regions, that is a signal to graduate to a ViewComponent with named slots.

Reference: [Rails Partial Layouts](https://guides.rubyonrails.org/layouts_and_rendering.html#partial-layouts)
