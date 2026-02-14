---
title: Concerns for Horizontal Code Sharing
impact: HIGH
impactDescription: reduces model file size from 800+ to 100-300 lines
tags: model, concerns, composition, modules
---

## Concerns for Horizontal Code Sharing

Extract shared functionality into 50-150 line concerns organized by domain responsibility. A model like `Card` includes `Assignable`, `Boostable`, `Eventable`, `Poppable`, `Searchable`, `Staged`, `Taggable` — each concern owns one slice of behavior. Concerns compose better than deep inheritance hierarchies because they can be mixed into any model independently, and each one remains small enough to read in a single sitting.

**Incorrect (bloated model with mixed responsibilities):**

```ruby
# app/models/card.rb — 800+ lines, everything inline
class Card < ApplicationRecord
  has_many :assignments
  has_many :assignees, through: :assignments, source: :person
  has_many :taggings
  has_many :tags, through: :taggings
  has_many :events

  scope :boosted, -> { where("boost_expires_at > ?", Time.current) }
  scope :tagged_with, ->(name) { joins(:tags).where(tags: { name: name }) }
  scope :assigned_to, ->(person) { joins(:assignments).where(assignments: { person: person }) }

  def boost!(duration: 1.hour)
    update!(boost_expires_at: Time.current + duration)
  end

  def boosted?
    boost_expires_at&.future?
  end

  def assign(person, role: :participant)
    assignments.create!(person: person, role: role)
  end

  def unassign(person)
    assignments.where(person: person).destroy_all
  end

  def tag(name)
    tags << Tag.find_or_create_by!(name: name) unless tagged_with?(name)
  end

  def tagged_with?(name)
    tags.exists?(name: name)
  end

  # ... 500 more lines of search, staging, event tracking, popover logic
end
```

**Correct (model composed of focused concerns):**

```ruby
# app/models/card.rb — clean, scannable
class Card < ApplicationRecord
  include Assignable
  include Boostable
  include Eventable
  include Searchable
  include Staged
  include Taggable
end

# app/models/concerns/boostable.rb — 30 lines, one responsibility
module Boostable
  extend ActiveSupport::Concern

  included do
    scope :boosted, -> { where("boost_expires_at > ?", Time.current) }
  end

  def boost!(duration: 1.hour)
    update!(boost_expires_at: Time.current + duration)
  end

  def boosted?
    boost_expires_at&.future?
  end
end

# app/models/concerns/assignable.rb — reusable across models
module Assignable
  extend ActiveSupport::Concern

  included do
    has_many :assignments, as: :assignable, dependent: :destroy
    has_many :assignees, through: :assignments, source: :person

    scope :assigned_to, ->(person) { joins(:assignments).where(assignments: { person: person }) }
  end

  def assign(person, role: :participant)
    assignments.create!(person: person, role: role)
  end

  def unassign(person)
    assignments.where(person: person).destroy_all
  end
end
```

**When NOT to use:**
- Do not create a concern for logic used in only one model. Inline it until a second model needs the same behavior — earn the abstraction.

Reference: [Vanilla Rails is Plenty](https://dev.37signals.com/vanilla-rails-is-plenty/)
