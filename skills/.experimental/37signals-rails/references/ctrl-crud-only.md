---
title: Use CRUD Controllers Over Custom Actions
impact: CRITICAL
impactDescription: enforces REST conventions, eliminates non-standard routing complexity
tags: ctrl, crud, rest, controllers
---

## Use CRUD Controllers Over Custom Actions

Controllers should only implement the 7 standard CRUD actions: `index`, `show`, `new`, `create`, `edit`, `update`, `destroy`. Custom member or collection actions create non-standard routes that are harder to discover, test, and maintain. When you need behavior beyond CRUD, model it as a separate resource instead.

**Incorrect (custom actions polluting the controller):**

```ruby
class CardsController < ApplicationController
  before_action :set_card, only: [:show, :edit, :update, :destroy, :archive, :unarchive, :duplicate, :move, :assign]

  def show
    # ...
  end

  # Non-standard actions — these don't map to CRUD verbs
  def archive
    @card.update!(archived: true)
    redirect_to board_path(@card.board)
  end

  def unarchive
    @card.update!(archived: false)
    redirect_to archives_path
  end

  def duplicate
    @new_card = @card.dup
    @new_card.save!
    redirect_to @new_card
  end

  def move
    @card.update!(list_id: params[:list_id])
    redirect_to board_path(@card.board)
  end

  private

  def set_card
    @card = Card.find(params[:id])
  end
end

# routes.rb — non-RESTful routes accumulate
resources :cards do
  member do
    post :archive
    post :unarchive
    post :duplicate
    patch :move
  end
end
```

**Correct (strict CRUD-only controller):**

```ruby
class CardsController < ApplicationController
  before_action :set_card, only: [:show, :edit, :update, :destroy]

  def index
    @cards = Current.board.cards
  end

  def show
  end

  def new
    @card = Card.new
  end

  def create
    @card = Current.board.cards.create!(card_params)
    redirect_to @card
  end

  def edit
  end

  def update
    @card.update!(card_params)
    redirect_to @card
  end

  def destroy
    @card.destroy!
    redirect_to cards_path
  end

  private

  def set_card
    @card = Card.find(params[:id])
  end

  def card_params
    params.expect(card: [:title, :description, :list_id])
  end
end

# routes.rb — clean, predictable
resources :cards
```

**When NOT to use:** If you are building a non-resource API endpoint (health checks, webhooks from external services), a dedicated controller with a single action is acceptable.

Reference: [Basecamp STYLE.md](https://github.com/basecamp/fizzy/blob/main/STYLE.md)
