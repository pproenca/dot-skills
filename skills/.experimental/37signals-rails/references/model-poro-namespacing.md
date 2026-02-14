---
title: Namespace POROs Under Parent Models
impact: HIGH
impactDescription: eliminates service objects while keeping models focused — 0 service layer classes needed
tags: model, poro, namespacing, organization
---

## Namespace POROs Under Parent Models

When domain logic doesn't fit into the ActiveRecord model itself, create Plain Old Ruby Objects (POROs) namespaced under the parent model. Place them in `app/models/` using nested directories. These are NOT service objects — they are model-adjacent: `Event::Description` for presentation, `Card::Eventable::SystemCommenter` for business logic, `User::Filtering` for view context bundling. The namespace makes ownership clear.

**Incorrect (service objects in a separate layer):**

```ruby
# app/services/card_search_filter.rb — service layer breaks the domain model
class CardSearchFilter
  def initialize(user, board, params)
    @user = user
    @board = board
    @params = params
  end

  def call
    cards = @board.cards
    cards = cards.where(assignee: @user) if @params[:mine]
    cards = cards.where(status: @params[:status]) if @params[:status]
    cards = cards.tagged_with(@params[:tag]) if @params[:tag]
    cards
  end
end

# app/services/event_formatter.rb — presentation logic in services
class EventFormatter
  def initialize(event)
    @event = event
  end

  def description
    case @event.action
    when "card_closed" then "#{@event.creator.name} closed this card"
    when "card_assigned" then "#{@event.creator.name} assigned this card"
    end
  end
end

# Controller must know to use the right service
@filter = CardSearchFilter.new(Current.user, @board, params)
@cards = @filter.call
```

**Correct (POROs namespaced under parent models):**

```ruby
# app/models/user/filtering.rb — view context bundled under User
class User::Filtering
  attr_reader :user, :board, :params

  def initialize(user, board, params = {})
    @user = user
    @board = board
    @params = params
  end

  def cards
    scope = board.cards
    scope = scope.where(assignee: user) if params[:mine]
    scope = scope.where(status: params[:status]) if params[:status]
    scope
  end
end

# app/models/event/description.rb — presentation logic under Event
class Event::Description
  def initialize(event) = @event = event

  def to_s
    case @event.action
    when "card_closed" then "#{@event.creator.name} closed this card"
    when "card_assigned" then "#{@event.creator.name} assigned this card"
    when "comment_created" then "#{@event.creator.name} commented"
    end
  end
end

# Controller usage — the namespace shows ownership
@filtering = User::Filtering.new(Current.user, @board, params)
@cards = @filtering.cards
```

**Guidelines:**
- Namespace under the model that "owns" the behavior: `User::Filtering`, not `FilterService`
- Place files in matching directory structure: `app/models/user/filtering.rb`
- These are NOT service objects — they don't replace model methods for core domain logic
- Use for: presentation formatting, complex query building, view context bundling, multi-step transformations

Reference: [Basecamp Fizzy](https://github.com/basecamp/fizzy)
