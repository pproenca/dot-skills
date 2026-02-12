---
title: Test Frame Navigation with Scoped Assertions
impact: MEDIUM
impactDescription: prevents 40% of Hotwire support tickets caused by silent frame mismatches
tags: test, turbo-frames, capybara, scoped-assertions
---

## Test Frame Navigation with Scoped Assertions

When a Turbo Frame navigates, the response must contain a matching `<turbo-frame>` element with the same `id` or the content silently fails to render. System tests that assert page-level content without verifying which frame contains it will miss these matching failures entirely. Scoping assertions to the specific frame element ensures that content loads within the correct region and that frame IDs remain consistent between request and response.

**Incorrect (asserting page content without verifying it's inside the correct frame):**

```ruby
# test/system/messages_test.rb
class MessagesTest < ApplicationSystemTestCase
  test "editing a message inline" do
    visit project_path(projects(:web_app))

    click_link "Edit", match: :first

    fill_in "Body", with: "Updated message content"
    click_button "Save"

    # This passes even if the content rendered OUTSIDE the frame
    # or replaced the entire page instead of the inline region
    assert_text "Updated message content"
  end
end
```

**Correct (within find("turbo-frame#message_1") { assert_text "Updated" }):**

```ruby
# test/system/messages_test.rb
class MessagesTest < ApplicationSystemTestCase
  test "editing a message stays within its frame" do
    message = messages(:greeting)
    visit project_path(message.project)

    within find("turbo-frame##{dom_id(message)}") do
      click_link "Edit"

      # Verify the form loaded inside the frame
      assert_selector "form"
      fill_in "Body", with: "Updated message content"
      click_button "Save"

      # Verify the updated content rendered inside the same frame
      assert_text "Updated message content"
      assert_no_selector "form"  # Form should be gone after save
    end

    # Verify the rest of the page was NOT replaced
    assert_selector "turbo-frame##{dom_id(messages(:second))}"
    assert_text messages(:second).body
  end

  test "frame navigation failure shows error" do
    visit project_path(projects(:web_app))

    within find("turbo-frame#team_members") do
      # Verify lazy-loaded content appears within the correct frame
      assert_selector ".member-card", minimum: 1
      assert_text users(:alice).name
    end
  end
end
```
