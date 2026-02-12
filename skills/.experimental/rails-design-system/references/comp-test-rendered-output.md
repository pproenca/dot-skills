---
title: Test Component Output, Not Internal Methods
impact: MEDIUM
impactDescription: reduces false test failures by 80% during component refactors
tags: comp, views, components, viewcomponent, testing, capybara
---

## Test Component Output, Not Internal Methods

Use `render_inline` and assert against the rendered HTML output with Capybara matchers. Do not test private helper methods directly with `send` or by making them public for testing. Testing the output means your tests verify what the user actually sees and survive internal refactoring. If you rename a private method or change how a CSS class is computed, the test still passes as long as the output is correct.

**Incorrect (testing internal methods):**

```ruby
# test/components/user_badge_component_test.rb
class UserBadgeComponentTest < ViewComponent::TestCase
  test "returns correct badge class for admin" do
    user = build(:user, role: "admin")
    component = UserBadgeComponent.new(user: user)

    # Testing a private method — breaks if you rename or refactor it
    assert_equal "badge-admin", component.send(:badge_class)
  end

  test "returns correct label for admin" do
    user = build(:user, role: "admin")
    component = UserBadgeComponent.new(user: user)

    assert_equal "Administrator", component.send(:role_label)
  end
end
```

**Correct (testing rendered output):**

```ruby
# test/components/user_badge_component_test.rb
class UserBadgeComponentTest < ViewComponent::TestCase
  test "renders admin badge with correct styling and label" do
    user = build(:user, role: "admin")

    render_inline(UserBadgeComponent.new(user: user))

    assert_selector ".badge-admin", text: "Administrator"
  end

  test "renders member badge for regular users" do
    user = build(:user, role: "member")

    render_inline(UserBadgeComponent.new(user: user))

    assert_selector ".badge-member", text: "Member"
  end

  test "does not render when user has no role" do
    user = build(:user, role: nil)

    render_inline(UserBadgeComponent.new(user: user))

    assert_no_selector ".badge"
  end
end
```

### Testing Slots

```ruby
# test/components/card_component_test.rb
class CardComponentTest < ViewComponent::TestCase
  test "renders card with title and body content" do
    render_inline(CardComponent.new(title: "Settings")) do
      "Your account settings"
    end

    assert_selector ".card-header h3", text: "Settings"
    assert_selector ".card-body", text: "Your account settings"
  end

  test "renders footer slot when provided" do
    render_inline(CardComponent.new(title: "Settings")) do |card|
      card.with_footer { "Last updated: today" }
      "Body content"
    end

    assert_selector ".card-footer", text: "Last updated: today"
  end

  test "does not render footer when slot is empty" do
    render_inline(CardComponent.new(title: "Settings")) do
      "Body content"
    end

    assert_no_selector ".card-footer"
  end
end
```

### Testing Conditional Rendering

```ruby
# test/components/sidebar_component_test.rb
class SidebarComponentTest < ViewComponent::TestCase
  test "does not render when user is nil" do
    render_inline(SidebarComponent.new(user: nil, notifications: []))

    # render? returns false — component produces empty string
    assert_equal "", rendered_content.strip
  end

  test "shows notification count badge" do
    user = build(:user)
    notifications = build_list(:notification, 5, :unread)

    render_inline(SidebarComponent.new(user: user, notifications: notifications))

    assert_selector "[data-testid='notification-badge']", text: "5"
  end
end
```

### Key Assertions

| Assertion | Use when |
|---|---|
| `assert_selector ".class", text: "..."` | Verify element exists with content |
| `assert_no_selector ".class"` | Verify element does not render |
| `assert_text "..."` | Verify text appears anywhere in output |
| `assert_link "...", href: "..."` | Verify a link with specific href |
| `assert_selector "[data-action='...']"` | Verify Stimulus bindings |

Reference: [ViewComponent Testing Guide](https://viewcomponent.org/guide/testing.html)
