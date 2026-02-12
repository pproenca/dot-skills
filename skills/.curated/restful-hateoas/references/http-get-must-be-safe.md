---
title: Keep GET Requests Free of Side Effects
impact: CRITICAL
impactDescription: enables caching, prefetching, and crawling without data corruption
tags: http, get, safe, idempotent, caching
---

## Keep GET Requests Free of Side Effects

GET is defined as a safe method (RFC 7231 Section 4.2.1) -- it must have no side effects. When GET mutates state, every cache, crawler, prefetch link, and browser back-button becomes a vector for silent data corruption. Proxies and CDNs freely replay GET requests, so a state-changing GET will fire multiple times without the client ever knowing.

**Incorrect (GET route silently mutates data):**

```ruby
# config/routes.rb
get "notifications/mark_all_read", to: "notifications#mark_all_read"

# app/controllers/notifications_controller.rb
class NotificationsController < ApplicationController
  def mark_all_read
    current_user.notifications.unread.update_all(read_at: Time.current)  # mutation on GET — prefetch corrupts data
    redirect_to notifications_path
  end
end
```

**Correct (GET reads, POST mutates):**

```ruby
# config/routes.rb
resources :notifications, only: [:index] do
  collection do
    post :mark_all_read  # POST for state change
  end
end

# app/controllers/notifications_controller.rb
class NotificationsController < ApplicationController
  def index
    @notifications = current_user.notifications.order(created_at: :desc)
    render json: NotificationSerializer.new(@notifications)
  end

  def mark_all_read
    current_user.notifications.unread.update_all(read_at: Time.current)
    head :no_content
  end
end
```

**Benefits:**
- Caches and CDNs can safely store and replay GET responses
- Browser prefetching and `<link rel="prefetch">` work without side effects
- Search engine crawlers cannot accidentally mutate your data
- Back/forward navigation never triggers unintended state changes

**Reference:** RFC 7231 Section 4.2.1 (Safe Methods)
