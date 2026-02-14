---
title: Database Constraints Over ActiveRecord Validations
impact: HIGH
impactDescription: enforces data integrity at the lowest level, prevents corruption from any code path
tags: state, constraints, database, integrity
---

## Database Constraints Over ActiveRecord Validations

Prefer database constraints (NOT NULL, UNIQUE, foreign keys, check constraints) over ActiveRecord validations for data integrity. AR validations only protect you when code goes through the model layer — raw SQL, bulk updates, background jobs with `update_column`, and race conditions all bypass them. Database constraints are the last line of defense and cannot be circumvented.

**Incorrect (relying solely on ActiveRecord validations):**

```ruby
# db/migrate/20240115_create_memberships.rb
class CreateMemberships < ActiveRecord::Migration[7.1]
  def change
    create_table :memberships do |t|
      t.references :user
      t.references :account
      t.string :role
      t.timestamps
    end
    # No database-level constraints — integrity depends entirely on AR
  end
end

# app/models/membership.rb
class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :account

  validates :user_id, presence: true
  validates :account_id, presence: true
  validates :role, presence: true, inclusion: { in: %w[admin member viewer] }
  validates :user_id, uniqueness: { scope: :account_id }

  # These validations are bypassed by:
  # Membership.insert_all([...])
  # membership.update_column(:role, "superadmin")
  # Raw SQL: ActiveRecord::Base.connection.execute("UPDATE memberships SET user_id = NULL")
  # Race condition: two threads both pass uniqueness check before either saves
end
```

**Correct (database constraints with minimal AR validations for UX):**

```ruby
# db/migrate/20240115_create_memberships.rb
class CreateMemberships < ActiveRecord::Migration[7.1]
  def change
    create_table :memberships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :account, null: false, foreign_key: true
      t.string :role, null: false, default: "member"
      t.timestamps
    end

    add_index :memberships, [:user_id, :account_id], unique: true
    add_check_constraint :memberships, "role IN ('admin', 'member', 'viewer')", name: "memberships_role_check"
  end
end

# app/models/membership.rb
class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :account

  enum :role, { admin: "admin", member: "member", viewer: "viewer" }, validate: true

  # AR validations only for user-facing error messages
  validates :user_id, uniqueness: { scope: :account_id, message: "is already a member of this account" }

  # Data integrity is guaranteed at the DB level:
  # - NULL user_id/account_id → DB rejects
  # - Invalid role → DB check constraint rejects
  # - Duplicate membership → DB unique index rejects
  # - Orphaned foreign key → DB FK constraint rejects
end
```

**Benefits:**
- Race conditions caught by unique indexes (AR validations have a TOCTOU gap)
- Bulk inserts, raw SQL, and `update_column` all remain safe
- Foreign keys prevent orphaned records when parent is deleted
- Check constraints enforce domain rules regardless of code path

**When NOT to use:**
- Complex cross-model business rules (e.g., "a user can only have 3 active projects") are better as AR validations or application-level checks — encoding these in SQL constraints is fragile and hard to maintain.

Reference: DHH's code review patterns
