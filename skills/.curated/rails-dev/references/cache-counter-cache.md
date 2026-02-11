---
title: Use Counter Caches for Association Counts
impact: HIGH
impactDescription: O(1) count lookup vs COUNT(*) query
tags: cache, counter-cache, associations, counts
---

## Use Counter Caches for Association Counts

Calling `.count` on associations triggers a COUNT query every time. Counter caches store the count in a column that updates automatically on create/destroy.

**Incorrect (COUNT query on every render):**

```ruby
# app/models/post.rb
class Post < ApplicationRecord
  has_many :comments
end

# In view — fires COUNT(*) query per post
<% @posts.each do |post| %>
  <span><%= post.comments.count %> comments</span>
<% end %>
```

**Correct (counter cache column):**

```ruby
# Migration
class AddCommentsCountToPosts < ActiveRecord::Migration[7.1]
  def change
    add_column :posts, :comments_count, :integer, default: 0, null: false
  end
end

# app/models/comment.rb
class Comment < ApplicationRecord
  belongs_to :post, counter_cache: true
end

# In view — reads column, zero queries
<% @posts.each do |post| %>
  <span><%= post.comments_count %> comments</span>
<% end %>
```

**Important:** Backfill counters for existing data in a separate data migration or rake task. Without this, all existing records show `comments_count: 0`:

```ruby
# Run after deploying the schema migration
Post.find_each { |post| Post.reset_counters(post.id, :comments) }
```

Reference: [Active Record Associations — Rails Guides](https://guides.rubyonrails.org/association_basics.html#options-for-belongs-to-counter-cache)
