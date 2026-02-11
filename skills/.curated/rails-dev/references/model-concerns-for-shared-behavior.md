---
title: Use Concerns for Shared Model Behavior
impact: MEDIUM-HIGH
impactDescription: eliminates code duplication across models
tags: model, concerns, modules, dry, reusability
---

## Use Concerns for Shared Model Behavior

Duplicating validations, scopes, and callbacks across models violates DRY. Concerns extract shared behavior into reusable modules.

**Incorrect (duplicated logic across models):**

```ruby
class Post < ApplicationRecord
  scope :published, -> { where("published_at <= ?", Time.current) }
  scope :draft, -> { where(published_at: nil) }

  def published?
    published_at.present? && published_at <= Time.current
  end
end

class Page < ApplicationRecord
  scope :published, -> { where("published_at <= ?", Time.current) }  # Duplicated
  scope :draft, -> { where(published_at: nil) }  # Duplicated

  def published?  # Duplicated
    published_at.present? && published_at <= Time.current
  end
end
```

**Correct (shared concern):**

```ruby
# app/models/concerns/publishable.rb
module Publishable
  extend ActiveSupport::Concern

  included do
    scope :published, -> { where("published_at <= ?", Time.current) }
    scope :draft, -> { where(published_at: nil) }
  end

  def published?
    published_at.present? && published_at <= Time.current
  end
end

# app/models/post.rb
class Post < ApplicationRecord
  include Publishable
end

# app/models/page.rb
class Page < ApplicationRecord
  include Publishable
end
```

Reference: [Active Support Core Extensions — Rails Guides](https://guides.rubyonrails.org/active_support_core_extensions.html)
