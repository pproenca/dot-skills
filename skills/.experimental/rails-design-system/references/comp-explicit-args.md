---
title: Pass All Data Through Constructor Arguments
impact: HIGH
impactDescription: eliminates hidden dependencies and makes components portable
tags: comp, views, components, viewcomponent, arguments, testing
---

## Pass All Data Through Constructor Arguments

Components must receive all data via `initialize` arguments. Never access controller instance variables, `params`, `Current.user`, or any global state directly from inside a component. This makes components fully portable between controllers, testable in isolation, and self-documenting through their constructor signature.

**Incorrect (hidden dependencies on global state):**

```ruby
# app/components/sidebar_component.rb
class SidebarComponent < ViewComponent::Base
  def initialize
    @user = Current.user
    @notifications = Current.user.notifications.unread
    @show_admin = params[:admin].present?
  end

  def render?
    @user.present?
  end
end
```

This component cannot be tested without setting up `Current.user` and `params`. It also breaks if rendered in a context where `Current` is not configured (mailers, background jobs generating HTML).

**Correct (explicit constructor arguments):**

```ruby
# app/components/sidebar_component.rb
class SidebarComponent < ViewComponent::Base
  def initialize(user:, notifications:, show_admin: false)
    @user = user
    @notifications = notifications
    @show_admin = show_admin
  end

  def render?
    @user.present?
  end

  def unread_count
    @notifications.size
  end

  def admin_section?
    @show_admin && @user.admin?
  end
end
```

```erb
<%# app/views/layouts/application.html.erb %>
<%= render(SidebarComponent.new(
  user: current_user,
  notifications: current_user.notifications.unread,
  show_admin: current_user.admin?
)) %>
```

### Testing With Explicit Arguments

Explicit arguments make component tests straightforward and fast:

```ruby
# test/components/sidebar_component_test.rb
class SidebarComponentTest < ViewComponent::TestCase
  test "does not render without user" do
    result = render_inline(SidebarComponent.new(user: nil, notifications: []))

    assert_no_selector ".sidebar"
  end

  test "shows unread notification count" do
    user = build(:user)
    notifications = build_list(:notification, 3)

    render_inline(SidebarComponent.new(user: user, notifications: notifications))

    assert_selector ".unread-badge", text: "3"
  end

  test "hides admin section for non-admin users" do
    user = build(:user, admin: false)

    render_inline(SidebarComponent.new(user: user, notifications: [], show_admin: true))

    assert_no_selector ".admin-section"
  end
end
```

No `Current` stubbing, no `params` mocking, no controller context needed.

Reference: [ViewComponent Guide](https://viewcomponent.org/guide/getting-started.html)
