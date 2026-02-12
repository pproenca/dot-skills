---
title: Configure Turbo Cache for Preview Pages
impact: HIGH
impactDescription: prevents stale data display and flash of old content
tags: drive, cache, preview, temporary
---

## Configure Turbo Cache for Preview Pages

Turbo caches pages to show instant previews when navigating back. Elements like flash messages, modal overlays, and loading spinners persist in the cache and reappear as stale artifacts. Mark transient elements with `data-turbo-temporary` to strip them before caching, and use `Turbo-Cache-Control` headers to disable caching entirely on pages with sensitive or rapidly-changing data.

**Incorrect (flash messages and modals persist in cache previews):**

```erb
<%# app/views/layouts/application.html.erb %>
<div class="flash-messages">
  <% flash.each do |type, message| %>
    <div class="flash flash-<%= type %>">
      <%= message %>
    </div>
  <% end %>
</div>

<%# Loading spinner shows in cached preview %>
<div id="loading-overlay" class="hidden">
  <div class="spinner">Loading...</div>
</div>
```

**Correct (transient elements removed before caching):**

```erb
<%# app/views/layouts/application.html.erb %>
<%# data-turbo-temporary removes this element before the page is cached %>
<div class="flash-messages" data-turbo-temporary>
  <% flash.each do |type, message| %>
    <div class="flash flash-<%= type %>">
      <%= message %>
    </div>
  <% end %>
</div>

<%# Loading overlays should also be temporary %>
<div id="loading-overlay" class="hidden" data-turbo-temporary>
  <div class="spinner">Loading...</div>
</div>
```

```ruby
# app/controllers/dashboards_controller.rb
class DashboardsController < ApplicationController
  def show
    # Prevent caching entirely for real-time data pages
    response.set_header("Turbo-Cache-Control", "no-cache")
    @metrics = Dashboard::Metrics.current
  end
end

# app/controllers/checkout_controller.rb
class CheckoutController < ApplicationController
  def show
    # Prevent preview (still caches for restoration visits)
    response.set_header("Turbo-Cache-Control", "no-preview")
    @order = current_order
  end
end
```
