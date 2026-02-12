---
title: Wait for Turbo Updates in System Tests
impact: MEDIUM
impactDescription: eliminates flaky tests caused by async DOM updates
tags: test, system-tests, capybara, async
---

## Wait for Turbo Updates in System Tests

Turbo Drive, Frames, and Streams all update the DOM asynchronously. Using `sleep` to wait for updates creates slow, brittle tests that still fail intermittently under CI load. Capybara's built-in matchers like `assert_text`, `assert_selector`, and `assert_no_selector` automatically retry with a configurable wait time, making them the correct way to synchronize tests with Turbo's async behavior.

**Incorrect (sleep after form submission to wait for Turbo Stream):**

```ruby
# test/system/comments_test.rb
class CommentsTest < ApplicationSystemTestCase
  test "posting a comment adds it to the list" do
    visit project_path(projects(:web_app))

    fill_in "Comment", with: "Looking great!"
    click_button "Post Comment"

    sleep 2  # Fragile: too short on slow CI, too long for fast machines
    assert page.has_content?("Looking great!")

    sleep 1  # Another sleep hoping the counter updated
    assert page.has_content?("4 comments")
  end

  test "deleting a comment removes it" do
    visit project_path(projects(:web_app))

    accept_confirm { click_button "Delete", match: :first }
    sleep 3  # Hoping the DOM has updated by now
    refute page.has_content?("Old comment")
  end
end
```

**Correct (assert_text auto-waits for Turbo to update the DOM):**

```ruby
# test/system/comments_test.rb
class CommentsTest < ApplicationSystemTestCase
  test "posting a comment adds it to the list" do
    visit project_path(projects(:web_app))

    fill_in "Comment", with: "Looking great!"
    click_button "Post Comment"

    # Capybara retries for up to Capybara.default_max_wait_time seconds
    assert_text "Looking great!"
    assert_text "4 comments"
  end

  test "deleting a comment removes it" do
    visit project_path(projects(:web_app))

    accept_confirm { click_button "Delete", match: :first }

    # assert_no_text retries until the text disappears or times out
    assert_no_text "Old comment"
    assert_text "2 comments"
  end

  test "turbo frame loads lazy content" do
    visit project_path(projects(:web_app))

    # Wait for the lazy-loaded frame to populate
    within "#team_members" do
      assert_selector ".member-card", count: 5
    end
  end
end
```
