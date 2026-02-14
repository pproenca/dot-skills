---
title: Model Non-CRUD Operations as Separate Resources
impact: CRITICAL
impactDescription: maintains REST purity, simplifies routing and controller logic
tags: ctrl, resources, rest, routing
---

## Model Non-CRUD Operations as Separate Resources

When an operation does not map to a standard CRUD verb, introduce a new resource rather than adding custom actions. Archiving a card becomes `Cards::ArchivalsController#create`. Reopening it becomes `Cards::ArchivalsController#destroy`. This keeps every controller CRUD-only and makes the domain model visible through the routing layer.

**Incorrect (custom routes for non-CRUD operations):**

```ruby
# routes.rb — custom actions break RESTful conventions
resources :cards do
  member do
    post :close
    post :reopen
    post :pin
    delete :unpin
  end
end

# cards_controller.rb — accumulates unrelated responsibilities
class CardsController < ApplicationController
  def close
    @card = Card.find(params[:id])
    @card.update!(closed_at: Time.current, closed_by: Current.user)
    redirect_to board_path(@card.board), notice: "Card closed"
  end

  def reopen
    @card = Card.find(params[:id])
    @card.update!(closed_at: nil, closed_by: nil)
    redirect_to @card, notice: "Card reopened"
  end

  def pin
    @card = Card.find(params[:id])
    Current.user.pins.create!(pinnable: @card)
    redirect_to @card
  end

  def unpin
    @card = Card.find(params[:id])
    Current.user.pins.find_by!(pinnable: @card).destroy!
    redirect_to @card
  end
end
```

**Correct (separate resource controllers for each operation):**

```ruby
# routes.rb — every action maps to standard CRUD
resources :cards do
  resource :closure, module: :cards, only: [:create, :destroy]
  resource :pin,     module: :cards, only: [:create, :destroy]
end

# app/controllers/cards/closures_controller.rb
class Cards::ClosuresController < ApplicationController
  before_action :set_card

  def create
    @card.close!(by: Current.user)
    redirect_to board_path(@card.board), notice: "Card closed"
  end

  def destroy
    @card.reopen!
    redirect_to @card, notice: "Card reopened"
  end

  private

  def set_card
    @card = Card.find(params[:card_id])
  end
end

# app/controllers/cards/pins_controller.rb
class Cards::PinsController < ApplicationController
  before_action :set_card

  def create
    Current.user.pins.create!(pinnable: @card)
    redirect_to @card
  end

  def destroy
    Current.user.pins.find_by!(pinnable: @card).destroy!
    redirect_to @card
  end

  private

  def set_card
    @card = Card.find(params[:card_id])
  end
end
```

**Benefits:**
- `rake routes` becomes the complete API documentation
- Each controller stays under 100 lines
- New operations require new controllers, not modifications to existing ones
- Testing is isolated: closure tests don't touch pin logic

Reference: [Basecamp STYLE.md](https://github.com/basecamp/fizzy/blob/main/STYLE.md)
