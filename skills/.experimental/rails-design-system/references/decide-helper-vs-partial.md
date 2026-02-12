---
title: Use Helpers for Fragments, Partials for Blocks
impact: CRITICAL
impactDescription: reduces file proliferation
tags: decide, helpers, partials, view-layer
---

## Use Helpers for Fragments, Partials for Blocks

Creating a partial file for a single HTML element adds filesystem noise and template-rendering overhead for no benefit. Helpers are purpose-built for small HTML fragments with logic -- badges, status dots, icons, formatted labels. Reserve partials for multi-element blocks with structural markup. The threshold is simple: if it fits in 3 lines of Ruby, it belongs in a helper.

**Incorrect (partial for a one-liner):**

```erb
<%# app/views/shared/_status_badge.html.erb %>
<span class="inline-flex items-center rounded-full px-2 py-1 text-xs font-medium
  <%= status == 'active' ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-600' %>">
  <%= status.titleize %>
</span>

<%# Usage — partial overhead for a single element %>
<%= render "shared/status_badge", status: user.status %>
```

**Correct (helper for a small fragment):**

```ruby
# app/helpers/status_helper.rb
module StatusHelper
  STATUS_STYLES = {
    "active"   => "bg-green-100 text-green-700",
    "inactive" => "bg-gray-100 text-gray-600",
    "pending"  => "bg-yellow-100 text-yellow-800",
    "archived" => "bg-red-100 text-red-700"
  }.freeze

  def status_badge(status)
    tag.span(
      status.titleize,
      class: "inline-flex items-center rounded-full px-2 py-1 text-xs font-medium #{STATUS_STYLES[status]}"
    )
  end
end
```

```erb
<%# Usage — clean, no file overhead %>
<td><%= status_badge(user.status) %></td>
```

**When NOT to use this pattern:** If the fragment grows beyond 3 lines of Ruby, contains nested HTML structure, or needs to yield a block of content, switch to a partial. Helpers that build complex multi-element HTML with `content_tag` nesting become unreadable fast. Also avoid helpers for elements that designers need to visually inspect -- partials are easier to locate and preview in Lookbook.

Reference: [Action View Helpers -- Rails Guides](https://guides.rubyonrails.org/action_view_helpers.html)
