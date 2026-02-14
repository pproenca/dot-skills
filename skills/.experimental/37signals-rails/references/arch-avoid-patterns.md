---
title: Deliberately Avoided Patterns and Gems
impact: CRITICAL
impactDescription: eliminates 10-15 unnecessary dependencies and architectural layers
tags: arch, anti-patterns, gems, simplicity
---

## Deliberately Avoided Patterns and Gems

37signals explicitly avoids these patterns and gems across Basecamp, HEY, and Fizzy. This is not accidental omission — each was evaluated and rejected in favor of vanilla Rails. When an agent or developer reaches for any of these, stop and use the built-in alternative instead.

**Incorrect (reaching for common gems and patterns):**

```ruby
# Gemfile — the "standard" Rails stack that 37signals rejects
gem "devise"              # authentication
gem "pundit"              # authorization
gem "sidekiq"             # background jobs
gem "redis"               # caching, pub/sub, sessions
gem "elasticsearch-rails" # search
gem "dry-validation"      # input validation
gem "interactor"          # service orchestration
gem "view_component"      # view encapsulation
gem "graphql"             # API layer

# app/services/create_card.rb — service object pattern
class CreateCard
  include Interactor

  def call
    card = Card.new(context.params)
    card.creator = context.user

    if card.save
      context.card = card
      CardNotifier.call(card)
    else
      context.fail!(errors: card.errors)
    end
  end
end

# app/graphql/types/card_type.rb — GraphQL type
class Types::CardType < Types::BaseObject
  field :id, ID, null: false
  field :title, String, null: false
end

# app/policies/card_policy.rb — Pundit policy
class CardPolicy < ApplicationPolicy
  def update?
    user.admin? || record.creator == user
  end
end
```

**Correct (vanilla Rails alternatives):**

```ruby
# Gemfile — the 37signals stack
gem "solid_queue"            # database-backed jobs (replaces Sidekiq + Redis)
gem "solid_cache"            # database-backed cache (replaces Redis)
gem "solid_cable"            # database-backed pub/sub (replaces Redis)
gem "mission_control-jobs"   # job monitoring dashboard

# Authentication: ~150 lines of custom passwordless auth (replaces Devise)
# Authorization: permission methods on models (replaces Pundit)
# Search: database full-text search or custom sharding (replaces Elasticsearch)
# API: REST with respond_to blocks (replaces GraphQL)
# Views: partials + helpers (replaces ViewComponent)

# app/models/card.rb — rich model replaces service objects
class Card < ApplicationRecord
  belongs_to :creator, class_name: "User", default: -> { Current.user }

  after_create_commit :notify_watchers

  def editable_by?(user)
    user.admin? || creator == user
  end

  private

  def notify_watchers
    CardMailer.created(self).deliver_later
  end
end

# app/controllers/cards_controller.rb — direct model calls
class CardsController < ApplicationController
  def create
    @card = Current.account.cards.create!(card_params)
    redirect_to @card
  end

  def update
    @card = Current.account.cards.find(params[:id])

    if @card.editable_by?(Current.user)
      @card.update!(card_params)
      redirect_to @card
    else
      redirect_to @card, alert: "Not authorized"
    end
  end
end
```

**The full avoidance list:**

| Pattern/Gem | 37signals Alternative |
|-------------|----------------------|
| Service objects / Interactors | Rich model methods |
| Form objects | `ActiveModel::Model` when truly needed (rare) |
| Decorators / Presenters | View helpers and model methods |
| GraphQL | REST with `respond_to` blocks |
| ViewComponent | Partials + helpers |
| Devise | Custom passwordless link auth (~150 lines) |
| Pundit / CanCanCan | Permission methods on models |
| Dry-rb gems | Plain Ruby validation |
| Trailblazer | Vanilla Rails |
| Sidekiq | Solid Queue |
| Redis | Solid Queue + Solid Cache + Solid Cable |
| Elasticsearch | Database full-text search |
| Sass / Tailwind / PostCSS | Vanilla CSS with native features |

Reference: [Vanilla Rails is Plenty](https://dev.37signals.com/vanilla-rails-is-plenty/)
