---
title: Select Only Needed Columns
impact: HIGH
impactDescription: reduces memory allocation and query transfer time by 50-90%
tags: io, select, pluck, activerecord, memory
---

## Select Only Needed Columns

Loading full ActiveRecord objects when you only need one or two columns wastes memory on attribute storage, type casting, and object overhead. Use `.select` for partial models or `.pluck` when you only need raw values without ActiveRecord instances.

**Incorrect (loads every column into full ActiveRecord objects):**

```ruby
class NewsletterService
  def subscriber_emails
    users = User.where(subscribed: true)  # SELECT * FROM users — loads all columns
    users.map(&:email)                    # instantiates a full User object per row
  end

  def active_user_ids
    User.where(active: true).map(&:id)  # loads all columns just to extract ids
  end
end
```

**Correct (loads only the columns needed):**

```ruby
class NewsletterService
  def subscriber_emails
    User.where(subscribed: true).pluck(:email)  # SELECT email FROM users — returns plain strings
  end

  def active_user_ids
    User.where(active: true).ids  # SELECT id FROM users — optimized id-only query
  end
end
```
