---
title: Write Reversible Zero-Downtime Migrations
impact: HIGH
impactDescription: prevents production downtime on deploys
tags: db, migrations, zero-downtime, safety
---

## Write Reversible Zero-Downtime Migrations

Irreversible migrations block rollbacks. Long-running migrations lock tables and cause downtime. Use reversible patterns and avoid locking operations.

**Incorrect (irreversible and locks table):**

```ruby
class UpdateUsersTable < ActiveRecord::Migration[7.1]
  def change
    remove_column :users, :legacy_role  # Irreversible without type info
    rename_column :users, :name, :full_name  # Locks table during rename
  end
end
```

**Correct (reversible with safety):**

```ruby
class UpdateUsersTable < ActiveRecord::Migration[7.1]
  def change
    remove_column :users, :legacy_role, :string, default: "member"  # Reversible

    safety_assured do  # strong_migrations gem
      rename_column :users, :name, :full_name
    end
  end
end
```

**Benefits:**
- Including column type makes `remove_column` reversible
- `strong_migrations` gem catches unsafe operations before deploy

Reference: [Active Record Migrations — Rails Guides](https://guides.rubyonrails.org/active_record_migrations.html#changing-existing-migrations)
