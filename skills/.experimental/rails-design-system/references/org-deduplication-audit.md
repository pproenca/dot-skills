---
title: Audit Views Quarterly for Duplicated UI Patterns
impact: LOW-MEDIUM
impactDescription: reduces duplicated UI patterns by 60-80% per quarter
tags: org, audit, deduplication, maintenance
---

## Audit Views Quarterly for Duplicated UI Patterns

Design systems drift. A developer copies a card layout into a new view, tweaks the spacing, and now you have two slightly different cards. Multiply this across a team over months and you get 15 variations of the same pattern. Quarterly audits catch this drift before it compounds into an unmaintainable mess.

**Incorrect (duplicated patterns scattered across views, never audited):**

```erb
<%# app/views/users/index.html.erb — copy-pasted card %>
<div class="bg-white rounded-lg shadow-md p-6 mb-4">
  <h3 class="text-lg font-semibold text-gray-900"><%= user.name %></h3>
  <p class="text-gray-600 mt-2"><%= user.bio %></p>
</div>

<%# app/views/posts/index.html.erb — slightly different card %>
<div class="bg-white rounded-lg shadow-md p-6 mb-4">
  <h3 class="text-lg font-semibold text-gray-900"><%= post.title %></h3>
  <p class="text-gray-600 mt-2"><%= post.excerpt %></p>
</div>

<%# 4 more files with the same card pattern, each with minor variations %>
```

**Correct (periodic audit identifies and extracts repeated patterns):**

```erb
<%# Run a quarterly audit to find duplicated patterns, then extract: %>

<%# app/views/shared/_card.html.erb %>
<div class="bg-white rounded-lg shadow-md p-6 mb-4">
  <% if local_assigns[:title] %>
    <h3 class="text-lg font-semibold text-gray-900"><%= title %></h3>
  <% end %>
  <%= yield %>
</div>

<%# app/views/users/index.html.erb %>
<%= render "shared/card", title: user.name do %>
  <p class="text-gray-600 mt-2"><%= user.bio %></p>
<% end %>
```

**How to find duplicated patterns:**

```bash
# Find repeated Tailwind class combinations (likely copy-pasted components)
grep -rn "rounded-lg shadow-md p-" app/views/ | sort | head -20

# Find repeated structural patterns (card-like wrappers)
grep -rn "class=.*bg-white.*rounded.*shadow" app/views/ --include="*.erb" | wc -l

# Find duplicated button class strings
grep -rn "bg-blue-600 text-white" app/views/ --include="*.erb"

# Find inline styles (should be zero in a design system)
grep -rn 'style="' app/views/ --include="*.erb" | wc -l

# Find hardcoded color values outside of token files
grep -rn "text-\[#" app/views/ --include="*.erb"
grep -rn "bg-\[#" app/views/ --include="*.erb"

# Count how many files use each shared partial vs inline markup
echo "=== Shared partial usage ==="
for partial in app/views/shared/_*.html.erb; do
  name=$(basename "$partial" | sed 's/^_//' | sed 's/\.html\.erb$//')
  count=$(grep -rn "render.*shared/${name}\|render.*\"shared/${name}\"" app/views/ --include="*.erb" | wc -l)
  echo "  $name: $count usages"
done
```

**Extraction threshold:** If a pattern appears in 3 or more files, extract it.

```ruby
# Before audit: same card pattern in 4 files
# app/views/users/index.html.erb
# app/views/posts/index.html.erb
# app/views/admin/dashboard.html.erb
# app/views/search/results.html.erb

# All contain:
<div class="bg-white rounded-lg shadow-md p-6 mb-4">
  <h3 class="text-lg font-semibold text-gray-900"><%= item.title %></h3>
  <p class="text-gray-600 mt-2"><%= item.description %></p>
</div>
```

```erb
<%# After audit: extracted to a shared partial %>
<%# app/views/shared/_card.html.erb %>
<div class="bg-white rounded-lg shadow-md p-6 mb-4">
  <% if local_assigns[:title] %>
    <h3 class="text-lg font-semibold text-gray-900"><%= title %></h3>
  <% end %>
  <%= yield %>
</div>

<%# Usage %>
<%= render "shared/card", title: item.title do %>
  <p class="text-gray-600 mt-2"><%= item.description %></p>
<% end %>
```

**Track metrics over time:**

| Metric | Q1 | Q2 | Q3 | Target |
|--------|----|----|-----|--------|
| Shared partials in use | 4 | 7 | 10 | Growing |
| Files with inline styles | 12 | 5 | 0 | Zero |
| Duplicated button patterns | 8 | 3 | 1 | Under 3 |
| Hardcoded color values | 15 | 6 | 2 | Under 5 |

Add the audit to your team's quarterly maintenance checklist alongside dependency updates and performance reviews.

Reference: [Rails Layouts and Rendering](https://guides.rubyonrails.org/layouts_and_rendering.html)
