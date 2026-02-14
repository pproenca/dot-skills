---
title: Records as State Over Boolean Columns
impact: HIGH
impactDescription: 100% audit coverage — tracks who, when, and full history per state change
tags: state, records, booleans, audit-trail
---

## Records as State Over Boolean Columns

State transitions should create database records instead of flipping boolean flags. When a card is archived, create an `Archiving` record rather than setting `archived: true`. This gives you who performed the action, when it happened, and a full reversible history — booleans give you none of that.

**Incorrect (boolean column for state):**

```ruby
# db/migrate/20240115_add_archived_to_cards.rb
class AddArchivedToCards < ActiveRecord::Migration[7.1]
  def change
    add_column :cards, :archived, :boolean, default: false, null: false
    add_column :cards, :archived_by_id, :bigint
    add_column :cards, :archived_at, :datetime
  end
end

# app/models/card.rb
class Card < ApplicationRecord
  belongs_to :archived_by, class_name: "User", optional: true

  scope :archived, -> { where(archived: true) }
  scope :active, -> { where(archived: false) }

  def archive(by:)
    # Boolean flip — no history, no undo trail, no audit log
    update!(archived: true, archived_by: by, archived_at: Time.current)
  end

  def unarchive
    # Previous archive context is lost forever
    update!(archived: false, archived_by: nil, archived_at: nil)
  end
end
```

**Correct (record-based state with full history):**

```ruby
# db/migrate/20240115_create_archivings.rb
class CreateArchivings < ActiveRecord::Migration[7.1]
  def change
    create_table :archivings do |t|
      t.references :card, null: false, foreign_key: true
      t.references :creator, null: false, foreign_key: { to_table: :users }
      t.timestamps
    end
  end
end

# app/models/archiving.rb
class Archiving < ApplicationRecord
  belongs_to :card
  belongs_to :creator, class_name: "User"
end

# app/models/card.rb
class Card < ApplicationRecord
  has_many :archivings, dependent: :destroy

  scope :archived, -> { where(id: Archiving.select(:card_id)) }
  scope :active, -> { where.not(id: Archiving.select(:card_id)) }

  def archive(by:)
    archivings.create!(creator: by)
  end

  def unarchive
    archivings.destroy_all
  end

  def archived?
    archivings.exists?
  end
end

# Full audit trail: Card.find(42).archivings
# => [#<Archiving card_id: 42, creator_id: 7, created_at: "2024-01-15 09:30:00">]
```

**Benefits:**
- Every state change records who, when, and is individually reversible
- History is queryable: "show me everything archived last week"
- Multiple archives/unarchives are fully tracked
- No orphaned metadata when state reverts

**When NOT to use:**
- Simple on/off toggles with no business need for history (e.g., a user's `dark_mode` preference) are fine as booleans — not every flag needs an audit trail.
- For high-traffic read paths, add an index on the state table's foreign key (`add_index :archivings, :card_id`) and consider a denormalized boolean maintained by callbacks for query performance.

Reference: [Basecamp Fizzy](https://github.com/basecamp/fizzy)
