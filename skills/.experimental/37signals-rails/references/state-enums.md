---
title: Enums for Categorical States
impact: HIGH
impactDescription: reduces 20+ lines of manual scope/predicate code to 1-line declaration
tags: state, enums, active-record, predicates
---

## Enums for Categorical States

Use Rails enums for categorical state that cycles through a fixed set of values and doesn't need per-transition history. Enums give you auto-generated scopes (`.active`, `.archived`), predicates (`.active?`, `.archived?`), and bang transitions (`.active!`) for free. They are safer than raw string columns because invalid values raise errors at assignment time.

**Incorrect (raw string column for categorical state):**

```ruby
# app/models/project.rb
class Project < ApplicationRecord
  # String column — no type safety, no generated methods
  scope :active, -> { where(status: "active") }
  scope :archived, -> { where(status: "archived") }
  scope :on_hold, -> { where(status: "on_hold") }

  def active?
    status == "active"  # typo "actve" silently passes
  end

  def archive!
    update!(status: "archived")  # nothing prevents "archvied"
  end

  validates :status, inclusion: { in: %w[active archived on_hold] }
  # Validation catches bad data but only at save time, not assignment
end
```

**Correct (Rails enum with integer-backed column):**

```ruby
# db/migrate/20240115_add_status_to_projects.rb
class AddStatusToProjects < ActiveRecord::Migration[7.1]
  def change
    add_column :projects, :status, :integer, default: 0, null: false
    add_index :projects, :status
  end
end

# app/models/project.rb
class Project < ApplicationRecord
  enum :status, {
    active:   0,
    on_hold:  1,
    archived: 2
  }, validate: true

  # All of these are auto-generated:
  # Scopes:     Project.active, Project.on_hold, Project.archived
  # Predicates: project.active?, project.on_hold?, project.archived?
  # Transitions: project.archived!
  # Raises ArgumentError on invalid: Project.new(status: "invalid")
end

# Usage is clean and discoverable
project = Project.active.first
project.archive!               # transitions and saves
project.archived?              # => true
Project.archived.count         # scoped query
```

**Alternative — explicit hash syntax for clarity:**

```ruby
class Message < ApplicationRecord
  enum :visibility, {
    everyone:   0,
    admins:     1,
    creator:    2
  }, suffix: true
  # Generates: everyone_visibility?, admins_visibility?
  # Useful when enum name collides with existing methods
end
```

**When NOT to use:**
- When you need a full audit trail of transitions (who changed state, when, and why) — use record-based state instead. Enums overwrite the previous value with no history.
- When state is binary (done/not done) — a nullable timestamp like `completed_at` is simpler and encodes timing.

Reference: [Basecamp Fizzy](https://github.com/basecamp/fizzy)
