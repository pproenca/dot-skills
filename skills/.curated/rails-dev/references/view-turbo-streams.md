---
title: Use Turbo Streams for Real-Time Page Mutations
impact: MEDIUM-HIGH
impactDescription: eliminates custom JavaScript for append/prepend/replace
tags: view, turbo-streams, hotwire, real-time, websockets
---

## Use Turbo Streams for Real-Time Page Mutations

Custom JavaScript for DOM manipulation creates fragile, hard-to-maintain code. Turbo Streams declaratively append, prepend, replace, or remove elements.

**Incorrect (custom JavaScript for dynamic updates):**

```erb
<!-- Custom JS to append new comment -->
<script>
  fetch("/comments", { method: "POST", body: formData })
    .then(response => response.json())
    .then(comment => {
      const html = `<div class="comment">${comment.body}</div>`;
      document.getElementById("comments").insertAdjacentHTML("beforeend", html);
    });
</script>
```

**Correct (Turbo Stream response):**

```ruby
# app/controllers/comments_controller.rb
class CommentsController < ApplicationController
  def create
    @comment = @post.comments.build(comment_params)
    @comment.save

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @post }
    end
  end
end
```

```erb
<!-- app/views/comments/create.turbo_stream.erb -->
<%= turbo_stream.append "comments" do %>
  <%= render partial: "comments/comment", locals: { comment: @comment } %>
<% end %>
```

Reference: [Turbo Streams — Hotwire](https://turbo.hotwired.dev/handbook/streams)
