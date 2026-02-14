---
title: No Foreign Key Constraints
impact: HIGH
impactDescription: eliminates migration ordering issues and enables flexible data cleanup strategies
tags: db, foreign-keys, constraints, migrations
---

## No Foreign Key Constraints

37signals intentionally removes all foreign key constraints from their databases. Fizzy runs without a single `foreign_key: true` directive. Data integrity is enforced at the application level through model associations and validations. This gives maximum flexibility for data migrations, bulk deletions, cross-shard operations, and import/export workflows where constraint ordering would create circular dependency problems.

**Incorrect (foreign key constraints on all associations):**

```ruby
# db/migrate/20240115_create_cards.rb
class CreateCards < ActiveRecord::Migration[8.0]
  def change
    create_table :cards, id: :uuid do |t|
      t.references :board, null: false, foreign_key: true, type: :uuid
      t.references :creator, null: false, foreign_key: { to_table: :users }, type: :uuid
      t.references :assignee, foreign_key: { to_table: :users }, type: :uuid
      t.references :account, null: false, foreign_key: true, type: :uuid
      t.timestamps
    end
  end
end

# Problems:
# - Cannot delete an account without first deleting all cards, boards, users in exact order
# - Import/export must insert records in dependency order — circular references fail
# - Bulk data cleanup requires careful ordering of DELETE statements
# - Cross-database operations (sharded search) can't maintain FK integrity
```

**Correct (no foreign keys, application-level integrity):**

```ruby
# db/migrate/20240115_create_cards.rb
class CreateCards < ActiveRecord::Migration[8.0]
  def change
    create_table :cards, id: :uuid do |t|
      t.references :board, null: false, type: :uuid
      t.references :creator, null: false, type: :uuid
      t.references :assignee, type: :uuid
      t.references :account, null: false, type: :uuid
      t.timestamps
    end

    add_index :cards, [:account_id, :board_id]
  end
end

# app/models/card.rb — integrity at the application layer
class Card < ApplicationRecord
  belongs_to :board
  belongs_to :creator, class_name: "User"
  belongs_to :assignee, class_name: "User", optional: true
  belongs_to :account

  # dependent: :destroy on the parent handles cleanup
end

# app/models/board.rb
class Board < ApplicationRecord
  has_many :cards, dependent: :destroy
  # Deletion cascades through Rails, not the database
  # Order doesn't matter — ActiveRecord handles it
end
```

**Benefits:**
- Import/export can insert records in any order — no circular dependency issues
- Bulk deletions don't require topological sorting of foreign key chains
- Sharded search tables can reference records across databases
- Simpler migrations — no foreign key syntax to remember or maintain
- `NOT NULL` constraints still enforce required associations at the database level

**When NOT to use:**
- If your application has no import/export, no cross-database operations, and you want maximum database-level safety, foreign keys are fine. The 37signals choice is pragmatic for their specific workflow needs (500+GB exports between Fizzy instances).

Reference: [Basecamp Fizzy AGENTS.md](https://github.com/basecamp/fizzy/blob/main/AGENTS.md)
