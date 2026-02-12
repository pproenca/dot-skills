---
title: Use Turbo Stream Test Helpers in Integration Tests
impact: MEDIUM
impactDescription: 10× faster than system tests for stream response validation
tags: test, turbo-streams, integration, assertions
---

## Use Turbo Stream Test Helpers in Integration Tests

Integration tests run without a browser, making them faster than system tests for verifying that controllers return correct Turbo Stream responses. The `turbo-rails` gem provides `assert_turbo_stream` and related helpers that validate stream actions, targets, and content structurally rather than through fragile string matching. These assertions confirm that the right DOM operations will occur without the overhead of browser rendering.

**Incorrect (parsing raw response body with regex to check for turbo-stream tags):**

```ruby
# test/integration/comments_test.rb
class CommentsIntegrationTest < ActionDispatch::IntegrationTest
  test "creating a comment returns turbo stream" do
    post project_comments_path(projects(:web_app)),
      params: { comment: { body: "Great progress!" } },
      headers: { "Accept" => "text/vnd.turbo-stream.html" }

    assert_response :success

    # Fragile: breaks if attribute order changes or whitespace differs
    assert_match /<turbo-stream action="append" target="comments">/, response.body
    assert_match /<turbo-stream action="update" target="comments_count">/, response.body
    assert_match /Great progress!/, response.body
  end
end
```

**Correct (assert_turbo_stream action: :append, target: "comments"):**

```ruby
# test/integration/comments_test.rb
class CommentsIntegrationTest < ActionDispatch::IntegrationTest
  test "creating a comment returns turbo stream with append and update" do
    post project_comments_path(projects(:web_app)),
      params: { comment: { body: "Great progress!" } },
      as: :turbo_stream

    assert_response :success
    assert_turbo_stream action: :append, target: "comments"
    assert_turbo_stream action: :update, target: "comments_count"
  end

  test "destroying a comment returns turbo stream with remove" do
    comment = comments(:first)

    delete project_comment_path(comment.project, comment),
      as: :turbo_stream

    assert_response :success
    assert_turbo_stream action: :remove, target: dom_id(comment)
  end

  test "invalid comment returns turbo stream with form errors" do
    post project_comments_path(projects(:web_app)),
      params: { comment: { body: "" } },
      as: :turbo_stream

    assert_response :unprocessable_entity
    assert_turbo_stream action: :replace, target: "comment_form"
  end
end
```
