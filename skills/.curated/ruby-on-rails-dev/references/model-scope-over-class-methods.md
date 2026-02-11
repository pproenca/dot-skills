---
title: Use Scopes Instead of Class Methods for Query Composition
impact: HIGH
impactDescription: enables chainable, composable query building
tags: model, scopes, class-methods, query-composition
---

## Use Scopes Instead of Class Methods for Query Composition

Class methods with conditional logic can return nil, breaking query chains. Scopes automatically wrap nil returns in `.all`, making them safe for conditional logic and always chainable.

**Incorrect (class method with conditional returns nil):**

```ruby
class Article < ApplicationRecord
  def self.published
    where(published: true) if publishing_enabled?  # Returns nil when condition is false
  end

  def self.featured
    where(featured: true)
  end
end

# Breaks when published returns nil
Article.published.featured  # NoMethodError: undefined method 'featured' for nil
```

**Correct (scope wraps nil in .all automatically):**

```ruby
class Article < ApplicationRecord
  scope :published, -> { where(published: true) if publishing_enabled? }  # Returns .all when nil
  scope :featured, -> { where(featured: true) }
  scope :recent, -> { order(created_at: :desc) }
end

# Always chainable — scope returns .all when block returns nil
Article.published.featured.recent
```

**Note:** Class methods that always return a relation (`def self.published; where(published: true); end`) are functionally identical to scopes. Prefer scopes when conditional logic is involved.

Reference: [Active Record Query Interface — Rails Guides](https://guides.rubyonrails.org/active_record_querying.html#scopes)
