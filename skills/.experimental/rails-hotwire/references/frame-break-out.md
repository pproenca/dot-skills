---
title: Handle Frame Breakout for Redirects
impact: HIGH
impactDescription: prevents silent failures on auth redirects
tags: frame, breakout, redirect, authentication
---

## Handle Frame Breakout for Redirects

When a Turbo Frame request receives a response that does not contain a matching `<turbo-frame>` element, Turbo silently renders nothing -- the frame goes blank. This commonly happens when an authenticated frame request gets redirected to a login page, or when a frame action redirects to an unrelated page. Use `target="_top"` on the frame or add a `turbo-visit-control` meta tag on redirect target pages to force a full-page visit.

**Incorrect (login redirect silently failing inside a frame):**

```erb
<%# app/views/projects/show.html.erb %>
<%# When session expires, this frame request redirects to /login
    but the login page has no matching frame — user sees blank space %>
<%= turbo_frame_tag "project_comments",
    src: project_comments_path(@project) do %>
  <p>Loading comments...</p>
<% end %>
```

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  private

  def authenticate_user!
    unless current_user
      # This redirect breaks frame requests — login page
      # won't have a matching turbo-frame tag
      redirect_to login_path
    end
  end
end
```

**Correct (proper breakout handling for auth and cross-page redirects):**

```erb
<%# app/views/sessions/new.html.erb (login page) %>
<%# Force full-page reload when login page is loaded inside a frame %>
<head>
  <meta name="turbo-visit-control" content="reload">
</head>

<h1>Sign in</h1>
<%= form_with url: session_path do |f| %>
  <%= f.email_field :email %>
  <%= f.password_field :password %>
  <%= f.submit "Sign in" %>
<% end %>
```

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  private

  def authenticate_user!
    unless current_user
      # Redirect normally — the meta tag on the login page handles breakout.
      # Turbo fetches the redirect target, sees turbo-visit-control="reload",
      # and triggers a full-page navigation automatically.
      redirect_to login_path
    end
  end
end
```

```erb
<%# Alternative: use target="_top" on the frame itself %>
<%= turbo_frame_tag "project_comments",
    src: project_comments_path(@project),
    target: "_top" do %>
  <p>Loading comments...</p>
<% end %>
```

**Caveat:** `turbo-visit-control="reload"` causes two GET requests — the first is the frame fetch that discovers the meta tag, and the second is the full-page reload Turbo triggers. Flash messages set during the redirect are consumed by the first request and lost before the second. If flash preservation matters, prefer handling the redirect in the controller with `turbo_frame_request?`:

```ruby
# app/controllers/application_controller.rb
def authenticate_user!
  unless current_user
    if turbo_frame_request?
      # Respond with a full-page redirect instead of rendering inside the frame
      render turbo_stream: turbo_stream.action(:redirect, login_path)
    else
      redirect_to login_path
    end
  end
end
```
