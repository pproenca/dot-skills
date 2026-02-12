---
title: Use Presenter Objects When Helpers Call Helpers
impact: HIGH
impactDescription: prevents helper method sprawl and untestable view logic
tags: partial, views, presenters, helpers, refactoring
---

## Use Presenter Objects When Helpers Call Helpers

When helper methods start calling other helper methods, extract a presenter. A presenter is a plain Ruby object that wraps a model and provides display-specific logic. Presenters are testable without rendering views, have clear ownership (one presenter per model concern), and eliminate the flat namespace collisions that plague helper modules.

**Incorrect (helper sprawl):**

```ruby
# app/helpers/users_helper.rb
module UsersHelper
  def user_display_name(user)
    user.preferred_name.presence || "#{user.first_name} #{user.last_name}"
  end

  def user_avatar_url(user)
    user.avatar.attached? ? url_for(user.avatar) : asset_path("default_avatar.png")
  end

  def user_role_badge(user)
    content_tag(:span, user_role_label(user), class: "badge badge-#{user_role_color(user)}")
  end

  def user_role_label(user)
    user.admin? ? "Administrator" : user.role.titleize
  end

  def user_role_color(user)
    user.admin? ? "red" : "gray"
  end
end
```

**Correct (presenter object):**

```ruby
# app/presenters/user_presenter.rb
class UserPresenter
  attr_reader :user

  delegate :email, :created_at, to: :user

  def initialize(user)
    @user = user
  end

  def display_name
    user.preferred_name.presence || "#{user.first_name} #{user.last_name}"
  end

  def avatar_url
    if user.avatar.attached?
      Rails.application.routes.url_helpers.url_for(user.avatar)
    else
      "default_avatar.png"
    end
  end

  def role_badge_class
    user.admin? ? "badge-red" : "badge-gray"
  end

  def role_label
    user.admin? ? "Administrator" : user.role.titleize
  end
end
```

```erb
<%# app/views/users/_user_card.html.erb %>
<%# locals: (user:) %>
<% presenter = UserPresenter.new(user) %>
<div class="user-card">
  <img src="<%= presenter.avatar_url %>" alt="<%= presenter.display_name %>">
  <h3><%= presenter.display_name %></h3>
  <span class="badge <%= presenter.role_badge_class %>"><%= presenter.role_label %></span>
</div>
```

### Testing Presenters

```ruby
# test/presenters/user_presenter_test.rb
class UserPresenterTest < ActiveSupport::TestCase
  test "display_name prefers preferred_name" do
    user = build(:user, preferred_name: "Pete", first_name: "Peter", last_name: "Smith")
    presenter = UserPresenter.new(user)

    assert_equal "Pete", presenter.display_name
  end

  test "display_name falls back to full name" do
    user = build(:user, preferred_name: nil, first_name: "Peter", last_name: "Smith")
    presenter = UserPresenter.new(user)

    assert_equal "Peter Smith", presenter.display_name
  end
end
```

Reference: [DHH on View Patterns at Basecamp](https://discuss.rubyonrails.org/t/do-basecamp-hey-use-viewcomponents/83270/9)
