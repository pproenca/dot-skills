---
title: Use Positive Names for Methods and Scopes
impact: MEDIUM
impactDescription: eliminates double negatives, reads naturally in conditionals
tags: style, naming, positive, readability
---

## Use Positive Names for Methods and Scopes

Name methods, scopes, and boolean attributes in the positive form. Positive names read naturally in conditionals and eliminate double negatives that force readers to mentally invert logic. When you write `unless not_deleted?` or `if !inactive?`, the intent is buried under two layers of negation. Positive names like `visible?`, `active?`, and `published?` make conditionals read like plain English.

**Incorrect (negative naming forces mental gymnastics):**

```ruby
# app/models/comment.rb
class Comment < ApplicationRecord
  scope :not_deleted, -> { where(deleted_at: nil) }
  scope :not_spam, -> { where(flagged_as_spam: false) }

  def not_deleted?
    deleted_at.nil?
  end

  def not_hidden?
    !hidden
  end
end

# Double negatives in calling code
comments = Comment.not_deleted.not_spam
comments.each do |comment|
  next unless comment.not_hidden?   # "unless not hidden" — what?
  render_comment(comment)
end
```

**Correct (positive naming reads naturally):**

```ruby
# app/models/comment.rb
class Comment < ApplicationRecord
  scope :visible, -> { where(deleted_at: nil) }
  scope :authentic, -> { where(flagged_as_spam: false) }

  def visible?
    deleted_at.nil?
  end

  def shown?
    !hidden
  end
end

# Calling code reads like English
comments = Comment.visible.authentic
comments.each do |comment|
  next unless comment.shown?   # "unless shown" — clear
  render_comment(comment)
end
```

**Alternative — when the domain naturally uses negation:**

```ruby
# Some domain terms are inherently negative and well-understood.
# "disabled" is acceptable when the domain concept IS disability (e.g., feature flags).
class Feature < ApplicationRecord
  scope :enabled, -> { where(enabled: true) }
  scope :disabled, -> { where(enabled: false) }

  # Both are positive expressions of their respective states
end
```

**When NOT to use:**
- When the negative form is the established domain term (e.g., `unpublished` in a CMS where drafts are the primary workflow state). Forcing a positive name like `in_draft` may confuse domain experts who think in terms of "unpublished."

Reference: DHH's code review patterns
