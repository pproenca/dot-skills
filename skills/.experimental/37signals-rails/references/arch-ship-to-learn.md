---
title: Start Simple — Add Complexity Only After Validation
impact: MEDIUM
impactDescription: 3-5x faster initial delivery — validated features get refined, unused features get deleted
tags: arch, simplicity, iteration, yagni
---

## Start Simple — Add Complexity Only After Validation

Build the minimal working version first: one model, one controller, basic CRUD. Skip abstractions, optimizations, and edge cases until real usage proves they're needed. A feature that ships with 3 models and no concerns is better than one with 8 models, 4 concerns, and a service layer that never sees production. Add complexity in response to observed problems, not anticipated ones.

**Incorrect (over-engineered first implementation):**

```ruby
# First commit for a new "labels" feature — too much, too soon
# app/models/label.rb
class Label < ApplicationRecord
  include Eventable
  include Searchable
  include Exportable

  has_many :card_labels, dependent: :destroy
  has_many :cards, through: :card_labels
  has_many :label_groups, dependent: :destroy

  validates :name, uniqueness: { scope: :account_id }
  validates :color, format: { with: /\A#[0-9a-f]{6}\z/i }

  scope :popular, -> { left_joins(:card_labels).group(:id).order("COUNT(card_labels.id) DESC") }
  scope :unused, -> { left_joins(:card_labels).where(card_labels: { id: nil }) }

  normalizes :name, with: -> { _1.strip.downcase }

  after_create_commit :reindex_searchable
  after_update_commit :broadcast_changes

  def merge_into(other)
    transaction do
      card_labels.update_all(label_id: other.id)
      destroy!
    end
  end
end

# app/models/label_group.rb — grouping before anyone has 10 labels
class LabelGroup < ApplicationRecord
  has_many :labels
  acts_as_list
end

# app/controllers/labels/merges_controller.rb — merge before anyone asked
class Labels::MergesController < ApplicationController
  def create
    @label = Label.find(params[:label_id])
    @target = Label.find(params[:target_id])
    @label.merge_into(@target)
    redirect_to labels_path
  end
end
```

**Correct (minimal first implementation — add complexity when needed):**

```ruby
# First commit — minimal working feature
# app/models/label.rb
class Label < ApplicationRecord
  has_many :card_labels, dependent: :destroy
  has_many :cards, through: :card_labels

  validates :name, presence: true

  normalizes :name, with: -> { _1.strip }
end

# app/models/card_label.rb
class CardLabel < ApplicationRecord
  belongs_to :card
  belongs_to :label
end

# app/controllers/labels_controller.rb
class LabelsController < ApplicationController
  def index
    @labels = Current.account.labels
  end

  def create
    @label = Current.account.labels.create!(label_params)
    redirect_to labels_path
  end

  def destroy
    Current.account.labels.find(params[:id]).destroy!
    redirect_to labels_path
  end

  private

  def label_params
    params.expect(label: [:name, :color])
  end
end

# Later — add concerns, scopes, and features as real usage demands them:
# - Uniqueness validation after users report duplicates
# - Eventable concern after activity tracking is needed
# - Merge functionality after users accumulate enough labels to need it
# - Label groups after users have 20+ labels and need organization
```

**When NOT to use:**
- Security features should be complete from the start — never ship "minimal" authentication or authorization.
- Database constraints (`null: false`, unique indexes) should be set correctly upfront — they're hard to add later with existing data.

Reference: [Shape Up — 37signals](https://basecamp.com/shapeup)
