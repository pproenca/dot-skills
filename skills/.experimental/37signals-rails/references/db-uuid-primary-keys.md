---
title: Use UUIDs as Primary Keys
impact: MEDIUM
impactDescription: prevents sequential ID enumeration, supports distributed systems
tags: db, uuid, primary-keys, security
---

## Use UUIDs as Primary Keys

Use UUIDs instead of sequential integers as primary keys. Sequential IDs leak information (total record count, creation order) and enable enumeration attacks where an attacker iterates through `/recordings/1`, `/recordings/2`, etc. 37signals uses base36-encoded UUIDv7 for shorter, URL-friendly identifiers.

**Incorrect (sequential integer primary keys exposing record structure):**

```ruby
# db/migrate/20240101000000_create_recordings.rb — default integer IDs
class CreateRecordings < ActiveRecord::Migration[8.0]
  def change
    create_table :recordings do |t|
      t.belongs_to :account, null: false
      t.string :title, null: false
      t.timestamps
    end
  end
end

# URLs expose sequential IDs: /recordings/1, /recordings/2, ...
# Attacker knows there are ~1000 recordings by checking /recordings/1000
```

**Correct (UUID primary keys):**

```ruby
# db/migrate/20240101000000_create_recordings.rb
class CreateRecordings < ActiveRecord::Migration[8.0]
  def change
    create_table :recordings, id: :uuid do |t|
      t.references :account, null: false, type: :uuid
      t.string :title, null: false
      t.timestamps
    end
  end
end

# config/initializers/generators.rb — UUIDs as default for all models
Rails.application.config.generators do |g|
  g.orm :active_record, primary_key_type: :uuid
end

# URLs are opaque: /recordings/a1b2c3d4-e5f6-7890-abcd-ef1234567890
# No enumeration possible, no record count leakage
```

**Alternative:** 37signals uses base36-encoded UUIDv7 (25-char strings) for shorter URLs. This requires custom ID generation via a `HasUuid` concern. For most applications, PostgreSQL's native `gen_random_uuid()` with `id: :uuid` is simpler and sufficient.

**When NOT to use:**
- Internal admin tools where ID enumeration is not a security concern and sequential IDs aid debugging.

Reference: [Basecamp Fizzy AGENTS.md](https://github.com/basecamp/fizzy/blob/main/AGENTS.md)
