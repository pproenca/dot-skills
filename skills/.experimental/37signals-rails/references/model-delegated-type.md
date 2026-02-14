---
title: Use delegated_type for Polymorphism
impact: HIGH
impactDescription: eliminates NULL columns, enables single-table queries
tags: model, delegated-type, polymorphism, active-record
---

## Use delegated_type for Polymorphism

Rails' `delegated_type` provides polymorphism through delegation rather than single-table inheritance. The parent table holds shared attributes queried across all types, while each type gets its own table for type-specific data. This avoids the STI problem of nullable columns and wide tables, while keeping single-table queries fast on the parent — you can query all entries without joining type-specific tables.

**Incorrect (single-table inheritance with nullable columns):**

```ruby
# One table with columns for every type — most are NULL per row
# entries: type, subject, body, url, caption, image_data, video_url, duration, ...

class Entry < ApplicationRecord
end

class Entry::Message < Entry
  validates :subject, :body, presence: true
  # url, caption, image_data, video_url, duration are always NULL
end

class Entry::Comment < Entry
  validates :body, presence: true
  # subject, url, image_data, video_url, duration are always NULL
end

class Entry::Share < Entry
  validates :url, presence: true
  # subject, body, image_data, video_url are always NULL
end

# Table grows wider with every new type
# NULL columns waste space and confuse developers
```

**Correct (delegated_type with focused tables):**

```ruby
# db/migrate — shared columns in entries, type-specific in their own tables
create_table :entries do |t|
  t.string  :entryable_type, null: false
  t.bigint  :entryable_id,   null: false
  t.bigint  :account_id,     null: false
  t.bigint  :creator_id,     null: false
  t.timestamps
end

create_table :messages do |t|
  t.string :subject, null: false
  t.text   :body,    null: false
end

create_table :comments do |t|
  t.text :body, null: false
end

# app/models/entry.rb
class Entry < ApplicationRecord
  delegated_type :entryable, types: %w[Message Comment Share], dependent: :destroy

  belongs_to :account
  belongs_to :creator, class_name: "Person"
end

# app/models/message.rb
class Message < ApplicationRecord
  has_one :entry, as: :entryable, touch: true

  validates :subject, :body, presence: true
end

# Single-table queries on the parent — no joins needed
Entry.where(account: current_account).order(created_at: :desc)

# Type-specific access through delegation
entry.entryable  # => #<Message subject: "Hello">
entry.message?   # => true
```

**Benefits:**
- No NULL columns — each type table has only its own attributes
- Single-table queries on entries for feeds, timelines, activity logs
- Adding a new type is a new table and a new class, no migration on existing tables
- Database constraints (NOT NULL) can be enforced per type

Reference: [Vanilla Rails is Plenty](https://dev.37signals.com/vanilla-rails-is-plenty/)
