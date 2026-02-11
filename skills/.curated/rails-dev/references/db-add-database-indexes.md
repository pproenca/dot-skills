---
title: Add Database Indexes on Queried Columns
impact: CRITICAL
impactDescription: 10-100× faster lookups on large tables
tags: db, indexing, migrations, query-performance
---

## Add Database Indexes on Queried Columns

Every column used in WHERE, JOIN, or ORDER BY needs an index. `t.references` adds a foreign key index by default since Rails 5, but columns like `status` and `placed_at` used in queries get no automatic index.

**Incorrect (no indexes on frequently queried columns):**

```ruby
class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders do |t|
      t.references :user, foreign_key: true  # Index on user_id added by default
      t.string :status                        # No index — full table scan
      t.datetime :placed_at                   # No index — full table scan
      t.timestamps
    end
  end
end

# These queries hit full table scans on status and placed_at
Order.where(status: "pending", user_id: current_user.id)
Order.where(user_id: current_user.id).order(placed_at: :desc)
```

**Correct (indexed columns for common query patterns):**

```ruby
class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders do |t|
      t.references :user, foreign_key: true
      t.string :status
      t.datetime :placed_at
      t.timestamps
    end

    add_index :orders, :status
    add_index :orders, [:user_id, :status]   # Composite for combined lookups
    add_index :orders, :placed_at
  end
end
```

**Benefits:**
- Composite indexes cover multiple query patterns in a single index
- Place the most selective column first in composite indexes

Reference: [Active Record Migrations — Rails Guides](https://guides.rubyonrails.org/active_record_migrations.html)
