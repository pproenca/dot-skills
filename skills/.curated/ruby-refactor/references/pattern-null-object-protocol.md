---
title: Implement Null Object with Full Protocol
impact: MEDIUM
impactDescription: eliminates conditional nil checking across entire call chain
tags: pattern, null-object, protocol, duck-typing
---

## Implement Null Object with Full Protocol

Repeated `if current_user` guards litter controllers, views, and helpers with defensive checks that obscure business logic. A single forgotten guard produces a NoMethodError in production. A GuestUser class that responds to the full User protocol with safe defaults eliminates every conditional at every call site, leveraging Ruby's duck typing to treat logged-out state as a first-class concept.

**Incorrect (nil checks scattered across the entire call chain):**

```ruby
class ApplicationController < ActionController::Base
  def dashboard
    if current_user
      @name = current_user.name
      @permissions = current_user.permissions
    else
      @name = "Guest"
      @permissions = []
    end

    @display_name = if current_user
      current_user.to_s  # repeated nil checks in every action
    else
      "Anonymous Visitor"
    end

    @can_edit = current_user&.permissions&.include?("edit") || false
    @avatar_url = current_user&.avatar_url || "/images/default_avatar.png"
  end
end
```

**Correct (GuestUser responds to full User protocol with safe defaults):**

```ruby
class GuestUser
  def name
    "Guest"
  end

  def to_s
    "Anonymous Visitor"
  end

  def permissions
    [].freeze  # safe default — no access granted
  end

  def avatar_url
    "/images/default_avatar.png"
  end

  def authenticated?
    false
  end

  def admin?
    false
  end
end

class ApplicationController < ActionController::Base
  def current_user
    super || GuestUser.new  # single fallback replaces all downstream nil checks
  end

  def dashboard
    @name = current_user.name
    @permissions = current_user.permissions
    @display_name = current_user.to_s
    @can_edit = current_user.permissions.include?("edit")
    @avatar_url = current_user.avatar_url  # no conditionals, same interface everywhere
  end
end
```
