---
title: Use Russian Doll Caching for Nested Collections
impact: HIGH
impactDescription: updates only changed fragments, 10-100× fewer re-renders
tags: cache, russian-doll, nested-caching, touch
---

## Use Russian Doll Caching for Nested Collections

When a child record updates, only its fragment re-renders. The outer fragment reuses all other cached children. Use `touch: true` on associations to propagate cache invalidation.

**Incorrect (flat caching, entire list re-renders on any change):**

```erb
<!-- Re-renders ALL comments when one changes -->
<% cache @post do %>
  <h1><%= @post.title %></h1>
  <% @post.comments.each do |comment| %>
    <div class="comment">
      <p><%= comment.body %></p>
      <span><%= comment.author.name %></span>
    </div>
  <% end %>
<% end %>
```

**Correct (nested cache fragments):**

```erb
<% cache @post do %>
  <h1><%= @post.title %></h1>
  <% @post.comments.each do |comment| %>
    <% cache comment do %>
      <div class="comment">
        <p><%= comment.body %></p>
        <span><%= comment.author.name %></span>
      </div>
    <% end %>
  <% end %>
<% end %>
```

```ruby
# app/models/comment.rb
class Comment < ApplicationRecord
  belongs_to :post, touch: true  # Invalidates post cache when comment changes
end
```

Reference: [Caching with Rails — Rails Guides](https://guides.rubyonrails.org/caching_with_rails.html#russian-doll-caching)
