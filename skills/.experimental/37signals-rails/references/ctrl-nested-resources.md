---
title: Nested Resources with scope module
impact: MEDIUM
impactDescription: eliminates deep nesting while maintaining clean URL hierarchies
tags: ctrl, routing, nested-resources, scope-module
---

## Nested Resources with scope module

Use `scope module:` to organize sub-resource controllers into namespaced directories without deeply nesting routes. Each sub-resource gets its own controller in a `cards/` directory (e.g., `Cards::ClosuresController`), keeping routes flat while the filesystem reflects the hierarchy. Combine with controller concerns like `CardScoped` to DRY up parent resource loading.

**Incorrect (deeply nested routes or flat routes with long names):**

```ruby
# config/routes.rb — deeply nested creates verbose URL helpers
resources :boards do
  resources :cards do
    resources :comments
    resources :closures
    resources :assignments
  end
end

# Generates: board_card_closure_path(@board, @card)
# 3 levels deep — verbose and hard to read

# Alternative mistake: flat routes lose hierarchy
resources :card_closures
resources :card_assignments
resources :card_comments
# No relationship between card and its sub-resources visible in routes
```

**Correct (scope module for organized sub-resources):**

```ruby
# config/routes.rb — flat routes, organized controllers
resources :cards do
  resource :closure,    module: :cards, only: [:create, :destroy]
  resource :assignment, module: :cards, only: [:create, :update, :destroy]
  resources :comments,  module: :cards
end

# Generates clean paths:
# POST   /cards/:card_id/closure    => Cards::ClosuresController#create
# DELETE /cards/:card_id/closure    => Cards::ClosuresController#destroy
# POST   /cards/:card_id/comments  => Cards::CommentsController#create

# app/controllers/concerns/card_scoped.rb — shared parent loading
module CardScoped
  extend ActiveSupport::Concern

  included do
    before_action :set_card
  end

  private

  def set_card
    @card = Current.account.cards.find(params[:card_id])
  end
end

# app/controllers/cards/closures_controller.rb
class Cards::ClosuresController < ApplicationController
  include CardScoped

  def create
    @card.close!(by: Current.user)
    redirect_to board_path(@card.board)
  end

  def destroy
    @card.reopen!
    redirect_to card_path(@card)
  end
end

# app/controllers/cards/comments_controller.rb
class Cards::CommentsController < ApplicationController
  include CardScoped

  def create
    @comment = @card.comments.create!(comment_params.merge(creator: Current.user))
    redirect_to card_path(@card)
  end

  private

  def comment_params
    params.expect(comment: [:body])
  end
end
```

**Benefits:**
- Controllers live in `app/controllers/cards/` — filesystem mirrors route hierarchy
- URL helpers are short: `card_closure_path(@card)`, not `board_card_closure_path(@board, @card)`
- `CardScoped` concern loads the parent once — no duplication across sub-resource controllers
- Adding a new sub-resource: create controller in `cards/`, add one route line

Reference: [Basecamp STYLE.md](https://github.com/basecamp/fizzy/blob/main/STYLE.md)
