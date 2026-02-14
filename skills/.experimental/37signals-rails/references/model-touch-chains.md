---
title: Touch Chains for Cache Invalidation
impact: HIGH
impactDescription: automatic cascade cache busting without manual invalidation logic
tags: model, touch, cache-invalidation, associations
---

## Touch Chains for Cache Invalidation

Add `touch: true` to `belongs_to` associations so changes propagate up the object graph automatically. When a comment is updated, its card's `updated_at` changes, which in turn updates the bucket's `updated_at` — busting every fragment cache along the chain. No manual cache expiration logic, no `Rails.cache.delete` calls, no stale data. The `updated_at` timestamp becomes the cache key, and Rails' fragment caching handles the rest.

**Incorrect (manual cache invalidation scattered across the codebase):**

```ruby
# app/models/comment.rb
class Comment < ApplicationRecord
  belongs_to :card

  after_save :invalidate_caches
  after_destroy :invalidate_caches

  private

  def invalidate_caches
    Rails.cache.delete("card/#{card_id}/comments")
    Rails.cache.delete("card/#{card_id}/fragment")
    Rails.cache.delete("bucket/#{card.bucket_id}/cards")
    card.update_column(:updated_at, Time.current)
    card.bucket.update_column(:updated_at, Time.current)
  end
end

# Fragile: every new cache site requires a new delete call
# Easy to miss a cache key when adding features
```

**Correct (touch chains with automatic cascade invalidation):**

```ruby
# app/models/comment.rb
class Comment < ApplicationRecord
  belongs_to :card, touch: true
end

# app/models/card.rb
class Card < ApplicationRecord
  belongs_to :bucket, touch: true
  has_many :comments, dependent: :destroy
end

# app/models/bucket.rb
class Bucket < ApplicationRecord
  has_many :cards, dependent: :destroy
end

# app/views/buckets/_bucket.html.erb — cache key includes updated_at
<% cache bucket do %>
  <h2><%= bucket.name %></h2>
  <% bucket.cards.each do |card| %>
    <% cache card do %>
      <%= render card.comments %>
    <% end %>
  <% end %>
<% end %>

# Comment saved → card.updated_at touched → bucket.updated_at touched
# All fragment caches auto-expire. Zero manual invalidation.
```

**When NOT to use:**
- High-write associations where touching the parent on every child write would cause excessive database updates (e.g., a chatroom with thousands of messages per minute). In those cases, use time-based cache expiration instead.

Reference: [Basecamp Fizzy](https://github.com/basecamp/fizzy)
