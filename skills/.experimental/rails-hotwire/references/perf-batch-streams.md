---
title: Batch Multiple Stream Updates into Single Responses
impact: MEDIUM-HIGH
impactDescription: 50 separate DOM operations (1500ms) reduced to 1 batched operation (45ms)
tags: perf, turbo-streams, dom, response
---

## Batch Multiple Stream Updates into Single Responses

When a single user action requires multiple DOM updates, sending separate HTTP requests or individual broadcasts for each change creates excessive network overhead and sequential DOM mutations. Combining all stream actions into a single response lets the browser batch-process DOM updates in one paint cycle, dramatically reducing total execution time and visual jank.

**Incorrect (separate HTTP requests or broadcasts for each DOM change):**

```ruby
# app/models/comment.rb
class Comment < ApplicationRecord
  after_create_commit :broadcast_updates

  private

  def broadcast_updates
    broadcast_append_to "comments", target: "comments"
    # Separate broadcast for count
    broadcast_replace_to "comments", target: "comments_count",
      partial: "comments/count", locals: { count: Comment.count }
    # Another separate broadcast for the sidebar
    broadcast_replace_to "comments", target: "recent_activity",
      partial: "shared/recent_activity"
  end
end
```

**Correct (single turbo_stream.erb with multiple actions):**

```ruby
# app/controllers/comments_controller.rb
class CommentsController < ApplicationController
  def create
    @comment = @project.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @project }
      end
    end
  end
end
```

```erb
<%# app/views/comments/create.turbo_stream.erb %>
<%= turbo_stream.append "comments" do %>
  <%= render @comment %>
<% end %>

<%= turbo_stream.update "comments_count" do %>
  <%= @project.comments.count %> comments
<% end %>

<%= turbo_stream.replace "recent_activity" do %>
  <%= render "shared/recent_activity", project: @project %>
<% end %>

<%= turbo_stream.remove "no_comments_placeholder" %>
```
