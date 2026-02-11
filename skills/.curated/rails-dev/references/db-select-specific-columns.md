---
title: Select Only Needed Columns
impact: CRITICAL
impactDescription: 2-5× less memory, 30-60% faster queries on wide tables
tags: db, select, pluck, memory, query-performance
---

## Select Only Needed Columns

Loading all columns wastes memory and bandwidth, especially on tables with text/blob columns. Use `select` or `pluck` to fetch only what you need.

**Incorrect (loads all 20+ columns per row):**

```ruby
users = User.where(active: true)
user_emails = users.map(&:email)  # Loads entire User objects into memory
```

**Correct (loads only needed column):**

```ruby
user_emails = User.where(active: true).pluck(:email)  # Returns array of strings
```

**Alternative (when you still need AR objects):**

```ruby
users = User.where(active: true).select(:id, :email, :name)
```

**When NOT to use this pattern:**
- When you need the full object for updates or serialization
- When table has fewer than 5 columns

Reference: [Active Record Query Interface — Rails Guides](https://guides.rubyonrails.org/active_record_querying.html#selecting-specific-fields)
