---
title: Use fresh_when and ETags for HTTP Caching
impact: HIGH
impactDescription: 50-80% reduction in server rendering — 304 Not Modified responses skip view rendering entirely
tags: view, caching, etags, fresh-when, performance
---

## Use fresh_when and ETags for HTTP Caching

Use `fresh_when` to declare cache dependencies so the server returns `304 Not Modified` when content hasn't changed. This skips view rendering entirely — the browser uses its cached copy. Fizzy uses global ETags bumped on deploy, concern-level ETags for timezone and identity, and per-action ETags for resource freshness. This is one of the highest-impact performance patterns with minimal code.

**Incorrect (always rendering full responses):**

```ruby
class CardsController < ApplicationController
  def show
    @card = Card.find(params[:id])
    @comments = @card.comments.includes(:creator)
    # Always renders the full view, even if nothing changed
    # Browser re-downloads the same HTML every time
  end

  def index
    @cards = Current.board.cards.includes(:creator)
    # Full render on every request — expensive for large boards
  end
end
```

**Correct (HTTP caching with fresh_when and ETags):**

```ruby
# app/controllers/application_controller.rb — global ETag busted on deploy
class ApplicationController < ActionController::Base
  etag { "v1" }  # bump to invalidate all browser caches on deploy
end

# app/controllers/concerns/current_timezone.rb — timezone in ETag
module CurrentTimezone
  extend ActiveSupport::Concern

  included do
    around_action :set_timezone
    etag { Current.user&.timezone }  # different timezone = different cached response
  end

  private

  def set_timezone
    Time.use_zone(Current.user&.timezone || "UTC") { yield }
  end
end

# app/controllers/concerns/authentication.rb — identity in ETag
module Authentication
  extend ActiveSupport::Concern

  included do
    etag { Current.identity&.id }  # prevents personalized content sharing
  end
end

# app/controllers/cards_controller.rb
class CardsController < ApplicationController
  include CurrentTimezone

  def show
    @card = Card.find(params[:id])
    fresh_when @card  # 304 if card hasn't been updated since last request
  end

  def index
    @cards = Current.board.cards
    fresh_when etag: [@cards, Current.user]  # composite ETag
  end
end

# app/controllers/boards_controller.rb — complex ETag dependencies
class BoardsController < ApplicationController
  def show
    @board = Current.account.boards.find(params[:id])
    @cards = @board.cards.preloaded
    @user_filtering = User::Filtering.new(Current.user, @board)

    fresh_when etag: [@board, @cards, @user_filtering]
  end
end
```

**How it works:**
- `fresh_when @card` generates an ETag from `card.cache_key_with_version` (includes `updated_at`)
- Browser sends `If-None-Match` header with previous ETag on subsequent requests
- If ETag matches, Rails returns `304 Not Modified` — no view rendering, no JSON serialization
- Global `etag { "v1" }` means bumping to `"v2"` invalidates every browser cache on deploy
- Concern-level ETags layer additional cache keys (timezone, identity, theme)

**When NOT to use:**
- Highly dynamic pages where every request returns different content (real-time dashboards, live feeds). Use Turbo Streams for those instead.
- Pages with CSRF tokens that change per-request — these already defeat ETag matching for forms.

Reference: [Basecamp Fizzy](https://github.com/basecamp/fizzy)
